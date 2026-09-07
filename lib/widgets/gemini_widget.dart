import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';
import '../service/gemini_service.dart';
import '../service/voice_service.dart';

class DurvasaAiAssistantSheet extends StatefulWidget {
  final RetailerModel? retailer;

  const DurvasaAiAssistantSheet({
    super.key,
    this.retailer,
  });

  /// Convenient helper to show the AI Assistant from any screen
  static Future<void> show(BuildContext context, {RetailerModel? retailer}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DurvasaAiAssistantSheet(retailer: retailer),
    );
  }

  @override
  State<DurvasaAiAssistantSheet> createState() => _DurvasaAiAssistantSheetState();
}

class _DurvasaAiAssistantSheetState extends State<DurvasaAiAssistantSheet>
    with SingleTickerProviderStateMixin {
  static const int maxUserChats = 10;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final GeminiService _geminiService;
  late final VoiceService _voiceService;

  final List<GeminiMessage> _messages = [];
  bool _isTyping = false;
  VoiceState _voiceState = VoiceState.idle;
  String _partialSpeechText = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int get _userMessageCount => _messages.where((m) => m.isUser).length;
  bool get _isLimitReached => _userMessageCount >= maxUserChats;

  final List<String> _quickSuggestions = [
    '🌿 Ayurvedic Wellness Tips',
    '📦 How to track my wholesale order?',
    '💊 How to take Ayurvedic medicines safely?',
    '📜 Return & replacement policy',
    '🩺 Tell me about my symptoms',
    '📞 How to contact my territory ASM?',
  ];

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(retailer: widget.retailer);
    _voiceService = VoiceService();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initVoiceService();

    // Initial warm welcome message
    final String greetingName = widget.retailer != null && widget.retailer!.name.isNotEmpty
        ? widget.retailer!.name
        : 'Valued Partner';

    _messages.add(
      GeminiMessage(
        isUser: false,
        text: 'Namaste, $greetingName! 🙏\n\n'
            'I am the **Durvasa Ayurved AI Voice Assistant**.\n'
            'You can type your message or tap the 🎤 **Microphone** button to speak with me.\n\n'
            '*(Session limit: 10 queries per session)*\n\n'
            'How may I assist you today?',
      ),
    );
  }

  void _initVoiceService() {
    _voiceService.onStateChanged = (state) {
      if (!mounted) return;
      setState(() {
        _voiceState = state;
        if (state != VoiceState.listening) {
          _partialSpeechText = '';
        }
      });
    };

    _voiceService.onPartialResult = (partial) {
      if (!mounted) return;
      setState(() {
        _partialSpeechText = partial;
      });
    };

    _voiceService.onFinalResult = (finalText) {
      if (!mounted) return;
      if (finalText.trim().isNotEmpty) {
        _handleSendMessage(predefinedText: finalText, isVoiceInput: true);
      }
    };

    _voiceService.onError = (errorMessage) {
      if (!mounted) return;
      _showVoiceSnackBar(errorMessage, isError: true);
    };

    // Pre-initialize voice engines in background
    _voiceService.initialize();
  }

  @override
  void dispose() {
    _voiceService.stopSpeaking();
    _voiceService.stopListening();
    _voiceService.onStateChanged = null;
    _voiceService.onPartialResult = null;
    _voiceService.onFinalResult = null;
    _voiceService.onError = null;

    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage({String? predefinedText, bool isVoiceInput = false}) async {
    final text = (predefinedText ?? _textController.text).trim();
    if (text.isEmpty || _isTyping) return;

    // Stop any active TTS before sending new question
    await _voiceService.stopSpeaking();

    // 10 Chat Validation Limit Check
    if (_isLimitReached) {
      _showVoiceSnackBar('Maximum limit of 10 chats reached. Please reset conversation.', isError: false);
      return;
    }

    _textController.clear();

    setState(() {
      _messages.add(GeminiMessage(text: text, isUser: true));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final reply = await _geminiService.sendMessage(text);

      if (!mounted) return;

      setState(() {
        _messages.add(GeminiMessage(text: reply, isUser: false));
        _isTyping = false;

        // If user reached the 10th chat, notify them in the chat
        if (_userMessageCount >= maxUserChats) {
          _messages.add(
            GeminiMessage(
              isUser: false,
              text: '⚠️ **Chat Limit Reached (10/10 Queries)**\n\n'
                  'You have used all 10 available chats for this session.\n'
                  'To continue chatting, please tap the **Refresh (🔄)** button at the top to start a fresh conversation.',
            ),
          );
        }
      });

      _scrollToBottom();

      // Automatically speak the response if question was asked by voice
      if (isVoiceInput && reply.trim().isNotEmpty) {
        await _voiceService.speak(reply);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          GeminiMessage(
            text: 'I apologize, I encountered a problem connecting to the server. Please try again.',
            isUser: false,
            isError: true,
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _toggleVoice() async {
    if (_isLimitReached) {
      _showVoiceSnackBar('10 chat session limit reached. Reset to speak.', isError: false);
      return;
    }

    if (_voiceState == VoiceState.listening) {
      await _voiceService.stopListening();
    } else if (_voiceState == VoiceState.speaking) {
      await _voiceService.stopSpeaking();
    } else if (_voiceState == VoiceState.idle) {
      await _voiceService.startListening();
    }
  }

  void _showVoiceSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded,
              color: AppColors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primaryGold,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearChat() {
    _voiceService.stopSpeaking();
    _voiceService.cancelListening();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Conversation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 16),
        ),
        content: Text(
          'This will clear your messages and give you 10 new chats.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _geminiService.resetChat();
              setState(() {
                _messages.clear();
                _messages.add(
                  GeminiMessage(
                    isUser: false,
                    text: 'Conversation reset. You have 10 chats available. How can I assist you with Durvasa Ayurved?',
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: Text('Reset', style: GoogleFonts.poppins(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final totalHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      height: totalHeight,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header Bar
          _buildHeader(),

          // Active Voice Listening / Speaking Banner
          if (_voiceState == VoiceState.listening || _voiceState == VoiceState.speaking)
            _buildVoiceStatusBanner(),

          // Messages & Quick Prompts
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Quick Suggestion Chips
                if (_messages.length <= 1) ...[
                  _buildQuickSuggestions(),
                  const SizedBox(height: 12),
                ],

                // Chat Messages
                ..._messages.map((msg) => _buildChatBubble(msg)),

                // Typing indicator
                if (_isTyping) _buildTypingIndicator(),

                const SizedBox(height: 8),
              ],
            ),
          ),

          // Safety Disclaimer & Input Bar
          _buildBottomArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // Avatar with AI badge
              Stack(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      border: Border.all(color: AppColors.primaryGold, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Lottie.asset(
                      'assets/Ai chat.json',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryGreen,
                        size: 22,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: _voiceState == VoiceState.listening
                            ? Colors.redAccent
                            : (_voiceState == VoiceState.speaking
                                ? AppColors.primaryGold
                                : AppColors.leafGreen),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Title & status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Durvasa Ayurved AI',
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: _isLimitReached
                                ? AppColors.error.withOpacity(0.9)
                                : (_userMessageCount >= 8
                                    ? Colors.orange.withOpacity(0.9)
                                    : AppColors.primaryGold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$_userMessageCount/$maxUserChats CHATS',
                            style: GoogleFonts.poppins(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: (_isLimitReached || _userMessageCount >= 8) ? AppColors.white : AppColors.primaryGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _voiceState == VoiceState.listening
                          ? '🎙️ Listening to you...'
                          : (_voiceState == VoiceState.speaking
                              ? '🔊 Speaking response...'
                              : (_isLimitReached
                                  ? 'Limit reached • Tap 🔄 to restart'
                                  : 'Voice & Text AI Assistant')),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: (_voiceState == VoiceState.listening || _voiceState == VoiceState.speaking)
                            ? AppColors.lightGold
                            : (_isLimitReached ? AppColors.error : AppColors.cream.withOpacity(0.9)),
                        fontWeight: (_voiceState != VoiceState.idle || _isLimitReached)
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Clear chat button
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.white, size: 20),
                tooltip: 'Reset Chat (Get 10 New Chats)',
                onPressed: _clearChat,
              ),

              // Close button
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.white, size: 22),
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceStatusBanner() {
    final isListening = _voiceState == VoiceState.listening;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isListening ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
        border: Border(
          bottom: BorderSide(
            color: isListening ? Colors.orange.shade300 : AppColors.secondaryGreen.withOpacity(0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isListening ? Icons.mic_rounded : Icons.volume_up_rounded,
            color: isListening ? Colors.deepOrange : AppColors.primaryGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isListening
                  ? (_partialSpeechText.isNotEmpty ? '“$_partialSpeechText”' : 'Listening... speak now')
                  : 'Gemini is speaking response...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isListening ? Colors.deepOrange.shade800 : AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              if (isListening) {
                _voiceService.stopListening();
              } else {
                _voiceService.stopSpeaking();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isListening ? Colors.deepOrange : AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isListening ? 'Done' : 'Stop',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Frequently Asked Queries:',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickSuggestions.map((prompt) {
            return InkWell(
              onTap: () => _handleSendMessage(predefinedText: prompt),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGold.withOpacity(0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  prompt,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChatBubble(GeminiMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGold, width: 1),
              ),
              child: const Icon(Icons.eco_rounded, color: AppColors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryGreen : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.primaryGreen
                      : (message.isError ? AppColors.error.withOpacity(0.5) : AppColors.lightGold.withOpacity(0.4)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _buildFormattedMessageText(message.text, isUser, message.isError),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          color: isUser ? AppColors.cream.withOpacity(0.8) : AppColors.textSecondary.withOpacity(0.6),
                        ),
                      ),
                      if (!isUser && !message.isError) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (_voiceState == VoiceState.speaking) {
                              _voiceService.stopSpeaking();
                            } else {
                              _voiceService.speak(message.text);
                            }
                          },
                          child: Icon(
                            _voiceState == VoiceState.speaking
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            size: 14,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: message.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied to clipboard', style: GoogleFonts.poppins(fontSize: 12)),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: AppColors.leafGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
              child: const Icon(Icons.person, color: AppColors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormattedMessageText(String text, bool isUser, bool isError) {
    if (isUser) {
      return SelectableText(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          height: 1.45,
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // Split text into lines for rich rendering
    final lines = text.split('\n');
    final List<Widget> lineWidgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        lineWidgets.add(const SizedBox(height: 6));
        continue;
      }

      // Check bullet point
      final isBullet = line.trim().startsWith('•') || line.trim().startsWith('* ') || line.trim().startsWith('- ');
      final cleanLine = isBullet ? line.trim().substring(2).trim() : line;

      // Parse bold **text** in the line
      final spans = _parseInlineMarkdown(cleanLine, isError);

      if (isBullet) {
        lineWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
                Expanded(
                  child: RichText(
                    text: TextSpan(children: spans),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        lineWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: RichText(
              text: TextSpan(children: spans),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lineWidgets,
    );
  }

  List<TextSpan> _parseInlineMarkdown(String text, bool isError) {
    final List<TextSpan> spans = [];
    final pattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.45,
              color: isError ? AppColors.error : AppColors.textDark,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.45,
            color: isError ? AppColors.error : AppColors.darkGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.45,
            color: isError ? AppColors.error : AppColors.textDark,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return spans;
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGold, width: 1),
            ),
            child: const Icon(Icons.eco_rounded, color: AppColors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGold.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Durvasa AI is formulating reply...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomArea() {
    final isListening = _voiceState == VoiceState.listening;
    final isSpeaking = _voiceState == VoiceState.speaking;
    final isProcessing = _voiceState == VoiceState.processing || _isTyping;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Session Limit Reached Alert Banner
            if (_isLimitReached) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.creamBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '10 chat session limit reached.',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearChat,
                      icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.primaryGreen),
                      label: Text(
                        'Reset (10 Chats)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        backgroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.lightGold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_messages.length > 1 && !_isTyping) ...[
              // Horizontal Quick Prompts Bar
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickSuggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final suggestion = _quickSuggestions[index];
                    return InkWell(
                      onTap: () => _handleSendMessage(predefinedText: suggestion),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.creamBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
                        ),
                        child: Center(
                          child: Text(
                            suggestion,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
            ],

            // Safety Disclaimer Tag
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 12, color: AppColors.secondaryGreen),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'AI guidance only. Consult a doctor for medical emergencies.',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Input Bar with Integrated Microphone & Send Buttons
            Row(
              children: [
                // Text input container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isLimitReached ? Colors.grey.shade100 : AppColors.creamBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isListening
                            ? Colors.deepOrange
                            : (_isLimitReached ? Colors.grey.shade300 : AppColors.lightGold.withOpacity(0.6)),
                        width: isListening ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          isListening
                              ? Icons.graphic_eq_rounded
                              : (isSpeaking ? Icons.volume_up_rounded : Icons.auto_awesome),
                          color: isListening
                              ? Colors.deepOrange
                              : (_isLimitReached ? Colors.grey : AppColors.primaryGold),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            enabled: !_isLimitReached && !isListening,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 4,
                            minLines: 1,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _isLimitReached ? Colors.grey : AppColors.textDark,
                            ),
                            decoration: InputDecoration(
                              hintText: isListening
                                  ? (_partialSpeechText.isNotEmpty ? _partialSpeechText : 'Listening... speak now')
                                  : (_isLimitReached
                                      ? '10 chat limit reached. Tap Reset above.'
                                      : 'Type or tap mic to speak...'),
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                fontStyle: isListening ? FontStyle.italic : FontStyle.normal,
                                color: isListening
                                    ? Colors.deepOrange.shade700
                                    : AppColors.textSecondary.withOpacity(0.7),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (_) => _handleSendMessage(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 🎤 Voice / Microphone Button
                GestureDetector(
                  onTap: isProcessing ? null : _toggleVoice,
                  child: ScaleTransition(
                    scale: isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isListening
                            ? Colors.deepOrange
                            : (isSpeaking
                                ? AppColors.primaryGold
                                : (isProcessing ? Colors.grey.shade300 : AppColors.white)),
                        border: Border.all(
                          color: isListening
                              ? Colors.white
                              : (isSpeaking ? AppColors.white : AppColors.primaryGold),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isListening
                                ? Colors.deepOrange.withOpacity(0.4)
                                : (isSpeaking
                                    ? AppColors.primaryGold.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.06)),
                            blurRadius: isListening ? 10 : 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isListening
                            ? Icons.mic_rounded
                            : (isSpeaking ? Icons.stop_rounded : Icons.mic_none_rounded),
                        color: isListening || isSpeaking
                            ? AppColors.white
                            : (isProcessing ? Colors.grey.shade500 : AppColors.primaryGreen),
                        size: 22,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 📤 Text Send Button
                InkWell(
                  onTap: (isProcessing || _isLimitReached || isListening)
                      ? null
                      : () => _handleSendMessage(),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isProcessing || _isLimitReached || isListening)
                          ? Colors.grey.shade400
                          : AppColors.primaryGreen,
                      boxShadow: [
                        if (!_isLimitReached && !isProcessing && !isListening)
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
