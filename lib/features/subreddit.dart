import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/widgets/loading_failed_indicator.dart';
import 'package:lurkur/app/widgets/loading_indicator.dart';
import 'package:lurkur/features/settings.dart';
import 'package:lurkur/features/subreddit/post_tile.dart';
import 'package:lurkur/features/subscriptions.dart';

/// Renders a subreddit's posts and scaffold content for interacting with the
/// subreddit and the rest of the app.
///
/// If a null [subreddit] is provided, then the user's home page is fetched.
class SubredditPage extends StatefulWidget {
  const SubredditPage({
    super.key,
    this.subreddit,
  });

  final String? subreddit;

  @override
  State<SubredditPage> createState() => _SubredditPageState();
}

class _SubredditPageState extends State<SubredditPage> {
  late Future<List<RedditPost>> posts;

  @override
  void initState() {
    super.initState();
    _getPosts();
  }

  @override
  void didUpdateWidget(covariant SubredditPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subreddit != widget.subreddit) {
      _getPosts();
    }
  }

  void _getPosts() {
    posts = RedditApi().getPosts(
      context,
      subreddit: widget.subreddit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Body(
        subreddit: widget.subreddit,
        posts: posts,
      ),
      bottomNavigationBar: const _BottomAppBar(),
      floatingActionButton: const _FloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.subreddit,
    required this.posts,
  });

  final String? subreddit;
  final Future<List<RedditPost>> posts;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RedditPost>>(
      future: posts,
      builder: (context, snapshot) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(subreddit ?? 'home'),
              centerTitle: false,
              floating: true,
            ),
            if (snapshot.hasError)
              const SliverFillRemaining(
                child: Center(
                  child: LoadingFailedIndicator(),
                ),
              ),
            if (!snapshot.hasData)
              const SliverFillRemaining(
                child: Center(
                  child: LoadingIndicator(),
                ),
              ),
            if (snapshot.hasData)
              SliverList.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return PostTile(
                    post: snapshot.data![index],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _FloatingActionButton extends StatelessWidget {
  const _FloatingActionButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showSubscriptionsPopup(context),
      child: const Icon(Icons.list),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => showSettingsPopup(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
