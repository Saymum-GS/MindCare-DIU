import '../providers/chat_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../shared/models/chat_session_model.dart';
import '../../../core/utils/responsive_util.dart';
import 'package:google_fonts/google_fonts.dart';
// lib/features/chat/screens/chat_request_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_loading_state.dart';

class ChatRequestScreen extends ConsumerStatefulWidget {
  const ChatRequestScreen({super.key});

  @override
  ConsumerState<ChatRequestScreen> createState() => _ChatRequestScreenState();
}

class _ChatRequestScreenState extends ConsumerState<ChatRequestScreen> {
  bool _isRequesting = false;
  String? _sessionId;
  String _selectedChannel = 'volunteer';

  Future<void> _requestChat() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    if (_selectedChannel == 'psychologist' && user.isAnonymous) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Account Required', style: TextStyle(fontSize: context.rf(18))),
          content: Text('Anonymous users cannot request a clinical psychologist. Please sign out and create an account to access clinical support.', style: TextStyle(fontSize: context.rf(14))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK', style: TextStyle(fontSize: context.rf(14))),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isRequesting = true);
    try {
      final repository = ref.read(chatRepositoryProvider);
      final sessionId = await repository.createChatRequest(
        channel: _selectedChannel,
        studentPseudonym: user.pseudonym,
        riskLevel: user.latestRiskLevel ?? 'green',
      );

      setState(() {
        _sessionId = sessionId;
        _isRequesting = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error requesting chat: $e', style: TextStyle(fontSize: context.rf(13)))),
        );
        setState(() => _isRequesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Request Chat',
            style: TextStyle(fontSize: context.rf(17), fontWeight: FontWeight.bold)),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, size: context.rs(22)),
            tooltip: 'My Support History',
            onPressed: () => context.push('/chat-history'),
          ),
          SizedBox(width: context.rs(8)),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _sessionId == null
                ? _buildRequestForm(isDark)
                : _buildWaitingScreen(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestForm(bool isDark) {
    return ListView(
      padding: EdgeInsets.all(context.rs(24)),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: context.rs(180)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.rs(24)),
              child: Image.asset('assets/images/chat_request_hero.png',
                  fit: BoxFit.contain),
            ),
          ),
        ),
        SizedBox(height: context.rs(32)),
        Text(
          'Who would you like to talk to?',
          style: GoogleFonts.dmSerifDisplay(
              fontSize: context.rf(28),
              color: isDark ? Colors.white : AppColors.gray900),
        ),
        SizedBox(height: context.rs(8)),
        Text(
          'Select the type of support that best fits your needs right now.',
          style: TextStyle(
              fontSize: context.rf(16),
              color: isDark ? AppColors.gray400 : AppColors.gray600),
        ),
        SizedBox(height: context.rs(32)),
        _ChannelCard(
          title: 'Peer Support Volunteer',
          description:
              'A trained student volunteer ready to listen and support you.',
          icon: Icons.favorite_rounded,
          isSelected: _selectedChannel == 'volunteer',
          onTap: () => setState(() => _selectedChannel = 'volunteer'),
          isDark: isDark,
        ),
        SizedBox(height: context.rs(16)),
        _ChannelCard(
          title: 'Psychologist',
          description:
              'A licensed mental health professional for clinical support.',
          icon: Icons.psychology_rounded,
          isSelected: _selectedChannel == 'psychologist',
          onTap: () => setState(() => _selectedChannel = 'psychologist'),
          isDark: isDark,
        ),
        SizedBox(height: context.rs(48)),
        FilledButton.icon(
          onPressed: _isRequesting ? null : _requestChat,
          icon: _isRequesting
              ? const SizedBox()
              : Icon(Icons.chat_bubble_outline_rounded, size: context.rs(20)),
          label: _isRequesting
              ? SizedBox(
                  height: context.rs(20),
                  width: context.rs(20),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text('Start Chat',
                  style: TextStyle(fontSize: context.rf(16), fontWeight: FontWeight.bold)),
          style: FilledButton.styleFrom(
            minimumSize: Size(double.infinity, context.rs(56)),
            backgroundColor: AppColors.blue600,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(16))),
          ),
        ),
        SizedBox(height: context.rs(16)),
        OutlinedButton.icon(
          onPressed: () => context.push('/chat-history'),
          icon: Icon(Icons.history_rounded, size: context.rs(20), color: isDark ? AppColors.gray300 : AppColors.gray700),
          label: Text('View Support & Consultations History',
              style: TextStyle(fontSize: context.rf(15), fontWeight: FontWeight.w600, color: isDark ? AppColors.gray300 : AppColors.gray700)),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, context.rs(52)),
            side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray300),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(16))),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingScreen(bool isDark) {
    final repository = ref.watch(chatRepositoryProvider);
    return StreamBuilder<ChatSession>(
      stream: repository.watchSession(_sessionId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(fontSize: context.rf(14), color: AppColors.red500)));
        }

        if (!snapshot.hasData) {
          return Center(
              child: AppLoadingState(itemCount: 1, height: context.rs(120)));
        }

        final session = snapshot.data!;

        // Automatically route to chat when accepted
        if (session.status == 'active') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.pushReplacement('/chat/${session.id}');
            }
          });
        }

        return Padding(
          padding: EdgeInsets.all(context.rs(32)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(context.rs(24)),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ],
                  ),
                  child: SizedBox(
                    width: context.rs(40),
                    height: context.rs(40),
                    child: CircularProgressIndicator(
                      color: AppColors.blue500,
                      strokeWidth: context.rs(4),
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.rs(48)),
              Text(
                _selectedChannel == 'psychologist' 
                    ? 'Request Sent' 
                    : 'Finding a Peer Listener...',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: context.rf(26),
                    color: isDark ? Colors.white : AppColors.gray900),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.rs(16)),
              Text(
                _selectedChannel == 'psychologist'
                    ? 'Your consultation request has been sent to our clinical team. A psychologist will review it and accept the chat when available.'
                    : 'You have been added to the queue. A peer support volunteer will be with you shortly.',
                style: TextStyle(
                    fontSize: context.rf(16),
                    color: isDark ? AppColors.gray400 : AppColors.gray600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.rs(48)),
              OutlinedButton.icon(
                onPressed: () {
                  repository.endSession(_sessionId!);
                  context.go('/home');
                },
                icon: Icon(Icons.close_rounded, size: context.rs(20)),
                label: Text('Cancel Request',
                    style: TextStyle(fontSize: context.rf(16), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, context.rs(56)),
                  foregroundColor: AppColors.riskRedFg,
                  side: const BorderSide(color: AppColors.riskRedFg),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.rs(16))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ChannelCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                ? AppColors.blue900.withValues(alpha: 0.3)
                : AppColors.blue50)
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(context.rs(20)),
        border: Border.all(
          color: isSelected
              ? AppColors.blue500
              : (isDark ? AppColors.darkBorder : AppColors.gray200),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
                color: AppColors.blue500.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(20)),
          child: Padding(
            padding: EdgeInsets.all(context.rs(20)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.rs(16)),
                  decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blue600
                          : (isDark
                              ? AppColors.darkSurface2
                              : AppColors.gray100),
                      borderRadius: BorderRadius.circular(context.rs(16)),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                              color: AppColors.blue600.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                      ]),
                  child: Icon(icon,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.gray400 : AppColors.gray600),
                      size: context.rs(32)),
                ),
                SizedBox(width: context.rs(20)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: context.rf(18),
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? (isDark ? AppColors.blue400 : AppColors.blue800)
                              : (isDark ? Colors.white : AppColors.gray900),
                        ),
                      ),
                      SizedBox(height: context.rs(6)),
                      Text(
                        description,
                        style: TextStyle(
                            color:
                                isDark ? AppColors.gray400 : AppColors.gray600,
                            fontSize: context.rf(13),
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
