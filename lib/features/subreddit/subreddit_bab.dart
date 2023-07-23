import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/reddit/subreddit_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/widgets/pop_ups.dart';
import 'package:lurkur/features/settings.dart';

class SubredditBab extends StatelessWidget {
  const SubredditBab({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showSortOptionsPopup(context),
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: () => showSettingsPopup(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  void _showSortOptionsPopup(BuildContext context) {
    final subredditCubit = context.read<SubredditCubit>();
    final routerCubit = context.read<RouterCubit>();
    showPrimaryPopup(
      context: context,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          children: [
            for (final option in [...SortOption.values])
              ListTile(
                leading: Icon(option.icon),
                title: Text(option.displayName),
                onTap: () {
                  subredditCubit.setSortOption(option);
                  routerCubit.pop(context);
                },
              ),
          ],
        );
      },
    );
  }
}

extension SubredditBabSortOptionX on SortOption {
  String get displayName => switch (this) {
        SortOption.hot => 'hot',
        SortOption.topHour => 'top of the hour',
        SortOption.topDay => 'top of the day',
        SortOption.topWeek => 'top of the week',
        SortOption.topMonth => 'top of the month',
        SortOption.topYear => 'top of the year',
        SortOption.topAllTime => 'top of all time',
      };

  IconData get icon => switch (this) {
        SortOption.hot => Icons.local_fire_department,
        SortOption.topHour => Icons.favorite,
        SortOption.topDay => Icons.favorite,
        SortOption.topWeek => Icons.favorite,
        SortOption.topMonth => Icons.favorite,
        SortOption.topYear => Icons.favorite,
        SortOption.topAllTime => Icons.favorite,
      };
}
