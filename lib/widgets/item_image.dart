import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/item.dart';

class ItemImage extends StatelessWidget {
  final Item item;
  final double size;

  const ItemImage({super.key, required this.item, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      item.image,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.style, size: size * 0.75, color: brown);
      },
    );
  }
}
