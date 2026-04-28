// lib/presentation/bloc/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final UpdateUserUseCase updateUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.updateUserUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<UpdateUserRequested>(_onUpdateUser);
  }

  Future<void> _onCheck(AuthCheckRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = await getCurrentUserUseCase();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final (user, failure) = await loginUseCase(e.email, e.password);
    if (failure != null) {
      emit(AuthError(failure.message));
    } else {
      emit(AuthAuthenticated(user!));
    }
  }

  Future<void> _onRegister(RegisterRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final (user, failure) = await registerUseCase(e.name, e.email, e.password);
    if (failure != null) {
      emit(AuthError(failure.message));
    } else {
      emit(AuthAuthenticated(user!));
    }
  }

  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested e,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;
    final updated = currentState.user.copyWith(name: e.name);
    await _persistAndEmit(updated, currentState.user, emit);
  }

  Future<void> _onUpdateUser(
    UpdateUserRequested e,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;
    await _persistAndEmit(e.user, currentState.user, emit);
  }

  Future<void> _persistAndEmit(
    UserEntity updated,
    UserEntity fallback,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final (ok, failure) = await updateUserUseCase(updated);
    if (failure != null) {
      emit(AuthError(failure.message));
      emit(AuthAuthenticated(fallback));
    } else if (ok) {
      emit(AuthAuthenticated(updated));
    } else {
      emit(AuthError('Failed to update user'));
      emit(AuthAuthenticated(fallback));
    }
  }
}
