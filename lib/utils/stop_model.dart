import 'package:flutter/foundation.dart';

class StopModel with ChangeNotifier {
  bool value = false;

  void flip() {
    value = !value;
    notifyListeners();
  }

  void set(bool newValue) {
    value = newValue;
    notifyListeners();
  }
}
