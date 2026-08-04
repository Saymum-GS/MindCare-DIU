import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/responsive_util.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/chat_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/models/chat_session_model.dart';

class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  ConsumerState<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Sessions', style: TextStyle(fontSize: context.rf(17)))),
            body: Center(child: Text('User not found.', style: TextStyle(fontSize: context.rf(16)))),
          );
        }

        String screenTitle = 'My Support History';
        if (user.role == 'psychologist') {
          screenTitle = 'Clinical Case Archive';
        } else if (user.role == 'volunteer') {
          screenTitle = 'Support Sessions Archive';
        }

        final filterOptions = _getFilterOptions(user.role);

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
          appBar: AppBar(
            title: Text(screenTitle, style: TextStyle(fontSize: context.rf(17), fontWeight: FontWeight.bold)),
            elevation: 0,
          ),
          body: Column(
            children: [
              // Search & Filter Header
              Container(
                padding: EdgeInsets.fromLTRB(context.rs(16), context.rs(8), context.rs(16), context.rs(16)),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray200)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search by name, pseudonym, or student ID...',
                        hintStyle: TextStyle(fontSize: context.rf(14), color: isDark ? AppColors.gray400 : AppColors.gray500),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.blue500, size: context.rs(20)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, size: context.rs(18)),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurface2 : AppColors.gray100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.rs(14)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: context.rs(16), vertical: context.rs(12)),
                      ),
                    ),
                    SizedBox(height: context.rs(12)),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filterOptions.map((opt) {
                          final isSelected = _selectedFilter == opt.key;
                          return Padding(
                            padding: EdgeInsets.only(right: context.rs(8)),
                            child: FilterChip(
                              label: Text(opt.label, style: TextStyle(fontSize: context.rf(13), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedFilter = opt.key),
                              selectedColor: AppColors.blue500.withValues(alpha: 0.15),
                              checkmarkColor: AppColors.blue500,
                              labelStyle: TextStyle(color: isSelected ? AppColors.blue500 : (isDark ? AppColors.gray300 : AppColors.gray700)),
                              backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.gray100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.rs(20)),
                                side: BorderSide(color: isSelected ? AppColors.blue500 : Colors.transparent),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Session List
              Expanded(
                child: StreamBuilder<List<ChatSession>>(
                  stream: ref.read(chatRepositoryProvider).watchChatHistory(user.uid, user.role),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: AppLoadingState());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: context.rf(14))));
                    }
                    
                    final allChats = snapshot.data ?? [];
                    final filteredChats = allChats.where((c) {
                      if (c.status == 'deleted') return false;

                      // Status & Channel Filter
                      if (_selectedFilter == 'escalated' && !c.crisisEscalated && c.status != 'escalated') return false;
                      if (_selectedFilter == 'completed' && c.status != 'ended') return false;
                      if (_selectedFilter == 'psychologist' && c.channel != 'psychologist') return false;
                      if (_selectedFilter == 'volunteer' && c.channel != 'volunteer') return false;

                      // Search Query Filter
                      if (_searchQuery.isNotEmpty) {
                        final peerName = _getSessionTitle(c, user.role).toLowerCase();
                        final realName = (c.studentRealName ?? '').toLowerCase();
                        final diuId = (c.studentDiuId ?? '').toLowerCase();
                        final pseudo = (c.studentPseudonym ?? '').toLowerCase();
                        final note = (c.ratingNote ?? '').toLowerCase();
                        if (!peerName.contains(_searchQuery) &&
                            !realName.contains(_searchQuery) &&
                            !diuId.contains(_searchQuery) &&
                            !pseudo.contains(_searchQuery) &&
                            !note.contains(_searchQuery)) {
                          return false;
                        }
                      }

                      return true;
                    }).toList();
                    
                    if (filteredChats.isEmpty) {
                      return AppEmptyState(
                        icon: Icons.history_rounded,
                        title: _searchQuery.isNotEmpty ? 'No Matching Sessions' : 'No $screenTitle',
                        message: _searchQuery.isNotEmpty
                            ? 'Try adjusting your search query or filter chips.'
                            : 'Your past conversations and support records will appear here.',
                      );
                    }
                    
                    return ListView.builder(
                      padding: EdgeInsets.all(context.rs(16)),
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final sessionTitle = _getSessionTitle(chat, user.role);

                        final dateStr = chat.startedAt != null 
                            ? DateFormat('MMM d, yyyy • h:mm a').format(chat.startedAt!)
                            : 'Unknown Date';

                        final start = chat.startedAt;
                        final end = chat.endedAt;
                        String duration = '';
                        if (start != null && end != null) {
                          final mins = end.difference(start).inMinutes;
                          duration = '$mins min';
                        }
                        final escalated = chat.crisisEscalated || chat.status == 'escalated';
                        final rating = chat.rating;
                        final ratingNote = chat.ratingNote;

                        return Container(
                          margin: EdgeInsets.only(bottom: context.rs(16)),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(context.rs(20)),
                            border: Border.all(
                                color: escalated
                                    ? AppColors.red500.withValues(alpha: 0.5)
                                    : (isDark ? AppColors.darkBorder : AppColors.gray200)),
                            boxShadow: [
                              BoxShadow(
                                color: (escalated ? AppColors.red500 : Colors.black)
                                    .withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(context.rs(20)),
                            onTap: () {
                              context.push('/chat/${chat.id}');
                            },
                            child: Padding(
                              padding: EdgeInsets.all(context.rs(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: context.rs(48),
                                        height: context.rs(48),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSurface2 : AppColors.blue50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            sessionTitle.isNotEmpty ? sessionTitle[0].toUpperCase() : '?',
                                            style: TextStyle(
                                              color: isDark ? AppColors.gray300 : AppColors.blue600,
                                              fontWeight: FontWeight.bold,
                                              fontSize: context.rf(20),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: context.rs(16)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    sessionTitle,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: context.rf(17),
                                                      color: isDark ? Colors.white : AppColors.gray900,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (escalated)
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: context.rs(10), vertical: context.rs(4)),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.red500,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.warning_rounded, color: Colors.white, size: context.rs(12)),
                                                        SizedBox(width: context.rs(4)),
                                                        Text('Escalated',
                                                            style: TextStyle(color: Colors.white, fontSize: context.rf(11), fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Wrap(
                                              spacing: context.rs(8),
                                              runSpacing: context.rs(4),
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: context.rs(8), vertical: context.rs(2)),
                                                  decoration: BoxDecoration(
                                                    color: chat.channel == 'psychologist' ? AppColors.purple50 : AppColors.sage50,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    chat.channel == 'psychologist' ? 'Psychologist' : 'Peer Support',
                                                    style: TextStyle(
                                                      fontSize: context.rf(11),
                                                      fontWeight: FontWeight.w700,
                                                      color: chat.channel == 'psychologist' ? AppColors.purple600 : AppColors.sage600,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  dateStr,
                                                  style: TextStyle(
                                                    fontSize: context.rf(13),
                                                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, color: AppColors.red500, size: context.rs(22)),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text('Delete Chat History?', style: TextStyle(fontSize: context.rf(18))),
                                              content: Text('This will delete the chat history for both parties. This action cannot be undone.', style: TextStyle(fontSize: context.rf(14))),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, false),
                                                  child: Text('Cancel', style: TextStyle(fontSize: context.rf(14))),
                                                ),
                                                FilledButton(
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  style: FilledButton.styleFrom(backgroundColor: AppColors.red500),
                                                  child: Text('Delete', style: TextStyle(fontSize: context.rf(14))),
                                                ),
                                              ],
                                            ),
                                          );
                                          
                                          if (confirm == true) {
                                            await ref.read(chatRepositoryProvider).deleteSessionForEveryone(chat.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Chat history deleted.')),
                                              );
                                            }
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                  if (duration.isNotEmpty || rating != null) ...[
                                    SizedBox(height: context.rs(16)),
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: context.rs(12), horizontal: context.rs(16)),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkSurface2 : AppColors.gray50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          if (duration.isNotEmpty) ...[
                                            Icon(Icons.timer_outlined, size: context.rs(16), color: isDark ? AppColors.gray400 : AppColors.gray500),
                                            SizedBox(width: context.rs(6)),
                                            Text(duration,
                                                style: TextStyle(fontSize: context.rf(13), fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.gray700)),
                                            SizedBox(width: context.rs(24)),
                                          ],
                                          if (rating != null) ...[
                                            Row(
                                              children: List.generate(
                                                  5,
                                                  (i) => Icon(i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                                      size: context.rs(18), color: i < rating ? AppColors.amber500 : AppColors.gray300)),
                                            ),
                                            SizedBox(width: context.rs(8)),
                                            Text('$rating/5',
                                                style: TextStyle(fontSize: context.rf(13), fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.gray700)),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (ratingNote != null && ratingNote.isNotEmpty) ...[
                                    SizedBox(height: context.rs(12)),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(context.rs(12)),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkSurface2 : AppColors.amber50.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(context.rs(10)),
                                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.amber200),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.format_quote_rounded, size: context.rs(18), color: AppColors.amber600),
                                          SizedBox(width: context.rs(8)),
                                          Expanded(
                                            child: Text(
                                              ratingNote,
                                              style: TextStyle(
                                                fontSize: context.rf(13),
                                                fontStyle: FontStyle.italic,
                                                color: isDark ? AppColors.gray300 : AppColors.gray800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: AppLoadingState())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  String _getSessionTitle(ChatSession chat, String myRole) {
    if (myRole == 'student') {
      if (chat.status == 'escalated' || chat.crisisEscalated) {
        return 'Clinical Crisis Support';
      } else if (chat.channel == 'psychologist') {
        return 'Clinical Consultation';
      } else {
        return 'Peer Support Session';
      }
    } else if (myRole == 'psychologist') {
      final realName = chat.studentRealName;
      final diuId = chat.studentDiuId;
      if (realName != null && realName.isNotEmpty) {
        return (diuId != null && diuId.isNotEmpty) ? '$realName ($diuId)' : realName;
      }
      return chat.studentPseudonym ?? 'Student';
    } else {
      return chat.studentPseudonym ?? 'Student';
    }
  }

  List<_FilterOption> _getFilterOptions(String role) {
    if (role == 'psychologist') {
      return [
        const _FilterOption('all', 'All Cases'),
        const _FilterOption('escalated', 'Escalated 🚨'),
        const _FilterOption('completed', 'Completed ✅'),
        const _FilterOption('psychologist', 'Clinical Consultations'),
      ];
    } else if (role == 'volunteer') {
      return [
        const _FilterOption('all', 'All Sessions'),
        const _FilterOption('escalated', 'Escalated 🚨'),
        const _FilterOption('completed', 'Completed ✅'),
      ];
    } else {
      return [
        const _FilterOption('all', 'All Support'),
        const _FilterOption('psychologist', 'Psychologists 🧠'),
        const _FilterOption('volunteer', 'Peer Listeners 🤝'),
        const _FilterOption('escalated', 'Escalated 🚨'),
      ];
    }
  }
}

class _FilterOption {
  final String key;
  final String label;
  const _FilterOption(this.key, this.label);
}
