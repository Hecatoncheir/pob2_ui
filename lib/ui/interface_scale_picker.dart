import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/interface_scale.dart';
import 'core/app_text.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'interface_scale_cubit.dart';

class InterfaceScalePicker extends StatelessWidget {
  const InterfaceScalePicker({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<InterfaceScaleCubit, InterfaceScaleState>(
        builder: (context, state) {
          final scale = context.read<InterfaceScaleCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText(
                'Масштаб интерфейса',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ArtIconButton(
                    'minus',
                    label: 'Уменьшить интерфейс',
                    onPressed: state.percent > minimumInterfaceScale
                        ? () => scale.changeBy(-10)
                        : null,
                  ),
                  Expanded(
                    child: Slider(
                      key: const Key('interface-scale-slider'),
                      value: state.percent.toDouble(),
                      min: 75,
                      max: 200,
                      divisions: 25,
                      label: '${state.percent}%',
                      onChanged: (value) => scale.setPercent(value.round()),
                    ),
                  ),
                  ArtIconButton(
                    'plus',
                    label: 'Увеличить интерфейс',
                    onPressed: state.percent < maximumInterfaceScale
                        ? () => scale.changeBy(10)
                        : null,
                  ),
                  SizedBox(
                    width: 52,
                    child: AppText(
                      '${state.percent}%',
                      style: Spark.mono,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => scale.setPercent(100),
                    child: const AppText('Сбросить'),
                  ),
                ],
              ),
              if (state.error != null)
                AppText(
                  'Не удалось сохранить масштаб.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          );
        },
      );
}
