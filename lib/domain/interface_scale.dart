const minimumInterfaceScale = 75;
const maximumInterfaceScale = 200;

int normalizeInterfaceScale(int percent) => ((percent / 5).round() * 5).clamp(
  minimumInterfaceScale,
  maximumInterfaceScale,
);

typedef InterfaceScaleState = ({int percent, String? error});
