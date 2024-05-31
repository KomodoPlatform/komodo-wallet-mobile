sudo chmod -R u+rwx,g+rwx /home/komodo/workspace
sudo chown -R /home/komodo/workspace
flutter pub get

curl -o assets/coins.json https://raw.githubusercontent.com/KomodoPlatform/coins/master/coins 
curl -o assets/coins_config.json https://raw.githubusercontent.com/KomodoPlatform/coins/master/utils/coins_config.json 
mkdir -p android/app/src/main/cpp/libs/armeabi-v7a 
mkdir -p android/app/src/main/cpp/libs/arm64-v8a 

cp /kdf/target/aarch64-linux-android/release/libmm2.a android/app/src/main/cpp/libs/arm64-v8a
cp /kdf/target/armv7-linux-androideabi/release/libmm2.a android/app/src/main/cpp/libs/armeabi-v7a