import 'package:material_ui/material_ui.dart';

class ItemArtworkImage extends StatelessWidget {
  const ItemArtworkImage({
    super.key,
    required this.url,
    this.placeholder = const SizedBox.shrink(),
  });
  final String url;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) => Image.network(
    url,
    headers: const {'Referer': 'https://poe2db.tw/'},
    fit: BoxFit.contain,
    excludeFromSemantics: true,
    frameBuilder: (context, child, frame, synchronouslyLoaded) =>
        frame == null ? placeholder : child,
    errorBuilder: (context, error, stack) => placeholder,
  );
}
