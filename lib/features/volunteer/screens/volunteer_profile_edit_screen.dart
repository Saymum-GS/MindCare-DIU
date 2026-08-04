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

class VolunteerProfileEditScreen extends StatefulWidget {
  const VolunteerProfileEditScreen({super.key});

  @override
  State<VolunteerProfileEditScreen> createState() =>
      _VolunteerProfileEditScreenState();
}

class _VolunteerProfileEditScreenState
    extends State<VolunteerProfileEditScreen> {
  final _deptController = TextEditingController();
  final _yearController = TextEditingController();
  final _whyController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _campusController = TextEditingController();
  final _badgeController = TextEditingController();
  final _languagesController = TextEditingController();
  final _topicsController = TextEditingController();
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
        _displayNameController.text = data['displayName'] ?? '';
        _deptController.text = data['department'] ?? '';
        _yearController.text = data['academicYear'] ?? '';
        _whyController.text = data['whyIVolunteer'] ?? '';
        _campusController.text = data['campus'] ?? 'Daffodil Smart City (DSC)';
        _badgeController.text = data['badgeLevel'] ?? 'Certified DIU Peer Listener';
        _languagesController.text = (data['languagesSpoken'] as List?)?.join(', ') ?? 'Bengali, English';
        _topicsController.text = (data['supportTopics'] as List?)?.join(', ') ?? 'Academic Stress, Campus Life, Time Management';
        _emergencyNameController.text = data['emergencyContactName'] ?? '';
        _emergencyPhoneController.text = data['emergencyContactPhone'] ?? '';
        _photoBase64 = data['photoBase64Thumb'] as String?;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final langs = _languagesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final topics = _topicsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({
        'displayName': _displayNameController.text.trim(),
        'department': _deptController.text.trim(),
        'academicYear': _yearController.text.trim(),
        'whyIVolunteer': _whyController.text.trim(),
        'campus': _campusController.text.trim(),
        'languagesSpoken': langs,
        'supportTopics': topics,
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
        minWidth: 80,
        minHeight: 80,
        quality: 75,
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
                padding: EdgeInsets.all(context.rs(20)),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _displayNameController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        hintText: 'Your name shown to students',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _deptController,
                            style: TextStyle(fontSize: context.rf(15)),
                            decoration: InputDecoration(
                              labelText: 'Department',
                              hintText: 'e.g. CSE',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                            controller: _yearController,
                            style: TextStyle(fontSize: context.rf(15)),
                            decoration: InputDecoration(
                              labelText: 'Academic Year',
                              hintText: 'e.g. 3rd Year',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                      controller: _campusController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'DIU Campus',
                        hintText: 'e.g. Daffodil Smart City (DSC)',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _badgeController,
                      readOnly: true,
                      style: TextStyle(fontSize: context.rf(15), color: AppColors.blue500, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Volunteer Badge Level (Verified & Assigned)',
                        helperText: 'Assigned officially by DIU Counseling Administration',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _languagesController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Languages Spoken (comma-separated)',
                        hintText: 'e.g. Bengali, English',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _topicsController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Support Topics (comma-separated)',
                        hintText: 'e.g. Academic Stress, Dorm Life, Career Anxiety',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _whyController,
                      maxLines: 4,
                      maxLength: 400,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Why I Volunteer / Bio',
                        hintText: 'Tell students a bit about your motivation to help.',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('🚨 PERSONAL EMERGENCY GUARDIAN', style: TextStyle(color: AppColors.red500, fontSize: context.rf(12), fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emergencyNameController,
                      style: TextStyle(fontSize: context.rf(15)),
                      decoration: InputDecoration(
                        labelText: 'Trusted Guardian Name',
                        hintText: 'e.g. Father / Mother / Sibling Name',
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: FilledButton.styleFrom(minimumSize: Size(0, context.rs(56))),
                  child: _isSaving
                      ? SizedBox(
                          height: context.rs(20),
                          width: context.rs(20),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Save Changes', style: TextStyle(fontSize: context.rf(16), fontWeight: FontWeight.bold)),
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
