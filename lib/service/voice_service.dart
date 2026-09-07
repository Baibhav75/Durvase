import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Represents the distinct states of voice interaction
enum VoiceState {
  idle,
  listening,
  processing,
  speaking,
  error,
}

/// Unified Voice Service managing Speech-To-Text (STT) and Text-To-Speech (TTS)
/// Implemented as a reusable singleton to prevent memory leaks and redundant instantiations.
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  // STT & TTS Core Engines
  stt.SpeechToText? _speechToText;
  FlutterTts? _flutterTts;

  bool _isSttInitialized = false;
  bool _isTtsInitialized = false;

  VoiceState _state = VoiceState.idle;
  VoiceState get state => _state;

  // Last recognized words buffer
  String _lastRecognizedWords = '';
  bool _hasDispatchedFinalResult = false;
  Timer? _silenceTimer;

  // Callbacks
  Function(VoiceState state)? onStateChanged;
  Function(String partialText)? onPartialResult;
  Function(String finalText)? onFinalResult;
  Function(String errorMessage)? onError;

  // ============================================================
  // INITIALIZATION & LIFECYCLE
  // ============================================================

  /// Initialize STT and TTS engines once
  Future<bool> initialize() async {
    bool sttOk = await _initSTT();
    bool ttsOk = await _initTTS();
    return sttOk && ttsOk;
  }

  Future<bool> _initSTT() async {
    if (_isSttInitialized && _speechToText != null) return true;

    try {
      _speechToText ??= stt.SpeechToText();
      _isSttInitialized = await _speechToText!.initialize(
        onError: _handleSttError,
        onStatus: _handleSttStatus,
        debugLogging: kDebugMode,
      );
      debugPrint('🎙️ [VoiceService] STT initialized: $_isSttInitialized');
      return _isSttInitialized;
    } catch (e) {
      debugPrint('❌ [VoiceService] STT Init Error: $e');
      _isSttInitialized = false;
      return false;
    }
  }

  Future<bool> _initTTS() async {
    if (_isTtsInitialized && _flutterTts != null) return true;

    try {
      _flutterTts ??= FlutterTts();

      // Configure audio settings
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setSpeechRate(0.5); // Natural conversational speed
      await _flutterTts!.setPitch(1.0);

      // Attempt Indian English / Hindi locale support with fallback
      try {
        final languages = await _flutterTts!.getLanguages;
        if (languages is List && languages.contains('en-IN')) {
          await _flutterTts!.setLanguage('en-IN');
        } else if (languages is List && languages.contains('hi-IN')) {
          await _flutterTts!.setLanguage('hi-IN');
        } else {
          await _flutterTts!.setLanguage('en-US');
        }
      } catch (_) {
        await _flutterTts!.setLanguage('en-US');
      }

      // Handlers for TTS lifecycle
      _flutterTts!.setStartHandler(() {
        debugPrint('🔊 [VoiceService] TTS Started speaking');
        _updateState(VoiceState.speaking);
      });

      _flutterTts!.setCompletionHandler(() {
        debugPrint('✅ [VoiceService] TTS Finished speaking');
        _updateState(VoiceState.idle);
      });

      _flutterTts!.setCancelHandler(() {
        debugPrint('⏹️ [VoiceService] TTS Cancelled');
        _updateState(VoiceState.idle);
      });

      _flutterTts!.setErrorHandler((dynamic msg) {
        debugPrint('❌ [VoiceService] TTS Error: $msg');
        _updateState(VoiceState.idle);
      });

      _isTtsInitialized = true;
      return true;
    } catch (e) {
      debugPrint('❌ [VoiceService] TTS Init Error: $e');
      _isTtsInitialized = false;
      return false;
    }
  }

  // ============================================================
  // SPEECH-TO-TEXT METHODS
  // ============================================================

  /// Start listening to user voice input
  Future<void> startListening({String? localeId}) async {
    // 1. Check & stop any ongoing TTS speech first
    await stopSpeaking();

    // 2. Request mic permission
    final permissionStatus = await Permission.microphone.request();
    if (permissionStatus != PermissionStatus.granted) {
      _emitError('Microphone permission is required for voice chat.');
      return;
    }

    // 3. Ensure STT is initialized
    if (!_isSttInitialized) {
      final initialized = await _initSTT();
      if (!initialized) {
        _emitError('Speech recognition is not available on this device.');
        return;
      }
    }

    // 4. Reset recognition state
    _lastRecognizedWords = '';
    _hasDispatchedFinalResult = false;
    _silenceTimer?.cancel();
    _updateState(VoiceState.listening);

    try {
      await _speechToText!.listen(
        onResult: _handleSpeechResult,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
        localeId: localeId,
      );
      debugPrint('🎙️ [VoiceService] Listening started...');
    } catch (e) {
      debugPrint('❌ [VoiceService] Error starting listen: $e');
      _emitError('Failed to start microphone. Please try again.');
    }
  }

  /// Stop listening and trigger final evaluation
  Future<void> stopListening() async {
    _silenceTimer?.cancel();
    if (_speechToText != null && _speechToText!.isListening) {
      await _speechToText!.stop();
    }
    _finalizeRecognizedText();
  }

  /// Cancel listening without processing result
  Future<void> cancelListening() async {
    _silenceTimer?.cancel();
    _hasDispatchedFinalResult = true;
    if (_speechToText != null && _speechToText!.isListening) {
      await _speechToText!.cancel();
    }
    _updateState(VoiceState.idle);
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    if (words.isNotEmpty) {
      _lastRecognizedWords = words;
      onPartialResult?.call(words);
    }

    // Reset silence debounce timer
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(milliseconds: 1800), () {
      if (_speechToText != null && _speechToText!.isListening) {
        stopListening();
      }
    });

    if (result.finalResult) {
      _finalizeRecognizedText();
    }
  }

  void _finalizeRecognizedText() {
    if (_hasDispatchedFinalResult) return;

    final text = _lastRecognizedWords.trim();
    _hasDispatchedFinalResult = true;
    _silenceTimer?.cancel();

    if (text.isNotEmpty) {
      debugPrint('🎙️ [VoiceService] Final recognized text: "$text"');
      _updateState(VoiceState.processing);
      onFinalResult?.call(text);
    } else {
      _updateState(VoiceState.idle);
    }
  }

  void _handleSttStatus(String status) {
    debugPrint('ℹ️ [VoiceService] STT Status: $status');
    if (status == 'done' || status == 'notListening') {
      if (_state == VoiceState.listening) {
        _finalizeRecognizedText();
      }
    }
  }

  void _handleSttError(SpeechRecognitionError error) {
    debugPrint('⚠️ [VoiceService] STT Error: ${error.errorMsg}');
    _silenceTimer?.cancel();

    if (error.errorMsg == 'error_no_match' || error.errorMsg == 'error_speech_timeout') {
      // Benign timeout or no speech heard
      _updateState(VoiceState.idle);
    } else {
      _emitError('Speech recognition error: ${error.errorMsg}');
    }
  }

  // ============================================================
  // TEXT-TO-SPEECH (TTS) METHODS
  // ============================================================

  /// Clean markdown and speak Gemini response text
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    if (!_isTtsInitialized) {
      await _initTTS();
    }

    // 1. Stop any current speech
    await stopSpeaking();

    // 2. Clean markdown symbols (*, **, #, bullet points, raw links) for smooth speech
    final cleanText = _cleanMarkdownForSpeech(text);
    if (cleanText.isEmpty) {
      _updateState(VoiceState.idle);
      return;
    }

    // Detect language preference (Hindi/English)
    _adjustLanguageForText(cleanText);

    try {
      _updateState(VoiceState.speaking);
      await _flutterTts!.speak(cleanText);
    } catch (e) {
      debugPrint('❌ [VoiceService] Speak error: $e');
      _updateState(VoiceState.idle);
    }
  }

  /// Stop any active TTS audio
  Future<void> stopSpeaking() async {
    if (_flutterTts != null) {
      try {
        await _flutterTts!.stop();
      } catch (_) {}
    }
    if (_state == VoiceState.speaking) {
      _updateState(VoiceState.idle);
    }
  }

  /// Auto-detect language script and set TTS language
  void _adjustLanguageForText(String text) {
    // Check if contains Devanagari script for Hindi
    final hasHindi = RegExp(r'[\u0900-\u097F]').hasMatch(text);
    if (hasHindi) {
      _flutterTts?.setLanguage('hi-IN');
    } else {
      _flutterTts?.setLanguage('en-IN');
    }
  }

  /// Strip markdown and formatting for crystal clear TTS audio
  String _cleanMarkdownForSpeech(String text) {
    var cleaned = text;

    // Remove code blocks
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    // Remove inline code `code`
    cleaned = cleaned.replaceAll(RegExp(r'`([^`]+)`'), r'$1');
    // Remove bold/italic **text** or *text*
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    // Remove markdown links [title](url) -> title
    cleaned = cleaned.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');
    // Remove bullet characters
    cleaned = cleaned.replaceAll(RegExp(r'^[•\-\*\+]\s+', multiLine: true), '');
    // Remove headers #, ##, ###
    cleaned = cleaned.replaceAll(RegExp(r'^#+\s+', multiLine: true), '');
    // Remove excess newlines/spaces
    cleaned = cleaned.replaceAll(RegExp(r'\n+'), '. ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _updateState(VoiceState newState) {
    _state = newState;
    onStateChanged?.call(newState);
  }

  void _emitError(String message) {
    _updateState(VoiceState.error);
    onError?.call(message);
    // Auto return to idle after brief error display
    Future.delayed(const Duration(seconds: 3), () {
      if (_state == VoiceState.error) {
        _updateState(VoiceState.idle);
      }
    });
  }

  /// Release resources
  void dispose() {
    _silenceTimer?.cancel();
    _speechToText?.stop();
    _flutterTts?.stop();
    onStateChanged = null;
    onPartialResult = null;
    onFinalResult = null;
    onError = null;
  }
}
