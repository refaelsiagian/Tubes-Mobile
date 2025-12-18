import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; 
import '../../data/services/auth_service.dart';

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

  // Kita butuh URL gambar lama biar kalau user gak ganti foto, 
  // fotonya gak hilang/kosong
  final String? initialAvatarUrl;
  final String? initialBannerUrl;

  const EditProfilePage({
    super.key,
    this.initialName = '',
    this.initialUsername = '',
    this.initialBio = '',
    this.initialEmail = '',
    this.initialAvatarUrl,
    this.initialBannerUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  Timer? _usernameDebounce;
  bool? _usernameAvailable;
  String? _usernameMessage;
  late String _initialUsernamePlain;

  // File untuk menampung hasil pick & crop
  File? _pickedBanner;
  File? _pickedProfile;
  
  bool _isLoading = false; // Loading state saat upload

  // Asset Default
  final String _defaultBannerAsset = 'assets/images/banner_default.jpg';
  final String _defaultAvatarAsset = 'assets/images/ava_default.jpg';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    // Hapus @ kalau ada, biar user edit username murni
    String cleanUsername = widget.initialUsername.startsWith('@')
        ? widget.initialUsername.substring(1)
        : widget.initialUsername;
    _usernameController = TextEditingController(text: cleanUsername);
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // === LOGIC 1: AMBIL FOTO DARI GALERI ===
  Future<void> _pickImage({required bool isProfile}) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Kompres sedikit biar ringan uploadnya
    );

    if (pickedFile == null) return;

    // Lanjut ke proses Crop
    await _cropImage(File(pickedFile.path), isProfile);
  }

  // === LOGIC 2: POTONG GAMBAR (CROP) ===
  Future<void> _cropImage(File imageFile, bool isProfile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      // PENTING: Rasio Profile 1:1 (Kotak), Banner 16:9 (Persegi Panjang)
      aspectRatio: isProfile
          ? const CropAspectRatio(ratioX: 1, ratioY: 1)
          : const CropAspectRatio(ratioX: 16, ratioY: 9),
      
      // Setting Tampilan Cropper biar warna Ungu
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isProfile ? 'Potong Foto Profil' : 'Potong Sampul',
          toolbarColor: _kPurpleColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: isProfile
              ? CropAspectRatioPreset.square
              : CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true, // Kunci rasio biar user gak asal crop
        ),
        IOSUiSettings(
          title: isProfile ? 'Potong Foto Profil' : 'Potong Sampul',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        if (isProfile) {
          _pickedProfile = File(croppedFile.path);
        } else {
          _pickedBanner = File(croppedFile.path);
        }
      });
    }
  }

  // === LOGIC 3: SIMPAN KE DATABASE ===
  Future<void> _savePublicProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true); // Mulai Loading

    try {
      final authService = AuthService();
      
      // Panggil fungsi updateProfile yang sudah kita buat di AuthService
      final result = await authService.updateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        avatar: _pickedProfile, // Kirim file avatar (kalau ada)
        banner: _pickedBanner,  // Kirim file banner (kalau ada)
      );

      setState(() => _isLoading = false); // Stop Loading

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: _kPurpleColor,
            ),
          );

          // Kembalikan data baru ke ProfilePage biar UI langsung update
          // Tanpa perlu refresh manual
          final newData = result['data'];
          Navigator.pop(context, {
            'name': newData['name'],
            'username': newData['username'],
            'bio': newData['bio'],
            'id': newData['id'],
            'profilePath': newData['avatar_url'], 
            'bannerPath': newData['banner_url'],
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal update profil'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // === HELPER: MENENTUKAN GAMBAR MANA YANG DITAMPILKAN ===
  ImageProvider _getImageProvider(File? pickedFile, String? url, String assetDefault) {
    if (pickedFile != null) {
      return FileImage(pickedFile); // 1. Prioritas: Gambar yang baru dipilih
    }
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url); // 2. Prioritas: Gambar dari URL Database
    }
    return AssetImage(assetDefault); // 3. Fallback: Gambar default asset
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
          // Ganti tombol teks dengan Loading Indicator kalau sedang upload
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(color: _kPurpleColor, strokeWidth: 2),
                  ),
                )
              : TextButton(
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
            _buildImageEditorSection(), // Bagian Banner & Avatar

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
                    hint: 'Username unik',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Bio',
                    controller: _bioController,
                    maxLines: 4,
                    hint: 'Ceritakan sedikit tentang dirimu...',
                  ),
                  const SizedBox(height: 16),
                  // Email Read Only
                  _buildTextField(
                    label: 'Email',
                    controller: TextEditingController(text: widget.initialEmail),
                    readOnly: true,
                    hint: 'Email kamu',
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _usernameAvailable = null;
        _usernameMessage = null;
      });
      return;
    }

    if (trimmed == _initialUsernamePlain) {
      setState(() {
        _usernameAvailable = true;
        _usernameMessage = 'Username tetap digunakan';
      });
      return;
    }

    _usernameDebounce = Timer(const Duration(milliseconds: 500), () async {
      final available = await AuthService().checkUsername(trimmed);
      if (!mounted) return;
      setState(() {
        _usernameAvailable = available;
        _usernameMessage =
            available ? 'Username tersedia' : 'Username sudah dipakai';
      });
    });
  }

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
          // === BANNER IMAGE ===
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: GestureDetector(
              onTap: () => _pickImage(isProfile: false), // Klik banner untuk ganti
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: DecorationImage(
                    image: _getImageProvider(
                      _pickedBanner, 
                      widget.initialBannerUrl, 
                      _defaultBannerAsset
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // === PROFILE AVATAR ===
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
                    backgroundColor: Colors.grey.shade300,
                    // Tampilkan gambar dengan logika prioritas
                    backgroundImage: _getImageProvider(
                      _pickedProfile, 
                      widget.initialAvatarUrl, 
                      _defaultAvatarAsset
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _pickImage(isProfile: true), // Klik ikon edit profile
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
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    String? helperText,
    Color? helperColor,
    Widget? suffixIcon,
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
          readOnly: readOnly,
          onChanged: onChanged,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: readOnly ? _kSubTextColor : _kTextColor,
            fontSize: 14.0,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixStyle: const TextStyle(
              color: _kSubTextColor,
              fontWeight: FontWeight.bold,
            ),
            suffixIcon: suffixIcon,
            helperText: helperText,
            helperStyle: helperColor != null
                ? TextStyle(color: helperColor, fontSize: 12)
                : null,
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : _kBackgroundColor,
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
}