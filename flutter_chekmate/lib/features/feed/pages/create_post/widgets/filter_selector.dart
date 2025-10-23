import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Filter Selector - TikTok-like filters for images and videos
class FilterSelector extends StatelessWidget {
  const FilterSelector({
    required this.selectedFilter,
    required this.onFilterSelected,
    super.key,
  });
  final String? selectedFilter;
  final void Function(String?) onFilterSelected;

  static const List<Map<String, dynamic>> filters = [
    {'id': null, 'name': 'Normal', 'icon': Icons.filter_none},
    {'id': 'beauty', 'name': 'Beauty', 'icon': Icons.face_retouching_natural},
    {'id': 'vintage', 'name': 'Vintage', 'icon': Icons.filter_vintage},
    {'id': 'vivid', 'name': 'Vivid', 'icon': Icons.filter_hdr},
    {'id': 'bw', 'name': 'B&W', 'icon': Icons.filter_b_and_w},
    {'id': 'warm', 'name': 'Warm', 'icon': Icons.wb_sunny},
    {'id': 'cool', 'name': 'Cool', 'icon': Icons.ac_unit},
    {'id': 'dramatic', 'name': 'Dramatic', 'icon': Icons.filter_drama},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.auto_fix_high,
              color: AppColors.primary,
              size: 20,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              'Filters & Effects',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = selectedFilter == filter['id'];

              return Padding(
                padding: EdgeInsets.only(
                  right: index < filters.length - 1 ? AppSpacing.sm : 0,
                ),
                child: _buildFilterItem(
                  id: filter['id'] as String?,
                  name: filter['name'] as String,
                  icon: filter['icon'] as IconData,
                  isSelected: isSelected,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterItem({
    required String? id,
    required String name,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onFilterSelected(id),
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: SizedBox(
          width: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
