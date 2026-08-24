import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter email and password.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        showMessage('Login failed.');
        return;
      }

      // Get the logged-in user's profile.
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        showMessage(
          'Your account profile was not found. '
          'Please contact support.',
        );
        return;
      }

      final role = profile['role']?.toString().toLowerCase();

      if (!mounted) return;

      // ----------------------------------------------------------
      // PATIENT
      // ----------------------------------------------------------

      if (role == 'patient') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/patient',
          (route) => false,
        );
      }
      // ----------------------------------------------------------
      // CAREGIVER
      // ----------------------------------------------------------
      else if (role == 'caregiver') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/caregiver',
          (route) => false,
        );
      }
      // ----------------------------------------------------------
      // DOCTOR
      // ----------------------------------------------------------
      else if (role == 'doctor') {
        Navigator.pushNamedAndRemoveUntil(context, '/doctor', (route) => false);
      }
      // ----------------------------------------------------------
      // INVALID ROLE
      // ----------------------------------------------------------
      else {
        showMessage('Invalid account role. Please contact support.');
      }
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      debugPrint('Login error: $e');

      showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage('Enter your email first.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.careconnect.app://reset-password/',
      );

      if (!mounted) return;

      showMessage(
        'Password reset email sent. '
        'Please check your inbox.',
      );
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      debugPrint('Password reset error: $e');

      showMessage('Unable to send password reset email.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 70),

                const Icon(
                  Icons.psychology,
                  size: 90,
                  color: Color(0xFF1565C0),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Sign in to continue',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),

                const SizedBox(height: 40),

                // =================================================
                // EMAIL
                // =================================================
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,

                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // PASSWORD
                // =================================================
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,

                  onSubmitted: (_) {
                    if (!isLoading) {
                      login();
                    }
                  },

                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),

                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // LOGIN
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // =================================================
                // FORGOT PASSWORD
                // =================================================
                TextButton(
                  onPressed: isLoading ? null : forgotPassword,

                  child: const Text('Forgot Password?'),
                ),

                const SizedBox(height: 15),

                const Divider(),

                const SizedBox(height: 15),

                // =================================================
                // SIGN UP
                // =================================================
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, '/signup');
                        },

                  child: const Text(
                    'Create New Account',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
