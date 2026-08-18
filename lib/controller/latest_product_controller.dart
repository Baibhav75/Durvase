import '../model/latest_product_model.dart';
import '../service/Auth_servcie.dart';

class LatestProductController {
  final AuthService _authService = AuthService();

  /// Fetch Latest Products
  Future<List<LatestProduct>> fetchLatestProducts() async {
    try {
      return await _authService.getLatestProducts();
    } catch (e) {
      return [];
    }
  }
}