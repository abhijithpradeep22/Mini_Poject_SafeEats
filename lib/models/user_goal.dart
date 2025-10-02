enum UserGoal { maintain, lose, gain }

extension UserGoalExtension on UserGoal {
  String get displayName {
    switch (this) {
      case UserGoal.maintain:
        return "Maintain Weight";
      case UserGoal.lose:
        return "Weight Loss";
      case UserGoal.gain:
        return "Weight Gain";
    }
  }

  static UserGoal fromString(String value) {
    switch (value.toLowerCase()) {
      case 'maintain':
        return UserGoal.maintain;
      case 'lose':
        return UserGoal.lose;
      case 'gain':
        return UserGoal.gain;
      default:
        return UserGoal.maintain;
    }
  }
}
