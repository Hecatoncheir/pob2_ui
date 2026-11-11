import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> disposeWidgetBloc(
  WidgetTester tester,
  BlocBase<Object?> bloc,
) async {
  // BlocProvider тоже запускает закрытие без ожидания в dispose.
  unawaited(bloc.close());
  await tester.pump();
}
