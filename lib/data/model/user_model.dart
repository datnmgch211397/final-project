class UserModel {
  final String email;
  final String username;
  final String bio;
  final String profile;
  final List following;
  final List followers;
  final String role;

  UserModel({
    required this.email,
    required this.username,
    required this.bio,
    required this.profile,
    required this.following,
    required this.followers,
    this.role = 'user',
  });
}
