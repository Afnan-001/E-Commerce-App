import 'package:shop/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getDiscoverCategories();
}

class DemoCategoryRepository implements CategoryRepository {
  const DemoCategoryRepository();

  @override
  Future<List<CategoryModel>> getDiscoverCategories() async {
    return demoCategories;
  }
}
