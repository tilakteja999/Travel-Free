import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatSupportScreen extends StatefulWidget {
  const ChatSupportScreen({super.key});

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  final TextEditingController _msgController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'agent',
      'text': 'Hello! Welcome to Travel Time Customer Support ✈️ How can I assist you with your travel plans or bookings today?',
      'time': '10:00 AM',
    },
  ];

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': '10:02 AM',
      });
      _msgController.clear();
    });

    // Simulated Auto Reply
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'agent',
          'text': 'Thanks for reaching out! A support executive is checking details regarding "$text". Average response time: 15 mins.',
          'time': '10:03 AM',
        });
      });
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Row(
          children: const [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.support_agent, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Support Agent', style: TextStyle(fontSize: 16)),
                Text('🟢 Online', style: TextStyle(fontSize: 11, color: Colors.lightGreenAccent)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                        bottomLeft: !isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(
                            color: isUser ? Colors.white : AppColors.textDark,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            msg['time'],
                            style: TextStyle(
                              color: isUser ? Colors.white70 : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.vanRed),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
