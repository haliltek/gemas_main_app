import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class GemasAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GemasAppBar({Key? key, required this.title, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      toolbarHeight: responsive.dp(6),
      titleSpacing: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.jpg',
            height: responsive.dp(3.5),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: responsive.dp(1.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: actions,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
