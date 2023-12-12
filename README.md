# Komodo Wallet - Open Source GitHub Repository 🚀

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/komodoplatform/atomicdex-mobile/build.yml)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/komodoplatform/atomicdex-mobile)
![GitHub contributors](https://img.shields.io/github/contributors-anon/komodoplatform/atomicdex-mobile)
![GitHub last commit](https://img.shields.io/github/last-commit/komodoplatform/atomicdex-mobile)
![GitHub top language](https://img.shields.io/github/languages/top/komodoplatform/atomicdex-mobile)
![Discord](https://img.shields.io/discord/412898016371015680)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/komodoplatform/atomicdex-mobile)
![GitHub repo size](https://img.shields.io/github/repo-size/komodoplatform/atomicdex-mobile)
![Twitter Follow](https://img.shields.io/twitter/follow/komodoplatform?style=social)

Welcome to the Komodo Wallet open-source repository! This cutting-edge project is brought to you by Komodo, providing a mighty non-custodial wallet and decentralised exchange all in one mobile app. Take control of your cryptocurrencies and trade seamlessly on your mobile phone or tablet with Komodo Wallet!

<p float="center">
  <img src="https://user-images.githubusercontent.com/77973576/229565868-b121e9b6-2d2b-4390-a81f-a7878d0bfea8.png" width="33%" />
  <img src="https://user-images.githubusercontent.com/77973576/229565938-81a51d44-5a73-4acd-8885-454e6fa6443d.png" width="33%" />
  <img src="https://user-images.githubusercontent.com/77973576/229565995-252df819-1ea9-4cc8-a9bc-4ab3e1c80caf.png" width="33%" />
  <img src="https://user-images.githubusercontent.com/77973576/229566018-285b6b6d-677e-464e-aafb-e55fecb2df82.png" width="33%" />
  <img src="https://user-images.githubusercontent.com/77973576/229566049-2f25b16b-da76-4295-b4e6-ba567ac582f7.png" width="33%" />
  <img src="https://user-images.githubusercontent.com/77973576/229566075-aa00a5a9-55ae-4acd-ad7b-d67ed3a65db6.png" width="33%" />
</p>

## Unleashing the Power of Komodo DeFi Framework 💡

We've made this repository public to showcase the incredible potential of the Komodo DeFi Framework and to spark interest among companies looking to integrate this game-changing technology into their own applications. Our goal is to drive innovation and expand the reach of decentralised exchange technology worldwide.

## Exciting Features 🌟

- **Non-custodial wallet:** You're in control - only you can access your private keys.
- **Decentralized exchange:** Trade cryptocurrencies effortlessly across blockchain networks with atomic swap technology, bypassing the need for a middleman.
- **500+ Listed Cryptocurrencies:** A vast and ever-growing list of supported cryptocurrencies.
- **Unlimited markets:** Over 300,000 completed atomic swaps and a staggering 10,000+ trading pairs.
- **User support:** Engage with our active Discord support channel, where official team members are ready to help. We'd also love to hear your feedback.
- **Most supported protocols:** Komodo Wallet outshines the competition by supporting the most blockchain protocols of any decentralized exchange on the market.
- **Established team:** Our pioneering Komodo developers have been at the forefront of DEX technology since 2014.
- **Frequent updates:** Our dedicated developers are constantly working to enhance the app's user experience, security, and feature set.

## Download Komodo Wallet 📲

Embrace financial freedom at your fingertips by downloading the Komodo Wallet:

- [iOS](https://testflight.apple.com/join/c2mOLEoC)
- [Android](https://play.google.com/store/apps/details?id=com.komodoplatform.atomicdex)

## Get Involved 🤝

We welcome developers, designers, and testers' contributions to our open-source project. If you'd like to contribute, please review the [contribution guidelines](CONTRIBUTING.md) and [code of conduct](CODE_OF_CONDUCT.md).

For any questions about the Komodo Wallet or the exchange, join our lively [Discord Support channel](https://komodoplatform.com/discord). Official team members are identifiable by the "Komodo Team" role.

# NB (Forkers/contributors)

This repository is currently in the process of undergoing safety and Flutter version upgrades. Expect major merge conflicts in the near future for any files updated from this repository. Please note that this software is under active development and provided "as is" without warranties or guarantees. Use at your own risk, as the authors and maintainers shall not be held liable for any issues, damages, or losses resulting from its use.

## Getting Started

Build requires up-to-date version of coins file from <https://github.com/KomodoPlatform/coins>

Commit hash and sha256sum of coins file is specified in `coins_ci.json`.
You may download one manually, use the `fetch_coin_assets.py` python script.

The `fetch_coin_assets.py` script requires python 3.8 or later. MacOS users might need to run the [following post-install commands](https://stackoverflow.com/a/42334357/5019115) for SSL certificate verification to work with their version of python:

```bash
pip install certifi
/Applications/Python\ 3.12/Install\ Certificates.command
```

## Build and run

<https://github.com/KomodoPlatform/AtomicDEX-mobile/wiki/Project-Setup#build-and-run>

## Run/Build with screenshot and video recording ON

```
flutter run --dart-define=screenshot=true
```

## Komodo DeFi Framework Library Setup

Komodo Wallet runs the Komodo DeFi Framework locally on the user's device. The API binary is platform-specific and must be manually set up by the developer instead of a typical Flutter dependency.

Ensure you run the most recent Komodo DeFi Framework [stable release](https://github.com/KomodoPlatform/atomicDEX-API/releases). Download the API binary for each platform and extract its `libmm2.a` file into the applicable platform's API folder.

### [Stable API releases](https://github.com/KomodoPlatform/atomicDEX-API/releases)

| API Build | API Path* |
|--|--|
| android-aarch64 | `android/app/src/main/cpp/libs/arm64-v8a/libmm2.a` |
| android-armv7 | `android/app/src/main/cpp/libs/armeabi-v7a/libmm2.a` |
| iOS | `ios/libmm2.a` |

**Relative to the Flutter project's root folder. E.g. if your name was Bob and you cloned the flutter project into your macOS home directory, the full path for the iOS API would be `/Users/Bob/atomicdex_mobile/ios/libmm2.a`*

See [our wiki](https://github.com/KomodoPlatform/atomicdex-mobile/wiki/Project-Setup#android-builds-from-scratch) here for more thorough project setup steps. Besides installing the API binary, Komodo Wallet is set up similarly to any other cloned Flutter project.

## Accessing the database

    adb exec-out run-as com.komodoplatform.atomicdex cat /data/data/com.komodoplatform.atomicdex/app_flutter/AtomicDEX.db > AtomicDEX.db
    sqlite3 AtomicDEX.db

## Localization

1. Extract messages to the .arb file:

```bash
flutter pub run intl_generator:extract_to_arb --output-dir=lib/l10n lib/localizations.dart
```

2. Sync generated `intl_messages.arb` with existing locale `intl_*.arb` files:

```bash
dart run sync_arb_files.dart
```

3. ARB files can be used for input to translation tools like [Arbify](https://github.com/Arbify/Arbify), [Localizely](https://localizely.com/) etc.
4. The resulting translations can be used to generate a set of libraries:

```bash
flutter pub run intl_generator:generate_from_arb --output-dir=lib/l10n  lib/localizations.dart lib/l10n/intl_*.arb
```

5. Manual editing of generated `messages_*.dart` files might be needed to delete nullable syntax (`?` symbol), since the app doesn't support it yet.

## Generate latest coin config

Clone the latest version of [coins](https://github.com/KomodoPlatform/coins)

Download and install the latest version of [python3](https://www.python.org/downloads/)

Open the cloned repository and run the script below in the terminal in the repo folder.

```bash
python3 utils/generate_app_configs.py
```

Copy the generated `coins_config.json` file from the Utils folder and paste it inside the `assets/` folder in the Komodo Wallet project.

## Audio samples sources

- [ticking sound](https://freesound.org/people/FoolBoyMedia/sounds/264498/)
- [silence](https://freesound.org/people/Mullabfuhr/sounds/540483/)
- [start (iOS)](https://freesound.org/people/pizzaiolo/sounds/320664/)

## Testing

### 1. Manual testing

 Manual testing plan:
[https://docs.google.com/spreadsheets/d/1jeIkGe2CmJ7YmuoVi6Rlc9KRr3wiBPf44Qy0Nd8qtOY/edit?usp=sharing](https://docs.google.com/spreadsheets/d/1jeIkGe2CmJ7YmuoVi6Rlc9KRr3wiBPf44Qy0Nd8qtOY/edit?usp=sharing)

### 2. Integration testing

 [Guide and coverage](integration_test/README.md)

### 3. Unit/Widget testing

 Not supported

## License 📄

This project is released under the [MIT License](COPYING).
