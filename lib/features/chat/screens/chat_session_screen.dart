import '../providers/chat_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../shared/models/chat_session_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_util.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/app_loading_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/utils/crisis_detector.dart';

class ChatSessionScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const ChatSessionScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ChatSessionScreen> createState() => _ChatSessionScreenState();
}

class _ChatSessionScreenState extends ConsumerState<ChatSessionScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  late final String _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    // Client-side crisis keyword detection using CrisisDetector
    final detectedKeyword = CrisisDetector.getDetectedKeyword(text);
    final potentialCrisis = detectedKeyword != null;

    setState(() => _isSending = true);

    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.sendMessage(
        sessionId: widget.sessionId,
        text: text,
        senderRole: user.role,
        senderName: user.role == 'student' ? user.pseudonym : user.displayName,
        crisisDetected: potentialCrisis,
        crisisKeyword: detectedKeyword,
      );
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e', style: TextStyle(fontSize: context.rf(13)))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }



  void _showEscalateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded,
            color: AppColors.red500, size: context.rs(32)),
        title: Text('Escalate to Psychologist', style: TextStyle(fontSize: context.rf(18))),
        content: Text(
          'This will immediately alert an on-call psychologist and create a crisis record.\n\nUse this only when you believe the student is in immediate danger.',
          style: TextStyle(fontSize: context.rf(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(fontSize: context.rf(14))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final repository = ref.read(chatRepositoryProvider);
                await repository.escalateManually(widget.sessionId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('✅ Escalated - a psychologist has been alerted.'),
                    backgroundColor: AppColors.red500,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text('Escalate Now', style: TextStyle(fontSize: context.rf(14))),
          ),
        ],
      ),
    );
  }

  void _showEmergencyProtocolDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.crisis_alert_rounded,
            color: AppColors.red500, size: context.rs(32)),
        title: Text('Initiate Emergency Protocol', style: TextStyle(fontSize: context.rf(18))),
        content: Text(
          'This will immediately trigger a high-priority clinical emergency incident for Campus Security & Administration response.\n\nUse this when immediate self-harm or suicide intervention is required.',
          style: TextStyle(fontSize: context.rf(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(fontSize: context.rf(14))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final repository = ref.read(chatRepositoryProvider);
                await repository.triggerClinicalEmergency(widget.sessionId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('🚨 Emergency Protocol Triggered - Campus administration alerted.'),
                    backgroundColor: AppColors.red500,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text('Trigger Emergency', style: TextStyle(fontSize: context.rf(14))),
          ),
        ],
      ),
    );
  }



  Future<void> _endSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End Session?', style: TextStyle(fontSize: context.rf(18))),
        content: Text('Are you sure you want to end this chat session?', style: TextStyle(fontSize: context.rf(14))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(fontSize: context.rf(14))),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red500),
            child: Text('End Chat', style: TextStyle(fontSize: context.rf(14))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repository = ref.read(chatRepositoryProvider);
      await repository.endSession(widget.sessionId);
    }
  }

  Future<void> _deleteSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.delete_forever_rounded,
            color: AppColors.red500, size: context.rs(32)),
        title: Text('Delete Chat for Everyone?', style: TextStyle(fontSize: context.rf(18))),
        content: Text(
          'This will permanently delete the chat history for both you and the other person.\n\nThis action cannot be undone.',
          style: TextStyle(fontSize: context.rf(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(fontSize: context.rf(14))),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red500),
            child: Text('Delete Chat', style: TextStyle(fontSize: context.rf(14))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repository = ref.read(chatRepositoryProvider);
      await repository.deleteSessionForEveryone(widget.sessionId);
      if (mounted) {
        final user = ref.read(currentUserProvider).valueOrNull;
        if (user?.role == 'volunteer') {
          context.go('/volunteer');
        } else if (user?.role == 'psychologist') {
          context.go('/psychologist/home');
        } else if (user?.role == 'admin') {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      }
    }
  }

  Future<void> _revealIdentity() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reveal Identity?', style: TextStyle(fontSize: context.rf(18))),
        content: Text('This will reveal your real name to the other person. Are you sure?', style: TextStyle(fontSize: context.rf(14))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(fontSize: context.rf(14))),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Reveal', style: TextStyle(fontSize: context.rf(14))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestorePaths.chatSessions)
            .doc(widget.sessionId)
            .update({
          'studentPseudonym': user.displayName,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Identity revealed!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _showPeerInfo() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(FirestorePaths.chatSessions).doc(widget.sessionId).get();
      final data = doc.data();
      final volunteerUid = data?['volunteerUid'] as String?;
      if (volunteerUid == null) return;

      final userDoc = await FirebaseFirestore.instance.collection(FirestorePaths.users).doc(volunteerUid).get();
      final userData = userDoc.data();
      if (userData == null) return;

      if (!mounted) return;
      final badge = userData['badgeLevel'] ?? 'Certified DIU Peer Listener';
      final campus = userData['campus'] ?? 'Daffodil Smart City (DSC)';
      final langs = (userData['languagesSpoken'] as List?)?.join(', ') ?? 'Bengali, English';
      final topics = (userData['supportTopics'] as List?)?.join(', ') ?? 'Academic Stress, Campus Life';

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('About your Peer Support', style: TextStyle(fontSize: context.rf(18), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue500.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(badge, style: TextStyle(fontSize: context.rf(12), color: AppColors.blue500, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Name', value: userData['displayName'] ?? 'Volunteer'),
                _InfoRow(label: 'Campus', value: campus),
                _InfoRow(label: 'Dept / Year', value: '${userData['department'] ?? 'CSE'} (${userData['academicYear'] ?? 'DIU'})'),
                _InfoRow(label: 'Languages', value: langs),
                _InfoRow(label: 'Topics', value: topics),
                if (userData['whyIVolunteer'] != null && (userData['whyIVolunteer'] as String).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Motivation:', style: TextStyle(fontSize: context.rf(12), color: AppColors.gray500, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(userData['whyIVolunteer'], style: TextStyle(fontSize: context.rf(13), height: 1.4)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(chatRepositoryProvider);
    final userAsync = ref.watch(currentUserProvider);

    // Deactivation guard for full-screen route
    final user = userAsync.valueOrNull;
    if (user != null && !user.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authRepositoryProvider).signOut();
        if (mounted) context.go('/welcome');
      });
      return const Scaffold(body: Center(child: Text('Account deactivated.', style: TextStyle(color: Colors.red))));
    }

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<ChatSession>(
          stream: repository.watchSession(widget.sessionId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('Chat', style: TextStyle(fontSize: context.rf(17)));
            final session = snapshot.data!;
            final currentUser = userAsync.valueOrNull;
            
            String peerName = 'Chat';
            if (currentUser != null) {
              if (currentUser.role == 'student') {
                if (session.status == 'escalated' || session.crisisEscalated) {
                  peerName = 'Clinical Crisis Support';
                } else if (session.channel == 'psychologist') {
                  peerName = 'Clinical Consultation';
                } else {
                  peerName = 'Peer Support Session';
                }
              } else if (currentUser.role == 'psychologist') {
                final realName = session.studentRealName;
                final diuId = session.studentDiuId;
                if (realName != null && realName.isNotEmpty) {
                  peerName = (diuId != null && diuId.isNotEmpty) ? '$realName ($diuId)' : realName;
                } else {
                  peerName = session.studentPseudonym ?? 'Student';
                }
              } else {
                // If I am a volunteer or admin, the peer is the student
                peerName = session.studentPseudonym ?? 'Student';
              }
            }
            
            return GestureDetector(
              onTap: () {
                if (currentUser?.role == 'student' && session.volunteerUid != null) {
                  _showPeerInfo();
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(peerName, style: TextStyle(fontSize: context.rf(17))),
                  if (session.status == 'active')
                    Text('Active',
                        style:
                            TextStyle(fontSize: context.rf(11), color: AppColors.riskGreenFg))
                  else if (session.status == 'waiting')
                    Text('Waiting for supporter...',
                        style:
                            TextStyle(fontSize: context.rf(11), color: AppColors.riskYellowFg))
                  else if (session.status == 'ended')
                    Text('Ended',
                        style: TextStyle(fontSize: context.rf(11), color: AppColors.red500)),
                ],
              ),
            );
          },
        ),
        actions: [
          StreamBuilder<ChatSession>(
            stream: repository.watchSession(widget.sessionId),
            builder: (context, snapshot) {
              final session = snapshot.data;
              final currentUser = userAsync.valueOrNull;
              if (session?.status == 'active' && currentUser?.role == 'student' && session?.volunteerUid != null) {
                return IconButton(
                  icon: Icon(Icons.info_outline_rounded, size: context.rs(22)),
                  tooltip: 'Volunteer Info',
                  onPressed: _showPeerInfo,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          userAsync.when(
            data: (user) {
              if (user?.role == 'volunteer') {
                return TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.red500),
                  onPressed: () => _showEscalateDialog(context),
                  child: Text('Escalate',
                      style: TextStyle(fontSize: context.rf(14), fontWeight: FontWeight.bold)),
                );
              } else if (user?.role == 'psychologist') {
                return TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.red500),
                  onPressed: () => _showEmergencyProtocolDialog(context),
                  child: Text('Emergency Alert',
                      style: TextStyle(fontSize: context.rf(14), fontWeight: FontWeight.bold)),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, size: context.rs(24)),
            onSelected: (value) {
              if (value == 'end') {
                _endSession();
              } else if (value == 'delete') {
                _deleteSession();
              } else if (value == 'reveal') {
                _revealIdentity();
              }
            },
            itemBuilder: (context) => [
              if (userAsync.valueOrNull?.role == 'student')
                PopupMenuItem(
                  value: 'reveal',
                  child: Row(
                    children: [
                      Icon(Icons.badge_rounded, color: AppColors.blue500, size: context.rs(20)),
                      SizedBox(width: context.rs(8)),
                      Text('Reveal Real Identity',
                          style: TextStyle(fontSize: context.rf(14), color: AppColors.blue500)),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'end',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app_rounded, color: AppColors.gray700, size: context.rs(20)),
                    SizedBox(width: context.rs(8)),
                    Text('End Session', style: TextStyle(fontSize: context.rf(14))),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever_rounded, color: AppColors.red500, size: context.rs(20)),
                    SizedBox(width: context.rs(8)),
                    Text('Delete for Everyone',
                        style: TextStyle(fontSize: context.rf(14), color: AppColors.red500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: repository.watchMessages(widget.sessionId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: context.rf(14))));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: AppLoadingState());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(context.rs(32)),
                      child: StreamBuilder<ChatSession>(
                            stream: repository.watchSession(widget.sessionId),
                            builder: (context, sessionSnapshot) {
                              final channel = sessionSnapshot.data?.channel ?? 'volunteer';
                              final isPsychologist = channel == 'psychologist';
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: context.rs(120)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(context.rs(24)),
                                      child: Image.asset('assets/images/chat_empty.png',
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                                  SizedBox(height: context.rs(24)),
                                  Text(
                                    isPsychologist 
                                        ? 'Your clinical consultation starts here.' 
                                        : 'Your confidential peer support session starts here.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.dmSerifDisplay(
                                        fontSize: context.rf(22),
                                        color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  SizedBox(height: context.rs(8)),
                                  Text(
                                    'This conversation is secure and confidential. Please wait a moment for a supporter to join if they haven\'t already.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.gray500,
                                        fontSize: context.rf(14),
                                        height: 1.5),
                                  ),
                                ],
                              );
                            }
                          ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  padding: EdgeInsets.symmetric(horizontal: context.rs(8)),
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderUid == _myUid;
                    return MessageBubble(
                      message: msg,
                      isMe: isMe,
                      showCrisisAlert: msg.crisisDetected && !isMe,
                      viewerRole: userAsync.valueOrNull?.role ?? '',
                    );
                  },
                );
              },
            ),
          ),
          StreamBuilder<ChatSession>(
            stream: repository.watchSession(widget.sessionId),
            builder: (context, snapshot) {
              final isEnded = snapshot.data?.status == 'ended';
              final isDark = Theme.of(context).brightness == Brightness.dark;

              Widget? endedBanner;
              if (isEnded) {
                final session = snapshot.data!;
                final isStaff = session.volunteerUid == _myUid ||
                    session.psychologistUid == _myUid;

                endedBanner = Container(
                  padding: EdgeInsets.symmetric(vertical: context.rs(16), horizontal: context.rs(16)),
                  color: isDark ? AppColors.darkSurface : AppColors.gray100,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: context.rs(12)),
                        child: Text(
                          'This session has concluded.',
                          style: TextStyle(
                            fontSize: context.rf(15),
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.gray900,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            if (isStaff) {
                              context.push('/summary/${widget.sessionId}');
                            } else {
                              context.push('/rating/${widget.sessionId}');
                            }
                          },
                          icon: Icon(Icons.assignment_rounded, size: context.rs(16)),
                          label: Text(isStaff ? 'Write Summary' : 'Rate Session', style: TextStyle(fontSize: context.rf(12))),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(12))),
                          ),
                        ),
                      ),
                      SizedBox(width: context.rs(8)),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _deleteSession,
                          icon: Icon(Icons.delete_forever_rounded, size: context.rs(16)),
                          label: Text('Delete Chat', style: TextStyle(fontSize: context.rf(12))),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.red500,
                            side: const BorderSide(color: AppColors.red500),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(12))),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ],
                ),
                );
              }

              return Column(
                children: [
                  if (endedBanner != null) endedBanner,
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: context.rs(16), vertical: context.rs(8)),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border(
                      top: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.gray300)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          maxLength: AppConstants.maxMessageLength,
                          maxLines: 4,
                          minLines: 1,
                          style: TextStyle(
                              fontSize: context.rf(15),
                              color: isDark ? Colors.white : AppColors.gray900),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            counterText: '',
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkSurface2
                                : AppColors.blue50,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: context.rs(16), vertical: context.rs(12)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(context.rs(24)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      SizedBox(width: context.rs(8)),
                      CircleAvatar(
                        backgroundColor: AppColors.blue500,
                        radius: context.rs(24),
                        child: IconButton(
                          icon: _isSending
                              ? SizedBox(
                                  width: context.rs(18),
                                  height: context.rs(18),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.send, color: Colors.white, size: context.rs(20)),
                          onPressed: _isSending ? null : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gray500)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

