class User {
  final int userId;
  final String name;
  final String empId;
  final String email;
  final String? designation;
  final String? usefor;

  User({
    required this.userId,
    required this.name,
    required this.empId,
    required this.email,
    this.designation,
    this.usefor,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    return User(
      userId: parseInt(json['user_id'] ?? json['id']),
      name: json['name'] ?? '',
      empId: (json['emp_id'] ?? '').toString(),
      email: json['email'] ?? '',
      designation: json['designation'],
      usefor: json['usefor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'emp_id': empId,
      'email': email,
      'designation': designation,
      'usefor': usefor,
    };
  }
}
