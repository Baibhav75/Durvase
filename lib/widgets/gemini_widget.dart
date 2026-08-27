import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';
import '../service/gemini_service.dart';

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

class _DurvasaAiAssistantSheetState extends State<DurvasaAiAssistantSheet> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final GeminiService _geminiService;

  final List<GeminiMessage> _messages = [];
  bool _isTyping = false;

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

    // Initial warm welcome message
    final String greetingName = widget.retailer != null && widget.retailer!.name.isNotEmpty
        ? widget.retailer!.name
        : 'Valued Partner';

    _messages.add(
      GeminiMessage(
        isUser: false,
        text: 'Namaste, $greetingName! 🙏\n\n'
            'I am the **Durvasa Ayurved AI Assistant**.\n'
            'I can help you with Ayurvedic wellness guidance, product details, orders, and retailer support.\n\n'
            'How may I assist you today?',
      ),
    );
  }

  @override
  void dispose() {
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

  Future<void> _handleSendMessage([String? predefinedText]) async {
    final text = (predefinedText ?? _textController.text).trim();
    if (text.isEmpty || _isTyping) return;

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
      });
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
    }

    _scrollToBottom();
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Conversation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to reset this chat session?',
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
                    text: 'Conversation reset. How can I assist you with Durvasa Ayurved?',
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: Text('Clear', style: GoogleFonts.poppins(color: AppColors.white)),
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
                        color: AppColors.leafGreen,
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
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '24/7 ASSISTANT',
                            style: GoogleFonts.poppins(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Ayurvedic Guidance & Retailer Support',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.cream.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Clear chat button
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.white, size: 20),
                tooltip: 'Clear Chat',
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
              onTap: () => _handleSendMessage(prompt),
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
                  SelectableText(
                    message.text,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.45,
                      color: isUser ? AppColors.white : (message.isError ? AppColors.error : AppColors.textDark),
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      color: isUser ? AppColors.cream.withOpacity(0.8) : AppColors.textSecondary.withOpacity(0.6),
                    ),
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
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Safety Disclaimer Tag
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 12, color: AppColors.secondaryGreen),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'AI guidance only. Consult a doctor for medical emergencies.',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Input Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.creamBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.lightGold.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.auto_awesome, color: AppColors.primaryGold, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 4,
                            minLines: 1,
                            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
                            decoration: InputDecoration(
                              hintText: 'Ask in Hindi, English or Hinglish...',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary.withOpacity(0.7),
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
                InkWell(
                  onTap: _isTyping ? null : () => _handleSendMessage(),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isTyping ? Colors.grey.shade400 : AppColors.primaryGreen,
                      boxShadow: [
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
