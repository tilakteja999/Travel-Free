import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'persistent_profile_widget.dart';

class AppBarWithProfile extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showProfile;
  final Color? backgroundColor;

  const AppBarWithProfile({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showProfile = true,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);
    final bool hasDrawer = scaffold?.hasDrawer ?? false;

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      backgroundColor: backgroundColor ?? AppColors.primaryBlue,
      leading: leading ??
          (hasDrawer
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, size: 22),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : null),
      actions: [
        if (showProfile)
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: PersistentProfileWidget(),
            ),
          ),
        ...?actions,
      ],
    );
  }
}
