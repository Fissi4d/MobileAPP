import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _currentThemeIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Color> _backgroundColors = [
    const Color(0xFF4338FF),
    const Color(0xFFB5A17C),
    const Color(0xFF0A4D4D),
    const Color(0xFF4A314A),
  ];

  void _cycleTheme() {
    setState(() {
      _currentThemeIndex = (_currentThemeIndex + 1) % _backgroundColors.length;
    });
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = 
            FacebookAuthProvider.credential(accessToken.tokenString);

        final UserCredential userCredential = 
            await _auth.signInWithCredential(credential);

        // Handle successful login
        print('Facebook User: ${userCredential.user?.displayName}');
        // Navigate to home screen or other post-login screen
        // Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('Login cancelled', 'You cancelled the Facebook login');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('Login failed', e.message);
    } catch (e) {
      _showErrorDialog('Error', 'An unexpected error occurred');
    }
  }

  void _showErrorDialog(String title, String? message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message ?? 'Unknown error occurred'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      _showErrorDialog('Login cancelled', 'You cancelled the Google login');
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    
    print('Google User: ${userCredential.user?.displayName}');
    // Navigate to home screen if needed
  } on FirebaseAuthException catch (e) {
    _showErrorDialog('Login failed', e.message);
  } catch (e) {
    _showErrorDialog('Error', 'An unexpected error occurred');
  }
}

  @override
  Widget build(BuildContext context) {
    final Color currentColor = _backgroundColors[_currentThemeIndex];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: currentColor,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _cycleTheme,
                    child: const Center(
                      child: _PulsingDot(),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SocialButton(
                        text: "Continue with Apple",
                        icon: FontAwesomeIcons.apple,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      _SocialButton(
                        text: "Continue with Google",
                        icon: FontAwesomeIcons.google,
                        backgroundColor: const Color(0xFF2C2C2C),
                        textColor: Colors.white,
                        onPressed: _signInWithGoogle,
                      ),
                      const SizedBox(height: 12),
                      _SocialButton(
                        text: "Continue with Meta",
                        icon: FontAwesomeIcons.facebook,
                        backgroundColor: const Color(0xFF2C2C2C),
                        textColor: Colors.white,
                        onPressed: _signInWithFacebook,
                      ),
                      const SizedBox(height: 12),
                      _SocialButton(
                        text: "Log in",
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Keep _PulsingDot and _SocialButton classes the same as before

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({super.key});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// A reusable social button widget with FontAwesome icon
class _SocialButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.text,
    this.icon, // Make icon nullable
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              FaIcon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}