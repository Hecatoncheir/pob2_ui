import 'package:material_ui/material_ui.dart';

import 'app_text.dart';

class DialogCloseButton extends StatelessWidget {
  const DialogCloseButton({super.key, this.label = 'Закрыть'});
  final String label;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => Navigator.pop(context),
    child: AppText(label),
  );
}
