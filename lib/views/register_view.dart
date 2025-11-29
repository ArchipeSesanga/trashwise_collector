// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashwisecollector/providers/auth_providers.dart';
import 'package:trashwisecollector/routes/app_routes.dart';
import 'package:trashwisecollector/views/widgets/my_button.dart';
import 'package:trashwisecollector/views/widgets/my_ext_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Image.asset(
                'assets/bg_image_login.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.7),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 100),
                    const SizedBox(height: 20),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Register to get started",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color.fromARGB(255, 191, 191, 191),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          MyTextField(
                            controller: _fullNameController,
                            name: "Full Name",
                            prefixIcon: Icons.person,
                            obscureText: false,
                            inputType: TextInputType.name,
                          ),
                          const SizedBox(height: 10),
                          MyTextField(
                            controller: _emailController,
                            name: "Email",
                            prefixIcon: Icons.email,
                            obscureText: false,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),
                          MyTextField(
                            controller: _passwordController,
                            name: "Password",
                            prefixIcon: Icons.lock,
                            obscureText: true,
                            inputType: TextInputType.text,
                          ),
                          const SizedBox(height: 10),
                          MyTextField(
                            controller: _confirmPasswordController,
                            name: "Confirm Password",
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            inputType: TextInputType.text,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 49,
                            child: authProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : MyButton(
                                    title: "Register",
                                    onPressed: () async {
                                      final fullName = _fullNameController.text
                                          .trim();
                                      final email = _emailController.text
                                          .trim();
                                      final password = _passwordController.text
                                          .trim();
                                      final confirm = _confirmPasswordController
                                          .text
                                          .trim();

                                      if (fullName.isEmpty ||
                                          email.isEmpty ||
                                          password.isEmpty ||
                                          confirm.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "All fields are required",
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      if (password != confirm) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Passwords do not match",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final success = await authProvider
                                          .register(
                                            fullName: fullName,
                                            email: email,
                                            password: password,
                                          );

                                      if (success) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.login,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              authProvider.errorMessage ??
                                                  "Registration failed",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            ),
                            child: const Text(
                              "Already have an account? Login",
                              style: TextStyle(color: Colors.green),
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
    );
  }
}
