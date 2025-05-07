import 'package:get/get.dart';

import '../../Model/GlobalModels/state_model.dart';
import '../../network/Service/state_service.dart';

class StateController extends GetxController {
  final StateService _stateService = StateService();
  var states = <StateModel>[].obs;
  var isLoading = true.obs;
  var selectedStateId = ''.obs;
  var selectedStateName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStates();
  }

  Future<void> fetchStates() async {
    try {
      isLoading.value = true;
      final stateList = await _stateService.fetchStates();
      states.assignAll(stateList);
    } catch (e) {
      print('Error fetching states: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedState(String? stateName) {
    selectedStateName.value = stateName ?? '';
    final selected = states.firstWhere(
      (state) => state.stateName == stateName,
      orElse: () => StateModel(id: '', stateName: ''),
    );
    selectedStateId.value = selected.id;
    print('Selected State ID: ${selectedStateId.value}');
  }
}