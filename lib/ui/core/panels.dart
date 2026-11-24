import 'app_text.dart';

import 'package:material_ui/material_ui.dart';

import 'spark_art.dart';
import 'spark_theme.dart';

class SurfacePanel extends StatelessWidget {
  const SurfacePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.showBorder = true,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showBorder;
  @override
  Widget build(BuildContext context) => Material(
    color: Spark.of(context).surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: showBorder
          ? BorderSide(color: Spark.of(context).line)
          : BorderSide.none,
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class PanelExpansionTile extends StatelessWidget {
  const PanelExpansionTile({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final outline = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: Spark.of(context).line),
    );
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      visualDensity: VisualDensity.compact,
      clipBehavior: Clip.antiAlias,
      collapsedBackgroundColor: colors.surfaceContainerHigh,
      backgroundColor: Color.alphaBlend(
        colors.primary.withValues(alpha: .06),
        colors.surfaceContainerHigh,
      ),
      title: AppText(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      shape: outline,
      collapsedShape: outline,
      children: children,
    );
  }
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({
    super.key,
    required this.title,
    required this.message,
    this.art = 'atlas',
    this.action,
  });
  final String title, message, art;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SparkArt('illustrations/$art', width: 200, height: 154),
            const SizedBox(height: 24),
            AppText(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: AppText(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Spark.of(context).muted),
              ),
            ),
            if (action != null) ...[const SizedBox(height: 22), action!],
          ],
        ),
      ),
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.subtitle, this.action});
  final String title;
  final String? subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                AppText(
                  subtitle!,
                  style: TextStyle(color: Spark.of(context).muted),
                ),
              ],
            ],
          ),
        ),
        ?action,
      ],
    ),
  );
}

class DotLabel extends StatelessWidget {
  const DotLabel(
    this.text, {
    super.key,
    this.active = true,
    this.maxLines,
    this.textAlign,
  });
  final String text;
  final int? maxLines;
  final TextAlign? textAlign;
  final bool active;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: active ? Spark.of(context).green : Spark.of(context).muted,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 7),
      Flexible(
        child: AppText(
          text,
          maxLines: maxLines,
          textAlign: textAlign,
          textWidthBasis: textAlign == TextAlign.center
              ? TextWidthBasis.longestLine
              : null,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ],
  );
}
