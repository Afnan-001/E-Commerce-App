import 'package:flutter/material.dart';

import 'package:shop/constants.dart';

class InfoBottomSheet extends StatelessWidget {
  const InfoBottomSheet({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<InfoSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 40,
                    child: BackButton(),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(defaultPadding),
                itemCount: sections.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: defaultPadding),
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.heading,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      Text(
                        section.body,
                        style: const TextStyle(height: 1.45),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoSection {
  const InfoSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}
