import 'package:flutter/material.dart';
import 'package:latihan_kuis_a/models/post.dart';
import 'post_detail_page.dart';

class AddToListButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const AddToListButton({super.key, this.onPressed});

  @override
  State<AddToListButton> createState() => _AddToListButtonState();
}

class _AddToListButtonState extends State<AddToListButton> {
  bool _isAdded = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isAdded = !_isAdded;
        });
        widget.onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _isAdded ? Colors.blue : Colors.white,
        foregroundColor: _isAdded ? Colors.white : Colors.black,
        side: BorderSide(color: _isAdded ? Colors.blue : Colors.grey, width: 1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(_isAdded ? 'Added' : 'Add to List'),
    );
  }
}

class PostListPage extends StatefulWidget {
  const PostListPage({super.key, required Post post});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  late List<Post> posts;

  @override
  void initState() {
    super.initState();
    posts = dummyPosts.map((post) => post).toList();
  }

  void handleVote(Post post, VoteStatus newVote) {
    setState(() {
      // Jika  tidak ada vote
      if (post.voteStatus == VoteStatus.none) {
        if (newVote == VoteStatus.upvoted) {
          post.upvotes++;
          post.voteStatus = VoteStatus.upvoted;
        } else if (newVote == VoteStatus.downvoted) {
          post.downvotes++;
          post.voteStatus = VoteStatus.downvoted;
        }
      }
      // Jika  sudah upvote
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
      // Jika  sudah downvote
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
        title: const Text('Post List'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailPage(post: post),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post.imageUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie, size: 40),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Post Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Rating
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.upvotes.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Upvote/Downvote Buttons
                          Row(
                            children: [
                              // Upvote Button
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_upward,
                                  size: 20,
                                  color: post.voteStatus == VoteStatus.upvoted
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    handleVote(post, VoteStatus.upvoted),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              Text('${post.upvotes}'),
                              const SizedBox(width: 8),

                              // Downvote Button
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_downward,
                                  size: 20,
                                  color: post.voteStatus == VoteStatus.downvoted
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    handleVote(post, VoteStatus.downvoted),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              Text('${post.downvotes}'),
                            ],
                          ),

                          const SizedBox(height: 8),

                          AddToListButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${post.title} added to list'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
