import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/review_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  final String carId;

  const ReviewsScreen({super.key, required this.carId});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(carReviewsProvider(widget.carId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text(AppStrings.reviews)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showAddReviewDialog(context, reviewsAsync.valueOrNull ?? []),
        icon: const Icon(Icons.rate_review),
        label: const Text(AppStrings.writeReview),
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return EmptyState(
              icon: Icons.reviews_outlined,
              title: AppStrings.noReviews,
              subtitle: 'Be the first to review this car',
            );
          }

          // Calculate average rating
          final avgRating =
              reviews.map((r) => r.rating).reduce((a, b) => a + b) /
              reviews.length;

          return Column(
            children: [
              // Rating summary header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.accent.withOpacity(0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        RatingBarIndicator(
                          rating: avgRating,
                          itemBuilder: (_, __) => const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                          ),
                          itemCount: 5,
                          itemSize: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Reviews list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final isOwner = currentUser?.uid == review.userId;
                    return _ReviewCard(
                      review: review,
                      isOwner: isOwner,
                      onDelete: isOwner
                          ? () => _deleteReview(context, review)
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _deleteReview(BuildContext context, ReviewModel review) async {
    final confirmed = await AppDialog.danger(
      context,
      title: 'Delete Review',
      message: 'Remove your review? This cannot be undone.',
      confirmText: 'Delete',
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed && context.mounted) {
      try {
        await ref
            .read(reviewsNotifierProvider.notifier)
            .deleteReview(review.id);
        if (context.mounted) {
          Helpers.showSnackBar(context, 'Review deleted');
        }
      } catch (e) {
        if (context.mounted) {
          Helpers.showSnackBar(context, e.toString(), isError: true);
        }
      }
    }
  }

  void _showAddReviewDialog(BuildContext context, List<ReviewModel> existing) {
    final currentUser = ref.read(currentUserProvider).valueOrNull;

    // Duplicate review check
    if (currentUser != null &&
        existing.any((r) => r.userId == currentUser.uid)) {
      Helpers.showSnackBar(
        context,
        'You have already reviewed this car',
        isError: true,
      );
      return;
    }

    double rating = 5.0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.writeReview,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: RatingBar.builder(
                      initialRating: rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: AppColors.warning),
                      onRatingUpdate: (value) {
                        setSheetState(() => rating = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: AppStrings.yourReview,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: AppStrings.submitReview,
                    onPressed: () async {
                      final user = ref.read(currentUserProvider).valueOrNull;
                      if (user == null) return;

                      Navigator.pop(context);

                      try {
                        await ref
                            .read(reviewsNotifierProvider.notifier)
                            .addReview(
                              userId: user.uid,
                              userName: user.name,
                              userPhoto: user.photoUrl,
                              carId: widget.carId,
                              rating: rating,
                              comment: commentController.text,
                            );
                        if (mounted) {
                          Helpers.showSnackBar(
                            context,
                            AppStrings.reviewSubmitted,
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          Helpers.showSnackBar(
                            context,
                            e.toString(),
                            isError: true,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isOwner;
  final VoidCallback? onDelete;

  const _ReviewCard({
    required this.review,
    required this.isOwner,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review.userPhoto.isNotEmpty
                    ? CachedNetworkImageProvider(review.userPhoto)
                    : null,
                child: review.userPhoto.isEmpty
                    ? Text(
                        review.userName.isNotEmpty ? review.userName[0] : '?',
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      Helpers.formatDate(review.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (isOwner && onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  tooltip: 'Delete review',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
