import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/application/category/bloc/category_event.dart';
import 'package:shopping_app/application/category/bloc/category_state.dart';
import 'package:shopping_app/infrastructure/api/category_api.dart';

/// Loads and exposes the product category list.
///
/// Categories are fetched once from GET /products/category-list and cached
/// in memory for the session. No API pagination is needed — there are ~35 categories.
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({CategoryApi? categoryApi})
      : _api = categoryApi ?? CategoryApi(),
        super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  final CategoryApi _api;

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      final categories = await _api.fetchCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }
}
