enum AppFlavor { dev, staging, prod }

class AppEnvironment {
  AppEnvironment({
    required this.flavor,
    required this.projectId,
  });

  final AppFlavor flavor;
  final String projectId;

  factory AppEnvironment.fromDartDefines() {
    const flavorValue = String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: 'dev',
    );
    const projectId = String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'smartnutri-dev',
    );

    return AppEnvironment(
      flavor: switch (flavorValue) {
        'staging' => AppFlavor.staging,
        'prod' => AppFlavor.prod,
        _ => AppFlavor.dev,
      },
      projectId: projectId,
    );
  }
}
