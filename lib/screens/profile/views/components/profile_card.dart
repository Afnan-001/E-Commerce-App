import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.proLableText = "Admin",
    this.isPro = false,
    this.press,
    this.isShowHi = true,
    this.isShowArrow = true,
  });

  final String name;
  final String email;
  final String proLableText;
  final bool isPro;
  final bool isShowHi;
  final bool isShowArrow;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? 'PP'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part.characters.first.toUpperCase())
            .join();

    return ListTile(
      onTap: press,
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: primaryColor.withValues(alpha: 0.12),
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      title: Wrap(
        spacing: defaultPadding / 2,
        runSpacing: defaultPadding / 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              isShowHi ? "Hi, $name" : name,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isPro)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2,
                vertical: defaultPadding / 4,
              ),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius:
                    BorderRadius.all(Radius.circular(defaultBorderRadious)),
              ),
              child: Text(
                proLableText,
                style: const TextStyle(
                  fontFamily: grandisExtendedFont,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.7,
                  height: 1,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isShowArrow
          ? SvgPicture.asset(
              "assets/icons/miniRight.svg",
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!.withValues(alpha: 0.4),
                BlendMode.srcIn,
              ),
            )
          : null,
    );
  }
}
