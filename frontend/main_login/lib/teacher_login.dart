import 'package:flutter/material.dart';
import 'package:core/api/auth_service.dart';
import 'package:teacher_app/main.dart' as teacher;
import 'create_password.dart';

void main() {
  runApp(const TeacherLoginPage());
}

class TeacherLoginPage extends StatefulWidget {
  const TeacherLoginPage({super.key});

  @override
  State<TeacherLoginPage> createState() => _TeacherLoginPageState();
}

class _TeacherLoginPageState extends State<TeacherLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                  color: const Color(0xF2FFFFFF),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2E000000),
                      blurRadius: 35,
                      offset: Offset(0, 12),
                    ),
                  ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Role Name
                        ShaderMask(
                          shaderCallback: (Rect bounds) =>
                              const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ).createShader(bounds),
                          child: const Text(
                            'Teacher Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your credentials to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Email Address Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF667EEA),
                                width: 2,
                              ),
                            ),
                          ),
                          // Validation is handled by backend
                          validator: (value) => null,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF667EEA),
                                width: 2,
                              ),
                            ),
                          ),
                          // Validation is handled by backend
                          validator: (value) => null,
                        ),
                        const SizedBox(height: 32),

                        // Login Button
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              // All validation and login logic is handled by the backend
                              setState(() {
                                _isLoading = true;
                              });

                              final authService = AuthService();
                              final result = await authService.login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                role: 'teacher',
                              );

                              setState(() {
                                _isLoading = false;
                              });

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ?? 'Login attempt completed'),
                                    backgroundColor: result['success']
                                        ? const Color(0xFF667EEA)
                                        : Colors.red,
                                  ),
                                );

                                if (result['success']) {
                                  // Check if user needs to create password
                                  final needsPasswordCreation = result['needs_password_creation'] as bool? ?? false;
                                  
                                  if (needsPasswordCreation) {
                                    // Navigate to create password page
                                    final passwordCreated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreatePasswordPage(
                                          role: 'teacher',
                                          userData: result['user'],
                                          tokens: result['tokens'],
                                          routes: result['routes'],
                                        ),
                                      ),
                                    );
                                    
                                    // If password was created successfully, navigate to dashboard
                                    if (passwordCreated == true && mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const teacher.TeacherDashboardApp(),
                                        ),
                                      );
                                    }
                                  } else {
                                    // Navigate to Teacher dashboard
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const teacher.TeacherDashboardApp(),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}