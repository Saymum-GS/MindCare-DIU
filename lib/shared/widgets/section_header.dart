import 'package:flutter/material.dart';

// A reusable section header with optional "See all" link
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                )),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}
