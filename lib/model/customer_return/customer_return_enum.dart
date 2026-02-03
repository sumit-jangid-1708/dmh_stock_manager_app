enum CustomerReturnCondition { safe, damaged, lost }

extension CoustmerReturnConditionX on CustomerReturnCondition {
  String get apiValue {
    switch (this) {
      case CustomerReturnCondition.safe:
        return "SAFE";
      case CustomerReturnCondition.damaged:
        return "DAMAGED";
      case CustomerReturnCondition.lost:
        return "LOST";
    }
  }
}
