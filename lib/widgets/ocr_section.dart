import 'package:flutter/material.dart';

class OCRSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;

  const OCRSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(imagePath),
        ),
        const SizedBox(height: 10),
        Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
