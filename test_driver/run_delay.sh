#!/bin/bash

source test_driver/source_me_for_test_seeds

if [[ -e "test_driver/link.txt" ]]; then
	flutter drive --target=test_driver/5-send-receive.dart --use-existing-app="$(cat test_driver/link.txt)"
	kill -USR2 $(cat test_driver/pid.txt)
	sleep 12s
	flutter drive --target=test_driver/6-swaps.dart --use-existing-app="$(cat test_driver/link.txt)"
fi
