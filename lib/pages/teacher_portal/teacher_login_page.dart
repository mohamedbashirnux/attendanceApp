import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import '../../widgets/app_drawer.dart';
import 'models/teacher_session.dart';
import 'teacher_api_service.dart';
import 'teacher_shell.dart';

class TeacherLoginPage extends StatefulWidget {
  const TeacherLoginPage({super.key});

  @override
  State<TeacherLoginPage> createState() => _TeacherLoginPageState();
}

class _TeacherLoginPageState extends State<TeacherLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = TeacherApiService();

  bool _obscurePassword = true;
  bool _usernameError = false;
  bool _passwordError = false;
  bool _loading = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = await TeacherSession.load();
    if (!mounted || session == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TeacherShell(session: session)),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final usernameEmpty = username.isEmpty;
    final passwordEmpty = password.isEmpty;

    setState(() {
      _usernameError = usernameEmpty;
      _passwordError = passwordEmpty;
      _serverError = null;
    });

    if (usernameEmpty || passwordEmpty) return;

    setState(() => _loading = true);
    try {
      final result = await _api.login(
        username: username,
        password: password,
      );
      final session = TeacherSession(
        token: result.token,
        teacher: result.teacher,
      );
      await session.save();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TeacherShell(session: session),
        ),
      );
    } on TeacherApiException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } catch (e) {
      if (!mounted) return;
      // Surface the real underlying error so we can tell localhost / DNS /
      // timeout issues apart from auth failures.
      setState(() => _serverError = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const errorColor = BrandColors.danger;
    final accent = BrandColors.accent;
    return Scaffold(
      backgroundColor: Colors.white,
      // The login page is reached from the main drawer, so we keep the
      // main app drawer reachable from here too (swipe / hamburger) so
      // the user can navigate to other sections without going back.
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo — bare image, no white card, no big shadow
                    Center(
                      child: Image.asset(
                        'assets/logo1.png',
                        height: 96,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title block
                    const Text(
                      'Lectures Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B1E22),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to access your classes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF5B6167),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Username
                    TextField(
                      controller: _usernameController,
                      enabled: !_loading,
                      onChanged: (_) {
                        if (_usernameError) {
                          setState(() => _usernameError = false);
                        }
                      },
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1B1E22),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        prefixIcon: Icon(
                          Iconsax.user,
                          color: _usernameError ? errorColor : accent,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        border: _border(Colors.grey.shade300),
                        enabledBorder: _border(
                          _usernameError ? errorColor : Colors.grey.shade300,
                        ),
                        focusedBorder: _border(
                          _usernameError ? errorColor : accent,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextField(
                      controller: _passwordController,
                      enabled: !_loading,
                      obscureText: _obscurePassword,
                      onChanged: (_) {
                        if (_passwordError) {
                          setState(() => _passwordError = false);
                        }
                      },
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1B1E22),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(
                          Iconsax.lock,
                          color: _passwordError ? errorColor : accent,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Iconsax.eye_slash
                                : Iconsax.eye,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: _loading
                              ? null
                              : () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        border: _border(Colors.grey.shade300),
                        enabledBorder: _border(
                          _passwordError ? errorColor : Colors.grey.shade300,
                        ),
                        focusedBorder: _border(
                          _passwordError ? errorColor : accent,
                          width: 2,
                        ),
                      ),
                      onSubmitted: (_) {
                        if (!_loading) _handleLogin();
                      },
                    ),

                    // Server error
                    if (_serverError != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _serverError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Sign In button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              accent.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Iconsax.login, size: 20),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Get account hint
                    TextButton(
                      onPressed: _loading ? null : _handleGetAccount,
                      child: Text.rich(
                        TextSpan(
                          text: 'Don\'t have an account? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Get Account',
                              style: TextStyle(
                                color: BrandColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  void _handleGetAccount() {
    setState(() => _serverError =
        'Please ask your faculty to create an account for you.');
  }
}
