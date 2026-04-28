class UserModel {
  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? birthDate;
  final String? avatarUrl;
  final String? createdAt;
  final String? position;
  final String? payoutWavePhone;
  final String? payoutOrangePhone;
  final String? payoutFreePhone;
  final String? preferredPayoutMethod;

  UserModel({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.avatarUrl,
    this.createdAt,
    this.position,
    this.payoutWavePhone,
    this.payoutOrangePhone,
    this.payoutFreePhone,
    this.preferredPayoutMethod,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      birthDate: json['birthDate'],
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'],
      position: json['position'],
      payoutWavePhone: json['payoutWavePhone'],
      payoutOrangePhone: json['payoutOrangePhone'],
      payoutFreePhone: json['payoutFreePhone'],
      preferredPayoutMethod: json['preferredPayoutMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
      'position': position,
      'payoutWavePhone': payoutWavePhone,
      'payoutOrangePhone': payoutOrangePhone,
      'payoutFreePhone': payoutFreePhone,
      'preferredPayoutMethod': preferredPayoutMethod,
    };
  }
}
