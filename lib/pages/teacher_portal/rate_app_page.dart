import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'widgets/coming_soon.dart';

class RateAppPage extends StatelessWidget {
  const RateAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      title: 'Rate the App',
      icon: Iconsax.star1,
      subtitle: 'Your feedback helps us improve. Rate the app here soon.',
    );
  }
}
