import 'package:flutter/material.dart';

// Konstanta Warna
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Color(0xFFF9F9F9);
const Color _kSubTextColor = Color(0xFF757575);
const Color _kErrorColor = Color(0xFFE53935);

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialUsername;
  final String initialBio;
  final String initialEmail;

  const EditProfilePage({
    super.key,
    this.initialName = '',
    this.initialUsername = '',
    this.initialBio = '',
    this.initialEmail = '',
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  // Email tidak diedit langsung di textfield, jadi kita simpan stringnya saja
  late String _currentEmail;

  final String _bannerImage = 'assets/images/banner.jpg';
  final String? _profileImage = null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _usernameController = TextEditingController(text: widget.initialUsername);
    _bioController = TextEditingController(text: widget.initialBio);
    _currentEmail = widget.initialEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _savePublicProfile() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'username': _usernameController.text.trim(),
      'bio': _bioController.text.trim(),
      // Email dan password ditangani terpisah, tidak dikirim balik lewat sini
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil publik diperbarui'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // --- LOGIC: UBAH PASSWORD (BOTTOM SHEET) ---
  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Supaya bisa naik kalau keyboard muncul
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ChangePasswordForm(),
    );
  }

  // --- LOGIC: UBAH EMAIL (BOTTOM SHEET) ---
  void _showChangeEmailSheet() {
    // Implementasi serupa dengan password, butuh verifikasi pass lama
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ChangeEmailForm(currentEmail: _currentEmail),
    );
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
          icon: const Icon(Icons.close, color: _kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: _kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _savePublicProfile,
            child: const Text(
              'Selesai',
              style: TextStyle(
                color: _kPurpleColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildImageEditorSection(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('Info Publik'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Nama',
                    controller: _nameController,
                    hint: 'Nama lengkap kamu',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Username',
                    controller: _usernameController,
                    prefix: '@',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Bio',
                    controller: _bioController,
                    maxLines: 4,
                    hint: 'Ceritakan sedikit tentang dirimu...',
                  ),

                  const SizedBox(height: 32),
                  const Divider(thickness: 1, color: _kBackgroundColor),
                  const SizedBox(height: 24),

                  _buildSectionLabel('Informasi Akun'),
                  const SizedBox(height: 4),
                  const Text(
                    'Detail pribadi ini tidak ditampilkan di profil publik.',
                    style: TextStyle(fontSize: 12, color: _kSubTextColor),
                  ),
                  const SizedBox(height: 16),

                  // Menu Ubah Email
                  _buildSecurityActionTile(
                    title: 'Email Address',
                    value: _currentEmail,
                    icon: Icons.email_outlined,
                    onTap: _showChangeEmailSheet,
                  ),

                  const SizedBox(height: 12),

                  // Menu Ubah Password
                  _buildSecurityActionTile(
                    title: 'Password',
                    value: '••••••••', // Masking
                    icon: Icons.lock_outline_rounded,
                    onTap: _showChangePasswordSheet,
                    isDestructive: false,
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _kTextColor,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildImageEditorSection() {
    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Banner Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: DecorationImage(
                  image: AssetImage(_bannerImage),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: IconButton(
                  onPressed: () {}, // TODO: Banner picker
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black45,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
              ),
            ),
          ),

          // Profile Avatar
          Positioned(
            bottom: 0,
            left: 20,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade300, // Warna Abu
                    backgroundImage: _profileImage != null
                        ? NetworkImage(_profileImage!)
                        : null,
                    // PERBAIKAN: Ganti Inisial Text dengan Icon Person
                    child: _profileImage == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 45,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {}, // TODO: Avatar picker
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _kPurpleColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? prefix,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _kSubTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: _kTextColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixStyle: const TextStyle(
              color: _kSubTextColor,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: _kBackgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kPurpleColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityActionTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
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
                color: isDestructive
                    ? _kErrorColor.withOpacity(0.1)
                    : _kPurpleColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? _kErrorColor : _kPurpleColor,
                size: 20,
              ),
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

// --- CLASS TERPISAH: Form Ubah Password ---
class _ChangePasswordForm extends StatefulWidget {
  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    // Menggunakan Padding bottom mengikuti keyboard
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
              onPressed: () {
                // TODO: Validasi password lama & simpan
                if (_newPassController.text != _confirmPassController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password baru tidak cocok')),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password berhasil diubah')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kTextColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Simpan Password Baru'),
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

// --- CLASS TERPISAH: Form Ubah Email ---
class _ChangeEmailForm extends StatelessWidget {
  final String currentEmail;
  _ChangeEmailForm({required this.currentEmail});

  final _passwordController = TextEditingController();
  final _newEmailController = TextEditingController();

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
          const Text(
            'Ubah Email',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Email saat ini: $currentEmail',
            style: TextStyle(color: Colors.grey[600]),
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
              onPressed: () {
                // TODO: Logic ubah email
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kTextColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Simpan Email Baru'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}