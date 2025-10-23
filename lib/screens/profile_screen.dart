import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomoro/screens/home_page.dart';
import 'package:roomoro/services/firestore_service.dart';
import 'package:roomoro/screens/welcomeScreen.dart';
import 'package:roomoro/screens/add_listing_screen.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<Map<String, dynamic>?>? _userData;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser?.uid;
    if (_uid != null) {
      _userData = _firestoreService.getUser(_uid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: ()  {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const HomePage()),

            );
          },
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User not found.'));
          }

          final userData = snapshot.data!;
          final fullName = userData['fullName'] ?? 'N/A';
          final role = userData['role'] ?? 'renter';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  NetworkImage('https://picsum.photos/200/300'),
                ),
                const SizedBox(height: 16),
                Text(
                  fullName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  role,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                if (role != 'renter') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddListingScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Room'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Analytics',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _AnalyticsCard(
                          icon: Icons.favorite,
                          value: '1.2K',
                          label: 'Likes'),
                      _AnalyticsCard(
                          icon: Icons.visibility,
                          value: '5.8K',
                          label: 'Views'),
                      _AnalyticsCard(
                          icon: Icons.chat_bubble,
                          value: '85%',
                          label: 'Inquiry Rate'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ProfileMenuItem(
                    icon: Icons.list,
                    text: 'My Listings',
                    onTap: () {},
                  ),
                ],
                _ProfileMenuItem(
                  icon: Icons.edit,
                  text: 'Edit Profile',
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.settings_applications,
                  text: 'App Settings',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Log Out',
                      style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WelcomeScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _AnalyticsCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
