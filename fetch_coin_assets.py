import urllib.request
import json
import os
import shutil
from typing import Any
import concurrent.futures


COINS_URL = "https://raw.githubusercontent.com/KomodoPlatform/coins"
COINS_CI_PATH = "./coins_ci.json"
COINS_PATH = "./assets/coins.json"
COINS_CONFIG_PATH = "./assets/coins_config.json"
COIN_ICONS_PATH = "./assets/coin-icons"


def download_coin_configs(coins_repo_commit: str) -> None:
    """
    Download the coins.json and coins_config.json files from the coins repo
    :param coins_repo_commit: commit id of the coins repo
    :return: None
    """
    coins_json_url = COINS_URL + f"/{coins_repo_commit}/coins"
    coins_config_url = COINS_URL + f"/{coins_repo_commit}/utils/coins_config.json"

    coins_json = urllib.request.urlopen(coins_json_url).read().decode("utf-8")
    coins_config = urllib.request.urlopen(coins_config_url).read().decode("utf-8")

    with open(COINS_PATH, "w") as f:
        f.write(coins_json)

    with open(COINS_CONFIG_PATH, "w") as f:
        f.write(coins_config)


def download_icon(coins_repo_commit: str, coin_name: str) -> None:
    """
    Download the icon for a single coin from the coins repo
    :param coins_repo_commit: commit id of the coins repo
    :param coin_name: name of the coin
    :return: None
    """
    try:
        icon_url = COINS_URL + f"/{coins_repo_commit}/icons/{coin_name}.png"
        icon = urllib.request.urlopen(icon_url).read()

        with open(f"{COIN_ICONS_PATH}/{coin_name}.png", "wb") as f:
            f.write(icon)
    except Exception as e:
        print(f"Failed to download icon for {coin_name}: {e}")


def download_coin_icons(
    coins_repo_commit: str, coin_names: list[str], max_concurrency: int = 4
) -> None:
    """
    Download the coin icons from the coins repo in parallel
    :param coins_repo_commit: commit id of the coins repo
    :param coin_names: list of coin names
    :param max_concurrency: maximum number of concurrent downloads
    :return: None
    """
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_concurrency) as executor:
        futures = {
            executor.submit(download_icon, coins_repo_commit, coin_name)
            for coin_name in coin_names
        }
        for future in concurrent.futures.as_completed(futures):
            try:
                future.result()
            except Exception as e:
                print(f"Failed to download an icon: {e}")


def load_coin_names(coins_path: str = COINS_PATH) -> list[str]:
    """
    Load the coin names from the coins.json file
    by taking the first part of the `coin` field in each coin object
    :param coins_path: path to the coins.json file
    :return: list of coin names
    """
    coins: list[dict[str, Any]] = []
    with open(coins_path, "r") as f:
        coins = json.load(f)

    if len(coins) == 0:
        raise Exception("No coins found in coins.json")

    coin_names = []
    for coin in coins:
        coin_name = coin["coin"].split("-")[0]
        coin_names.append(coin_name.lower())

    return coin_names


def load_coins_commit(ci_path: str = COINS_CI_PATH) -> str:
    """
    Load the commit id from the coins_ci.json file
    :param ci_path: path to the coins_ci.json file
    :return: commit id
    """
    with open(ci_path, "r") as f:
        ci = json.load(f)

    if "coins_repo_commit" not in ci:
        raise Exception("coins_repo_commit not found in coins_ci.json")

    return ci["coins_repo_commit"]


def main() -> None:
    """
    Download the latest coin configs and icons.
    Delete the old ones first (if they exist).
    """
    if os.path.exists(COINS_PATH):
        os.remove(COINS_PATH)

    if os.path.exists(COINS_CONFIG_PATH):
        os.remove(COINS_CONFIG_PATH)

    if os.path.exists(COIN_ICONS_PATH):
        shutil.rmtree(COIN_ICONS_PATH, ignore_errors=True)

    os.mkdir("./assets/coin-icons")

    coins_repo_commit = load_coins_commit()
    download_coin_configs(coins_repo_commit)
    coin_names = load_coin_names()
    download_coin_icons(coins_repo_commit, coin_names)


if __name__ == "__main__":
    main()
