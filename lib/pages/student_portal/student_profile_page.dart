import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import '../../widgets/logout_button.dart';
import 'models/student_session.dart';
import 'student_api_service.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = StudentSession.student;
    return Scaffold(
      backgroundColor: BrandColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: BrandColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: BrandColors.accent,
          size: 24,
        ),
        actions: const [
          LogoutButton(),
          SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: BrandColors.accentGradient,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(s?.fullName ?? '?'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s?.fullName ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s?.studentId ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
            ),
            child: Column(
              children: [
                _Item(
                  icon: Iconsax.people,
                  label: 'Class',
                  value: s?.className ?? '—',
                ),
                const Divider(height: 1, color: Color(0xFFEEF0EE)),
                _Item(
                  icon: Iconsax.building,
                  label: 'Department',
                  value: s?.departmentName ?? '—',
                ),
                const Divider(height: 1, color: Color(0xFFEEF0EE)),
                _Item(
                  icon: Iconsax.buildings,
                  label: 'Faculty',
                  value: s?.facultyName ?? '—',
                ),
                const Divider(height: 1, color: Color(0xFFEEF0EE)),
                _Item(
                  icon: Iconsax.call,
                  label: 'Phone',
                  value: (s?.phone ?? '').isEmpty ? '—' : s!.phone!,
                ),
                const Divider(height: 1, color: Color(0xFFEEF0EE)),
                _Item(
                  icon: Iconsax.shield_tick,
                  label: 'Status',
                  value: s?.status ?? '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          // Account section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: BrandColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Change password action
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => showChangePasswordDialog(context),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: BrandColors.accentSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Iconsax.key,
                        size: 18,
                        color: BrandColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change password',
                            style: TextStyle(
                              fontSize: 14,
                              color: BrandColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Update your account password',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: BrandColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Iconsax.arrow_right_3,
                      size: 16,
                      color: BrandColors.textMuted,
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Item({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: BrandColors.accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: BrandColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: BrandColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: BrandColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Change password dialog
// ---------------------------------------------------------------------------

Future<void> showChangePasswordDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ChangePasswordDialog(),
  );
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _api = StudentApiService();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _error;
  String? _currentError;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final next = _newController.text;
    final confirm = _confirmController.text;

    final currentEmpty = current.isEmpty;
    final newEmpty = next.isEmpty;
    final newShort = next.isNotEmpty && next.length < 8;
    final sameAsCurrent = next.isNotEmpty && next == current;
    final confirmMismatch = confirm.isNotEmpty && confirm != next;
    final confirmEmpty = confirm.isEmpty;

    setState(() {
      _currentError = currentEmpty ? 'Required' : null;
      _newError = newEmpty
          ? 'Required'
          : (newShort
              ? 'Must be at least 8 characters'
              : (sameAsCurrent
                  ? 'New password must be different'
                  : null));
      _confirmError = confirmEmpty
          ? 'Required'
          : (confirmMismatch ? 'Passwords do not match' : null);
      _error = null;
    });

    if (currentEmpty || newEmpty || newShort || sameAsCurrent ||
        confirmEmpty || confirmMismatch) {
      return;
    }

    final token = StudentSession.token;
    if (token == null) {
      setState(() => _error = 'Not signed in');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _api.changePassword(
        token: token,
        currentPassword: current,
        newPassword: next,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password updated successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: BrandColors.accent,
        ),
      );
    } on StudentApiException catch (e) {
      if (!mounted) return;
      // "Current password is incorrect" — point the user at the right
      // field; everything else goes to a generic top-of-form error.
      if (e.message.toLowerCase().contains('current password')) {
        setState(() {
          _currentError = e.message;
          _submitting = false;
        });
      } else {
        setState(() {
          _error = e.message;
          _submitting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not reach the server. ($e)';
        _submitting = false;
      });
    }
  }

  OutlineInputBorder _border(Color color, {double width = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: BrandColors.accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.key,
                      size: 18,
                      color: BrandColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Change password',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your current password, then choose a new one (8+ characters).',
                style: TextStyle(
                  fontSize: 12.5,
                  color: BrandColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              // Current password
              TextField(
                controller: _currentController,
                enabled: !_submitting,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Current password',
                  prefixIcon: const Icon(
                    Iconsax.lock,
                    size: 18,
                    color: BrandColors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _submitting
                        ? null
                        : () => setState(
                            () => _obscureCurrent = !_obscureCurrent),
                    icon: Icon(
                      _obscureCurrent ? Iconsax.eye_slash : Iconsax.eye,
                      size: 18,
                      color: BrandColors.textMuted,
                    ),
                  ),
                  filled: true,
                  fillColor: BrandColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: _border(
                    _currentError != null
                        ? BrandColors.danger
                        : const Color(0xFFE6E8EB),
                  ),
                  focusedBorder: _border(
                    _currentError != null
                        ? BrandColors.danger
                        : BrandColors.accent,
                    width: 1.5,
                  ),
                ),
              ),
              if (_currentError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _currentError!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: BrandColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // New password
              TextField(
                controller: _newController,
                enabled: !_submitting,
                obscureText: _obscureNew,
                onChanged: (_) {
                  if (_newError != null) {
                    setState(() => _newError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'New password',
                  prefixIcon: const Icon(
                    Iconsax.lock,
                    size: 18,
                    color: BrandColors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _obscureNew = !_obscureNew),
                    icon: Icon(
                      _obscureNew ? Iconsax.eye_slash : Iconsax.eye,
                      size: 18,
                      color: BrandColors.textMuted,
                    ),
                  ),
                  filled: true,
                  fillColor: BrandColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: _border(
                    _newError != null
                        ? BrandColors.danger
                        : const Color(0xFFE6E8EB),
                  ),
                  focusedBorder: _border(
                    _newError != null
                        ? BrandColors.danger
                        : BrandColors.accent,
                    width: 1.5,
                  ),
                ),
              ),
              if (_newError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _newError!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: BrandColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // Confirm new password
              TextField(
                controller: _confirmController,
                enabled: !_submitting,
                obscureText: _obscureConfirm,
                onChanged: (_) {
                  if (_confirmError != null) {
                    setState(() => _confirmError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Confirm new password',
                  prefixIcon: const Icon(
                    Iconsax.lock,
                    size: 18,
                    color: BrandColors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _submitting
                        ? null
                        : () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm ? Iconsax.eye_slash : Iconsax.eye,
                      size: 18,
                      color: BrandColors.textMuted,
                    ),
                  ),
                  filled: true,
                  fillColor: BrandColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: _border(
                    _confirmError != null
                        ? BrandColors.danger
                        : const Color(0xFFE6E8EB),
                  ),
                  focusedBorder: _border(
                    _confirmError != null
                        ? BrandColors.danger
                        : BrandColors.accent,
                    width: 1.5,
                  ),
                ),
              ),
              if (_confirmError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _confirmError!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: BrandColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.warning_2,
                      size: 14,
                      color: BrandColors.danger,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: BrandColors.danger,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: BrandColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            BrandColors.accent.withOpacity(0.6),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
