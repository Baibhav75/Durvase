import 'package:get/get.dart';

import '../model/country_model.dart';
import '../service/country_service.dart';

class CountryController extends GetxController {
  final CountryService _service = CountryService();

  final RxList<CountryModel> countries =
      <CountryModel>[].obs;

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  CountryModel? selectedCountry;

  @override
  void onInit() {
    super.onInit();

    getCountries();
  }

  Future<void> getCountries() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result =
      await _service.getAllCountries();

      countries.assignAll(result);

      print(
        '✅ Countries Loaded: ${countries.length}',
      );
    } catch (e) {
      errorMessage.value =
          e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      print(
        '❌ Country Controller Error: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectCountry(CountryModel country) {
    selectedCountry = country;

    print(
      'Selected Country: '
          '${country.countryName} '
          '(${country.countryId})',
    );

    update();
  }

  void clearSelection() {
    selectedCountry = null;

    update();
  }

  Future<void> refreshCountries() async {
    await getCountries();
  }
}