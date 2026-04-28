// lib/presentation/bloc/notification_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quize_app/core/services/notification_service.dart';


// ── Events ────────────────────────────────────────────────────────────────────

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load persisted settings from SharedPreferences
class NotificationSettingsLoaded extends NotificationEvent {}

/// User toggled the master enable switch
class NotificationToggled extends NotificationEvent {
  final bool enabled;
  NotificationToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

/// User changed the time window
class NotificationWindowChanged extends NotificationEvent {
  final int windowStart;
  final int windowEnd;
  NotificationWindowChanged(this.windowStart, this.windowEnd);
  @override
  List<Object?> get props => [windowStart, windowEnd];
}

/// Request an immediate test notification
class NotificationTestRequested extends NotificationEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationReady extends NotificationState {
  final NotificationSettings settings;
  final bool permissionGranted;
  NotificationReady({required this.settings, required this.permissionGranted});
  @override
  List<Object?> get props => [settings, permissionGranted];
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationTestSent extends NotificationState {
  final NotificationSettings settings;
  NotificationTestSent(this.settings);
  @override
  List<Object?> get props => [settings];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _service;

  NotificationBloc(this._service) : super(NotificationInitial()) {
    on<NotificationSettingsLoaded>(_onLoad);
    on<NotificationToggled>(_onToggle);
    on<NotificationWindowChanged>(_onWindowChanged);
    on<NotificationTestRequested>(_onTest);
  }

  Future<void> _onLoad(
    NotificationSettingsLoaded e,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final settings = await _service.loadSettings();
      // We optimistically assume permission is granted on load;
      // the OS will block the notification itself if not.
      emit(NotificationReady(settings: settings, permissionGranted: true));
    } catch (ex) {
      emit(NotificationError(ex.toString()));
    }
  }

  Future<void> _onToggle(
    NotificationToggled e,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationReady) return;

    emit(NotificationLoading());

    bool granted = current.permissionGranted;

    if (e.enabled) {
      // Request permission first
      granted = await _service.requestPermission();
      if (granted) {
        await _service.scheduleDailyReminder(
          windowStart: current.settings.windowStart,
          windowEnd: current.settings.windowEnd,
        );
      }
    } else {
      await _service.cancelDailyReminder();
    }

    final updated = current.settings.copyWith(enabled: e.enabled && granted);
    await _service.saveSettings(updated);

    emit(NotificationReady(settings: updated, permissionGranted: granted));
  }

  Future<void> _onWindowChanged(
    NotificationWindowChanged e,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationReady) return;

    final updated = current.settings.copyWith(
      windowStart: e.windowStart,
      windowEnd: e.windowEnd,
    );
    await _service.saveSettings(updated);

    // Re-schedule with new window if enabled
    if (updated.enabled) {
      await _service.scheduleDailyReminder(
        windowStart: updated.windowStart,
        windowEnd: updated.windowEnd,
      );
    }

    emit(NotificationReady(settings: updated, permissionGranted: current.permissionGranted));
  }

  Future<void> _onTest(
    NotificationTestRequested e,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationReady) return;

    await _service.showStreakNotification(current.settings.streak > 0 ? current.settings.streak : 1);
    emit(NotificationTestSent(current.settings));
    // Return to ready immediately so UI can react
    await Future.delayed(const Duration(milliseconds: 300));
    emit(NotificationReady(settings: current.settings, permissionGranted: current.permissionGranted));
  }
}