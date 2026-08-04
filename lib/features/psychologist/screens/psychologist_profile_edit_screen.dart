import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_util.dart';

import '../../../shared/widgets/app_surface.dart';

class PsychologistProfileEditScreen extends StatefulWidget {
  const PsychologistProfileEditScreen({super.key});

  @override
  State<PsychologistProfileEditScreen> createState() =>
      _PsychologistProfileEditScreenState();
}

class _PsychologistProfileEditScreenState
    extends State<PsychologistProfileEditScreen> {
  final _bioController = TextEditingController();
  final _titleController = TextEditingController();
  final _feeController = TextEditingController();
  final _eduController = TextEditingController();
  final _expController = TextEditingController();
  final _licenseController = TextEditingController();
  final _langController = TextEditingController();
  final _officeController = TextEditingController();
  final _approachesController = TextEditingController();
  final _hoursController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  bool _isSaving = false;
  String? _photoBase64;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(uid)
        .get();
    if (mounted) {
      setState(() {
        final data = doc.data() ?? {};
        _bioController.text = data['bio'] ?? '';
        _titleController.text = data['title'] ?? '';
        _feeController.text = (data['sessionFeeExternal'] ?? 0).toString();
        _eduController.text = data['education'] ?? '';
        _expController.text = (data['experienceYears'] ?? '').toString();
        _licenseController.text = data['licenseNumber'] ?? '';
        _langController.text = (data['consultationLanguages'] as List?)?.join(', ') ?? 'English, Bengali';
        _officeController.text = data['officeLocation'] ?? 'DSC Campus Counseling Center, Room 302';
        _approachesController.text = (data['therapeuticApproaches'] as List?)?.join(', ') ?? 'CBT, Mindfulness, Person-Centered Therapy';
        _hoursController.text = data['consultingHours'] ?? 'Sun - Thu, 10:00 AM - 4:00 PM';
        _emergencyNameController.text = data['emergencyContactName'] ?? '';
        _emergencyPhoneController.text = data['emergencyContactPhone'] ?? '';
        _photoBase64 = data['photoBase64Thumb'] as String?;
      });
    }
  }

  Future<void> _pickAndSavePhoto() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    Uint8List imageBytes;
    if (kIsWeb) {
      imageBytes = await file.readAsBytes();
    } else {
      final compressed = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 120,
        minHeight: 120,
        quality: 70,
        keepExif: false,
      );
      if (compressed == null) return;
      imageBytes = compressed;
    }

    final base64Thumb = base64Encode(imageBytes);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({'photoBase64Thumb': base64Thumb});

      setState(() => _photoBase64 = base64Thumb);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile photo updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo: $e')),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove Photo?', style: TextStyle(fontSize: context.rf(18))),
        content: const Text('Are you sure you want to remove your profile photo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({'photoBase64Thumb': FieldValue.delete()});

      setState(() => _photoBase64 = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo removed.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final langs = _langController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final approaches = _approachesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({
        'bio': _bioController.text.trim(),
        'title': _titleController.text.trim(),
        'sessionFeeExternal': int.tryParse(_feeController.text.trim()) ?? 0,
        'education': _eduController.text.trim(),
        'experienceYears': int.tryParse(_expController.text.trim()) ?? 0,
        'licenseNumber': _licenseController.text.trim(),
        'consultationLanguages': langs,
        'officeLocation': _officeController.text.trim(),
        'therapeuticApproaches': approaches,
        'consultingHours': _hoursController.text.trim(),
        'emergencyContactName': _emergencyNameController.text.trim(),
        'emergencyContactPhone': _emergencyPhoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(fontSize: context.rf(17))),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.rs(24)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: context.rs(60),
                      backgroundColor: AppColors.gray200,
                      backgroundImage: _photoBase64 != null
                          ? _getSafeImage(_photoBase64!)
                          : null,
                      child: _photoBase64 == null
                          ? Icon(Icons.person,
                              size: context.rs(60), color: AppColors.gray500)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _photoBase64 == null ? _pickAndSavePhoto : _removePhoto,
                        child: Container(
                          padding: EdgeInsets.all(context.rs(8)),
                          decoration: BoxDecoration(
                            color: _photoBase64 == null ? AppColors.blue500 : AppColors.red500,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(
                            _photoBase64 == null ? Icons.add_a_photo_rounded : Icons.delete_rounded,
                            size: context.rs(18),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_photoBase64 == null)
                TextButton(
                  onPressed: _pickAndSavePhoto,
                  child: Text('Add Profile Photo', style: TextStyle(fontSize: context.rf(14))),
                ),
              SizedBox(height: context.rs(24)),
              AppSurface(
                padding: EdgeInsets.all(context.rs(24)),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Professional Title',
                        hintText: 'e.g. Clinical Psychologist',
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _feeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Fee for External Users (BDT)',
                        hintText: 'e.g. 1500',
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Fee is required';
                        }
                        if (int.tryParse(v) == null) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _eduController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Education / Credentials',
                        hintText: 'e.g. MS in Clinical Psychology, DU',
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: context.rf(15)),
                            decoration: InputDecoration(
                              labelText: 'Experience (Years)',
                              hintText: 'e.g. 5',
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _licenseController,
                            style: TextStyle(fontSize: context.rf(15)),
                            decoration: InputDecoration(
                              labelText: 'License Number',
                              hintText: 'e.g. PSY-12345',
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _langController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Consultation Languages',
                        hintText: 'e.g. English, Bengali',
                        helperText: 'Separate with commas',
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _officeController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'DIU Office Location / Online',
                        hintText: 'e.g. DSC Counseling Center, Room 302, AB-4',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _approachesController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Therapeutic Approaches (comma-separated)',
                        hintText: 'e.g. CBT, Mindfulness, Rogerian Therapy',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hoursController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Consulting Schedule & Hours',
                        hintText: 'e.g. Sun - Thu, 10:00 AM - 4:00 PM',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 5,
                      maxLength: 600,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Bio / About Me',
                        hintText:
                            'Describe your experience, approach, and background.',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().length < 50)
                          ? 'Bio should be at least 50 characters'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text('🚨 PERSONAL EMERGENCY GUARDIAN', style: TextStyle(color: AppColors.red500, fontSize: context.rf(12), fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emergencyNameController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Trusted Guardian Name',
                        hintText: 'e.g. Spouse / Colleague / Relative Name',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emergencyPhoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Emergency Phone Number',
                        hintText: 'e.g. 017xxxxxxxx',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.rs(32)),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: FilledButton.styleFrom(minimumSize: Size(0, context.rs(52))),
                  child: _isSaving
                      ? SizedBox(
                          height: context.rs(20),
                          width: context.rs(20),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Save Profile', style: TextStyle(fontSize: context.rf(16), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _getSafeImage(String base64) {
    try {
      return MemoryImage(base64Decode(base64));
    } catch (_) {
      return const AssetImage('assets/images/default_avatar.png');
    }
  }
}
