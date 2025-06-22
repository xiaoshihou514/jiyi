<div align="center">
    <h1>Jiyi</h1>
</div>

Jiyi is a cross-platform encrypted voice note application.

- **Protect Your Privacy**: In today's world where cloud services are increasingly prevalent, privacy has become a black box. All features of Jiyi run locally to fully protect your privacy.
- **Hear Past Selves**: In the hustle and bustle of life, writing a diary seems like a luxury. Open your phone and record a short voice note to capture the present moment.
- **Visualize Your Journey**: Explore the world and leave behind voice notes in different corners! Jiyi supports recording the location at the time of recording, helping you visualize your travels.

![Screenshot](https://github.com/user-attachments/assets/0943329e-faa0-4786-9a47-cce64bd72ede)

## Technical Stack

- **Encryption**: [Argon2](https://en.wikipedia.org/wiki/Argon2), [ChaCha20-Poly1305](https://en.wikipedia.org/wiki/ChaCha20-Poly1305)
- **Speech Recognition System**: [Next-generation Kaldi (sherpa-onnx)](https://github.com/k2-fsa/sherpa-onnx)

## Building

Install dependencies:

```shell
sudo dnf install
    gstreamer1 \                                     # Audio recording
    gstreamer1-devel gstreamer1-plugins-base-devel \ # Audio playback
    pam-devel \                                      # Auth
    libsecret-devel \                                # Save sensitive data
    gtk3-devel \                                     # Linux UI
    squashfs-tools                                   # Linux Appimage packaging
```

`flutter doctor` (My configuration):

<details>
[✓] Flutter (Channel stable, 3.32.1, on Fedora Linux 41 (Workstation Edition) 6.14.5-200.fc41.x86_64, locale zh_CN.UTF-8)
    • Flutter version 3.32.1 on channel stable at /home/xiaoshihou/Applications/flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision b25305a883 (2 weeks ago), 2025-05-29 10:40:06 -0700
    • Engine revision 1425e5e9ec
    • Dart version 3.8.1
    • DevTools version 2.45.1

[✓] Android toolchain - develop for Android devices (Android SDK version 35.0.0)
• Android SDK at /home/xiaoshihou/Applications/android_sdk/
• Platform android-35, build-tools 35.0.0
• Java binary at: /home/xiaoshihou/Applications/android-studio/jbr/bin/java
This is the JDK bundled with the latest Android Studio installation on this machine.
To manually set the JDK path, use: `flutter config --jdk-dir="path/to/jdk"`.
• Java version OpenJDK Runtime Environment (build 21.0.4+-12422083-b607.1)
• All Android licenses accepted.

[✓] Linux toolchain - develop for Linux desktop
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
dart run build_runner build
# Android
flutter build apk --release
# Linux
flutter build linux --release
cp -r build/linux/x64/release/bundle ./AppDir
appimage-builder
```
