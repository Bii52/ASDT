class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatar;
  final String role;
  final bool emailVerified;
  final bool phoneVerified;
  final String? specialty;
  final String? bio;
  final String? licenseNumber;
  final double averageRating;
  final int totalRatings;

  // Health Metrics
  final double? height;
  final double? weight;
  final String? bloodPressure;
  final int? heartRate;
  final String? bloodType;
  
  // Pharmacist specific fields
  final String? pharmacyName;
  final String? pharmacyLicense;
  final String? pharmacyAddress;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatar,
    required this.role,
    required this.emailVerified,
    required this.phoneVerified,
    this.specialty,
    this.bio,
    this.licenseNumber,
    required this.averageRating,
    required this.totalRatings,
    this.height,
    this.weight,
    this.bloodPressure,
    this.heartRate,
    this.bloodType,
    this.pharmacyName,
    this.pharmacyLicense,
    this.pharmacyAddress,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      avatar: json['avatar'],
      role: json['role'] ?? 'user',
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      specialty: json['specialty'],
      bio: json['bio'],
      licenseNumber: json['licenseNumber'],
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bloodPressure: json['bloodPressure'],
      heartRate: (json['heartRate'] as num?)?.toInt(),
      bloodType: json['bloodType'],
      pharmacyName: json['pharmacyName'],
      pharmacyLicense: json['pharmacyLicense'],
      pharmacyAddress: json['pharmacyAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'role': role,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'specialty': specialty,
      'bio': bio,
      'licenseNumber': licenseNumber,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'height': height,
      'weight': weight,
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
      'bloodType': bloodType,
      'pharmacyName': pharmacyName,
      'pharmacyLicense': pharmacyLicense,
      'pharmacyAddress': pharmacyAddress,
    };
  }
}
