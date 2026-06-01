import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// 通用搜索栏组件
class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCameraTap;
  final VoidCallback? onFilterTap;
  final bool showCameraButton;
  final bool showFilterButton;

  const SearchBar({
    super.key,
    required this.controller,
    this.hintText = '搜索商品名称',
    this.onSubmitted,
    this.onCameraTap,
    this.onFilterTap,
    this.showCameraButton = true,
    this.showFilterButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.tapTarget + 4,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.m),
          const Icon(Icons.search, color: AppColors.textHint, size: 20),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.bodySecondary,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (showCameraButton)
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.textSecondary),
              onPressed: onCameraTap,
              constraints: const BoxConstraints(
                minWidth: AppSpacing.tapTarget,
                minHeight: AppSpacing.tapTarget,
              ),
            ),
          if (showFilterButton)
            IconButton(
              icon: const Icon(Icons.tune, color: AppColors.textSecondary),
              onPressed: onFilterTap,
              constraints: const BoxConstraints(
                minWidth: AppSpacing.tapTarget,
                minHeight: AppSpacing.tapTarget,
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }
}