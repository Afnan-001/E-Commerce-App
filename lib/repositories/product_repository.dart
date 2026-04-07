import 'package:shop/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getPopularProducts();
  Future<List<ProductModel>> getFlashSaleProducts();
  Future<List<ProductModel>> getBestSellerProducts();
  Future<List<ProductModel>> getMostPopularProducts();
  Future<List<ProductModel>> getBookmarkedProducts();
}

class DemoProductRepository implements ProductRepository {
  const DemoProductRepository();

  @override
  Future<List<ProductModel>> getBestSellerProducts() async {
    return demoBestSellersProducts;
  }

  @override
  Future<List<ProductModel>> getBookmarkedProducts() async {
    return demoPopularProducts;
  }

  @override
  Future<List<ProductModel>> getFlashSaleProducts() async {
    return demoFlashSaleProducts;
  }

  @override
  Future<List<ProductModel>> getMostPopularProducts() async {
    return demoPopularProducts;
  }

  @override
  Future<List<ProductModel>> getPopularProducts() async {
    return demoPopularProducts;
  }
}
