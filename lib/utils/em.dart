import 'package:flutter_screenutil/flutter_screenutil.dart';

extension Em on num {
  double get em => (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
      ? sh / 128
      : sw / 150;
}
