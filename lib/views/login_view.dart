// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ensure this import is present for context.read()
import 'package:trashwisecollector/providers/auth_providers.dart';
import 'package:trashwisecollector/routes/app_routes.dart';
import 'package:trashwisecollector/views/widgets/my_button.dart';
import 'package:trashwisecollector/views/widgets/my_ext_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper function for showing simple SnackBar messages
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use listen: true here (default) or context.watch() for updating based on isLoading
    final authProvider = Provider.of<AuthProvider>(context); 

    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND IMAGE
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Image.asset(
                "assets/bg_image_login.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// CONTENT CENTERED
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                
                  Image.asset(
                    'assets/logo.png',
                    height: 120,
                  ),
                  const SizedBox(height: 20),

                  /// WHITE CARD CONTAINER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Welcome back!",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),

                        /// EMAIL FIELD
                        MyTextField(
                          controller: _emailController,
                          name: "Email",
                          prefixIcon: Icons.email,
                          obscureText: false,
                          inputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),

                        /// PASSWORD FIELD
                        MyTextField(
                          controller: _passwordController,
                          name: "Password",
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          inputType: TextInputType.text,
                        ),
                        const SizedBox(height: 20),

                        /// LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 49,
                          child: authProvider.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : MyButton(
                                  title: "Login",
                                  onPressed: () async {
                                    final email =
                                        _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();

                                    if (email.isEmpty || password.isEmpty) {
                                      _showSnackBar("All fields are required");
                                      return;
                                    }

                                    // FIX: Use context.read() for non-listening, single-time access
                                    final provider =
                                        context.read<AuthProvider>();

                                    final success = await provider.login(
                                      email: email,
                                      password: password,
                                    );

                                    // CRITICAL: Check if the widget is still in the tree after the await
                                    if (!mounted) return;

                                    if (success) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.mainView,
                                      );
                                    } else {
                                      _showSnackBar(
                                        provider.errorMessage ?? "Login failed",
                                      );
                                    }
                                  },
                                ),
                        ),

                        const SizedBox(height: 15),

                        /// REGISTER LINK
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.register);
                          },
                          child: const Text(
                            "Don't have an account? Register",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}