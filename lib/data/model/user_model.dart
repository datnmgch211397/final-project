class UserModel {
  String email;
  String username;
  String bio;
  String profile;
  List following;
  List followers;
  UserModel(
    this.email,
    this.username,
    this.bio,
    this.profile,
    this.following,
    this.followers,
  );
}
