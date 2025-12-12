import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../auth/login_page.dart';

// Konstanta Warna
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Color(0xFFF9F9F9);
const Color _kSubTextColor = Color(0xFF757575);
const Color _kErrorColor = Color(0xFFE53935);

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _authService = AuthService();
  String _currentEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profile = await _authService.getProfile();
    if (mounted && profile['success']) {
      setState(() {
        _currentEmail = profile['data']['email'] ?? '';
        _isLoading = false;
      });
    }
  }

  void _showChangeEmailSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ChangeEmailForm(
        currentEmail: _currentEmail,
        onEmailChanged: (newEmail) {
          setState(() => _currentEmail = newEmail);
        },
      ),
    );
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ChangePasswordForm(),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: _kErrorColor),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginPage(
              onRegisterTap: () {}, // Placeholder callbacks
              onForgotTap: () {},
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Pengaturan Akun',
          style: TextStyle(
            color: _kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPurpleColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Akun',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kelola email dan password akun Anda',
                    style: TextStyle(fontSize: 12, color: _kSubTextColor),
                  ),
                  const SizedBox(height: 20),

                  // Email Tile
                  _buildSecurityActionTile(
                    title: 'Email Address',
                    value: _currentEmail,
                    icon: Icons.email_outlined,
                    onTap: _showChangeEmailSheet,
                  ),

                  const SizedBox(height: 12),

                  // Password Tile
                  _buildSecurityActionTile(
                    title: 'Password',
                    value: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    onTap: _showChangePasswordSheet,
                  ),

                  const SizedBox(height: 40),
                  const Divider(thickness: 1, color: _kBackgroundColor),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text('Keluar dari Akun'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kErrorColor,
                        side: BorderSide(color: _kErrorColor.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSecurityActionTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kPurpleColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _kPurpleColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _kTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 13, color: _kSubTextColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// --- Change Email Form ---
class _ChangeEmailForm extends StatefulWidget {
  final String currentEmail;
  final Function(String) onEmailChanged;

  const _ChangeEmailForm({
    required this.currentEmail,
    required this.onEmailChanged,
  });

  @override
  State<_ChangeEmailForm> createState() => _ChangeEmailFormState();
}

class _ChangeEmailFormState extends State<_ChangeEmailForm> {
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleChangeEmail() async {
    if (_newEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email baru tidak boleh kosong')),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password diperlukan untuk verifikasi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.changeEmail(
      _newEmailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        widget.onEmailChanged(_newEmailController.text.trim());
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email berhasil diubah')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengubah email'),
            backgroundColor: _kErrorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ubah Email',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Email saat ini: ${widget.currentEmail}',
            style: const TextStyle(color: _kSubTextColor),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _newEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Baru',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              helperText: 'Masukkan password untuk verifikasi',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleChangeEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurpleColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Simpan Email Baru'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- Change Password Form ---
class _ChangePasswordForm extends StatefulWidget {
  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _authService = AuthService();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  Future<void> _handleChangePassword() async {
    if (_oldPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password lama tidak boleh kosong')),
      );
      return;
    }

    if (_newPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru tidak boleh kosong')),
      );
      return;
    }

    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru tidak cocok')),
      );
      return;
    }

    if (_newPassController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.changePassword(
      _oldPassController.text,
      _newPassController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengubah password'),
            backgroundColor: _kErrorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ubah Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildPassField(
            'Password Lama',
            _oldPassController,
            _obscureOld,
            () => setState(() => _obscureOld = !_obscureOld),
          ),
          const SizedBox(height: 16),
          _buildPassField(
            'Password Baru',
            _newPassController,
            _obscureNew,
            () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 16),
          _buildPassField(
            'Ulangi Password Baru',
            _confirmPassController,
            _obscureConfirm,
            () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleChangePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurpleColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Simpan Password Baru'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPassField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
