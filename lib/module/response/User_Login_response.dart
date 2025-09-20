class UserLoginResponse {
  String message;
  User user;

  UserLoginResponse({
    required this.message,
    required this.user,
  });

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) =>
      UserLoginResponse(
        message: json["message"],
        user: User.fromJson(json["user"]),
      );
}

class User {
  int userId;
  String username;
  String email;
  String fullName;
  String role;
  String wallet;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.wallet,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json["user_id"],
        username: json["username"],
        email: json["email"],
        fullName: json["full_name"],
        role: json["role"],
        wallet: json["wallet"],
      );
}
