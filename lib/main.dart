// lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quize_app/core/services/notification_service.dart';
import 'core/constants/app_theme.dart';
import 'core/core/di/injection.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/subject_bloc.dart';
import 'presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const TshsQuizApp());
  unawaited(_initNotifications());
}

Future<void> _initNotifications() async {
  try {
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermission();
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }
}

class TshsQuizApp extends StatelessWidget {
  const TshsQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: sl(),
            registerUseCase: sl(),
            getCurrentUserUseCase: sl(),
            logoutUseCase: sl(),
            updateUserUseCase: sl(),
          ),
        ),
        BlocProvider<SubjectBloc>(
          create: (_) => SubjectBloc(
            getAllSubjectsUseCase: sl(),
            getFavoritesUseCase: sl(),
            toggleFavoriteUseCase: sl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'TSHS Quiz',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
