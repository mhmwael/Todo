import 'package:flutter/foundation.dart'
    hide
        Category;
import '../models/category.dart';
import '../core/database/category_database_service.dart';

class CategoryController
    extends
        ChangeNotifier {
  final CategoryDatabaseService
  _databaseService = CategoryDatabaseService();

  List<
    Category
  >
  _categories = [];
  bool
  _isLoading = true;
  String?
  _error;

  List<
    Category
  >
  get categories => _categories;
  bool
  get isLoading => _isLoading;
  String?
  get error => _error;

  CategoryController() {
    _loadCategories();
  }

  Future<
    void
  >
  _loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _categories = await _databaseService.getAllCategories();
      _isLoading = false;
    } catch (
      e
    ) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<
    void
  >
  addCategory(
    String name,
  ) async {
    try {
      final newCategory = await _databaseService.addCategory(
        name,
      );
      _categories.add(
        newCategory,
      );
      notifyListeners();
    } catch (
      e
    ) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<
    void
  >
  updateCategory(
    int id,
    String newName,
  ) async {
    try {
      await _databaseService.updateCategory(
        id,
        newName,
      );
      final index = _categories.indexWhere(
        (
          cat,
        ) =>
            cat.id ==
            id,
      );
      if (index !=
          -1) {
        _categories[index] = Category(
          id: id,
          name: newName,
        );
      }
      notifyListeners();
    } catch (
      e
    ) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<
    void
  >
  deleteCategory(
    int id,
  ) async {
    try {
      await _databaseService.deleteCategory(
        id,
      );
      _categories.removeWhere(
        (
          cat,
        ) =>
            cat.id ==
            id,
      );
      notifyListeners();
    } catch (
      e
    ) {
      _error = e.toString();
      notifyListeners();
    }
  }

  String?
  getCategoryNameById(
    int? id,
  ) {
    if (id ==
        null) {
      return null;
    }
    try {
      return _categories
          .firstWhere(
            (
              cat,
            ) =>
                cat.id ==
                id,
          )
          .name;
    } catch (
      e
    ) {
      return null;
    }
  }
}
