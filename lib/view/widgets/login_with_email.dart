import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/bloc/auth/auth_bloc.dart';

import '../../data/local/pref_service.dart';
import '../../main.dart';
import '../../resources/resources.dart';
import '../../routes/routes_name.dart';
import '../../utils/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;

  void login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // 👉 API / Firebase login logic here
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Email
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  if (!value.contains("@")) {
                    return "Enter valid email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is required";
                  }
                  if (value.length < 6) {
                    return "Minimum 6 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
              ),

              const SizedBox(height: 16),

              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthLoginSuccessState) {
                    final data = state.response;

                    // Save data
                    PrefService().setRegId(data['data']['vendor']['_id']);
                    PrefService().setToken(data['data']['accessToken']);
                    PrefService().setUserSession(true);

                    Utils.snackBar(data['message'], context);

                    // Navigate to Home
                    Navigator.popUntil(context, (route) => route.isFirst);
                    GoRouter.of(context).pushNamed(RoutesName.navigationScreen);

                    // Optional
                    sendNotificationLive();
                  }

                  if (state is AuthErrorState) {
                    Utils.snackBar(
                      "Invalid email or password. Please try again.",
                      context,
                    );
                  }
                },

                builder: (context, state) {
                  if (state is AuthLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                        Utils.snackBar(
                          "Email and password must not be empty",
                          context,
                        );
                        return;
                      }

                      BlocProvider.of<AuthBloc>(context).add(
                        SignupEvent(
                          data: {
                            "email": emailController.text.trim(),
                            "password": passwordController.text.trim(),
                          },
                        ),
                      );
                    },
                    child: _buildSocialButton(text: 'Login'),
                  );
                },
              )

            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSocialButton({required String text}) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: MediaQuery.of(context).size.height * 0.06,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Resources.colors.buttonColor,
      ),
      child: Text(text, style: Resources.styles.kTextStyle16B(Colors.white)),
    );
  }
}
