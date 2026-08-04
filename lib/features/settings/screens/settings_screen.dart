import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive_util.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_loading_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authRepo = AuthRepository();
  bool _loading = false;
  String? _displayName;
  String? _pseudonym;
  String? _role;
  bool _isAnonymous = true;
  String? _linkedEmail;
  String? _photoBase64;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _pickAndSavePhoto() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _loading = true);
    try {
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
        if (compressed == null) throw 'Compression failed';
        imageBytes = compressed;
      }

      final base64Thumb = base64Encode(imageBytes);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({'photoBase64Thumb': base64Thumb});

      if (mounted) {
        setState(() => _photoBase64 = base64Thumb);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated'), backgroundColor: AppColors.sage500),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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

    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({'photoBase64Thumb': FieldValue.delete()});

      if (mounted) {
        setState(() => _photoBase64 = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _isAnonymous = user.isAnonymous;
      _linkedEmail = user.email;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .get();
      if (mounted && doc.exists) {
        final d = doc.data()!;
        setState(() {
          _displayName = d['displayName'] as String?;
          _pseudonym = d['pseudonym'] as String?;
          _role = d['role'] as String?;
          _photoBase64 = d['photoBase64Thumb'] as String?;
        });
      }
    } catch (_) {
      // Ignore network errors on initial settings load
    }
  }

  Future<void> _editDisplayName() async {
    final controller = TextEditingController(text: _displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit Profile Name', style: TextStyle(fontSize: context.rf(18))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(fontSize: context.rf(16)),
                decoration: InputDecoration(
                  hintText: 'Enter your real profile name',
                  hintStyle: TextStyle(fontSize: context.rf(14)),
                  border: const OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
              SizedBox(height: context.rs(8)),
              Text(
                'This is the name shown on your profile and to staff as appropriate.',
                style: TextStyle(fontSize: context.rf(12), color: AppColors.gray500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(fontSize: context.rf(14))),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text('Save', style: TextStyle(fontSize: context.rf(14))),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName != _displayName) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      setState(() => _loading = true);
      try {
        await FirebaseFirestore.instance
            .collection(FirestorePaths.users)
            .doc(uid)
            .update({'displayName': newName});
        await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
        if (mounted) {
          setState(() => _displayName = newName);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile Name updated successfully'),
                backgroundColor: AppColors.sage500),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  Future<void> _editPseudonym() async {
    final controller = TextEditingController(text: _pseudonym);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit Chat Pseudonym', style: TextStyle(fontSize: context.rf(18))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: TextStyle(fontSize: context.rf(16)),
                decoration: InputDecoration(
                  hintText: 'Enter your new name or pseudonym',
                  hintStyle: TextStyle(fontSize: context.rf(14)),
                  border: const OutlineInputBorder(),
                ),
                maxLength: 30,
              ),
              SizedBox(height: context.rs(8)),
              Text(
                'This is the anonymous alias shown in peer-support contexts.',
                style: TextStyle(fontSize: context.rf(12), color: AppColors.gray500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(fontSize: context.rf(14))),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text('Save', style: TextStyle(fontSize: context.rf(14))),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName != _pseudonym) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      setState(() => _loading = true);
      try {
        await FirebaseFirestore.instance
            .collection(FirestorePaths.users)
            .doc(uid)
            .update({'pseudonym': newName});
        if (mounted) {
          setState(() => _pseudonym = newName);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Name updated successfully'),
                backgroundColor: AppColors.sage500),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  Future<void> _signOut() async {
    await _authRepo.signOut();
    if (mounted) context.go('/welcome');
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded,
            color: AppColors.red500, size: context.rs(36)),
        title: Text('Delete Account?', style: TextStyle(fontSize: context.rf(20))),
        content: Text(
          'This will permanently delete your login access and personal profile.\n\n'
          'Mood history will be removed. Chat transcripts and screening records will be anonymised '
          'and retained for auditing and safety purposes. This cannot be undone.',
          style: TextStyle(fontSize: context.rf(14)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text('Cancel', style: TextStyle(fontSize: context.rf(14)))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () => Navigator.pop(c, true),
            child: Text('Delete My Account', style: TextStyle(fontSize: context.rf(14))),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;

      // Clean up personal Firestore data
      final batch = FirebaseFirestore.instance.batch();

      // 1. Delete notifications
      final notifs = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection('notifications')
          .get();
      for (final doc in notifs.docs) {
        batch.delete(doc.reference);
      }

      // 2. Delete mood history
      final moods = await FirebaseFirestore.instance
          .collection(FirestorePaths.moodEntries)
          .where('studentUid', isEqualTo: uid)
          .get();
      for (final doc in moods.docs) {
        batch.delete(doc.reference);
      }

      // 2. Delete user profile document
      batch.delete(
          FirebaseFirestore.instance.collection(FirestorePaths.users).doc(uid));

      await batch.commit();

      // 3. Delete Auth record
      await user.delete();

      if (mounted) context.go('/welcome');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showChatAlias = _role == 'student' && !_isAnonymous;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontSize: context.rf(17))),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: EdgeInsets.all(context.rs(16)),
            children: [
              // User card
              Container(
                padding: EdgeInsets.all(context.rs(16)),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(context.rs(16)),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickAndSavePhoto,
                      child: Stack(
                        children: [
                          AppAvatar(
                            name: _displayName ?? _pseudonym ?? 'Unknown',
                            photoBase64: _photoBase64,
                            radius: context.rs(32),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _photoBase64 == null ? _pickAndSavePhoto : _removePhoto,
                              child: Container(
                                padding: EdgeInsets.all(context.rs(4)),
                                decoration: BoxDecoration(
                                  color: _photoBase64 == null ? AppColors.blue500 : AppColors.red500,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  _photoBase64 == null ? Icons.add_a_photo_rounded : Icons.delete_rounded,
                                  size: context.rs(12),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.rs(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(_displayName ?? 'Loading...',
                                      style: GoogleFonts.dmSerifDisplay(
                                          fontSize: context.rf(22),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                                ),
                              ),
                              SizedBox(width: context.rs(4)),
                              if (_displayName != null)
                                IconButton(
                                  onPressed: _editDisplayName,
                                  icon: Icon(Icons.edit_rounded,
                                      size: context.rs(18), color: AppColors.blue500),
                                  tooltip: 'Edit Profile Name',
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (showChatAlias) ...[
                            Row(
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text('Alias: ${_pseudonym ?? "Loading..."}',
                                        style: GoogleFonts.outfit(
                                            fontSize: context.rf(14),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant)),
                                  ),
                                ),
                                SizedBox(width: context.rs(4)),
                                if (_pseudonym != null)
                                  IconButton(
                                    onPressed: _editPseudonym,
                                    icon: Icon(Icons.edit_rounded,
                                        size: context.rs(16), color: AppColors.gray500),
                                    tooltip: 'Edit Chat Pseudonym',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          Row(children: [
                            if (!_isAnonymous)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: context.rs(8), vertical: context.rs(2)),
                                decoration: BoxDecoration(
                                  color: AppColors.blue50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(_role ?? 'student',
                                    style: TextStyle(
                                        color: AppColors.blue500,
                                        fontSize: context.rf(11),
                                        fontWeight: FontWeight.w700)),
                              ),
                            if (_isAnonymous) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: context.rs(8), vertical: context.rs(2)),
                                decoration: BoxDecoration(
                                    color: AppColors.riskYellowBg,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text('Anonymous',
                                    style: TextStyle(
                                        color: AppColors.riskYellowFg,
                                        fontSize: context.rf(11),
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.rs(24)),

              // Account security section
              Text('Account Security',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: context.rf(18),
                      color: Theme.of(context).colorScheme.onSurface)),
              SizedBox(height: context.rs(12)),

              if (_isAnonymous) ...[
                Container(
                  padding: EdgeInsets.all(context.rs(14)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.riskYellowBgDark
                        : AppColors.amber50,
                    borderRadius: BorderRadius.circular(context.rs(12)),
                    border: Border.all(color: AppColors.amber100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.riskYellowFg, size: context.rs(20)),
                      SizedBox(width: context.rs(10)),
                      Expanded(
                          child: Text(
                        'You are using MindCare anonymously. To keep access across devices or after reinstalling, please sign out and create a regular account from the welcome screen.',
                        style: TextStyle(
                            color: AppColors.riskYellowFg,
                            fontSize: context.rf(13),
                            height: 1.5),
                      )),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(context.rs(14)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.riskGreenBgDark
                        : AppColors.sage50,
                    borderRadius: BorderRadius.circular(context.rs(12)),
                    border: Border.all(color: AppColors.sage100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.riskGreenFg, size: context.rs(20)),
                      SizedBox(width: context.rs(10)),
                      Expanded(
                          child: Text(
                        'Account secured · ${_linkedEmail ?? ""}',
                        style: TextStyle(
                            color: AppColors.riskGreenFg,
                            fontSize: context.rf(14),
                            fontWeight: FontWeight.w600),
                      )),
                    ],
                  ),
                ),
              ],

              SizedBox(height: context.rs(24)),

              // Navigation links
              AppSurface(
                padding: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderColor: AppColors.gray200,
                child: Column(
                  children: [
                    _SettingsTile(
                        icon: Icons.history_rounded,
                        label: 'Support & Chat History',
                        onTap: () => context.push('/chat-history')),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () => context.push('/privacy')),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & FAQ',
                        onTap: () => context.push('/help')),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'About MindCare@DIU',
                        onTap: () => context.push('/about')),
                  ],
                ),
              ),

              SizedBox(height: context.rs(24)),

              // Theme toggle
              Consumer(builder: (context, ref, _) {
                final mode = ref.watch(themeModeProvider);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(context.rs(16), context.rs(12), context.rs(16), context.rs(6)),
                      child: Text('APPEARANCE',
                          style: TextStyle(
                            fontSize: context.rf(11),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                    ),
                    ListTile(
                      leading: Icon(Icons.brightness_6_outlined, size: context.rs(22)),
                      title: Text('Theme', style: TextStyle(fontSize: context.rf(16))),
                      subtitle: Text(mode == ThemeMode.system
                          ? 'System default'
                          : mode == ThemeMode.dark
                              ? 'Dark'
                              : 'Light',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: context.rf(14))),
                      trailing: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: context.rs(160)),
                        child: SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment(
                                value: ThemeMode.light,
                                icon: Icon(Icons.light_mode_outlined, size: context.rs(14))),
                            ButtonSegment(
                                value: ThemeMode.system,
                                icon: Icon(Icons.brightness_auto, size: context.rs(14))),
                            ButtonSegment(
                                value: ThemeMode.dark,
                                icon: Icon(Icons.dark_mode_outlined, size: context.rs(14))),
                          ],
                          selected: {mode},
                          onSelectionChanged: (val) => ref
                              .read(themeModeProvider.notifier)
                              .state = val.first,
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: WidgetStateProperty.all(EdgeInsets.zero),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              SizedBox(height: context.rs(16)),

              // Sign out
              OutlinedButton.icon(
                onPressed: _loading ? null : _signOut,
                icon: Icon(Icons.logout_rounded, size: context.rs(20)),
                label: Text('Sign Out', style: TextStyle(fontSize: context.rf(16))),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gray500,
                  side: const BorderSide(color: AppColors.gray500),
                  minimumSize: Size(double.infinity, context.rs(50)),
                ),
              ),
              SizedBox(height: context.rs(16)),
              AppSurface(
                padding: EdgeInsets.symmetric(vertical: context.rs(8)),
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(context.rs(8)),
                    decoration: BoxDecoration(
                        color: AppColors.red50,
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.delete_forever_outlined,
                        color: AppColors.red500, size: context.rs(24)),
                  ),
                  title: Text('Delete Account',
                      style: TextStyle(
                          fontSize: context.rf(16),
                          color: AppColors.red500,
                          fontWeight: FontWeight.w600)),
                  trailing: _loading
                      ? SizedBox(
                          width: context.rs(20),
                          height: context.rs(20),
                          child: AppLoadingState(itemCount: 1, height: context.rs(20)))
                      : Icon(Icons.chevron_right_rounded, size: context.rs(20)),
                  onTap: _loading ? null : _deleteAccount,
                ),
              ),
              SizedBox(height: context.rs(32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.gray700, size: 21),
      title: Text(label,
          style: TextStyle(
              fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.gray400, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minVerticalPadding: 0,
    );
  }
}
