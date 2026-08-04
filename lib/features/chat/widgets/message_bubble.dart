import '../../../shared/models/chat_session_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showCrisisAlert;
  final String viewerRole;
  final String sessionChannel;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showCrisisAlert = false,
    this.viewerRole = '',
    this.sessionChannel = 'volunteer',
  });

  @override
  Widget build(BuildContext context) {
    // If the message is from the system, center it
    if (message.senderRole == 'system') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            message.text,
            style: const TextStyle(
              color: AppColors.gray600,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final bubbleColor = isMe ? AppColors.blue600 : Colors.white;
    final textColor = isMe ? Colors.white : AppColors.gray900;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 0),
      bottomRight: Radius.circular(isMe ? 0 : 16),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isMe ? 'You' : message.senderName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('h:mm a')
                    .format(message.createdAt ?? DateTime.now()),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: showCrisisAlert ? AppColors.red50 : bubbleColor,
              borderRadius: borderRadius,
              border: isMe ? null : Border.all(color: showCrisisAlert ? AppColors.red500 : AppColors.gray300),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: showCrisisAlert ? AppColors.gray900 : textColor,
                fontSize: 16,
              ),
            ),
          ),
          if (showCrisisAlert) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red500.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.red500, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        (viewerRole == 'psychologist' || sessionChannel == 'psychologist')
                            ? 'Clinical Risk Detected'
                            : 'Crisis Detected',
                        style: const TextStyle(color: AppColors.red500, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (viewerRole == 'psychologist' || sessionChannel == 'psychologist')
                        ? 'High-risk keywords detected. Conduct clinical safety assessment. If imminent self-harm or suicide danger is confirmed, initiate Emergency Protocol or contact Campus Security.'
                        : 'Handle with care. Validate their feelings. Escalate to a Psychologist if there is immediate danger.',
                    style: const TextStyle(color: AppColors.red500, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
