class UserProfile {
  const UserProfile({
    required this.id,
    required this.nickname,
    required this.phoneMasked,
    required this.avatar,
    required this.points,
    required this.vipStatus,
    required this.checkedInToday,
  });

  final String id;
  final String nickname;
  final String phoneMasked;
  final String avatar;
  final int points;
  final String vipStatus;
  final bool checkedInToday;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      phoneMasked: json['phoneMasked'] as String,
      avatar: json['avatar'] as String,
      points: json['points'] as int? ?? 0,
      vipStatus: json['vipStatus'] as String,
      checkedInToday: json['checkedInToday'] as bool? ?? false,
    );
  }

  UserProfile copyWith({
    int? points,
    bool? checkedInToday,
  }) {
    return UserProfile(
      id: id,
      nickname: nickname,
      phoneMasked: phoneMasked,
      avatar: avatar,
      points: points ?? this.points,
      vipStatus: vipStatus,
      checkedInToday: checkedInToday ?? this.checkedInToday,
    );
  }
}
