import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class IDVerificationScreen extends StatefulWidget {
  const IDVerificationScreen({super.key});

  @override
  State<IDVerificationScreen> createState() => _IDVerificationScreenState();
}

class _IDVerificationScreenState extends State<IDVerificationScreen> {
  void _uploadId() {
    // TODO: Implement image picker to select an ID
    // TODO: Implement Firebase Storage to upload the file
    print('Upload ID placeholder');
  }

  void _submitForVerification() {
    // TODO: Call a Firebase function or save verification request
    print('Submit for Verification pressed');
    // On success, maybe navigate to the main app screen
    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => RenterDashboard()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
        const Text('ID Verification', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
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
                onTap: _uploadId,
                // --- MODIFICATION START ---
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    // A simple, solid border instead of the dotted one
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: const Column(
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
                  ),
                ),
                // --- MODIFICATION END ---
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
                onPressed: _submitForVerification,
                child: const Text('Submit for Verification',
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
