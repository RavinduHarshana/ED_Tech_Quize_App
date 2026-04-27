// lib/presentation/bloc/quiz_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/question_entity.dart';
import '../../../domain/entities/quiz_result_entity.dart';
import '../../../domain/entities/subject_entity.dart';
import '../../../domain/usecases/question_usecases.dart';
import '../../../domain/usecases/quiz_result_usecases.dart';


// ── Events ────────────────────────────────────────────────

abstract class QuizEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class QuizStarted extends QuizEvent {
  final SubjectEntity subject;
  final int userId;
  QuizStarted(this.subject, this.userId);
  @override
  List<Object?> get props => [subject, userId];
}

class QuizAnswerSelected extends QuizEvent {
  final int optionIndex;
  QuizAnswerSelected(this.optionIndex);
  @override
  List<Object?> get props => [optionIndex];
}

class QuizNextQuestion extends QuizEvent {}

class QuizFinished extends QuizEvent {}

// ── States ────────────────────────────────────────────────

abstract class QuizState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}
class QuizLoading extends QuizState {}

class QuizInProgress extends QuizState {
  final List<QuestionEntity> questions;
  final int currentIndex;
  final int? selectedAnswer;
  final bool answered;
  final int correctCount;
  final SubjectEntity subject;

  QuizInProgress({
    required this.questions,
    required this.currentIndex,
    required this.selectedAnswer,
    required this.answered,
    required this.correctCount,
    required this.subject,
  });

  QuestionEntity get currentQuestion => questions[currentIndex];
  int get totalQuestions => questions.length;
  double get progress => (currentIndex + 1) / totalQuestions;

  QuizInProgress copyWith({
    int? currentIndex,
    int? selectedAnswer,
    bool? answered,
    int? correctCount,
    bool clearSelected = false,
  }) {
    return QuizInProgress(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: clearSelected ? null : selectedAnswer ?? this.selectedAnswer,
      answered: answered ?? this.answered,
      correctCount: correctCount ?? this.correctCount,
      subject: subject,
    );
  }

  @override
  List<Object?> get props => [questions, currentIndex, selectedAnswer, answered, correctCount];
}

class QuizCompleted extends QuizState {
  final QuizResultEntity result;
  final SubjectEntity subject;
  QuizCompleted(this.result, this.subject);
  @override
  List<Object?> get props => [result, subject];
}

class QuizError extends QuizState {
  final String message;
  QuizError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetQuestionsBySubjectUseCase getQuestionsUseCase;
  final SaveQuizResultUseCase saveResultUseCase;

  late int _userId;
  late SubjectEntity _subject;

  QuizBloc({
    required this.getQuestionsUseCase,
    required this.saveResultUseCase,
  }) : super(QuizInitial()) {
    on<QuizStarted>(_onStart);
    on<QuizAnswerSelected>(_onAnswer);
    on<QuizNextQuestion>(_onNext);
    on<QuizFinished>(_onFinish);
  }

  Future<void> _onStart(QuizStarted e, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    _userId = e.userId;
    _subject = e.subject;

    final (questions, failure) = await getQuestionsUseCase(e.subject.id!);
    if (failure != null) {
      emit(QuizError(failure.message));
      return;
    }
    if (questions.isEmpty) {
      emit(QuizError('No questions available for this subject'));
      return;
    }

    emit(QuizInProgress(
      questions: questions,
      currentIndex: 0,
      selectedAnswer: null,
      answered: false,
      correctCount: 0,
      subject: _subject,
    ));
  }

  void _onAnswer(QuizAnswerSelected e, Emitter<QuizState> emit) {
    final current = state as QuizInProgress;
    if (current.answered) return;

    final isCorrect = e.optionIndex == current.currentQuestion.correctIndex;
    emit(current.copyWith(
      selectedAnswer: e.optionIndex,
      answered: true,
      correctCount: isCorrect ? current.correctCount + 1 : current.correctCount,
    ));
  }

  void _onNext(QuizNextQuestion e, Emitter<QuizState> emit) {
    final current = state as QuizInProgress;
    if (current.currentIndex + 1 >= current.totalQuestions) {
      add(QuizFinished());
      return;
    }
    emit(current.copyWith(
      currentIndex: current.currentIndex + 1,
      answered: false,
      clearSelected: true,
    ));
  }

  Future<void> _onFinish(QuizFinished e, Emitter<QuizState> emit) async {
    final current = state as QuizInProgress;
    final pct = (current.correctCount / current.totalQuestions * 100).round();

    final result = QuizResultEntity(
      userId: _userId,
      subjectId: _subject.id!,
      subjectName: _subject.name,
      correct: current.correctCount,
      total: current.totalQuestions,
      scorePct: pct,
      takenAt: DateTime.now().toIso8601String(),
    );

    await saveResultUseCase(result);
    emit(QuizCompleted(result, _subject));
  }
}