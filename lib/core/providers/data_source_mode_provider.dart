import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

final useLiveApiProvider =
    NotifierProvider<DataSourceModeNotifier, bool>(DataSourceModeNotifier.new);

class DataSourceModeNotifier extends Notifier<bool> {
  @override
  bool build() => AppConstants.useLiveApi;

  void toggle() {
    state = !state;
  }

  void setUseLiveApi(bool value) {
    state = value;
  }
}
