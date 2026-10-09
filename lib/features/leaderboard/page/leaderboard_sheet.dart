import 'package:flutter/material.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/leaderboard/state/leaderboard_repository.dart';
import 'package:night_jump/utils/theme/app_color.dart';

Future<void> showLeaderboardSheet(
  BuildContext context, {
  LeaderboardRepository? repository,
  VoidCallback? onPlayNow,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: AppColor.canvasMidnight,
  builder: (_) => LeaderboardSheet(
    repository: repository ?? LeaderboardRepository(),
    onPlayNow: onPlayNow,
  ),
);

class LeaderboardSheet extends StatefulWidget {
  const LeaderboardSheet({super.key, required this.repository, this.onPlayNow});
  final LeaderboardRepository repository;
  final VoidCallback? onPlayNow;
  @override
  State<LeaderboardSheet> createState() => _LeaderboardSheetState();
}

class _LeaderboardSheetState extends State<LeaderboardSheet> {
  late final _scores = widget.repository.loadSnapshot();
  late final _legacy = widget.repository.scoreRepository.getLegacyScore();
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'MIS RÉCORDS',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 24,
              color: AppColor.electricCyan,
            ),
          ),
          const Text(
            'Guardados en este dispositivo',
            style: TextStyle(color: AppColor.slateWhite),
          ),
          FutureBuilder<Map<GameDifficulty, int>>(
            future: _scores,
            builder: (context, snapshot) => Column(
              children: [
                for (final mode in GameDifficulty.values)
                  ListTile(
                    title: Text(
                      mode.label,
                      style: const TextStyle(color: AppColor.slateWhite),
                    ),
                    trailing: Text(
                      snapshot.hasData ? '${snapshot.data![mode]}' : '…',
                      style: const TextStyle(
                        color: AppColor.electricCyan,
                        fontSize: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          FutureBuilder<int>(
            future: _legacy,
            builder: (_, snapshot) => (snapshot.data ?? 0) > 0
                ? Text(
                    'Récord anterior sin modo: ${snapshot.data}',
                    style: const TextStyle(color: AppColor.slateWhite),
                  )
                : const SizedBox.shrink(),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPlayNow?.call();
            },
            child: const Text('JUGAR'),
          ),
        ],
      ),
    ),
  );
}
