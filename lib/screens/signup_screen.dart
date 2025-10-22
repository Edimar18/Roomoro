import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomoro/screens/login_screen.dart';
import 'package:roomoro/screens/select_user_role_screen.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <-- ADD THIS IMPORT
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // <-- ADD THIS


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false; // To show a loading indicator

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> initGoogleSignInOnce() async {
    // Optional: pass serverClientId if required (often needed on Android 7.1.x)
    // await GoogleSignIn.instance.initialize(serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com');
    await GoogleSignIn.instance.initialize();
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await initGoogleSignInOnce();
      // Start interactive auth flow
      final GoogleSignInAccount? account =  await GoogleSignIn.instance.authenticate();
      await GoogleSignIn.instance.authenticate(); // Replaces signIn() in v7+ [web:6][web:21][web:15]
      if (account == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in cancelled')),
        );
        return;
      }

      // Fetch tokens (idToken is used for Firebase)
      final auth = await account.authentication; // Provides idToken in v7+ [web:6][web:15]
      final idToken = auth.idToken;
      if (idToken == null) {
        _showErrorDialog('Failed to get Google ID token.');
        return;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await FirebaseAuth.instance.signInWithCredential(credential); // Firebase accepts idToken [web:27][web:20]

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelectUserRoleScreen()),
      );
    } catch (e) {
      _showErrorDialog('Google Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential =
        FacebookAuthProvider.credential(accessToken.tokenString);

        await FirebaseAuth.instance.signInWithCredential(credential);

        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const SelectUserRoleScreen()));
        }
      } else if (result.status == LoginStatus.cancelled) {
        // User cancelled the login
      } else {
        _showErrorDialog(
            result.message ?? 'Failed to sign in with Facebook.');
      }
    } catch (e) {
      _showErrorDialog('Failed to sign in with Facebook. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred'),
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

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match.');
      return;
    }
    if (!_agreeToTerms) {
      _showErrorDialog('Please agree to the terms and conditions.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Optionally, update the user's profile with their full name
      await credential.user?.updateDisplayName(_fullNameController.text.trim());

      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const SelectUserRoleScreen()));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('Something went wrong. Please try again later.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
            children: <Widget>[
              const SizedBox(height: 20),
              const Icon(Icons.person_add_alt_1_rounded,
                  color: Colors.blue, size: 60),
              const SizedBox(height: 20),
              const Text(
                'Create an Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find your perfect room in Cagayan de Oro City.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  const Flexible(
                    child: Text('I agree to the '),
                  ),
                  TextButton(
                      onPressed: () {}, child: const Text('Terms and Conditions')),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : const Text('Sign Up',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),

              const SizedBox(height: 24),
              const Row(
                children: <Widget>[
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                label: const Text('Continue with Google'),
                onPressed: _isLoading ? null : _loginWithGoogle, // <-- CONNECT THE FUNCTION
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // --- START: ADD THE FACEBOOK BUTTON HERE ---
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.facebook, color: Colors.blue),
                label: const Text('Continue with Facebook'),
                onPressed: _isLoading ? null : _loginWithFacebook, // <-- CONNECT THE FUNCTION
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // --- END: ADD THE FACEBOOK BUTTON HERE ---


              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text('Sign In'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
