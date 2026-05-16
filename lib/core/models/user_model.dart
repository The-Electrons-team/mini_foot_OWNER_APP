class UserModel {
  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? birthDate;
  final String? avatarUrl;
  final String? cniNumber;
  final String? cniFrontUrl;
  final String? cniBackUrl;
  final String? ownerStatus;
  final String? ownerRejectionReason;
  final String? createdAt;
  final String? position;
  final String? payoutWavePhone;
  final String? payoutOrangePhone;
  final String? payoutFreePhone;
  final String? preferredPayoutMethod;
  final String role;

  UserModel({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.avatarUrl,
    this.cniNumber,
    this.cniFrontUrl,
    this.cniBackUrl,
    this.ownerStatus,
    this.ownerRejectionReason,
    this.createdAt,
    this.position,
    this.payoutWavePhone,
    this.payoutOrangePhone,
    this.payoutFreePhone,
    this.preferredPayoutMethod,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      birthDate: json['birthDate'],
      avatarUrl: json['avatarUrl'],
      cniNumber: json['cniNumber'] ?? json['cni_number'],
      cniFrontUrl: json['cniFrontUrl'] ?? json['cni_front_url'],
      cniBackUrl: json['cniBackUrl'] ?? json['cni_back_url'],
      ownerStatus: (json['ownerStatus'] ?? json['owner_status'])?.toString(),
      ownerRejectionReason: json['ownerRejectionReason'],
      createdAt: json['createdAt'],
      position: json['position'],
      payoutWavePhone: json['payoutWavePhone'],
      payoutOrangePhone: json['payoutOrangePhone'],
      payoutFreePhone: json['payoutFreePhone'],
      preferredPayoutMethod: json['preferredPayoutMethod'],
      role: (json['role'] ?? json['role_name'] ?? '').toString().trim(),
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
      'cniNumber': cniNumber,
      'cniFrontUrl': cniFrontUrl,
      'cniBackUrl': cniBackUrl,
      'ownerStatus': ownerStatus,
      'ownerRejectionReason': ownerRejectionReason,
      'createdAt': createdAt,
      'position': position,
      'payoutWavePhone': payoutWavePhone,
      'payoutOrangePhone': payoutOrangePhone,
      'payoutFreePhone': payoutFreePhone,
      'preferredPayoutMethod': preferredPayoutMethod,
      'role': role,
    };
  }

  bool get isController => role == 'CONTROLLER';
  bool get isOwner => role == 'OWNER';
  bool get canUseOwnerApp => isOwner || isController;
  bool get isOwnerApproved =>
      !isOwner ||
      ownerStatus?.toUpperCase() == 'APPROVED' ||
      ownerStatus?.toUpperCase() == 'NOT_REQUIRED';
  bool get isOwnerPending => isOwner && ownerStatus == 'PENDING';
  bool get isOwnerRejected => isOwner && ownerStatus == 'REJECTED';
}
