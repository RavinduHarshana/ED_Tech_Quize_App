// lib/core/constants/app_constants.dart

class AppConstants {
  // Database
  static const String dbName = 'tshs_quiz.db';
  // static const int dbVersion = 1;
  static const int dbVersion = 2;

  // Tables
  static const String usersTable = 'users';
  static const String questionsTable = 'questions';
  static const String subjectsTable = 'subjects';
  static const String quizResultsTable = 'quiz_results';
  static const String favoritesTable = 'favorites';

  // SharedPrefs
  static const String loggedInUserKey = 'logged_in_user_id';

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String quizRoute = '/quiz';
  static const String resultRoute = '/result';
  static const String subjectsRoute = '/subjects';
  static const String profileRoute = '/profile';
  static const String favoritesRoute = '/favorites';
  static const String chatbotRoute = '/chatbot';
  
}
