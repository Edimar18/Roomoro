// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get or create a chat room between the current user and another user
  Future<String> getOrCreateChatSession(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("You must be logged in to start a chat.");
    }

    final currentUserId = currentUser.uid;

    // Create a consistent chat ID regardless of who starts the conversation
    List<String> participants = [currentUserId, otherUserId];
    participants.sort(); // Ensure the order is always the same
    String chatId = participants.join('_');

    final chatDocRef = _db.collection('chats').doc(chatId);
    final chatDoc = await chatDocRef.get();

    if (!chatDoc.exists) {
      // If the chat session doesn't exist, create it
      await chatDocRef.set({
        'participants': participants,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null, // No messages yet
      });
      print('New chat session created with ID: $chatId');
    }

    return chatId;
  }

  Future<void> sendMessage(String chatId, String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in.");
    }
    if (text.trim().isEmpty) {
      return; // Don't send empty messages
    }

    final messageData = {
      'senderId': currentUser.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Add the new message to the messages sub-collection
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Update the lastMessage field in the parent chat document
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': {
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      },
    });
  }

  // --- NEW METHOD TO GET THE USER'S CHAT SESSIONS ---
  Stream<QuerySnapshot> getChatSessions() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Return an empty stream if the user is not logged in
      return Stream.empty();
    }

    return _db
        .collection('chats')
    // Find chats where the current user's ID is in the 'participants' array
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessage.timestamp', descending: true) // Show most recent chats first
        .snapshots();
  }


  Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // Order by newest first
        .snapshots();
  }

}

