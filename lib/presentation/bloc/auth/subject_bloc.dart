// lib/presentation/bloc/subject_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/subject_entity.dart';
import '../../../domain/usecases/subject_usecases.dart';

// ── Events ────────────────────────────────────────────────
abstract class SubjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubjectsLoadRequested extends SubjectEvent {}

class FavoriteSubjectsLoadRequested extends SubjectEvent {
  final int userId;
  FavoriteSubjectsLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class FavoriteToggled extends SubjectEvent {
  final int userId;
  final int subjectId;
  FavoriteToggled(this.userId, this.subjectId);
  @override
  List<Object?> get props => [userId, subjectId];
}

// ── States ────────────────────────────────────────────────
abstract class SubjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {}

class SubjectsLoaded extends SubjectState {
  final List<SubjectEntity> subjects;
  SubjectsLoaded(this.subjects);
  @override
  List<Object?> get props => [subjects];
}

class FavoriteSubjectsLoaded extends SubjectState {
  final List<SubjectEntity> favorites;
  FavoriteSubjectsLoaded(this.favorites);
  @override
  List<Object?> get props => [favorites];
}

class SubjectError extends SubjectState {
  final String message;
  SubjectError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────
class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final GetAllSubjectsUseCase getAllSubjectsUseCase;
  final GetFavoriteSubjectsUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  List<SubjectEntity> _allSubjects = const [];
  List<SubjectEntity> _favoriteSubjects = const [];

  List<SubjectEntity> get allSubjects => _allSubjects;
  List<SubjectEntity> get favoriteSubjects => _favoriteSubjects;

  SubjectBloc({
    required this.getAllSubjectsUseCase,
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(SubjectInitial()) {
    on<SubjectsLoadRequested>(_onLoadAll);
    on<FavoriteSubjectsLoadRequested>(_onLoadFavorites);
    on<FavoriteToggled>(_onToggle);
  }

  Future<void> _onLoadAll(
    SubjectsLoadRequested e,
    Emitter<SubjectState> emit,
  ) async {
    if (_allSubjects.isEmpty) {
      emit(SubjectLoading());
    }
    final (subjects, failure) = await getAllSubjectsUseCase();
    if (failure != null) {
      emit(SubjectError(failure.message));
    } else {
      _allSubjects = subjects;
      emit(SubjectsLoaded(subjects));
    }
  }

  Future<void> _onLoadFavorites(
    FavoriteSubjectsLoadRequested e,
    Emitter<SubjectState> emit,
  ) async {
    if (_favoriteSubjects.isEmpty) {
      emit(SubjectLoading());
    }
    final (favorites, failure) = await getFavoritesUseCase(e.userId);
    if (failure != null) {
      emit(SubjectError(failure.message));
    } else {
      _favoriteSubjects = favorites;
      emit(FavoriteSubjectsLoaded(favorites));
    }
  }

  Future<void> _onToggle(FavoriteToggled e, Emitter<SubjectState> emit) async {
    await toggleFavoriteUseCase(e.userId, e.subjectId);
    add(FavoriteSubjectsLoadRequested(e.userId));
  }
}
