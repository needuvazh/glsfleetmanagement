import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CargoPolicyState {
  const CargoPolicyState({
    required this.hardBlockMode,
    required this.isLoaded,
  });

  final bool hardBlockMode;
  final bool isLoaded;

  CargoPolicyState copyWith({
    bool? hardBlockMode,
    bool? isLoaded,
  }) {
    return CargoPolicyState(
      hardBlockMode: hardBlockMode ?? this.hardBlockMode,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

final cargoPolicyViewModelProvider =
    StateNotifierProvider<CargoPolicyViewModel, CargoPolicyState>(
  (ref) => CargoPolicyViewModel()..load(),
);

class CargoPolicyViewModel extends StateNotifier<CargoPolicyState> {
  CargoPolicyViewModel()
      : super(const CargoPolicyState(hardBlockMode: true, isLoaded: false));

  static const _hardBlockModeKey = 'cargo_hard_block_mode_v1';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_hardBlockModeKey) ?? true;
    state = state.copyWith(hardBlockMode: value, isLoaded: true);
  }

  Future<void> setHardBlockMode(bool value) async {
    state = state.copyWith(hardBlockMode: value, isLoaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hardBlockModeKey, value);
  }
}
