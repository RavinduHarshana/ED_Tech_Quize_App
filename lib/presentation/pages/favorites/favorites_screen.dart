// lib/presentation/pages/favorites/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/subject_bloc.dart';
import '../../../domain/entities/subject_entity.dart';
import '../../widgets/subject_tile.dart';
import '../quiz/quiz_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<SubjectBloc>().add(
        FavoriteSubjectsLoadRequested(authState.user.id!),
      );
    }
  }

  int get _userId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.id! : -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<SubjectBloc, SubjectState>(
        builder: (context, state) {
          final cachedFavorites = context.read<SubjectBloc>().favoriteSubjects;

          if (state is SubjectLoading && cachedFavorites.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.purple),
            );
          }

          final favorites = state is FavoriteSubjectsLoaded
              ? state.favorites
              : cachedFavorites;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 70,
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No favorites yet',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to add subjects you love',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Subject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: favorites.length,
            itemBuilder: (_, i) {
              final subject = favorites[i];
              return Stack(
                children: [
                  SubjectTile(
                    subject: subject,
                    onTap: () => _startQuiz(context, subject),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.pink,
                      ),
                      onPressed: () {
                        context.read<SubjectBloc>().add(
                          FavoriteToggled(_userId, subject.id!),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Subject'),
      ),
    );
  }

  void _startQuiz(BuildContext context, SubjectEntity subject) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizScreen(subject: subject, userId: authState.user.id!),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    // Need all subjects for selection
    context.read<SubjectBloc>().add(SubjectsLoadRequested());

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SubjectBloc>(),
        child: _AddFavoriteSheet(userId: _userId, onDone: _loadFavorites),
      ),
    );
  }
}

class _AddFavoriteSheet extends StatefulWidget {
  final int userId;
  final VoidCallback onDone;
  const _AddFavoriteSheet({required this.userId, required this.onDone});
  @override
  State<_AddFavoriteSheet> createState() => _AddFavoriteSheetState();
}

class _AddFavoriteSheetState extends State<_AddFavoriteSheet> {
  Set<int> _favorites = {};

  @override
  void initState() {
    super.initState();
    // Trigger subjects load
    context.read<SubjectBloc>().add(SubjectsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add to Favorites',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SubjectBloc, SubjectState>(
                builder: (context, state) {
                  if (state is SubjectsLoaded) {
                    return ListView.builder(
                      controller: scrollCtrl,
                      itemCount: state.subjects.length,
                      itemBuilder: (_, i) {
                        final s = state.subjects[i];
                        final isFav = _favorites.contains(s.id);
                        return ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: s.color.withOpacity(.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                s.icon,
                                style: TextStyle(
                                  color: s.color,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: isFav
                              ? const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.pink,
                                )
                              : const Icon(
                                  Icons.favorite_border_rounded,
                                  color: AppColors.textGrey,
                                ),
                          onTap: () async {
                            context.read<SubjectBloc>().add(
                              FavoriteToggled(widget.userId, s.id!),
                            );
                            setState(() {
                              if (isFav) {
                                _favorites.remove(s.id);
                              } else {
                                _favorites.add(s.id!);
                              }
                            });
                            await Future.delayed(
                              const Duration(milliseconds: 300),
                            );
                            if (context.mounted) {
                              widget.onDone();
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.purple),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
