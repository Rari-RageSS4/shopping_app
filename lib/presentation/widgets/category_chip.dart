import 'package:flutter/material.dart';
import 'package:shopping_app/core/theme/app_theme.dart';
import 'package:shopping_app/domain/category_model/category_model.dart';

/// A horizontally scrollable row of category filter chips.
///
/// Includes an "All" chip at the start that clears any active filter.
/// The selected chip is highlighted with the primary colour.
///
/// [onCategorySelected] is called with the slug, or null for "All".
class CategoryChipRow extends StatelessWidget {
  const CategoryChipRow({
    super.key,
    required this.categories,
    required this.selectedSlug,
    required this.onCategorySelected,
  });

  final List<CategoryModel> categories;
  final String? selectedSlug; // null = "All" is selected
  final void Function(String? slug) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        itemCount: categories.length + 1, // +1 for the "All" chip
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppTheme.spacingSm),
        itemBuilder: (context, index) {
          // Center loosens the list's tight height so the chip keeps its own
          // height and its label is vertically centred.
          if (index == 0) {
            return Center(
              child: _CategoryChip(
                label: 'All',
                isSelected: selectedSlug == null,
                onTap: () => onCategorySelected(null),
              ),
            );
          }
          final category = categories[index - 1];
          return Center(
            child: _CategoryChip(
              label: category.displayName,
              isSelected: selectedSlug == category.slug,
              onTap: () => onCategorySelected(category.slug),
            ),
          );
        },
      ),
    );
  }
}

/// An individual category chip with selected/unselected visual states.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusFull);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: radius,
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: 1.5,
          ),
          boxShadow: isSelected ? AppTheme.softShadow : const [],
        ),
        // The transparent Material sits above the decoration so the ripple
        // is visible on top of the chip colour.
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              child: AnimatedDefaultTextStyle(
                duration: AppTheme.durationFast,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.textOnDark
                          : AppTheme.textPrimary,
                    ),
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}