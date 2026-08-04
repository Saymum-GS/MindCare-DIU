import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final Alignment alignment;

  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth = 520,
    this.padding = const EdgeInsets.all(24),
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final contentWidth =
            availableWidth < maxWidth ? availableWidth : maxWidth;

        return SingleChildScrollView(
          padding: padding,
          child: Align(
            alignment: alignment,
            child: SizedBox(
              width: contentWidth,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
