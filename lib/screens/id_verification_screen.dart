import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomoro/services/firestore_service.dart';
import 'package:roomoro/screens/home_page.dart';

class IDVerificationScreen extends StatefulWidget {
  const IDVerificationScreen({super.key});

  @override
  State<IDVerificationScreen> createState() => _IDVerificationScreenState();
}

class _IDVerificationScreenState extends State<IDVerificationScreen> {
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  String? _uploadedFileName;

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

  void _uploadId() {
    // TODO: Implement image picker to select an ID
    // TODO: Implement Firebase Storage to upload the file
    print('Upload ID placeholder');

    // For demonstration purposes, simulate a file upload
    setState(() {
      _uploadedFileName = 'drivers_license.jpg';
    });
  }

  Future<void> _submitForVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('No user is currently signed in.');
      return;
    }

    if (_uploadedFileName == null) {
      _showErrorDialog('Please upload your ID before submitting.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Upload ID to Firebase Storage and save the URL to Firestore
      // For now, we'll just update the verification status

      // Update verification status in Firestore
      await _firestoreService.updateVerificationStatus(user.uid, true);

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Verification Submitted'),
          content: const Text(
            'Your ID has been submitted for verification. We\'ll review it and notify you once approved.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(ctx).pop();
                // TODO: Navigate to Renter Dashboard

                 Navigator.pushAndRemoveUntil(
                   context,
                   MaterialPageRoute(builder: (context) => const HomePage()),
                   (route) => false,
                 );


              },
            )
          ],
        ),
      );
    } catch (e) {
      _showErrorDialog('Failed to submit verification: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ID Verification', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Verify Your Identity',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'For the safety of our community, we require all users to verify their identity.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Accepted IDs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIdType('Driver\'s\nLicense', Icons.credit_card),
                      _buildIdType('Passport', Icons.airplanemode_active),
                      _buildIdType('National ID', Icons.badge),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _isLoading ? null : _uploadId,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: _uploadedFileName == null
                          ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to upload your ID',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Text('PNG, JPG, or PDF',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 40, color: Colors.green),
                          const SizedBox(height: 8),
                          Text(_uploadedFileName!,
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          const Text('Tap to change',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Tips for a successful upload',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildTip('Place your ID on a flat surface.'),
                  _buildTip('Ensure good lighting, avoid shadows.'),
                  _buildTip('Avoid glare and blur.'),
                  _buildTip('Make sure all text is readable.'),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submitForVerification,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text('Submit for Verification',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        /* TODO: Handle trouble link */
                      },
                      child: const Text('Having trouble?'),
                    ),
                  )
                ],
              ),
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

  Widget _buildIdType(String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.blue, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}