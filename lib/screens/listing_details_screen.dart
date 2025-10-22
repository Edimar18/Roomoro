// lib/screens/listing_details_screen.dart
import 'package:flutter/material.dart';
import '../models/room_listing.dart';
import 'package:roomoro/services/firestore_service.dart';
import 'package:roomoro/services/chatService.dart';
import 'package:roomoro/screens/chat_list_screen.dart';
import 'package:roomoro/screens/conversation_screen.dart';

class ListingDetailsScreen extends StatefulWidget {
  final RoomListing listing;

  const ListingDetailsScreen({super.key, required this.listing});

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();

}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  final _chatService = ChatService(); // Create an instance of ChatService
  final _fireStoreService = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing.title),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for the image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.listing.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.listing.title,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '₱${widget.listing.price.toStringAsFixed(2)} / month',
                style: TextStyle(fontSize: 20, color: Colors.teal[700], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.pink, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.listing.likes} likes',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Divider(height: 40),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.listing.description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
              ),
              const Divider(height: 40,),
              const Text(
                'About the seller',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12,),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                  ),
                  const SizedBox(width: 12),

                  FutureBuilder(
                      future: _fireStoreService.getUser(widget.listing.ownerId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return  Text(
                              widget.listing.ownerId
                          );
                        }

                        final userData = snapshot.data!;
                        final fullName = userData['fullName'] ?? 'N/A';

                        return Text(
                          fullName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        );

                      }

                  ),

                ],
              ),
              const Divider(height: 10,),
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(


                      onPressed: () async {
                        try {
                          // magbutang dre ug function para chat sa seller
                          final chatId = await _chatService
                              .getOrCreateChatSession(widget.listing.ownerId);

                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  ConversationScreen(chatId: chatId),
                              )
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to start a chat: ${e.toString()}.'))
                          );
                        }
                      },

                      icon: const Icon(Icons.message, color: Colors.white),
                      label: const Text('Message seller', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          )
                      )
                  )
              )


              // You can add more details here, like amenities
            ],
          ),
        ),
      ),
    );
  }
}
