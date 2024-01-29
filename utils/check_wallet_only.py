#!/usr/bin/env python3
from os.path import dirname, abspath
import re
import json

PROJECT_PATH = dirname(dirname(abspath(__file__)))

with open(f"{PROJECT_PATH}/assets/coins_config.json", "r") as f:
    coins_json = json.load(f)
wallet_only_coins = [
    coin["coin"] for coin in coins_json.values() if coin["wallet_only"]
]
with open(f"{PROJECT_PATH}/lib/app_config/app_config.dart", "r") as f:
    dart_file = f.read()
coins_dart = re.findall(r"walletOnlyCoins => \[\s*([^]]+?)\s*\]", dart_file)
coins_dart = [coin.strip().strip("'") for coin in coins_dart[0].split(",") if coin]
missing_coins = set(wallet_only_coins) - set(coins_dart)
assert len(missing_coins) == 0, f"Missing coins: {missing_coins}"
