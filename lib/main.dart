// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_theme.dart';
import 'core/core/di/injection.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/subject_bloc.dart';
import 'presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const TshsQuizApp());
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