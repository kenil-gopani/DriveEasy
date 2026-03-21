import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AiAssistantSheet extends StatefulWidget {
  const AiAssistantSheet({super.key});

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  final _aiService = AiService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'message': 'Hello! I am your DriveEasy Assistant. How can I help you today?'},
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'message': text});
      _isLoading = true;
      _controller.clear();
    });

    _scrollToBottom();

    final response = await _aiService.getResponse(text);

    if (mounted) {
      setState(() {
        _messages.add({'role': 'ai', 'message': response});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        children: [
          // Drag handle and Title
          const SizedBox(height: 12),
          Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: const Color(0xFF8E2DE2).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                   child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8E2DE2), size: 24),
                ),
                const SizedBox(width: 16),
                const Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text('DriveEasy AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                      Text('Online • Ready to help', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                   ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Messages area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                   SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E2DE2)))),
                   SizedBox(width: 12),
                   Text('AI is thinking...', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
               color: Colors.white,
               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask me about cars...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8E2DE2),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0xFF8E2DE2), blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> msg) {
    final isAi = msg['role'] == 'ai';
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isAi ? Colors.grey[100] : const Color(0xFF8E2DE2),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAi ? 0 : 20),
            bottomRight: Radius.circular(isAi ? 20 : 0),
          ),
        ),
        child: Text(
          msg['message']!,
          style: TextStyle(
            color: isAi ? Colors.black87 : Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
