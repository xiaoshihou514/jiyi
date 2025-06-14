<div align="center">
    <h1>记忆</h1>
</div>

记忆是一款跨平台加密语音日志应用

- _你的心声值得保护_：在当今云端服务越来越多的情况下，隐私问题成了一个黑盒。记忆的所有功能均为本地运行，充分保护您的隐私。
- _听见过去的自己_：在繁忙的生活中，手写日记似乎成了一种奢侈。打开手机录一小段话，记录当前的自己。
- _看见过去的足迹_：走遍世界，在世界的各个角落留下声音！记忆支持记录录音时的地理位置，帮你可视化你的旅途。

![](https://github.com/user-attachments/assets/0943329e-faa0-4786-9a47-cce64bd72ede)

## 技术栈

- 加密系统：[Argon2](https://en.wikipedia.org/wiki/Argon2)，[ChaCha20-Poly1305](https://en.wikipedia.org/wiki/ChaCha20-Poly1305)
- 语音识别系统：[新一代Kaldi（sherpa-onnx）](https://github.com/k2-fsa/sherpa-onnx)

## 构建

安装依赖：

```shell
sudo dnf install
    gstreamer1 \                                     # 录音
    gstreamer1-devel gstreamer1-plugins-base-devel \ # 播放
    pam-devel                                        # 身份验证
```

`flutter doctor`（我的配置）：

<details>
[✓] Flutter (Channel stable, 3.32.1, on Fedora Linux 41 (Workstation Edition) 6.14.5-200.fc41.x86_64, locale zh_CN.UTF-8) [122ms]
    • Flutter version 3.32.1 on channel stable at /home/xiaoshihou/Applications/flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision b25305a883 (2 周前), 2025-05-29 10:40:06 -0700
    • Engine revision 1425e5e9ec
    • Dart version 3.8.1
    • DevTools version 2.45.1

[✓] Android toolchain - develop for Android devices (Android SDK version 35.0.0) [1,595ms]
• Android SDK at /home/xiaoshihou/Applications/android_sdk/
• Platform android-35, build-tools 35.0.0
• Java binary at: /home/xiaoshihou/Applications/android-studio/jbr/bin/java
This is the JDK bundled with the latest Android Studio installation on this machine.
To manually set the JDK path, use: `flutter config --jdk-dir="path/to/jdk"`.
• Java version OpenJDK Runtime Environment (build 21.0.4+-12422083-b607.1)
• All Android licenses accepted.

[✓] Linux toolchain - develop for Linux desktop [907ms]
• clang version 19.1.7 (Fedora 19.1.7-3.fc41)
• cmake version 3.30.8
• ninja version 1.12.1
• pkg-config version 2.3.0
• OpenGL core renderer: AMD Radeon Graphics (radeonsi, renoir, ACO, DRM 3.61, 6.14.5-200.fc41.x86_64)
• OpenGL core version: 4.6 (Core Profile) Mesa 25.0.4
• OpenGL core shading language version: 4.60
• OpenGL ES renderer: AMD Radeon Graphics (radeonsi, renoir, ACO, DRM 3.61, 6.14.5-200.fc41.x86_64)
• OpenGL ES version: OpenGL ES 3.2 Mesa 25.0.4
• OpenGL ES shading language version: OpenGL ES GLSL ES 3.20
• GL_EXT_framebuffer_blit: yes
• GL_EXT_texture_format_BGRA8888: yes

</details>

```shell
dart run build_runner build   # 生成json相关代码
flutter build apk --release   # 构建安卓apk
flutter build linux --release # 构建Linux可执行文件
cp -r build/linux/x64/release/bundle ./AppDir
appimage-builder              # 打包AppImage
```
