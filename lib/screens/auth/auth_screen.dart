import 'package:academitrack/screens/main_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  String errorMsg = '';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _submit() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        (!isLogin && _confirmController.text.isEmpty)) {
      setState(() {
        errorMsg = 'Please fill in all required fields';
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        if (password != confirm) {
          throw Exception("Passwords do not match");
        }
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;
      _emailController.clear();
      _passwordController.clear();
      _confirmController.clear();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainTabScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => errorMsg = e.message ?? 'Authentication failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => errorMsg = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                // Logo
                SizedBox(
                  height: 100,
                  width: 100,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.school, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "AcademiTrack",
                  style: TextStyle(
                    fontFamily: 'Cursive',
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTabButton("Login", isLogin),
                    _buildTabButton("Signup", !isLogin),
                  ],
                ),
                const SizedBox(height: 20),

                _buildTextField(_emailController, "Email address"),
                const SizedBox(height: 12),
                _buildTextField(
                  _passwordController,
                  isLogin ? "Password" : "Create Password",
                ),
                if (!isLogin) ...[
                  const SizedBox(height: 12),
                  _buildTextField(_confirmController, "Confirm Password"),
                ],
                const SizedBox(height: 20),

                if (errorMsg.isNotEmpty)
                  Text(
                    errorMsg,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),

                if (isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 12,
                          ),
                          elevation: 4,
                        ),
                        onPressed: _submit,
                        child: Text(
                          isLogin ? "Login" : "Signup",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          try {
                            final userCredential = await FirebaseAuth.instance
                                .signInAnonymously();
                            debugPrint(
                              'Signed in as guest: ${userCredential.user?.uid}',
                            );

                            if (!context.mounted) return;

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const MainTabScreen(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            debugPrint("Anonymous sign-in failed: $e");
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Failed to continue as guest: $e",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          "Continue as Guest",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    final isPassword = hint.toLowerCase().contains("password");

    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildTabButton(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => isLogin = label == "Login"),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.grey.shade300 : Colors.transparent,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
