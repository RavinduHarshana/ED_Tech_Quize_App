// lib/presentation/bloc/dashboard_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/quiz_result_entity.dart';
import '../../../domain/usecases/quiz_result_usecases.dart';

// ── Events ────────────────────────────────────────────────
abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  final int userId;
  DashboardLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

// ── States ────────────────────────────────────────────────
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<QuizResultEntity> results;
  final Map<String, dynamic> stats;
  DashboardLoaded(this.results, this.stats);
  @override
  List<Object?> get props => [results, stats];
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetUserResultsUseCase getResultsUseCase;
  final GetUserStatsUseCase getStatsUseCase;

  DashboardBloc({
    required this.getResultsUseCase,
    required this.getStatsUseCase,
  }) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(DashboardLoadRequested e, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    final (results, rFailure) = await getResultsUseCase(e.userId);
    final (stats, sFailure) = await getStatsUseCase(e.userId);

    if (rFailure != null || sFailure != null) {
      emit(DashboardError(rFailure?.message ?? sFailure!.message));
      return;
    }
    emit(DashboardLoaded(results, stats));
  }
}