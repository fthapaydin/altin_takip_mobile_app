sealed class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  final String operation;
  const SettingsLoading(this.operation);
}

class SettingsSuccess extends SettingsState {
  final String message;
  const SettingsSuccess(this.message);
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
}
