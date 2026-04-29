import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.friend, this.tripId});

  final Map<String, dynamic>? friend;
  final String? tripId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    _messages = [
      {
        'text': 'Hey! Ready for the trip?',
        'isUser': false,
        'time': '10:30 AM',
        'sender': 'Sarah',
      },
      {
        'text': 'Yes! Can\'t wait!',
        'isUser': true,
        'time': '10:31 AM',
        'sender': 'You',
      },
      {
        'text': 'I booked the hotel already.',
        'isUser': false,
        'time': '10:32 AM',
        'sender': 'Sarah',
      },
      {
        'text': 'Great! I\'ll handle the transport.',
        'isUser': true,
        'time': '10:33 AM',
        'sender': 'You',
      },
    ];
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isUser': true,
        'time': DateFormat('h:mm a').format(DateTime.now()),
        'sender': 'You',
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.friend != null
              ? 'Chat with ${widget.friend!['name']}'
              : 'Trip Group Chat',
        ),
        backgroundColor: const Color(0xFF2D9C7C),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages.reversed.toList()[index];
                return Align(
                  alignment: msg['isUser']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg['isUser']
                          ? const Color(0xFF2D9C7C)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!msg['isUser'])
                          Text(
                            msg['sender'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          msg['text'],
                          style: TextStyle(
                            color: msg['isUser']
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: TextStyle(
                            fontSize: 10,
                            color: msg['isUser'] ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF2D9C7C)),
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
