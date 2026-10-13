class ChildProfile {
  final int? id;
  final String fullName;
  final String? dateOfBirth;
  final String gender;
  final String notes;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  ChildProfile({
    this.id,
    required this.fullName,
    this.dateOfBirth,
    this.gender = '',
    this.notes = '',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as int?,
      fullName: (json['full_name'] ?? '') as String,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: (json['gender'] ?? '') as String,
      notes: (json['notes'] ?? '') as String,
      isActive: (json['is_active'] ?? true) as bool,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'full_name': fullName,
      'gender': gender,
      'notes': notes,
      'is_active': isActive,
    };
    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
      data['date_of_birth'] = dateOfBirth;
    }
    return data;
  }

  ChildProfile copyWith({
    int? id,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? notes,
    bool? isActive,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get genderLabel {
    switch (gender) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      case 'O':
        return 'Other';
      default:
        return 'Not specified';
    }
  }
}