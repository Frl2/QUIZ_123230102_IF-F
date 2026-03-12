import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Post post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  void handleVote(VoteStatus newVote) {
    setState(() {
      // Jika sebelumnya tidak ada vote
      if (post.voteStatus == VoteStatus.none) {
        if (newVote == VoteStatus.upvoted) {
          post.upvotes++;
          post.voteStatus = VoteStatus.upvoted;
        } else if (newVote == VoteStatus.downvoted) {
          post.downvotes++;
          post.voteStatus = VoteStatus.downvoted;
        }
      }
      // Jika sebelumnya sudah upvote
      else if (post.voteStatus == VoteStatus.upvoted) {
        if (newVote == VoteStatus.upvoted) {
          // Membatalkan upvote
          post.upvotes--;
          post.voteStatus = VoteStatus.none;
        } else if (newVote == VoteStatus.downvoted) {
          // Ganti dari upvote ke downvote
          post.upvotes--;
          post.downvotes++;
          post.voteStatus = VoteStatus.downvoted;
        }
      }
      // Jika sebelumnya sudah downvote
      else if (post.voteStatus == VoteStatus.downvoted) {
        if (newVote == VoteStatus.downvoted) {
          // Membatalkan downvote
          post.downvotes--;
          post.voteStatus = VoteStatus.none;
        } else if (newVote == VoteStatus.upvoted) {
          // Ganti dari downvote ke upvote
          post.downvotes--;
          post.upvotes++;
          post.voteStatus = VoteStatus.upvoted;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Picture
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[900],
                  child: Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          post.upvotes.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Username
                  Text(
                    post.username,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  // Upvote/Downvote Buttons (Horizontal)
                  Row(
                    children: [
                      // Upvote Button
                      IconButton(
                        icon: Icon(
                          Icons.arrow_upward,
                          color: post.voteStatus == VoteStatus.upvoted
                              ? Colors.orange
                              : Colors.grey,
                          size: 28,
                        ),
                        onPressed: () => handleVote(VoteStatus.upvoted),
                      ),
                      Text(
                        '${post.upvotes}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 16),

                      // Downvote Button
                      IconButton(
                        icon: Icon(
                          Icons.arrow_downward,
                          color: post.voteStatus == VoteStatus.downvoted
                              ? Colors.blue
                              : Colors.grey,
                          size: 28,
                        ),
                        onPressed: () => handleVote(VoteStatus.downvoted),
                      ),
                      Text(
                        '${post.downvotes}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Content
                  const Text(
                    'Content',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Comments Section
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...post.comments.map(
                    (comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.comment,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(comment)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Url Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final Uri url = Uri.parse(post.postUrl);
                        try {
                          if (!await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not launch page'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open Page'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
