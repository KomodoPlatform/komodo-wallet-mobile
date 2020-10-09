#!/bin/bash

if [[ -e "test_driver/link.txt" ]]; then
	flutter drive --target=test_driver/1-create-wallet.dart --use-existing-app="$(cat test_driver/link.txt)"
	kill -USR2 $(cat test_driver/pid.txt)
	sleep 12s
	flutter drive --target=test_driver/2-restore-wallet.dart --use-existing-app="$(cat test_driver/link.txt)"
	kill -USR2 $(cat test_driver/pid.txt)
	sleep 12s
	flutter drive --target=test_driver/4-markets-and-feed.dart --use-existing-app="$(cat test_driver/link.txt)"
	kill -USR2 $(cat test_driver/pid.txt)
	sleep 15s
fi
