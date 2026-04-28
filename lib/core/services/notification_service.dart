// lib/core/services/notification_service.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Keys stored in SharedPreferences
class _PrefKeys {
  static const enabled = 'notif_enabled';
  static const windowStart = 'notif_window_start'; // hour 0-23
  static const windowEnd = 'notif_window_end'; // hour 0-23
  static const streak = 'notif_streak';
}

/// Notification IDs — keep stable so we can cancel/replace them
class _NotifIds {
  static const dailyReminder = 1;
  static const streakCelebration = 2;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Motivational message pools
// ─────────────────────────────────────────────────────────────────────────────
const _titles = [
  '📚 Time to practise!',
  '🧠 Your brain is waiting!',
  '⚡ Quick quiz time!',
  '🎯 Hit your daily goal!',
  '🔥 Keep the streak alive!',
  '💡 Learn something new today!',
  '🏆 Champions practise daily!',
  '✨ A few questions a day…',
];

const _bodies = [
  'Take a short quiz and sharpen your knowledge today.',
  'Even 5 minutes of practice moves you forward.',
  'Your future self will thank you. Start now!',
  'Don\'t break the streak — jump in for a quick quiz!',
  'A daily quiz habit leads to exam success. Go!',
  'Ready to earn some XP? Open TSHS Quiz now.',
  'Small steps every day = big results on exam day.',
  'Your subjects are waiting. Let\'s go! 🚀',
];

// ─────────────────────────────────────────────────────────────────────────────
//  NotificationService
// ─────────────────────────────────────────────────────────────────────────────
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _rng = Random();

  bool _initialized = false;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    // Timezone data (needed for exact-time scheduling)
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('[NotificationService] initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigation is handled via the app's own navigator key if needed.
    debugPrint('[NotificationService] tapped: ${response.payload}');
  }

  // ── Permission ───────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    // Android 13+
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true; // other platforms
  }

  // ── Schedule / Cancel ────────────────────────────────────────────────────

  /// Schedules ONE daily reminder at a RANDOM time within [windowStart, windowEnd).
  /// Cancels any previously scheduled reminder first.
  Future<void> scheduleDailyReminder({
    required int windowStart, // e.g. 8  → 08:xx
    required int windowEnd, // e.g. 21 → 21:xx
  }) async {
    await cancelDailyReminder();

    // Pick a random hour inside the window, and a random minute
    final rangeHours = windowEnd - windowStart;
    if (rangeHours <= 0) return;

    final randomHour = windowStart + _rng.nextInt(rangeHours);
    final randomMinute = _rng.nextInt(60);

    final scheduledTime = _nextInstanceOf(randomHour, randomMinute);

    // // 🔥 TEST MODE (1 minute notification)
    // final scheduledTime = tz.TZDateTime.now(
    //   tz.local,
    // ).add(const Duration(seconds: 30));

    debugPrint('[TEST] Notification will fire at: ${scheduledTime.toLocal()}');

    final titleIndex = _rng.nextInt(_titles.length);
    final bodyIndex = _rng.nextInt(_bodies.length);

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Practice Reminder',
      channelDescription: 'Reminds you to practise your quiz every day',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      _NotifIds.dailyReminder,
      _titles[titleIndex],
      _bodies[bodyIndex],
      scheduledTime,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      payload: 'daily_reminder',
    );

    debugPrint(
      '[NotificationService] scheduled daily @ ${scheduledTime.toLocal()}',
    );
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_NotifIds.dailyReminder);
    debugPrint('[NotificationService] daily reminder cancelled');
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('[NotificationService] all notifications cancelled');
  }

  // ── Streak celebration (fires immediately) ───────────────────────────────

  Future<void> showStreakNotification(int streak) async {
    const androidDetails = AndroidNotificationDetails(
      'streak',
      'Streak Celebrations',
      channelDescription: 'Celebrates your quiz streak milestones',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      _NotifIds.streakCelebration,
      '🔥 $streak-day streak!',
      'Amazing! You\'ve been practising for $streak days in a row. Keep it up!',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'streak',
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns the next TZDateTime for [hour]:[minute] — today if still future,
  /// tomorrow otherwise.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ── Preferences helpers ──────────────────────────────────────────────────

  Future<NotificationSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettings(
      enabled: prefs.getBool(_PrefKeys.enabled) ?? false,
      windowStart: prefs.getInt(_PrefKeys.windowStart) ?? 8,
      windowEnd: prefs.getInt(_PrefKeys.windowEnd) ?? 21,
      streak: prefs.getInt(_PrefKeys.streak) ?? 0,
    );
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_PrefKeys.enabled, settings.enabled);
    await prefs.setInt(_PrefKeys.windowStart, settings.windowStart);
    await prefs.setInt(_PrefKeys.windowEnd, settings.windowEnd);
    await prefs.setInt(_PrefKeys.streak, settings.streak);
  }

  /// Call this after each completed quiz to increment streak & maybe celebrate.
  Future<void> recordPractice() async {
    final settings = await loadSettings();
    final prefs = await SharedPreferences.getInstance();
    final lastPractice = prefs.getString('last_practice_date');
    final today = _dateKey(DateTime.now());

    if (lastPractice == today) return; // already recorded today

    final yesterday = _dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final newStreak = lastPractice == yesterday ? settings.streak + 1 : 1;

    await prefs.setString('last_practice_date', today);
    await saveSettings(settings.copyWith(streak: newStreak));

    // Celebrate milestone streaks
    if (newStreak == 3 || newStreak == 7 || newStreak % 10 == 0) {
      await showStreakNotification(newStreak);
    }

    // Re-randomise tomorrow's notification time
    if (settings.enabled) {
      await scheduleDailyReminder(
        windowStart: settings.windowStart,
        windowEnd: settings.windowEnd,
      );
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Value object
// ─────────────────────────────────────────────────────────────────────────────
class NotificationSettings {
  final bool enabled;
  final int windowStart; // hour, 0-23
  final int windowEnd; // hour, 0-23
  final int streak;

  const NotificationSettings({
    required this.enabled,
    required this.windowStart,
    required this.windowEnd,
    required this.streak,
  });

  NotificationSettings copyWith({
    bool? enabled,
    int? windowStart,
    int? windowEnd,
    int? streak,
  }) => NotificationSettings(
    enabled: enabled ?? this.enabled,
    windowStart: windowStart ?? this.windowStart,
    windowEnd: windowEnd ?? this.windowEnd,
    streak: streak ?? this.streak,
  );

  String get windowLabel {
    final s = _fmt(windowStart);
    final e = _fmt(windowEnd);
    return '$s – $e';
  }

  String _fmt(int hour) {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:00 $suffix';
  }
}
