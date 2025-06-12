import 'package:flutter/foundation.dart';

class Notifier with ChangeNotifier {
  void trigger() {
    notifyListeners();
  }
}
