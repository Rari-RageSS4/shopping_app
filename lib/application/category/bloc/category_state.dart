import 'package:equatable/equatable.dart';
import 'package:shopping_app/domain/category_model/category_model.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

/// Categories loaded successfully.
/// [categories] is the full list; [selectedSlug] is the active filter (null = "All").
class CategoryLoaded extends CategoryState {
  const CategoryLoaded({
    required this.categories,
    this.selectedSlug,
  });

  final List<CategoryModel> categories;
  final String? selectedSlug; // null means no category filter active

  @override
  List<Object?> get props => [categories, selectedSlug];
}

class CategoryError extends CategoryState {
  const CategoryError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
