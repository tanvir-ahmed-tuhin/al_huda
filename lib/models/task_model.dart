class TaskItem {
  final String id;
  final String title;
  final String category; // 'নামাজ', 'কুরআন', 'যিকির', 'নেক আমল'
  final bool isCompleted;
  final int points;
  final String iconName;

  const TaskItem({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.points = 10,
    this.iconName = 'check',
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? category,
    bool? isCompleted,
    int? points,
    String? iconName,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      points: points ?? this.points,
      iconName: iconName ?? this.iconName,
    );
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'নেক আমল',
      isCompleted: json['isCompleted'] as bool? ?? false,
      points: json['points'] as int? ?? 10,
      iconName: json['iconName'] as String? ?? 'check',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'isCompleted': isCompleted,
      'points': points,
      'iconName': iconName,
    };
  }
}
