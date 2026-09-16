import 'package:flutter/material.dart';

import 'package:night_jump/features/leaderboard/state/leaderboard_repository.dart';
import 'package:night_jump/features/leaderboard/state/leaderboard_snapshot.dart';
import 'package:night_jump/features/leaderboard/widgets/leaderboard_progress_banner.dart';
import 'package:night_jump/features/leaderboard/widgets/leaderboard_tile.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// Opens the "Rankings Globales" screen as a modal bottom sheet.
Future<void> showLeaderboardSheet(
  BuildContext context, {
  LeaderboardRepository? repository,
  VoidCallback? onPlayNow,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => LeaderboardSheet(
      repository: repository ?? LeaderboardRepository(),
      onPlayNow: onPlayNow,
    ),
  );
}

class LeaderboardSheet extends StatefulWidget {
  const LeaderboardSheet({super.key, required this.repository, this.onPlayNow});

  final LeaderboardRepository repository;
  final VoidCallback? onPlayNow;

  @override
  State<LeaderboardSheet> createState() => _LeaderboardSheetState();
}

class _LeaderboardSheetState extends State<LeaderboardSheet> {
  LeaderboardTab _tab = LeaderboardTab.global;
  late Future<LeaderboardSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = widget.repository.loadSnapshot(tab: _tab);
  }

  void _changeTab(LeaderboardTab tab) {
    setState(() {
      _tab = tab;
      _snapshotFuture = widget.repository.loadSnapshot(tab: tab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.responsive(mobile: double.infinity, tablet: 480.0);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.canvasMidnight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: AppColor.electricCyan.withValues(alpha: 0.2),
              ),
            ),
            child: FutureBuilder<LeaderboardSnapshot>(
              future: _snapshotFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColor.electricCyan),
                    ),
                  );
                }
                return _LeaderboardContent(
                  snapshot: snapshot.data!,
                  tab: _tab,
                  onTabChanged: _changeTab,
                  onPlayNow: widget.onPlayNow,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  const _LeaderboardContent({
    required this.snapshot,
    required this.tab,
    required this.onTabChanged,
    required this.onPlayNow,
  });

  final LeaderboardSnapshot snapshot;
  final LeaderboardTab tab;
  final ValueChanged<LeaderboardTab> onTabChanged;
  final VoidCallback? onPlayNow;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColor.slateGlow.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColor.electricCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: AppColor.electricCyan,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RÁNKINGS GLOBALES',
                      style: TextStyle(
                        color: AppColor.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Sora',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: AppColor.electricCyan),
                        const SizedBox(width: 6),
                        Text(
                          'SERVIDOR ACTIVO • ${snapshot.seasonLabel}',
                          style: TextStyle(
                            color: AppColor.slateGlow,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_rounded, color: AppColor.slateWhite),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.hudGlass.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: AppColor.slateGlow),
                const SizedBox(width: 6),
                Text(
                  'Termina en ${_formatCountdown(snapshot.seasonEndsIn)}',
                  style: TextStyle(
                    color: AppColor.slateGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                const Spacer(),
                Icon(Icons.bolt_rounded, size: 14, color: AppColor.electricCyan),
                const SizedBox(width: 4),
                Text(
                  snapshot.modeLabel,
                  style: TextStyle(
                    color: AppColor.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _LeaderboardTabBar(tab: tab, onChanged: onTabChanged),
          const SizedBox(height: 16),
          for (final entry in snapshot.topEntries) LeaderboardTile(entry: entry),
          const SizedBox(height: 4),
          LeaderboardTile(entry: snapshot.playerEntry),
          const SizedBox(height: 8),
          LeaderboardProgressBanner(
            pointsToNextRank: snapshot.pointsToNextRank,
            nextRank: snapshot.nextRank,
            currentScore: snapshot.playerEntry.score,
            nextRankScore: snapshot.playerEntry.score + snapshot.pointsToNextRank,
          ),
          const SizedBox(height: 16),
          _PlayNowButton(onTap: onPlayNow),
        ],
      ),
    );
  }

  String _formatCountdown(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    return '${days}d ${hours.toString().padLeft(2, '0')}h';
  }
}

class _LeaderboardTabBar extends StatelessWidget {
  const _LeaderboardTabBar({required this.tab, required this.onChanged});

  final LeaderboardTab tab;
  final ValueChanged<LeaderboardTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.canvasBase,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Global',
              selected: tab == LeaderboardTab.global,
              onTap: () => onChanged(LeaderboardTab.global),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Amigos',
              selected: tab == LeaderboardTab.friends,
              onTap: () => onChanged(LeaderboardTab.friends),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Liga T4',
              selected: tab == LeaderboardTab.league,
              onTap: () => onChanged(LeaderboardTab.league),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColor.electricCyan : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColor.canvasBase : AppColor.slateGlow,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayNowButton extends StatelessWidget {
  const _PlayNowButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.electricCyan,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pop();
          onTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.electricCyan.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, color: AppColor.canvasBase, size: 20),
              const SizedBox(width: 8),
              Text(
                'JUGAR AHORA & SUPERAR RÉCORD',
                style: TextStyle(
                  color: AppColor.canvasBase,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.05,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
