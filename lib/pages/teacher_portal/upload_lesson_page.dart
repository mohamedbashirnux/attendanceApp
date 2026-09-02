import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'widgets/coming_soon.dart';

class UploadLessonPage extends StatelessWidget {
  const UploadLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      title: 'Upload Lesson',
      icon: Iconsax.document_upload,
      subtitle: 'Upload and share lesson materials with your class soon.',
    );
  }
}
