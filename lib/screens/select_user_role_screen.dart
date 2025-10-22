import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomoro/screens/id_verification_screen.dart';
import 'package:roomoro/services/firestore_service.dart';

class SelectUserRoleScreen extends StatefulWidget {
  const SelectUserRoleScreen({super.key});

  @override
  State<SelectUserRoleScreen> createState() => _SelectUserRoleScreenState();
}

class _SelectUserRoleScreenState extends State<SelectUserRoleScreen> {
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _selectRenter(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('No user is currently signed in.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update user role in Firestore
      await _firestoreService.updateUserRole(user.uid, 'renter');

      if (!mounted) return;

      // Navigate to ID Verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IDVerificationScreen()),
      );
    } catch (e) {
      _showErrorDialog('Failed to update role: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectRoomSeeker(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('No user is currently signed in.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update user role in Firestore
      await _firestoreService.updateUserRole(user.uid, 'owner');

      if (!mounted) return;

      // Navigate to Room Seeker home screen (TODO: Create this screen)
      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome, Room Seeker!')),
      );

      // TODO: Replace with actual navigation
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const RoomSeekerHomeScreen()),
      // );
    } catch (e) {
      _showErrorDialog('Failed to update role: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 40),
                const Icon(Icons.home_work_outlined, size: 60, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to Roomoro!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find your perfect room in Cagayan de Oro City. What are you looking for?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 60),
                _buildRoleCard(
                  context: context,
                  icon: Icons.apartment,
                  title: 'Renter',
                  subtitle: 'I want to list my room/property.',
                  onTap: () => _selectRenter(context),
                ),
                const SizedBox(height: 20),
                _buildRoleCard(
                  context: context,
                  icon: Icons.search,
                  title: 'Room Seeker',
                  subtitle: 'I\'m looking for a place to stay.',
                  onTap: () => _selectRoomSeeker(context),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                )
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}