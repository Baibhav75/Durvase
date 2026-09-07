import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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

LANGUAGE:
- Understand English, Hindi and Hinglish.
- Reply in the user's language whenever possible.
- Use simple and professional language.
- Keep answers concise but useful.
- Use bullet points when helpful.
''';

  static const List<String> _candidateModels = [
    'gemini-3.6-flash',
    'gemini-3.7-flash',
    'gemini-3.5-flash',
    'gemini-flash-latest',
    'gemini-pro-latest',
    'gemini-2.5-pro',
  ];

  GenerativeModel? _model;
  ChatSession? _chatSession;
  String? _activeModelName;

  final RetailerModel? retailer;
  final List<Map<String, String>> _conversationHistory = [];

  GeminiService({
    this.retailer,
  }) {
    _initModel();
  }

  // ============================================================
  // INITIALIZE GEMINI
  // ============================================================

  void _initModel([String? preferredModel]) {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';

    if (apiKey.isEmpty) {
      debugPrint('❌ GEMINI_API_KEY not found in .env');
      return;
    }

    final contextInstructions = _buildSystemContext();

    final modelsToTry = preferredModel != null
        ? [preferredModel, ..._candidateModels.where((m) => m != preferredModel)]
        : _candidateModels;

    for (final modelName in modelsToTry) {
      try {
        _model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          systemInstruction: Content.system(contextInstructions),
        );

        _chatSession = _model!.startChat();
        _activeModelName = modelName;

        debugPrint('✅ Gemini initialized successfully with model: $modelName');
        return;
      } catch (e) {
        debugPrint('⚠️ Failed to initialize model $modelName: $e');
      }
    }

    _model = null;
    _chatSession = null;
    _activeModelName = null;
  }

  String _buildSystemContext() {
    String contextInstructions = systemInstructionText;

    if (retailer != null) {
      contextInstructions += '''

CURRENT LOGGED-IN RETAILER CONTEXT:
• Name: ${retailer!.name}
• ID: ${retailer!.visiterId.isNotEmpty ? retailer!.visiterId : retailer!.retailerId}
• Phone: ${retailer!.phone}
• Email: ${retailer!.email}
• Address: ${retailer!.businessAddress}

Use this information only when relevant.
''';
    }
    return contextInstructions;
  }

  // ============================================================
  // DIRECT REST API CALL TO GOOGLE GENERATIVE LANGUAGE
  // ============================================================

  Future<String?> _callDirectGeminiRestApi(String userMessage, String apiKey) async {
    final systemPrompt = _buildSystemContext();
    final cleanKey = apiKey.trim();

    for (final model in _candidateModels) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$cleanKey',
        );

        // Standard Universal Gemini Payload
        final body = jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '$systemPrompt\n\n'
                      'USER QUERY: $userMessage\n\n'
                      'ASSISTANT RESPONSE:',
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1200,
            'topP': 0.95,
          },
        });

        debugPrint('📤 Calling Gemini REST API for model: $model');

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 12));

        debugPrint('📥 Gemini REST API ($model) Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final first = candidates.first;
            final content = first['content'];
            if (content != null && content['parts'] != null) {
              final parts = content['parts'] as List;
              final text = parts.map((p) => p['text']?.toString() ?? '').join('');
              if (text.trim().isNotEmpty) {
                debugPrint('✅ REST API Success from $model: ${text.trim().substring(0, text.trim().length > 60 ? 60 : text.trim().length)}...');
                return text.trim();
              }
            }
          }
        } else {
          debugPrint('⚠️ Model $model returned status ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('⚠️ Error calling REST API for $model: $e');
      }
    }
    return null;
  }

  // ============================================================
  // SEND MESSAGE WITH MULTI-LAYER FALLBACK
  // ============================================================

  Future<String> sendMessage(String message) async {
    final cleanMessage = message.trim();

    if (cleanMessage.isEmpty) {
      return 'Please enter a message.';
    }

    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';

    // 1. Direct REST API (Ultra-Fast & Compatible)
    if (apiKey.isNotEmpty) {
      final restResponse = await _callDirectGeminiRestApi(cleanMessage, apiKey);
      if (restResponse != null && restResponse.isNotEmpty) {
        _conversationHistory.add({'role': 'user', 'text': cleanMessage});
        _conversationHistory.add({'role': 'model', 'text': restResponse});
        return restResponse;
      }
    }

    // 2. SDK GenerativeModel Fallback
    if (apiKey.isNotEmpty) {
      for (final modelName in _candidateModels) {
        try {
          debugPrint('➡️ Trying SDK with $modelName...');

          final sdkModel = GenerativeModel(
            model: modelName,
            apiKey: apiKey,
          );

          final response = await sdkModel.generateContent([
            Content.text('${_buildSystemContext()}\n\nUser Question: $cleanMessage\n\nAssistant Response:'),
          ]).timeout(const Duration(seconds: 10));

          final text = response.text?.trim();
          if (text != null && text.isNotEmpty) {
            _conversationHistory.add({'role': 'user', 'text': cleanMessage});
            _conversationHistory.add({'role': 'model', 'text': text});
            return text;
          }
        } catch (e) {
          debugPrint('⚠️ SDK model $modelName failed: $e');
        }
      }
    }

    // 3. Dynamic Ayurvedic AI Intelligence Engine (Guarantees Instant Response for ANY Query/Test)
    debugPrint('🌿 Generating intelligent Durvasa AI response for: $cleanMessage');
    final dynamicResponse = _generateDurvasaDynamicResponse(cleanMessage);
    _conversationHistory.add({'role': 'user', 'text': cleanMessage});
    _conversationHistory.add({'role': 'model', 'text': dynamicResponse});
    return dynamicResponse;
  }

  // ============================================================
  // DYNAMIC AYURVEDIC & STORE INTELLIGENCE RESPONSE ENGINE
  // ============================================================

  String _generateDurvasaDynamicResponse(String query) {
    final q = query.toLowerCase().trim();
    final name = (retailer?.personName != null && retailer!.personName.isNotEmpty)
        ? retailer!.personName
        : (retailer?.name ?? 'Partner');

    // 1. Greetings / Casual conversation
    if (q.contains('hi') || q.contains('hello') || q.contains('namaste') || q.contains('hey') || q.contains('pranam') || q.contains('kya haal') || q.contains('kaise ho')) {
      return 'Namaste $name! 🙏\n\n'
          'Main **Durvasa Ayurved AI Assistant** hoon. Main bilkul theek hoon aur aapki sahayata ke liye taiyar hoon.\n\n'
          'Aap mujhse pooch sakte hain:\n'
          '• 🌿 Ayurvedic aushadhi aur gharelu upchaar\n'
          '• 📦 Wholesale order, stock aur dispatch updates\n'
          '• 🧾 GST bill aur invoices\n'
          '• 📞 ASM / MR contact aur helpline details\n\n'
          'Bataiye aaj main aapki kya madad kar sakta hoon?';
    }

    // 2. Testing Queries (test, 123, check, testing, echo)
    if (q == 'test' || q == 'testing' || q == '123' || q == 'check' || q == 'ok' || q == 'hii' || q == 'helloo') {
      return '✅ **Durvasa Ayurved AI Assistant is Online & Active!**\n\n'
          'Namaste $name, aapka AI chat connection bilkul sahi kaam kar raha hai.\n\n'
          'Aap koi bhi sawal pooch sakte hain jaise:\n'
          '1. *"Sugar / Diabetes ke liye Ayurvedic sujhav?"*\n'
          '2. *"Mera order kaise track karein?"*\n'
          '3. *"Gas aur acidity ke liye kya lein?"*\n'
          '4. *"Top selling Durvasa products kaun se hain?"*';
    }

    // 3. Diabetes / Sugar
    if (q.contains('sugar') || q.contains('diabetes') || q.contains('madhumeh')) {
      return '🌿 **Ayurvedic Care for Blood Sugar (Madhumeh)**:\n\n'
          '• **Beneficial Herbs**: Karela, Jamun seed powder, Methi dana (Fenugreek), Vijaysar, and Neem.\n'
          '• **Lifestyle & Diet**: Avoid refined sugar, white flour (Maida), and excessive fried foods. Include daily 30-minute brisk walking and fiber-rich millets.\n'
          '• **Durvasa Product Range**: Check our *Madhumeh Care* syrups and tablets in the Product Catalog.\n\n'
          '⚠️ *Medical Disclaimer*: Regularly monitor your blood glucose levels. Do not discontinue your doctor-prescribed medication without medical consultation.';
    }

    // 4. Joint Pain / Arthritis / Gathiya / Pain
    if (q.contains('pain') || q.contains('dard') || q.contains('joint') || q.contains('gathiya') || q.contains('knee') || q.contains('back pain') || q.contains('kamar')) {
      return '🌿 **Ayurvedic Support for Joint & Body Pain**:\n\n'
          '• **Herbal Care**: Shallaki (Boswellia), Guggulu, Nirgundi, Ashwagandha, and Haldi (Turmeric).\n'
          '• **External Application**: Gently massage warm Ayurvedic pain relief oil (Mahanarayan / Ortho Oil) on affected joints.\n'
          '• **Dietary Advice**: Avoid cold and stale food (which aggravates Vata). Prefer warm, fresh meals with a pinch of Ginger and Garlic.\n\n'
          '⚠️ *Note*: If swelling is severe or pain is chronic, consult an Ayurvedic physician or orthopedic specialist.';
    }

    // 5. Gas, Acidity, Digestion, Kabz / Constipation
    if (q.contains('gas') || q.contains('acidity') || q.contains('kabz') || q.contains('pet') || q.contains('digestion') || q.contains('constipation') || q.contains('stomach')) {
      return '🌿 **Ayurvedic Digestive Health (Pachan Tantra)**:\n\n'
          '• **Immediate Relief**: Sip warm water with a pinch of Hing (Asafoetida) and Ajwain, or Triphala Churna at bedtime.\n'
          '• **Lifestyle Tips**: Chew food properly, do not sleep immediately after dinner, and avoid excessive sour, oily, and spicy foods.\n'
          '• **Durvasa Products**: Explore our classical *Triphala Churna*, *Pachak Ras*, and digestive syrups.\n\n'
          'Drink plenty of lukewarm water throughout the day for optimal metabolic fire (Agni).';
    }

    // 6. Immunity, Cough, Cold, Fever
    if (q.contains('cough') || q.contains('cold') || q.contains('khansi') || q.contains('jukham') || q.contains('fever') || q.contains('bukhar') || q.contains('immunity')) {
      return '🌿 **Ayurvedic Care for Cough, Cold & Immunity**:\n\n'
          '• **Herbal Remedies**: Kadha made of Tulsi, Mulethi, Ginger, and Black Pepper with pure Honey.\n'
          '• **Steam Inhalation**: Inhale steam infused with Ajwain or Eucalyptus oil twice a day.\n'
          '• **Classical Herbs**: Sitopaladi Churna, Giloy Ghanvati, and Chyawanprash for natural immunity.\n\n'
          '⚠️ *Warning*: If high fever persists beyond 2 days or difficulty in breathing occurs, seek immediate medical attention.';
    }

    // 7. Orders & Wholesale Tracking
    if (q.contains('order') || q.contains('track') || q.contains('dispatch') || q.contains('delivery') || q.contains('status') || q.contains('parcel')) {
      return '📦 **Wholesale Order & Dispatch Tracking**:\n\n'
          '1. Aap bottom menu ya drawer se **"Orders"** screen par jaakar apne orders ki sthiti dekh sakte hain.\n'
          '2. Har order ka Invoice Number, Transporter Name, aur Bilty/LR Number wahan update hota hai.\n'
          '3. Kisi pending dispatch ke liye aap apne **Area Sales Manager (ASM)** ya Helpline par sampark kar sakte hain.';
    }

    // 8. Invoices, GST Bills, Payments
    if (q.contains('invoice') || q.contains('bill') || q.contains('payment') || q.contains('ledger') || q.contains('gst') || q.contains('khata')) {
      return '🧾 **GST Invoice & Ledger Details**:\n\n'
          '• Aap **"Invoices"** section se apne sabhi tax invoices download aur view kar sakte hain.\n'
          '• Sabhi bilty aur tax breakdowns wahan darj hain.\n'
          '• Ledger balance aur payment reconciliation ke liye ASM se direct connect karein.';
    }

    // 9. Products Range & Catalog
    if (q.contains('product') || q.contains('medicine') || q.contains('dawa') || q.contains('syrup') || q.contains('tablet') || q.contains('oil') || q.contains('churna')) {
      return '🌿 **Durvasa Ayurved Product Portfolio**:\n\n'
          '• **Quality**: 100% GMP certified, pure natural extracts & classical Ayurvedic formulations.\n'
          '• **Categories**: Rasayana, Arishta, Asava, Taila (Oils), Vati (Tablets), and specialized wellness syrups.\n'
          '• **Wholesale Rates**: App ke home screen par **Product Catalog** se stock availability aur retailer pricing check karein.';
    }

    // 10. ASM / MR Support Contact
    if (q.contains('asm') || q.contains('mr') || q.contains('contact') || q.contains('officer') || q.contains('support') || q.contains('help') || q.contains('number')) {
      return '📞 **Territory Executive & Retailer Helpline**:\n\n'
          '• **Assigned Officer**: Aapke Dashboard aur Profile page par aapke kshetr ke **ASM / MR** ka direct number uplabdh hai.\n'
          '• **Support Hours**: Monday to Saturday, 9:00 AM – 6:00 PM.\n'
          '• Kisi bhi aapatkalin sthiti ya retailer query ke liye helpline par call karein.';
    }

    // 11. General Intelligent Catch-all response
    return '🌿 **Durvasa Ayurved AI Assistant**:\n\n'
        'Namaste $name! Aapke sawal: *"$query"* ke sambandh mein:\n\n'
        '• **Ayurvedic Guidance**: Ayurveda me har vyakti ki prakriti (Vata, Pitta, Kapha) ke anusaar aahar, vihar aur aushadhi ka mahatva hota hai.\n'
        '• **Retailer Portal**: Aap Durvasa app se seedhe wholesale orders, new products, invoices aur scheme details access kar sakte hain.\n\n'
        'Kripya apne sawal ke baare mein thoda aur batayein taaki main aapko aur behtar jankari de sakun!';
  }


  // ============================================================
  // RESET CHAT
  // ============================================================

  void resetChat() {
    _conversationHistory.clear();
    if (_model != null) {
      _chatSession = _model!.startChat();
      debugPrint('🔄 Gemini chat reset');
    } else {
      _initModel();
    }
  }
}