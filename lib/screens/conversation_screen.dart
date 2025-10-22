// lib/screens/conversation_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomoro/services/chatService.dart';
import 'package:roomoro/services/firestore_service.dart';


class ConversationScreen extends StatefulWidget {
  final String chatId;

  const ConversationScreen({super.key, required this.chatId});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _firestoreService = FirestoreService();
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String _otherUserName = "Chat";
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _chatService.sendMessage(widget.chatId, _messageController.text);
      _messageController.clear(); // Clear the input field after sending
    }
  }


  // --- NEW METHOD TO GET THE OTHER USER'S NAME ---
  void _getOtherUserName() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Extract the other user's ID from the chatId
    final participantIds = widget.chatId.split('_');
    final otherUserId = participantIds.firstWhere((id) => id != currentUser.uid);

    // Fetch user data using FirestoreService
    final userData = await _firestoreService.getUser(otherUserId);
    if (userData != null && userData.containsKey('fullName')) {
      setState(() {
        _otherUserName = userData['fullName'];
      });
    } else {
      setState(() {
        _otherUserName = "User"; // Fallback name
      });
    }
  }



  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getOtherUserName();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(_otherUserName),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // --- MESSAGE LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Say hello!"),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong."));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // To show the latest messages at the bottom
                  itemCount: messages.length,
                  padding: const EdgeInsets.all(16.0),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageData = message.data() as Map<String, dynamic>;
                    final isMe = messageData['senderId'] == currentUserId;

                    return _buildMessageBubble(messageData['text'], isMe);
                  },
                );
              },
            ),
          ),
          // --- MESSAGE INPUT ---
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Widget for displaying a single message bubble
  Widget _buildMessageBubble(String text, bool isMe) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Widget for the text input field and send button
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
