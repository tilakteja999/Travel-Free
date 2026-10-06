import 'dart:async';
import 'package:flutter/material.dart';
import '../features/ride_hailing/repositories/local_ride_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/persistent_profile_widget.dart';

class RideChatScreen extends StatefulWidget {
  final String rideId;
  final String driverName;

  const RideChatScreen({
    super.key,
    required this.rideId,
    required this.driverName,
  });

  @override
  State<RideChatScreen> createState() => _RideChatScreenState();
}

class _RideChatScreenState extends State<RideChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];
  final LocalRideRepository _repo = LocalRideRepository();

  final List<String> _quickReplies = [
    'I am waiting at the pickup point',
    'Please come to the main gate',
    'How long will you take?',
    'I will be there in 2 minutes',
  ];

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  void _loadChat() async {
    final list = await _repo.getChatMessages(widget.rideId);
    setState(() {
      _messages.clear();
      _messages.addAll(list);
    });
  }

  void _sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    _textController.clear();
    final userMsg = 'You: $clean';
    setState(() {
      _messages.add(userMsg);
    });
    await _repo.addChatMessage(widget.rideId, userMsg);

    // Simulate automated driver response after 1.5 seconds
    Timer(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      final driverReply = 'Driver: Got it! I will reach there shortly.';
      setState(() {
        _messages.add(driverReply);
      });
      await _repo.addChatMessage(widget.rideId, driverReply);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat with ${widget.driverName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Automated demo ride chat', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: PersistentProfileWidget()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.startsWith('You:');
                final displayText = msg.replaceFirst(RegExp(r'^(You:|Driver:)\s*'), '');

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUser ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Reply Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickReplies.length,
              itemBuilder: (context, index) {
                final reply = _quickReplies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    label: Text(reply, style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    onPressed: () => _sendMessage(reply),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type a message to driver...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF0F2F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
