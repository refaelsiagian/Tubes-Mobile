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
  bool _isVerified = false;
  bool _sendingVerification = false;
  String? _verificationMessage;
  String? _verificationError;

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
        _isVerified = profile['data']['is_verified'] == true ||
            profile['data']['email_verified_at'] != null;
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerification() async {
    setState(() {
      _sendingVerification = true;
      _verificationMessage = null;
      _verificationError = null;
    });

    final result = await _authService.sendVerificationEmail();

    if (!mounted) return;

    setState(() {
      _sendingVerification = false;
      if (result['success'] == true) {
        _verificationMessage = result['message'] ?? 'Email verifikasi dikirim';
      } else {
        _verificationError = result['message'] ?? 'Gagal mengirim email verifikasi';
      }
    });
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

  void _showNeedVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verifikasi email terlebih dahulu untuk mengubah data akun'),
        backgroundColor: _kErrorColor,
      ),
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

                  if (!_isVerified) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFC48C)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email belum terverifikasi',
                            style: TextStyle(
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Verifikasi email terlebih dahulu untuk mengubah email dan password.',
                            style: TextStyle(
                              color: Color(0xFF8B5E3C),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _sendingVerification ? null : _resendVerification,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFE65100),
                                side: const BorderSide(color: Color(0xFFE65100)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _sendingVerification
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFE65100),
                                      ),
                                    )
                                  : const Text('Kirim Ulang Email Verifikasi'),
                            ),
                          ),
                          if (_verificationMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _verificationMessage!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (_verificationError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _verificationError!,
                              style: const TextStyle(
                                color: _kErrorColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Email Tile
                  _buildSecurityActionTile(
                    title: 'Email Address',
                    value: _currentEmail,
                    icon: Icons.email_outlined,
                    onTap: _isVerified
                        ? _showChangeEmailSheet
                        : () => _showNeedVerification(),
                  ),

                  const SizedBox(height: 12),

                  // Password Tile
                  _buildSecurityActionTile(
                    title: 'Password',
                    value: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    onTap: _isVerified
                        ? _showChangePasswordSheet
                        : () => _showNeedVerification(),
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

// --- PERBAIKAN 1: Change Email Form ---
// --- PERBAIKAN 1: Change Email Form (Dengan Error Text & Delayed SnackBar) ---
class _ChangeEmailForm extends StatefulWidget {
  final String currentEmail;
  final Function(String) onEmailChanged;

  const _ChangeEmailForm({
    super.key, // Tambahkan super.key best practice
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
  String? _errorMessage; // Variabel untuk menampung pesan error

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangeEmail() async {
    // Reset error
    setState(() => _errorMessage = null);
    FocusScope.of(context).unfocus();

    if (_newEmailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Email baru tidak boleh kosong');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Password diperlukan untuk verifikasi');
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
        // 1. Update Data Parent
        widget.onEmailChanged(_newEmailController.text.trim());

        // 2. Tutup Sheet Dulu
        Navigator.pop(context);

        // 3. Tunggu sebentar (300ms) agar sheet tertutup sempurna
        await Future.delayed(const Duration(milliseconds: 300));

        // 4. Baru Tampilkan SnackBar di Halaman Utama (Parent)
        if (mounted) {
          // Cek mounted lagi karena context berubah
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email berhasil diubah'),
              backgroundColor: Color(0xFF8D07C6),
            ),
          );
        }
      } else {
        // JIKA GAGAL: Tampilkan teks merah di dalam sheet (Bukan SnackBar)
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal mengubah email';
        });
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
            style: const TextStyle(color: Color(0xFF757575)),
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

          // --- TAMPILKAN ERROR DI SINI ---
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // -------------------------------
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleChangeEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8D07C6),
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

// --- PERBAIKAN 2: Change Password Form (Dengan Error Text & Delayed SnackBar) ---
class _ChangePasswordForm extends StatefulWidget {
  const _ChangePasswordForm({super.key}); // Tambahkan key

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
  String? _errorMessage; // Variabel error
  String? _newPassHint;
  Color? _newPassColor;
  String? _confirmPassHint;
  Color? _confirmPassColor;

  @override
  void initState() {
    super.initState();
    _newPassController.addListener(_validateNewPassword);
    _confirmPassController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _validateNewPassword() {
    final text = _newPassController.text;
    setState(() {
      if (text.isEmpty) {
        _newPassHint = null;
        _newPassColor = null;
      } else if (text.length < 6) {
        _newPassHint = 'Minimal 6 karakter';
        _newPassColor = _kErrorColor;
      } else {
        _newPassHint = 'Password kuat';
        _newPassColor = Colors.green;
      }
    });
    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    final confirm = _confirmPassController.text;
    final newPass = _newPassController.text;
    setState(() {
      if (confirm.isEmpty) {
        _confirmPassHint = null;
        _confirmPassColor = null;
      } else if (confirm == newPass) {
        _confirmPassHint = 'Password cocok';
        _confirmPassColor = Colors.green;
      } else {
        _confirmPassHint = 'Password tidak cocok';
        _confirmPassColor = _kErrorColor;
      }
    });
  }

  Future<void> _handleChangePassword() async {
    setState(() => _errorMessage = null);
    FocusScope.of(context).unfocus();

    if (_oldPassController.text.isEmpty) {
      setState(() => _errorMessage = 'Password lama tidak boleh kosong');
      return;
    }

    if (_newPassController.text.isEmpty) {
      setState(() => _errorMessage = 'Password baru tidak boleh kosong');
      return;
    }

    if (_newPassController.text != _confirmPassController.text) {
      setState(() => _errorMessage = 'Password baru tidak cocok');
      return;
    }

    if (_newPassController.text.length < 6) {
      setState(() => _errorMessage = 'Password minimal 6 karakter');
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
        // SUKSES: Tutup dulu, baru SnackBar
        Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password berhasil diubah'),
              backgroundColor: Color(0xFF8D07C6),
            ),
          );
        }
      } else {
        // GAGAL: Tampilkan text merah di sheet
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal mengubah password';
        });
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
            helperText: _newPassHint,
            helperColor: _newPassColor,
          ),
          const SizedBox(height: 16),
          _buildPassField(
            'Ulangi Password Baru',
            _confirmPassController,
            _obscureConfirm,
            () => setState(() => _obscureConfirm = !_obscureConfirm),
            helperText: _confirmPassHint,
            helperColor: _confirmPassColor,
          ),

          // --- TAMPILKAN ERROR DI SINI ---
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // -------------------------------
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleChangePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8D07C6),
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

  // ... (Widget _buildPassField tetap sama) ...
  Widget _buildPassField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle,
    {String? helperText, Color? helperColor}
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
        helperText: helperText,
        helperStyle: helperColor != null
            ? TextStyle(color: helperColor, fontSize: 12)
            : null,
      ),
    );
  }
}
