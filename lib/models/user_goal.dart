enum UserGoal { maintain, lose, gain }

extension UserGoalExtension on UserGoal {
  String capitalize() {
    return name[0].toUpperCase() + name.substring(1);
  }
}
