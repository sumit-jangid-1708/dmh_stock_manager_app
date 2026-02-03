enum ReturnCondition { damaged, safe }

enum ClaimStatus { claimed, notClaimed }

enum ClaimResult { received, rejected }

extension ReturnConditionX on ReturnCondition {
  String get apiValue {
    switch (this) {
      case ReturnCondition.damaged:
        return "DAMAGED";
      case ReturnCondition.safe:
        return "SAFE";
    }
  }
}

extension ClaimStautsX on ClaimStatus {
  String get apiValue {
    switch (this) {
      case ClaimStatus.claimed:
        return "CLAIMED";
      case ClaimStatus.notClaimed:
        return "NOT_CLAIMED";
    }
  }
}

extension CLaimResultX on ClaimResult {
  String get apiValue {
    switch (this) {
      case ClaimResult.received:
        return "RECEIVED";
      case ClaimResult.rejected:
        return "RETURNED";
    }
  }
}
