// lib/presentation/pages/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../auth/login_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator(color: AppColors.purple));
        }
        final user = state.user;
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, bottom: 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.purple, AppColors.purpleLight],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.white24,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: GestureDetector(
                              onTap: () => _showEditDialog(context, user.name),
                              child: Container(
                                width: 28, height: 28,
                                decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                                child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ProfileStat(value: '${user.xpPoints}', label: 'XP Points'),
                          Container(width: 1, height: 36, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
                          _ProfileStat(value: '${user.trophyCount}', label: 'Trophies'),
                          Container(width: 1, height: 36, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
                          _ProfileStat(value: _memberSince(user.createdAt), label: 'Member'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Account'),
                      _MenuCard(items: [
                        _MenuItem(icon: Icons.person_rounded, label: 'Edit Profile', onTap: () => _showEditDialog(context, user.name)),
                        _MenuItem(icon: Icons.lock_rounded, label: 'Change Password', onTap: () => _showChangePasswordDialog(context)),
                        _MenuItem(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () {}),
                      ]),
                      const SizedBox(height: 20),
                      _sectionLabel('Preferences'),
                      _MenuCard(items: [
                        _MenuItem(icon: Icons.language_rounded, label: 'Language', onTap: () {}),
                        _MenuItem(icon: Icons.dark_mode_rounded, label: 'Dark Mode', onTap: () {}),
                        _MenuItem(icon: Icons.help_rounded, label: 'Help & Support', onTap: () {}),
                        _MenuItem(icon: Icons.info_outline_rounded, label: 'About', onTap: () => _showAbout(context)),
                      ]),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmLogout(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.wrong,
                            side: const BorderSide(color: AppColors.wrong),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 1)),
  );

  String _memberSince(String createdAt) {
    final date = DateTime.tryParse(createdAt);
    if (date == null) return 'New';
    final months = DateTime.now().difference(date).inDays ~/ 30;
    if (months < 1) return 'New';
    return '${months}mo';
  }

  void _showEditDialog(BuildContext context, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            validator: Validators.validateName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.purple),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              context.read<AuthBloc>().add(UpdateProfileRequested(ctrl.text.trim()));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile updated!'),
                  backgroundColor: AppColors.correct,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure1 = true;
    bool obscure2 = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPassCtrl,
                  obscureText: obscure1,
                  validator: Validators.validatePassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.purple),
                    suffixIcon: IconButton(
                      icon: Icon(obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textGrey),
                      onPressed: () => setState(() => obscure1 = !obscure1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: obscure2,
                  validator: (v) => Validators.validateConfirmPassword(v, newPassCtrl.text),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.purple),
                    suffixIcon: IconButton(
                      icon: Icon(obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textGrey),
                      onPressed: () => setState(() => obscure2 = !obscure2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Password changed successfully!'),
                    backgroundColor: AppColors.correct,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'TSHS Quiz',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: AppColors.purple, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.edit_rounded, color: AppColors.gold, size: 28),
      ),
      children: const [
        Text('A quiz application to train your knowledge.\nBuilt with Flutter & Clean Architecture.'),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.wrong, foregroundColor: Colors.white),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  const _ProfileStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _MenuItem({required this.icon, required this.label, required this.onTap});
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10)],
    ),
    child: Column(
      children: items.asMap().entries.map((e) {
        final isLast = e.key == items.length - 1;
        return Column(
          children: [
            ListTile(
              onTap: e.value.onTap,
              leading: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.purpleBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(e.value.icon, color: AppColors.purple, size: 20),
              ),
              title: Text(e.value.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey, size: 20),
            ),
            if (!isLast)
              Divider(height: 1, indent: 66, endIndent: 16, color: Colors.grey.shade100),
          ],
        );
      }).toList(),
    ),
  );
}