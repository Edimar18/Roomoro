// lib/widgets/chat_list_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomoro/screens/conversation_screen.dart';
import 'package:roomoro/services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListItem extends StatefulWidget {
  final QueryDocumentSnapshot chatDoc;

  const ChatListItem({super.key, required this.chatDoc});

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  final _firestoreService = FirestoreService();
  final _auth = FirebaseAuth.instance;

  // We will get this from the chat document
  String? otherUserId;

  @override
  void initState() {
    super.initState();
    // Get the other user's ID once
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final data = widget.chatDoc.data() as Map<String, dynamic>;
    final List<dynamic> participants = data['participants'];

    // Find the ID that is NOT the current user's
    otherUserId = participants.firstWhere((id) => id != currentUser.uid, orElse: () => null);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.chatDoc.data() as Map<String, dynamic>;
    final lastMessageData = data['lastMessage'] as Map<String, dynamic>?;

    String lastMessageText = "No messages yet";
    String lastMessageTime = "";

    if (lastMessageData != null) {
      lastMessageText = lastMessageData['text'] ?? '...';
      final timestamp = lastMessageData['timestamp'] as Timestamp?;
      if (timestamp != null) {
        lastMessageTime = timeago.format(timestamp.toDate());
      }
    }

    // If we couldn't find the other user, show an error tile.
    if (otherUserId == null) {
      return const ListTile(
        leading: CircleAvatar(child: Icon(Icons.error)),
        title: Text("Error: Invalid Chat"),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      // Use the otherUserId to fetch the user data
      future: _firestoreService.getUser(otherUserId!),
      builder: (context, snapshot) {

        // Use the snapshot data to build the UI
        String otherUserName = '...';

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          final userData = snapshot.data;
          otherUserName = userData?['fullName'] ?? 'User';
        }

        return ListTile(
          leading: const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            otherUserName, // This will now update automatically
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            lastMessageText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            lastMessageTime,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationScreen(chatId: widget.chatDoc.id),
              ),
            );
          },
        );
      },
    );
  }
}
