enum UserRole {
  resident,
  owner,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.resident:
        return 'User';
      case UserRole.owner:
        return 'Manager';
    }
  }

  String get subtitle {
    switch (this) {
      case UserRole.resident:
        return 'Access meals, dues & tickets';
      case UserRole.owner:
        return 'Manage property & ledgers';
    }
  }
}
