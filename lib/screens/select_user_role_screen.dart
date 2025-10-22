import 'package:flutter/material.dart';
import 'package:roomoro/screens/id_verification_screen.dart';


class SelectUserRoleScreen extends StatelessWidget {
  const SelectUserRoleScreen({super.key});

  void _selectRenter(BuildContext context) {
    // TODO: Handle Renter selection logic
    print('Renter selected');
    Navigator.push(context, MaterialPageRoute(builder: (context) => const IDVerificationScreen()));
  }

  void _selectRoomSeeker(BuildContext context) {
    // TODO: Handle Room Seeker selection logic
    print('Room Seeker selected');
    // Example: Navigate to a different screen for room seekers
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomSeekerHomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40),
            const Icon(Icons.home_work_outlined, size: 60, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Roomie!',
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
      onTap: onTap,
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
