import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

/// Dispatched once when the home page loads to populate the category row.
class LoadCategories extends CategoryEvent {
  const LoadCategories();
}
