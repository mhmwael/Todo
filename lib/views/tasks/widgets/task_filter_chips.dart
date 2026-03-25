import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../controllers/category_controller.dart';

class TaskFilterChips
    extends
        StatefulWidget {
  final ValueChanged<
    String
  >
  onCategoryChanged;

  const TaskFilterChips({
    super.key,
    required this.onCategoryChanged,
  });

  @override
  State<
    TaskFilterChips
  >
  createState() => _TaskFilterChipsState();
}

class _TaskFilterChipsState
    extends
        State<
          TaskFilterChips
        > {
  late String
  selectedCategory;
  final TextEditingController
  _categoryNameController = TextEditingController();

  @override
  void
  initState() {
    super.initState();
    selectedCategory = 'All';
  }

  @override
  void
  dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  void
  _showCategoryDialog(
    CategoryController categoryController,
  ) {
    showDialog(
      context: context,
      builder:
          (
            dialogContext,
          ) => AlertDialog(
            title: const Text(
              'Manage Categories',
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _categoryNameController,
                      decoration: InputDecoration(
                        hintText: 'New category name',
                        prefixIcon: const Icon(
                          Icons.add,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_categoryNameController.text.trim().isNotEmpty) {
                            categoryController.addCategory(
                              _categoryNameController.text.trim(),
                            );
                            _categoryNameController.clear();
                            Navigator.pop(
                              dialogContext,
                            );
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Category added',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.add,
                        ),
                        label: const Text(
                          'Add Category',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    const Text(
                      'Existing Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      height: 300,
                      child:
                          Consumer<
                            CategoryController
                          >(
                            builder:
                                (
                                  context,
                                  controller,
                                  _,
                                ) {
                                  return ListView.builder(
                                    itemCount: controller.categories.length,
                                    itemBuilder:
                                        (
                                          context,
                                          index,
                                        ) {
                                          final category = controller.categories[index];
                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                8.0,
                                              ),
                                            ),
                                            elevation: 2.0,
                                            child: ListTile(
                                              title: Text(
                                                category.name,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  controller.deleteCategory(
                                                    category.id!,
                                                  );
                                                  Navigator.pop(
                                                    dialogContext,
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${category.name} deleted',
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              tileColor: AppColors.surface,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 8.0,
                                              ),
                                            ),
                                          );
                                        },
                                  );
                                },
                          ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                ),
                child: const Text(
                  'Close',
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Consumer<
      CategoryController
    >(
      builder:
          (
            context,
            categoryController,
            child,
          ) {
            final categories = [
              'All',
              ...categoryController.categories.map(
                (
                  cat,
                ) => cat.name,
              ),
            ];

            return SizedBox(
              height: 56,
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 0,
                          children:
                              List<
                                Widget
                              >.generate(
                                categories.length,
                                (
                                  int index,
                                ) {
                                  final category = categories[index];
                                  final isSelected =
                                      selectedCategory ==
                                      category;
                                  return FilterChip(
                                    label: Text(
                                      category,
                                    ),
                                    selected: isSelected,
                                    onSelected:
                                        (
                                          bool value,
                                        ) {
                                          setState(
                                            () {
                                              selectedCategory = category;
                                            },
                                          );
                                          widget.onCategoryChanged(
                                            category,
                                          );
                                        },
                                    backgroundColor: AppColors.surface,
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        20,
                                      ),
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.divider,
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                    ),
                    child: IconButton(
                      onPressed: () => _showCategoryDialog(
                        categoryController,
                      ),
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textPrimary,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }
}
