import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/review_model.dart';
import '../../../services/review_service.dart';

class AdminReviewsScreen extends StatefulWidget {
  static const String routeName = '/admin/reviews';
  final AdminModel admin;

  const AdminReviewsScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('reviews').get();
      final list = snapshot.docs.map((d) => ReviewModel.fromMap(d.data(), d.id)).toList();
      setState(() {
        _reviews = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _replyDialog(ReviewModel review) async {
    final replyCtrl = TextEditingController(text: review.replyText ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reply to Review #${review.reviewId}'),
        content: TextField(
          controller: replyCtrl,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Admin Reply Message *', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (replyCtrl.text.trim().isEmpty) return;
              try {
                await _reviewService.replyToReview(review.reviewId, replyCtrl.text.trim(), repliedBy: widget.admin.name);
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Submit Reply'),
          ),
        ],
      ),
    );

    if (result == true) _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Reviews & Moderation Center'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReviews),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reviews.isEmpty
                ? const Center(child: Text('No guest reviews submitted yet.'))
                : ListView.builder(
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final r = _reviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: Text('${r.rating}★', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                          title: Text('Booking #${r.bookingId} — Status: ${r.status.toUpperCase()}'),
                          subtitle: Text(r.reviewText, maxLines: 2, overflow: TextOverflow.ellipsis),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAlignment.start,
                                children: [
                                  Text('Full Review: ${r.reviewText}'),
                                  if (r.replyText != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                      child: Text('Admin Reply (${r.repliedBy}): ${r.replyText}', style: const TextStyle(fontStyle: FontStyle.italic)),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                        onPressed: () async {
                                          await _reviewService.updateReviewStatus(r.reviewId, 'approved', performedBy: widget.admin.email);
                                          _loadReviews();
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.block, size: 16),
                                        label: const Text('Reject'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                        onPressed: () async {
                                          await _reviewService.updateReviewStatus(r.reviewId, 'rejected', performedBy: widget.admin.email);
                                          _loadReviews();
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.reply, size: 16),
                                        label: const Text('Reply'),
                                        onPressed: () => _replyDialog(r),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
