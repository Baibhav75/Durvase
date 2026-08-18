import '../model/banner_model.dart';
import '../service/Auth_servcie.dart';

class BannerController {

  final AuthService _service = AuthService();

  Future<List<BannerItem>> fetchBanners() {
    return _service.getBannerImages();
  }

}