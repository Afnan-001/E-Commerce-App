import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/review_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/app_user_model.dart';
import 'package:shop/models/product_review_model.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/repositories/product_review_repository.dart';

class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ProductReviewRepository>();
    final authProvider = context.watch<AuthProvider>();

    return StreamBuilder<List<ProductReviewModel>>(
      stream: repository.watchReviews(productId),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <ProductReviewModel>[];
        final summary = _ReviewSummary.fromReviews(reviews);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: const BorderRadius.all(
              Radius.circular(defaultBorderRadious),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product reviews',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (!authProvider.isAuthenticated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in to add a review.'),
                            ),
                          );
                          return;
                        }

                        final currentUser = authProvider.currentUser!;
                        ProductReviewModel? existingReview;
                        for (final review in reviews) {
                          if (review.userId == currentUser.uid) {
                            existingReview = review;
                            break;
                          }
                        }

                        await _showAddReviewSheet(
                          context: context,
                          repository: repository,
                          productId: productId,
                          currentUser: currentUser,
                          initialReview: existingReview,
                        );
                      },
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Write review'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              if (reviews.isEmpty)
                const Text(
                  'No reviews yet. Be the first customer to review this product.',
                )
              else ...[
                ReviewCard(
                  rating: summary.averageRating,
                  numOfReviews: summary.totalReviews,
                  numOfFiveStar: summary.fiveStar,
                  numOfFourStar: summary.fourStar,
                  numOfThreeStar: summary.threeStar,
                  numOfTwoStar: summary.twoStar,
                  numOfOneStar: summary.oneStar,
                ),
                const SizedBox(height: defaultPadding),
                ...reviews.take(6).map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: defaultPadding),
                    child: _ReviewTile(review: review),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddReviewSheet({
    required BuildContext context,
    required ProductReviewRepository repository,
    required String productId,
    required AppUserModel currentUser,
    ProductReviewModel? initialReview,
  }) async {
    final commentController = TextEditingController(
      text: initialReview?.comment ?? '',
    );
    double rating = initialReview?.rating ?? 4;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                defaultPadding,
                defaultPadding,
                defaultPadding,
                MediaQuery.of(context).viewInsets.bottom + defaultPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    initialReview == null ? 'Add review' : 'Update review',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding),
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    allowHalfRating: true,
                    itemSize: 30,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star_rounded,
                      color: warningColor,
                    ),
                    onRatingUpdate: (value) {
                      rating = value;
                    },
                  ),
                  const SizedBox(height: defaultPadding),
                  TextField(
                    controller: commentController,
                    minLines: 3,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Your review',
                      hintText: 'Share your experience with this product',
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final comment = commentController.text.trim();
                            if (comment.isEmpty) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Please add a short review comment.'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              isSubmitting = true;
                            });

                            try {
                              await repository.upsertReview(
                                productId: productId,
                                review: ProductReviewModel(
                                  userId: currentUser.uid,
                                  userName: currentUser.name,
                                  userEmail: currentUser.email,
                                  rating: rating,
                                  comment: comment,
                                ),
                              );
                              if (!sheetContext.mounted) return;
                              Navigator.pop(sheetContext);
                            } catch (error) {
                              if (!sheetContext.mounted) return;
                              setState(() {
                                isSubmitting = false;
                              });
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(
                                  content: Text(error.toString()),
                                ),
                              );
                            }
                          },
                    child: Text(
                      isSubmitting ? 'Saving...' : 'Submit review',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    commentController.dispose();
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
  });

  final ProductReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultBorderRadious),
        ),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: primaryColor.withValues(alpha: 0.12),
                child: Text(
                  _initials(review.userName),
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: defaultPadding / 2),
              Expanded(
                child: Text(
                  review.userName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: defaultPadding / 2),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating.round()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 18,
                color: warningColor,
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          Text(review.comment),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Today';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _ReviewSummary {
  const _ReviewSummary({
    required this.totalReviews,
    required this.averageRating,
    required this.fiveStar,
    required this.fourStar,
    required this.threeStar,
    required this.twoStar,
    required this.oneStar,
  });

  final int totalReviews;
  final double averageRating;
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;

  factory _ReviewSummary.fromReviews(List<ProductReviewModel> reviews) {
    if (reviews.isEmpty) {
      return const _ReviewSummary(
        totalReviews: 0,
        averageRating: 0,
        fiveStar: 0,
        fourStar: 0,
        threeStar: 0,
        twoStar: 0,
        oneStar: 0,
      );
    }

    int five = 0;
    int four = 0;
    int three = 0;
    int two = 0;
    int one = 0;
    double total = 0;

    for (final review in reviews) {
      total += review.rating;
      final rounded = review.rating.round().clamp(1, 5);
      switch (rounded) {
        case 5:
          five++;
          break;
        case 4:
          four++;
          break;
        case 3:
          three++;
          break;
        case 2:
          two++;
          break;
        default:
          one++;
      }
    }

    return _ReviewSummary(
      totalReviews: reviews.length,
      averageRating: total / reviews.length,
      fiveStar: five,
      fourStar: four,
      threeStar: three,
      twoStar: two,
      oneStar: one,
    );
  }
}
