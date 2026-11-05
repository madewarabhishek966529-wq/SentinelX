import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final int retentionDays;
  final int refreshIntervalSeconds;
  final bool quietHoursEnabled;
  final int quietHoursStart; // 24-hr format (e.g. 22 = 10 PM)
  final int quietHoursEnd;   // 24-hr format (e.g. 7 = 7 AM)
  final bool deduplicateAlerts;
  final bool localOnlyLogging;

  const AppSettings({
    this.retentionDays = 30,
    this.refreshIntervalSeconds = 5,
    this.quietHoursEnabled = false,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 7,
    this.deduplicateAlerts = true,
    this.localOnlyLogging = true,
  });

  AppSettings copyWith({
    int? retentionDays,
    int? refreshIntervalSeconds,
    bool? quietHoursEnabled,
    int? quietHoursStart,
    int? quietHoursEnd,
    bool? deduplicateAlerts,
    bool? localOnlyLogging,
  }) {
    return AppSettings(
      retentionDays: retentionDays ?? this.retentionDays,
      refreshIntervalSeconds: refreshIntervalSeconds ?? this.refreshIntervalSeconds,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      deduplicateAlerts: deduplicateAlerts ?? this.deduplicateAlerts,
      localOnlyLogging: localOnlyLogging ?? this.localOnlyLogging,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return const AppSettings();
  }

  void setRetentionDays(int days) {
    state = state.copyWith(retentionDays: days);
  }

  void setRefreshInterval(int seconds) {
    state = state.copyWith(refreshIntervalSeconds: seconds);
  }

  void toggleQuietHours(bool enabled) {
    state = state.copyWith(quietHoursEnabled: enabled);
  }

  void toggleDeduplication(bool enabled) {
    state = state.copyWith(deduplicateAlerts: enabled);
  }

  void toggleLocalOnlyLogging(bool enabled) {
    state = state.copyWith(localOnlyLogging: enabled);
  }
}
