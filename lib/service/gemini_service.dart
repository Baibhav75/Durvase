import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/Retailer_model/retailer_login_model.dart';

class GeminiMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  GeminiMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class GeminiService {
  // ============================================================
  // MASTER SYSTEM PROMPT
  // ============================================================

  static const String systemInstructionText = '''
You are the AI Assistant for Durvasa Ayurved.

Your role is to help authorized retailers and users with:

1. General health and wellness information.
2. General Ayurvedic information.
3. General information about Durvasa Ayurved products.
4. Product usage information only when verified product information is provided.
5. Order, dispatch, invoice, billing, payment and retailer-support questions
   when verified application data is available.
6. Basic symptom understanding and safe health guidance.

IMPORTANT SAFETY RULES:

- You are an AI assistant, not a doctor.
- Never claim to provide a medical diagnosis.
- Never tell the user that they definitely have a disease based only on symptoms.
- Do not prescribe prescription medicines.
- Do not tell users to stop medicines prescribed by their doctor.
- Do not invent medical information.
- Do not invent product ingredients, dosage, prices, stock, orders, invoices,
  retailer information, ASM information or MR information.
- If verified application information is unavailable, clearly say that it
  is unavailable.
- For serious, worsening, persistent or emergency symptoms, recommend
  professional medical evaluation.
- For pregnancy, children, elderly users, severe allergies, serious chronic
  diseases or multiple medicines, recommend professional medical advice.

SYMPTOM HANDLING & NON-DIAGNOSTIC PROTOCOL:

The user may describe symptoms and ask "What do I have?" or "What is the diagnosis?"

Do NOT provide a definitive diagnosis.

Instead, follow this structured approach:
1. Identify and summarize the symptoms explicitly mentioned by the user.
2. Ask for missing information that materially affects the situation, such as:
   - age group
   - duration (how long it has been happening)
   - severity
   - precise location of symptoms
   - associated symptoms
   - existing diagnosed conditions
   - current medications when relevant
3. Explain a small number of possible causes or general categories as possibilities only.
4. Clearly distinguish possibilities from a confirmed diagnosis.
5. Highlight red-flag warning signs.
6. If red flags are present, recommend prompt professional medical evaluation or emergency care.
7. Give only low-risk general wellness/self-care information and avoid prescribing treatment or medicines.
8. Never invent medical history, test results or diagnoses.

Example Response Structure for Symptoms:
"Based on what you've described, I can't confirm a diagnosis, but these symptoms can sometimes be associated with several possibilities.

What you've reported:
- [Symptom 1]
- [Symptom 2]

To understand the situation better:
- [Follow-up question 1: e.g. age group, duration]
- [Follow-up question 2: e.g. severity, associated symptoms]

Please seek professional medical care promptly if:
- [Red-flag warning sign 1]
- [Red-flag warning sign 2]

If you want, tell me your age group, how long this has been happening, severity, and any other symptoms you might have."

AYURVEDA:

- You may explain general Ayurvedic concepts.
- Do not claim that an Ayurvedic product cures a disease unless verified
  information explicitly supports that claim.
- Do not invent dosage or treatment duration.
- If product-specific information is required, ask for the product name.
- Use verified product information supplied by the application whenever available.

RETAILER SUPPORT:

For retailer questions:

- Prefer verified application data over assumptions.
- Do not invent order status.
- Do not invent invoice information.
- Do not invent payment or ledger information.
- Do not invent stock availability.
- Do not invent ASM, MR or retailer information.

LANGUAGE:

- Understand English, Hindi and Hinglish.
- Reply in the user's language whenever possible.
- Use simple and professional language.
- Keep answers concise but useful.
- Use bullet points when helpful.
- Ask one or two relevant follow-up questions instead of asking many questions.

IMPORTANT:

Never pretend to have access to information that has not been provided
by the application or user.
''';

  GenerativeModel? _model;
  ChatSession? _chatSession;

  final RetailerModel? retailer;

  GeminiService({
    this.retailer,
  }) {
    _initModel();
  }

  // ============================================================
  // INITIALIZE GEMINI
  // ============================================================

  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';

    if (apiKey.isEmpty) {
      debugPrint(
        '❌ GEMINI_API_KEY not found in .env',
      );
      return;
    }

    String contextInstructions = systemInstructionText;

    // ============================================================
    // RETAILER CONTEXT
    // ============================================================

    if (retailer != null) {
      contextInstructions += '''

CURRENT LOGGED-IN RETAILER CONTEXT:

Retailer Name:
${retailer!.name}

Retailer ID:
${retailer!.retailerId}

Phone:
${retailer!.phone}

Email:
${retailer!.email}

Business Address:
${retailer!.businessAddress}

Use this information only when relevant.
Do not expose unnecessary personal information.
''';
    }

    try {
      _model = GenerativeModel(
        // IMPORTANT:
        // Do NOT use gemini-1.5-flash here.
        model: 'gemini-3.6-flash',

        apiKey: apiKey,

        systemInstruction: Content.system(
          contextInstructions,
        ),
      );

      _chatSession = _model!.startChat();

      debugPrint(
        '✅ Gemini initialized successfully',
      );
    } catch (e) {
      debugPrint(
        '❌ Failed to initialize Gemini: $e',
      );

      _model = null;
      _chatSession = null;
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<String> sendMessage(String message) async {
    final cleanMessage = message.trim();

    if (cleanMessage.isEmpty) {
      return 'Please enter a message.';
    }

    // Make sure Gemini is initialized.
    if (_model == null || _chatSession == null) {
      _initModel();
    }

    if (_model == null || _chatSession == null) {
      return '''
Gemini AI Assistant is currently unavailable.

Please check:
• GEMINI_API_KEY in your .env file
• Internet connection
• Gemini API configuration
''';
    }

    try {
      debugPrint(
        '➡️ Sending message to Gemini...',
      );

      final response = await _chatSession!.sendMessage(
        Content.text(cleanMessage),
      );

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        return 'I could not generate a response. Please try again.';
      }

      debugPrint(
        '✅ Gemini response received',
      );

      return text;
    } on InvalidApiKey catch (e) {
      debugPrint(
        '❌ Invalid Gemini API key: $e',
      );

      return '''
The Gemini API key is invalid or has been revoked.

Please create a new API key and update GEMINI_API_KEY
in your .env file.
''';
    } on GenerativeAIException catch (e) {
      debugPrint(
        '❌ Gemini API error: $e',
      );

      return '''
Gemini could not process the request.

Please try again in a moment.
''';
    } catch (e) {
      debugPrint(
        '❌ Gemini Chat Error: $e',
      );

      return '''
I am experiencing a temporary connection issue.

Please check your internet connection and try again.
''';
    }
  }

  // ============================================================
  // RESET CHAT
  // ============================================================

  void resetChat() {
    if (_model != null) {
      _chatSession = _model!.startChat();

      debugPrint(
        '🔄 Gemini chat reset',
      );
    }
  }
}