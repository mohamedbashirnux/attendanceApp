import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'api_config.dart';
import 'models/student_session.dart';
import 'student_api_service.dart';
import 'student_shell.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = StudentApiService();
  bool _obscurePassword = true;
  bool _studentIdError = false;
  bool _passwordError = false;
  bool _submitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    // If a session is already persisted, jump straight to the shell.
    if (StudentSession.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentShell()),
        );
      });
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _formError = null;
    });

    final sid = _studentIdController.text.trim();
    final pw = _passwordController.text;

    final idEmpty = sid.isEmpty;
    final pwEmpty = pw.isEmpty;
    if (idEmpty || pwEmpty) {
      setState(() {
        _studentIdError = idEmpty;
        _passwordError = pwEmpty;
      });
      return;
    }
    setState(() {
      _studentIdError = false;
      _passwordError = false;
      _submitting = true;
    });

    try {
      final res = await _api.login(studentId: sid, password: pw);
      if (!mounted) return;
      await StudentSession.save(token: res.token, student: res.student);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentShell()),
      );
    } on StudentApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _formError = e.message;
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // e.g. SocketException when the dev server is unreachable.
        _formError =
            'Cannot reach ${resolveBaseUrl()}. Make sure the Next.js dev server is running and your phone is on the same WiFi as your PC. ($e)';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF5F61E6);

    OutlineInputBorder border(Color color, {double width = 1.2}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/logo1.png',
                  height: 96,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Student Portal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B1E22),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sign in to view your attendance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8A8F95),
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _studentIdController,
                enabled: !_submitting,
                onChanged: (_) {
                  if (_studentIdError) {
                    setState(() => _studentIdError = false);
                  }
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Student ID (e.g. S001)',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8A8F95),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Iconsax.user,
                    size: 18,
                    color: Color(0xFF8A8F95),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: border(
                    _studentIdError ? Colors.red : const Color(0xFFE6E8EB),
                  ),
                  focusedBorder: border(
                    _studentIdError ? Colors.red : accent,
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                enabled: !_submitting,
                obscureText: _obscurePassword,
                onChanged: (_) {
                  if (_passwordError) {
                    setState(() => _passwordError = false);
                  }
                },
                onSubmitted: (_) => _submit(),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8A8F95),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Iconsax.lock,
                    size: 18,
                    color: Color(0xFF8A8F95),
                  ),
                  suffixIcon: IconButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                    icon: Icon(
                      _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                      size: 18,
                      color: const Color(0xFF8A8F95),
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: border(
                    _passwordError ? Colors.red : const Color(0xFFE6E8EB),
                  ),
                  focusedBorder: border(
                    _passwordError ? Colors.red : accent,
                    width: 1.5,
                  ),
                ),
              ),
              if (_formError != null) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.warning_2,
                      size: 14,
                      color: Color(0xFFE5484D),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formError!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFFE5484D),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: accent.withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
