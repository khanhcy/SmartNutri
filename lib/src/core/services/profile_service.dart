import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

class ProfileService {
  final Map<String, UserProfile> _profiles = <String, UserProfile>{};

  Future<UserProfile?> getProfile(String uid) async {
    return _profiles[uid];
  }

  Future<void> upsertProfile(UserProfile profile) async {
    _profiles[profile.uid] = profile;
  }
}
