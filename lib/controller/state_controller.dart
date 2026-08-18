import 'package:get/get.dart';
import '../model/state_model.dart';
import '../service/state_service.dart';
import '../model/district_model.dart';
import '../service/district_service.dart';
import '../model/block_model.dart';
import '../service/block_service.dart';

class StateController extends GetxController {
  final StateService _stateService = StateService();
  final DistrictService _districtService = DistrictService();
  final BlockService _blockService = BlockService();

  // State Management
  final RxList<StateModel> states = <StateModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  StateModel? selectedState;
  int? currentCountryId;

  // District Management
  final RxList<DistrictModel> districts = <DistrictModel>[].obs;
  final RxBool isDistrictsLoading = false.obs;
  final RxString districtErrorMessage = ''.obs;

  DistrictModel? selectedDistrict;
  int? currentStateId;

  // Block Management
  final RxList<BlockModel> blocks = <BlockModel>[].obs;
  final RxBool isBlocksLoading = false.obs;
  final RxString blockErrorMessage = ''.obs;

  BlockModel? selectedBlock;
  int? currentDistrictId;

  // ==================== STATE METHODS ====================

  Future<void> fetchStates(int countryId) async {
    try {
      currentCountryId = countryId;
      isLoading.value = true;
      errorMessage.value = '';
      selectedState = null;
      states.clear();
      clearDistricts();

      final result = await _stateService.getStatesByCountryId(countryId);

      states.assignAll(result);

      print('✅ States Loaded for Country $countryId: ${states.length}');
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      print('❌ State Controller Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectState(StateModel state) {
    selectedState = state;
    print('Selected State: ${state.stateName} (${state.stateId})');
    fetchDistricts(state.stateId);
    update();
  }

  void clearStates() {
    states.clear();
    selectedState = null;
    currentCountryId = null;
    errorMessage.value = '';
    clearDistricts();
    update();
  }

  Future<void> refreshStates() async {
    if (currentCountryId != null) {
      await fetchStates(currentCountryId!);
    }
  }

  // ==================== DISTRICT METHODS ====================

  Future<void> fetchDistricts(int stateId) async {
    try {
      currentStateId = stateId;
      isDistrictsLoading.value = true;
      districtErrorMessage.value = '';
      selectedDistrict = null;
      districts.clear();
      clearBlocks();

      final result = await _districtService.getDistrictsByStateId(stateId);

      districts.assignAll(result);

      print('✅ Districts Loaded for State $stateId: ${districts.length}');
    } catch (e) {
      districtErrorMessage.value =
          e.toString().replaceFirst('Exception: ', '');
      print('❌ District Controller Error: $e');
    } finally {
      isDistrictsLoading.value = false;
    }
  }

  void selectDistrict(DistrictModel district) {
    selectedDistrict = district;
    print('Selected District: ${district.districtName} (${district.districtId})');
    fetchBlocks(district.districtId);
    update();
  }

  void clearDistricts() {
    districts.clear();
    selectedDistrict = null;
    currentStateId = null;
    districtErrorMessage.value = '';
    clearBlocks();
    update();
  }

  Future<void> refreshDistricts() async {
    if (currentStateId != null) {
      await fetchDistricts(currentStateId!);
    }
  }

  // ==================== BLOCK METHODS ====================

  Future<void> fetchBlocks(int districtId) async {
    try {
      currentDistrictId = districtId;
      isBlocksLoading.value = true;
      blockErrorMessage.value = '';
      selectedBlock = null;
      blocks.clear();

      final result = await _blockService.getBlocksByDistrictId(districtId);

      blocks.assignAll(result);

      print('✅ Blocks Loaded for District $districtId: ${blocks.length}');
    } catch (e) {
      blockErrorMessage.value =
          e.toString().replaceFirst('Exception: ', '');
      print('❌ Block Controller Error: $e');
    } finally {
      isBlocksLoading.value = false;
    }
  }

  void selectBlock(BlockModel block) {
    selectedBlock = block;
    print('Selected Block: ${block.blockName} (${block.blockId})');
    update();
  }

  void clearBlocks() {
    blocks.clear();
    selectedBlock = null;
    currentDistrictId = null;
    blockErrorMessage.value = '';
    update();
  }

  Future<void> refreshBlocks() async {
    if (currentDistrictId != null) {
      await fetchBlocks(currentDistrictId!);
    }
  }
}


