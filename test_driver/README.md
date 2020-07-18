### !!!IMPORTANT!!!

Full test-runs should be performed only on fresh build. 
There're a lot of variables that can change during a single run. 
The only way to ensure the default environment is fresh build.

### How to run tests:

Because of the issue that was uncovered here https://github.com/ca333/komodoDEX/issues/732
TL;DR - mm2 refuses to launch alongside flutter_driver on the same run.

Until this is fixed we have to run tests the following way:

1. flutter run -t test_driver/app.dart
2. flutter drive --target=test_driver/app.dart --use-existing-app=[link_from flutter run]

In order to test swaps and send/receive (Scenario 4) I used the following seeds as env variables:
    export RICK='offer venue embark tank eyebrow grape great era nothing top unveil pear'
    export MORTY='pear enforce exit dial spell draft chief lobster cabin refuse swift scan'

or simply do: 

```
source test_driver/source_me_for_test_seeds
```

For every created wallet auth is as follows:
PIN: 000000
password: '           a'; ---> (11 spaces + 'a')


### Another way to run tests: 

Would probably be used in ci pipeline: put generated link into a file and then read it from this file.

```
flutter run -t test_driver/app.dart --vmservice-out-file=test.txt
source test_driver/source_me_for_test_seeds
flutter drive --target=test_driver/app.dart --use-existing-app="$(cat test.txt)"
```
