import 'package:flutter_screenutil/flutter_screenutil.dart';

extension Em on num {
  double get em =>
      (ScreenUtil.defaultSize.width > ScreenUtil.defaultSize.height
          ? sw / 100
          : sh / 300);
}
