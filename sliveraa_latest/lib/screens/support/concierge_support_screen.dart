import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/api_service.dart';
import '../../theme/app_colors.dart';

class ConciergeSupportScreen extends StatefulWidget {
  const ConciergeSupportScreen({super.key});

  @override
  State<ConciergeSupportScreen> createState() => _ConciergeSupportScreenState();
}

class _ConciergeSupportScreenState extends State<ConciergeSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text': 'Hi, I\'m your Silvra AI Concierge. How can I help you today with your Gold or Silver investments?',
      'time': DateFormat('hh:mm a').format(DateTime.now().subtract(const Duration(minutes: 5))),
    },
    {
      'isMe': true,
      'text': 'I wanted to know more about physical delivery.',
      'time': DateFormat('hh:mm a').format(DateTime.now().subtract(const Duration(minutes: 3))),
    },
    {
      'isMe': false,
      'text': 'Certainly! You can request physical delivery of any gold or silver in your vault. We deliver certified coins and bars starting from 0.5g.',
      'time': DateFormat('hh:mm a').format(DateTime.now().subtract(const Duration(minutes: 1))),
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
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

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = {
      'isMe': true,
      'text': text,
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    };

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await ApiService().sendChat(text);
      if (response.statusCode == 200) {
        final reply = response.data['reply'] ?? "I'm sorry, I couldn't process that.";
        final time = response.data['timestamp'] ?? DateFormat('hh:mm a').format(DateTime.now());
        
        if (mounted) {
          setState(() {
            _messages.add({
              'isMe': false,
              'text': reply,
              'time': time,
            });
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'isMe': false,
            'text': "I'm having trouble connecting to Silvra's support. Please check your network.",
            'time': DateFormat('hh:mm a').format(DateTime.now()),
          });
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Date Badge
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'TODAY',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          
          // Chat List (includes Suggested Actions at the bottom)
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildSuggestedActions();
                }
                final msg = _messages[index];
                return _buildChatBubble(msg['text'], msg['isMe'], msg['time']);
              },
            ),
          ),
          
          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.darkText, size: 20),
        ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCAA779), width: 1.5),
              color: const Color(0xFFF5EDE3),
            ),
            child: Center(
              child: Text(
                'AI',
                style: GoogleFonts.inter(
                  color: const Color(0xFF8B6B4D),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Concierge Support',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Online',
                style: GoogleFonts.inter(
                  color: const Color(0xFF22C55E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: Colors.black, size: 24),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildChatBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? null : Colors.white,
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFFCAA779), Color(0xFFA67C41)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                color: isMe ? Colors.white : const Color(0xFF475569),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: GoogleFonts.inter(
                  color: isMe ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedActions() {
    // Hide suggested actions if the user has already sent a message
    if (_messages.length > 3) return const SizedBox.shrink();

    final actions = [
      'What is the current gold price?',
      'How do I withdraw my savings?',
      'Tell me about the rewards wheel.',
      'How safe is my gold vault?',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'SUGGESTED ACTIONS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Column(
            children: actions.map((action) => _buildActionCard(action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _sendMessage(text),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: const Color(0xFF2563EB),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                onSubmitted: (value) => _sendMessage(value),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCAA779), Color(0xFFA67C41)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC1A27B).withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
