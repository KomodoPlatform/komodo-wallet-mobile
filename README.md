# komodo_dex

Komodo dex application use marketmaker on back.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## For iOS build:

1. Plug your device (iPhone) to your computer.

2. 
```
git clone https://github.com/ca333/komodoDEX.git
cd komodoDEX 
flutter packages get
```
3. Copy your libmm2.a generate by [this repo](https://gitlab.com/artemciy/mm2tester?nav_source=navbar) on `komodoDEX/ios/.`.

4. `flutter run`

5. If it's your first compilation on this device you must give authorization on your device go to `Settings > General > Device Management` then trust the application. You can now `flutter run` again.

## For Android build:

1. `git clone https://github.com/ca333/komodoDEX.git`

2. `git clone https://github.com/KomodoPlatform/plugins.git`

3. `cd komodoDEX`

4. `flutter packages get`

5. Copy your `key.properties` file to `komodoDEX/android/.`

6. Copy your `mm2` bin into `komodoDEX/assets/.`, generate by this repo `https://gitlab.com/artemciy/supernet` on branch mm2-cross.

7. If you want to build a apk `flutter build apk`.

8. If you want to debug use `flutter run`, you will need to comment this line in `komodoDEX/android/app/build.gradle`
```         
ndk {
  abiFilters 'armeabi-v7a'
}
```
