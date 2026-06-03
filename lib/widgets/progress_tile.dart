import 'package:flutter/material.dart';

class ProgressTile extends StatelessWidget {
  const ProgressTile({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.progress,
  });

  final String label;
  final String value;
  final String? subtitle;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label),
        subtitle: subtitle == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(subtitle!),
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress),
                    ],
                  ],
                ),
              ),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
