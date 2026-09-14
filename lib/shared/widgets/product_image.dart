import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/core/network/api_endpoints.dart';


class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ProductImageWidget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }

    // Base64 image
    if (imageUrl!.startsWith('data:image')) {
      try {
        final base64Str = imageUrl!.split(',').last;
        final Uint8List bytes = base64Decode(base64Str);

        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image.memory(
            bytes,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
        );
      } catch (_) {
        return _placeholder();
      }
    }

    // Resolve relative backend URL:
    // /uploads/products/xxx.jpg
    // ->
    // https://glowauraapimongodb-production.up.railway.app/uploads/products/xxx.jpg
    final resolvedUrl = imageUrl!.startsWith('/')
        ? '${ApiEndpoints.baseUrl}$imageUrl'
        : imageUrl!;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        resolvedUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.primarySubtle,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: (height ?? 120) * 0.4,
          color: AppColors.primaryTint,
        ),
      ),
    );
  }
}
