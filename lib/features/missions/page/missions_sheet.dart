import 'package:flutter/material.dart';

import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/missions/state/missions_snapshot.dart';
import 'package:night_jump/features/missions/widgets/mission_card.dart';
import 'package:night_jump/features/missions/widgets/weekly_highlight_card.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

Future<void> showMissionsSheet(
  BuildContext context, {
  MissionsRepository? repository,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        MissionsSheet(repository: repository ?? MissionsRepository()),
  );
}

class MissionsSheet extends StatefulWidget {
  const MissionsSheet({super.key, required this.repository});

  final MissionsRepository repository;

  @override
  State<MissionsSheet> createState() => _MissionsSheetState();
}

class _MissionsSheetState extends State<MissionsSheet> {
  late Future<MissionsSnapshot> _snapshotFuture;
  bool _showWeeklyTab = false;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = widget.repository.loadSnapshot();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.responsive(mobile: double.infinity, tablet: 480.0);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.canvasMidnight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(
                color: AppColor.electricCyan.withValues(alpha: 0.15),
              ),
            ),
            child: FutureBuilder<MissionsSnapshot>(
              future: _snapshotFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColor.electricCyan,
                      ),
                    ),
                  );
                }
                return _MissionsContent(
                  snapshot: snapshot.data!,
                  showWeeklyTab: _showWeeklyTab,
                  onTabChanged: (isWeekly) =>
                      setState(() => _showWeeklyTab = isWeekly),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionsContent extends StatelessWidget {
  const _MissionsContent({
    required this.snapshot,
    required this.showWeeklyTab,
    required this.onTabChanged,
  });

  final MissionsSnapshot snapshot;
  final bool showWeeklyTab;
  final ValueChanged<bool> onTabChanged;

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
                  color: AppColor.neonRose.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColor.neonRose,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RETOS Y MISIONES',
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
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppColor.slateGlow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reinicio en ${_formatCountdown(snapshot.timeUntilDailyReset)}',
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.hudGlass,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColor.electricCyan,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${snapshot.stardust}',
                      style: TextStyle(
                        color: AppColor.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_rounded, color: AppColor.slateWhite),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _PeriodTabBar(showWeeklyTab: showWeeklyTab, onChanged: onTabChanged),
          const SizedBox(height: 16),
          if (!showWeeklyTab) ...[
            for (final mission in snapshot.dailyMissions)
              MissionCard(mission: mission),
            if (snapshot.weeklyMissions.isNotEmpty) ...[
              const SizedBox(height: 4),
              WeeklyHighlightCard(mission: snapshot.weeklyMissions.first),
            ],
          ] else ...[
            for (final mission in snapshot.weeklyMissions)
              MissionCard(mission: mission),
          ],
        ],
      ),
    );
  }

  String _formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }
}

class _PeriodTabBar extends StatelessWidget {
  const _PeriodTabBar({required this.showWeeklyTab, required this.onChanged});

  final bool showWeeklyTab;
  final ValueChanged<bool> onChanged;

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
              label: 'DIARIOS',
              selected: !showWeeklyTab,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'SEMANALES',
              selected: showWeeklyTab,
              onTap: () => onChanged(true),
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
              letterSpacing: 0.1,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ),
      ),
    );
  }
}
