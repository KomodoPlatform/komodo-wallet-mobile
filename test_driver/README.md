### IMPORTANT

Full test-runs should be performed only on fresh build. 
There're lots of variables that can change during a single run. 
The only way to ensure the default environment is a fresh build.

### How to run tests:

Because of the issue that was uncovered here https://github.com/ca333/komodoDEX/issues/732
TL;DR - mm2 refuses to launch alongside flutter_driver on the same run.

Until this is fixed we have to run tests the following way:

#### Launching tests all together:

```
flutter run -t test_driver/app.dart --vmservice-out-file=test_driver/link.txt --pid-file=test_driver/pid.txt
test_driver/run_all.sh
```


#### Launching tests individually:

```
flutter run -t test_driver/app.dart --vmservice-out-file=test_driver/link.txt
flutter drive --target=test_driver/1-create-wallet.dart --use-existing-app="$(cat test_driver/link.txt)"
flutter drive --target=test_driver/2-restore-wallet.dart --use-existing-app="$(cat test_driver/link.txt)"
flutter drive --target=test_driver/4-markets-and-feed.dart --use-existing-app="$(cat test_driver/link.txt)"

source test_driver/source_me_for_test_seeds - only needed for below tests
flutter drive --target=test_driver/5-send-receive.dart --use-existing-app="$(cat test_driver/link.txt)"
flutter drive --target=test_driver/6-swaps.dart --use-existing-app="$(cat test_driver/link.txt)"

- not yet implemented:
flutter drive --target=test_driver/3-portfolio-and-settings.dart --use-existing-app="$(cat test_driver/link.txt)" 
```


For every created wallet auth is as follows:

```
PIN: 000000
password: '           a'; ---> (11 spaces + 'a')
```
