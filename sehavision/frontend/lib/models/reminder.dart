class Reminder {
  final int id;
  final int userId;
  final int medicineId;
  final String title;
  final String? description;
  final DateTime scheduledTime;
  final String frequency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields from join
  final String? medicineName;
  final String? medicineBrand;
  final String? dosage;

  Reminder({
    required this.id,
    required this.userId,
    required this.medicineId,
    required this.title,
    this.description,
    required this.scheduledTime,
    this.frequency = 'once',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.medicineName,
    this.medicineBrand,
    this.dosage,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      medicineId: json['medicine_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'])
          : DateTime.now(),
      frequency: json['frequency'] ?? 'once',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      medicineName: json['medicine_name'],
      medicineBrand: json['medicine_brand'],
      dosage: json['dosage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'title': title,
      'description': description,
      'scheduled_time': scheduledTime.toIso8601String(),
      'frequency': frequency,
    };
  }

  Reminder copyWith({
    int? id,
    int? userId,
    int? medicineId,
    String? title,
    String? description,
    DateTime? scheduledTime,
    String? frequency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? medicineName,
    String? medicineBrand,
    String? dosage,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicineId: medicineId ?? this.medicineId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      medicineName: medicineName ?? this.medicineName,
      medicineBrand: medicineBrand ?? this.medicineBrand,
      dosage: dosage ?? this.dosage,
    );
  }

  bool get isOverdue {
    return isActive && DateTime.now().isAfter(scheduledTime);
  }

  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
    );
    return reminderDate == today;
  }

  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final reminderDate = DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
    );
    return reminderDate == tomorrow;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return scheduledTime.isAfter(startOfWeek) &&
        scheduledTime.isBefore(endOfWeek);
  }

  String get displayName {
    if (medicineName != null && medicineName!.isNotEmpty) {
      if (medicineBrand != null && medicineBrand!.isNotEmpty) {
        return '$medicineName ($medicineBrand)';
      }
      return medicineName!;
    }
    return title;
  }

  String get timeDisplay {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (isOverdue) {
      if (difference.inDays < -1) {
        return '${(-difference.inDays)} days ago';
      } else if (difference.inHours < -1) {
        return '${(-difference.inHours)} hours ago';
      } else {
        return '${(-difference.inMinutes)} minutes ago';
      }
    } else {
      if (difference.inDays > 1) {
        return 'In ${difference.inDays} days';
      } else if (difference.inHours > 1) {
        return 'In ${difference.inHours} hours';
      } else if (difference.inMinutes > 1) {
        return 'In ${difference.inMinutes} minutes';
      } else {
        return 'Now';
      }
    }
  }

  String get frequencyDisplay {
    switch (frequency) {
      case 'once':
        return 'Once';
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return 'Once';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder &&
        other.id == id &&
        other.userId == userId &&
        other.medicineId == medicineId &&
        other.title == title &&
        other.scheduledTime == scheduledTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        medicineId.hashCode ^
        title.hashCode ^
        scheduledTime.hashCode;
  }

  @override
  String toString() {
    return 'Reminder(id: $id, title: $title, scheduledTime: $scheduledTime, isActive: $isActive)';
  }
}
