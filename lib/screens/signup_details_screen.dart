import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';

class SignUpDetailsScreen extends StatefulWidget {
  const SignUpDetailsScreen({super.key});

  @override
  State<SignUpDetailsScreen> createState() => _SignUpDetailsScreenState();
}

class _SignUpDetailsScreenState extends State<SignUpDetailsScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthdayController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // iOS-style navigation bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF4B4BF5),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  // Domain text with lock icon
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.lock_fill,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'auth0.convoai.com',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  // Right icons
                  const Row(
                    children: [
                      Icon(
                        CupertinoIcons.person_crop_circle,
                        color: Color(0xFF4B4BF5),
                        size: 22,
                      ),
                      SizedBox(width: 16),
                      Icon(
                        CupertinoIcons.arrow_2_circlepath,
                        color: Color(0xFF4B4BF5),
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      // Chat bubble logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4B4BF5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.chat_bubble_fill,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Title
                      const Text(
                        'Tell us about you',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Form fields
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              placeholder: 'First name',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastNameController,
                              placeholder: 'Last name',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _birthdayController,
                        placeholder: 'Birthday',
                      ),
                      const SizedBox(height: 24),
                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add final submission logic
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen()), // Create this
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B4BF5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Terms text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          children: const [
                            TextSpan(
                              text: 'By clicking "Continue", you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: Color(0xFF4B4BF5),
                              ),
                            ),
                            TextSpan(
                              text: ' and acknowledge our ',
                            ),
                            TextSpan(
                              text: 'Privacy policy',
                              style: TextStyle(
                                color: Color(0xFF4B4BF5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      style: const TextStyle(
        fontSize: 17,
        color: Color(0xFF1C1C1E),
      ),
      placeholderStyle: TextStyle(
        fontSize: 17,
        color: Colors.grey.shade500,
      ),
    );
  }
}