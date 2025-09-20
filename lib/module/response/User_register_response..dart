// To parse this JSON data, do
//
//     final userRegisterResponse = userRegisterResponseFromJson(jsonString);

import 'dart:convert';

UserRegisterResponse userRegisterResponseFromJson(String str) => UserRegisterResponse.fromJson(json.decode(str));

String userRegisterResponseToJson(UserRegisterResponse data) => json.encode(data.toJson());

class UserRegisterResponse {
    String username;
    String password;
    String fullName;
    String email;
    String role;
    int wallet;

    UserRegisterResponse({
        required this.username,
        required this.password,
        required this.fullName,
        required this.email,
        required this.role,
        required this.wallet,
    });

    factory UserRegisterResponse.fromJson(Map<String, dynamic> json) => UserRegisterResponse(
        username: json["username"],
        password: json["password"],
        fullName: json["full_name"],
        email: json["email"],
        role: json["role"],
        wallet: json["wallet"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
        "full_name": fullName,
        "email": email,
        "role": role,
        "wallet": wallet,
    };
}
