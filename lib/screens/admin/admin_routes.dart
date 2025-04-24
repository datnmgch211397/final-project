import 'package:flutter/material.dart';
import 'package:final_app2/screens/admin/manage_users_screen.dart';
import 'package:final_app2/screens/admin/manage_posts_screen.dart';
import 'package:final_app2/screens/admin/manage_reels_screen.dart';
import 'package:final_app2/screens/admin/manage_comments_screen.dart';
import 'package:final_app2/screens/admin/dashboard_screen.dart';

class AdminRoutes {
  static void goToManageUsers(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ManageUsersScreen()));
  }

  static void goToManagePosts(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ManagePostsScreen()));
  }

  static void goToManageReels(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ManageReelsScreen()));
  }

  static void goToManageComments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ManageCommentsScreen()),
    );
  }

  static void goToDashboard(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const DashboardScreen()));
  }
}
