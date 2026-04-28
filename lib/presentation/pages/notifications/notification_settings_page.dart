// lib/presentation/pages/notifications/notification_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quize_app/core/core/di/injection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../bloc/bloc/notification_bloc.dart';


class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc(sl<NotificationService>())
        ..add(NotificationSettingsLoaded()),
      child: const _NotificationSettingsView(),
    );
  }
}

class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.purpleBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.chevron_left_rounded, color: AppColors.purple),
          ),
        ),
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationTestSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text('Test notification sent!'),
                  ],
                ),
                backgroundColor: AppColors.correct,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          if (state is NotificationReady && !state.permissionGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Permission denied. Please enable notifications in Settings.'),
                backgroundColor: AppColors.wrong,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.purple));
          }
          if (state is NotificationError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.wrong)));
          }

          final settings = state is NotificationReady
              ? state.settings
              : (state as NotificationTestSent).settings;
          final isReady = state is NotificationReady;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Banner ──────────────────────────────────
                _HeroBanner(enabled: settings.enabled, streak: settings.streak),
                const SizedBox(height: 24),

                // ── Master Toggle ────────────────────────────────
                _SectionLabel('Daily Practice Reminder'),
                _ToggleCard(
                  enabled: settings.enabled,
                  onChanged: isReady
                      ? (v) => context.read<NotificationBloc>().add(NotificationToggled(v))
                      : null,
                ),
                const SizedBox(height: 8),
                if (!settings.enabled)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Text(
                      'Enable to receive a daily reminder to keep your practice streak going.',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ),

                // ── Time Window ──────────────────────────────────
                const SizedBox(height: 20),
                _SectionLabel('Reminder Window'),
                _TimeWindowCard(
                  settings: settings,
                  enabled: settings.enabled,
                  onWindowChanged: isReady
                      ? (start, end) => context.read<NotificationBloc>().add(
                            NotificationWindowChanged(start, end),
                          )
                      : null,
                ),

                // ── How it works ─────────────────────────────────
                const SizedBox(height: 20),
                _SectionLabel('How it works'),
                _InfoCard(settings: settings),

                // ── Streak ───────────────────────────────────────
                const SizedBox(height: 20),
                _SectionLabel('Your Streak'),
                _StreakCard(streak: settings.streak),

                // ── Test ─────────────────────────────────────────
                const SizedBox(height: 24),
                if (settings.enabled)
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: OutlinedButton.icon(
                      onPressed: isReady
                          ? () => context.read<NotificationBloc>().add(NotificationTestRequested())
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.purple,
                        side: const BorderSide(color: AppColors.purple),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.notifications_active_rounded),
                      label: const Text('Send Test Notification', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final bool enabled;
  final int streak;
  const _HeroBanner({required this.enabled, required this.streak});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: enabled
            ? [AppColors.purple, AppColors.purpleDark]
            : [const Color(0xFF9CA3AF), const Color(0xFF6B7280)],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: (enabled ? AppColors.purple : Colors.grey).withOpacity(.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                enabled ? 'Reminders Active 🔔' : 'Reminders Off',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                enabled
                    ? 'You\'ll get a random daily nudge to practise.'
                    : 'Turn on reminders to build a daily habit.',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              if (streak > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '🔥 $streak day streak',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Toggle Card ───────────────────────────────────────────────────────────────

class _ToggleCard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool>? onChanged;
  const _ToggleCard({required this.enabled, this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10)],
    ),
    child: SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: enabled ? AppColors.purpleBg : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          enabled ? Icons.notifications_rounded : Icons.notifications_off_rounded,
          color: enabled ? AppColors.purple : AppColors.textGrey,
          size: 20,
        ),
      ),
      title: const Text('Daily reminder', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
      subtitle: Text(
        enabled ? 'Reminder is active' : 'Tap to enable',
        style: TextStyle(fontSize: 12, color: enabled ? AppColors.correct : AppColors.textGrey),
      ),
      value: enabled,
      onChanged: onChanged,
      activeColor: AppColors.purple,
    ),
  );
}

// ── Time Window Card ──────────────────────────────────────────────────────────

class _TimeWindowCard extends StatelessWidget {
  final NotificationSettings settings;
  final bool enabled;
  final void Function(int start, int end)? onWindowChanged;

  const _TimeWindowCard({
    required this.settings,
    required this.enabled,
    this.onWindowChanged,
  });

  String _hourLabel(int h) {
    final suffix = h >= 12 ? 'PM' : 'AM';
    final disp = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$disp:00 $suffix';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.purpleBg, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.schedule_rounded, color: AppColors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reminder window', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                  Text(
                    settings.windowLabel,
                    style: const TextStyle(fontSize: 13, color: AppColors.purple, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Preset chips
        const Text('Quick presets', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _presets.map((p) {
            final active = settings.windowStart == p.start && settings.windowEnd == p.end;
            return GestureDetector(
              onTap: enabled && onWindowChanged != null
                  ? () => onWindowChanged!(p.start, p.end)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? AppColors.purple : AppColors.purpleBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? AppColors.purple : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      p.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Custom sliders
        const Text('Custom window', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
        const SizedBox(height: 8),
        _WindowSlider(
          label: 'From',
          value: settings.windowStart,
          min: 5,
          max: settings.windowEnd - 1,
          enabled: enabled,
          onChanged: onWindowChanged != null
              ? (v) => onWindowChanged!(v, settings.windowEnd)
              : null,
          displayLabel: _hourLabel(settings.windowStart),
        ),
        const SizedBox(height: 8),
        _WindowSlider(
          label: 'Until',
          value: settings.windowEnd,
          min: settings.windowStart + 1,
          max: 23,
          enabled: enabled,
          onChanged: onWindowChanged != null
              ? (v) => onWindowChanged!(settings.windowStart, v)
              : null,
          displayLabel: _hourLabel(settings.windowEnd),
        ),
      ],
    ),
  );

  static final _presets = [
    _Preset('🌅', 'Morning', 7, 10),
    _Preset('☀️', 'Midday', 11, 14),
    _Preset('🌆', 'Afternoon', 14, 17),
    _Preset('🌙', 'Evening', 18, 21),
    _Preset('🎲', 'Anytime', 8, 22),
  ];
}

class _Preset {
  final String emoji, label;
  final int start, end;
  const _Preset(this.emoji, this.label, this.start, this.end);
}

class _WindowSlider extends StatelessWidget {
  final String label, displayLabel;
  final int value, min, max;
  final bool enabled;
  final ValueChanged<int>? onChanged;
  const _WindowSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.displayLabel,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 48,
        child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ),
      Expanded(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: enabled ? AppColors.purple : Colors.grey.shade300,
            inactiveTrackColor: AppColors.purpleBg,
            thumbColor: enabled ? AppColors.purple : Colors.grey,
            overlayColor: AppColors.purple.withOpacity(.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: enabled && onChanged != null
                ? (v) => onChanged!(v.round())
                : null,
          ),
        ),
      ),
      SizedBox(
        width: 70,
        child: Text(
          displayLabel,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: enabled ? AppColors.purple : AppColors.textGrey,
          ),
        ),
      ),
    ],
  );
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final NotificationSettings settings;
  const _InfoCard({required this.settings});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.purpleBg,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        _InfoRow(Icons.shuffle_rounded, 'Random time',
            'Each day a new reminder time is chosen randomly within your window.'),
        const SizedBox(height: 12),
        _InfoRow(Icons.repeat_rounded, 'Daily repeat',
            'The reminder repeats automatically every day — no manual reset needed.'),
        const SizedBox(height: 12),
        _InfoRow(Icons.battery_saver_rounded, 'Battery-friendly',
            'Uses Android exact alarms so the notification fires even in Doze mode.'),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _InfoRow(this.icon, this.title, this.body);

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.purple, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(body, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.4)),
          ],
        ),
      ),
    ],
  );
}

// ── Streak Card ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final milestones = [1, 3, 7, 14, 30, 60, 100];
    final nextMilestone = milestones.firstWhere((m) => m > streak, orElse: () => streak + 10);
    final progress = streak == 0 ? 0.0 : streak / nextMilestone;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: streak > 0 ? AppColors.gold.withOpacity(.15) : AppColors.purpleBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    streak > 0 ? '🔥' : '💤',
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streak == 0 ? 'No streak yet' : '$streak-day streak!',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark),
                    ),
                    Text(
                      streak == 0
                          ? 'Complete a quiz to start your streak'
                          : 'Next milestone: $nextMilestone days',
                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: streak > 0 ? AppColors.gold.withOpacity(.15) : AppColors.purpleBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$streak',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: streak > 0 ? AppColors.goldDark : AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
          if (streak > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: AppColors.purpleBg,
                valueColor: AlwaysStoppedAnimation(
                  streak >= 7 ? AppColors.gold : AppColors.purple,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$streak days', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                Text('$nextMilestone days', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ],
          // Milestone badges
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MilestoneBadge(days: 3, streak: streak),
              _MilestoneBadge(days: 7, streak: streak),
              _MilestoneBadge(days: 14, streak: streak),
              _MilestoneBadge(days: 30, streak: streak),
              _MilestoneBadge(days: 100, streak: streak),
            ],
          ),
        ],
      ),
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  final int days, streak;
  const _MilestoneBadge({required this.days, required this.streak});

  String get _emoji {
    if (days >= 100) return '👑';
    if (days >= 30) return '💎';
    if (days >= 14) return '🏆';
    if (days >= 7) return '⭐';
    return '🎯';
  }

  @override
  Widget build(BuildContext context) {
    final achieved = streak >= days;
    return Column(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: achieved ? AppColors.gold.withOpacity(.2) : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: achieved ? Border.all(color: AppColors.gold, width: 2) : null,
          ),
          child: Center(
            child: Text(_emoji, style: TextStyle(fontSize: 18, color: achieved ? null : const Color(0xFFD1D5DB))),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${days}d',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: achieved ? AppColors.gold : AppColors.textGrey),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 1),
    ),
  );
}

// Expose goldDark from AppColors here for convenience (already defined in app_colors.dart)
extension _AppColorsExt on AppColors {
  static const goldDark = Color(0xFFD97706);
}