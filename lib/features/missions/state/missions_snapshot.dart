import 'package:night_jump/features/missions/state/mission.dart';

class MissionsSnapshot {
  const MissionsSnapshot({
    required this.stardust,
    required this.timeUntilDailyReset,
    required this.dailyMissions,
    required this.weeklyMissions,
  });

  final int stardust;
  final Duration timeUntilDailyReset;
  final List<Mission> dailyMissions;
  final List<Mission> weeklyMissions;
}
