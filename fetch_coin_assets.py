#!/usr/bin/env python3
import urllib.request
import json
import os
import shutil
import concurrent.futures
import argparse
from dataclasses import dataclass

# Constants
COINS_CI_PATH = "assets/coins_ci.json"
COINS_PATH = "assets/coins.json"
COINS_CONFIG_PATH = "assets/coins_config.json"
COIN_ICONS_PATH = "assets/coin-icons/"
ICON_DOWNLOAD_TIMEOUT_SECONDS = 10
CONCURRENCY_LIMIT = 4


@dataclass
class CoinCIConfig:
    bundled_coins_repo_commit: str
    coins_repo_url: str
    coins_repo_branch: str
    runtime_updates_enabled: bool
    mapped_files: dict[str, str]
    mapped_folders: dict[str, str]

    @staticmethod
    def load(path: str = COINS_CI_PATH):
        with open(path, "r") as f:
            data = json.load(f)
            return CoinCIConfig(**data)  # type: ignore

    def save(self, path: str = COINS_CI_PATH):
        with open(path, "w") as f:
            json.dump(self.__dict__, f, indent=2)


def main() -> None:
    """Entry point for the script."""
    parser = init_argparse()
    args = parser.parse_args()

    coins_data = CoinCIConfig.load()
    current_commit_hash = coins_data.bundled_coins_repo_commit
    latest_commit_hash = get_latest_commit_hash(
        coins_data.coins_repo_url, coins_data.coins_repo_branch
    )
    coins_data.bundled_coins_repo_commit = latest_commit_hash
    coins_data.save()
    if not args.force and current_commit_hash != latest_commit_hash:
        print("New coins repo commit found and coins_ci.json has been updated.")
        print("Please run the script again or use the -f/--force flag to update.")
        print(f"Current commit: {current_commit_hash}")
        print(f"Latest commit: {latest_commit_hash}")
        exit(1)

    # Default to cleaning existing files and redownloading the latest versions
    # Could check the sha hash of existing files and skip the download if they match
    clean_coin_assets()

    mapped_coins_path = coins_data.mapped_files[COINS_PATH]
    mapped_coins_config_path = coins_data.mapped_files[COINS_CONFIG_PATH]
    download_coin_configs(
        coins_data.coins_repo_url,
        coins_data.bundled_coins_repo_commit,
        mapped_coins_path,
        mapped_coins_config_path,
    )

    if not os.path.exists(COIN_ICONS_PATH):
        os.mkdir(COIN_ICONS_PATH)
    download_coin_icons(
        coins_data.coins_repo_url,
        coins_data.mapped_folders[COIN_ICONS_PATH],
        coins_data.bundled_coins_repo_commit,
    )


def get_latest_commit_hash(repo_url: str, branch: str = "master") -> str:
    """Get the latest commit hash for a repo

    Args:
        repo_url (str): The GitHub API URL for the repo
        branch (str, optional): The github branch name or commit hash to be used as ref. Defaults to "master".

    Returns:
        str: The latest commit hash
    """
    api_url = f"{repo_url}/commits/{branch}"
    with urllib.request.urlopen(api_url) as response:
        data = json.loads(response.read())
        return data["sha"]


def download_coin_configs(
    repo_url: str,
    repo_commit: str,
    mapped_coins_path: str,
    mapped_coins_config_path: str,
) -> None:
    """Download the coins.json and coins_config.json files from the coins repo

    Args:
        repo_url (str): GitHub API URL for the coins repo
        repo_commit (str): The commit hash to be used as ref
        mapped_coins_path (str): mapped path to the coins.json file in the coins repo
        mapped_coins_config_path (str): mapped path to the coins_config.json file in the coins repo
    """

    headers = {"Accept": "application/vnd.github.v3+json"}
    coins_json_url = f"{repo_url}/contents/{mapped_coins_path}?ref={repo_commit}"
    coins_req = urllib.request.Request(coins_json_url, headers=headers)
    coins_config_url = (
        f"{repo_url}/contents/{mapped_coins_config_path}?ref={repo_commit}"
    )
    coins_config_req = urllib.request.Request(coins_config_url, headers=headers)

    with urllib.request.urlopen(coins_req) as response:
        response = response.read().decode("utf-8")
        response_json = json.loads(response)
        if "download_url" not in response_json:
            print("Failed to download coins.json")
            exit(1)

        with urllib.request.urlopen(response_json["download_url"]) as coins_response:
            data = coins_response.read().decode("utf-8")
            with open(COINS_PATH, "w") as f:
                f.write(data)

    with urllib.request.urlopen(coins_config_req) as response:
        response = response.read().decode("utf-8")
        response_json = json.loads(response)
        if "download_url" not in response_json:
            print("Failed to download coins_config.json")
            exit(1)

        with urllib.request.urlopen(
            response_json["download_url"]
        ) as coins_config_response:
            coins_config = coins_config_response.read().decode("utf-8")
            with open(COINS_CONFIG_PATH, "w") as f:
                f.write(coins_config)


def download_coin_icons(
    repo_url: str,
    repo_path: str,
    repo_commit: str,
    local_dir: str = COIN_ICONS_PATH,
    max_concurrency: int = CONCURRENCY_LIMIT,
    timeout: int = ICON_DOWNLOAD_TIMEOUT_SECONDS,
) -> None:
    """Download the coin icons from the coins repo

    Args:
        repo_url (str): GitHub API URL for the coins repo
        repo_path (str): path to the icons directory in the coins repo
        repo_commit (str): The commit hash to be used as ref
        local_dir (str, optional): local directory to save the icons to. Defaults to COIN_ICONS_PATH.
        max_concurrency (int, optional): Maximum number of concurrent processes to spawn. Defaults to CONCURRENCY_LIMIT.
        timeout (int, optional): Maximum timeout in seconds per download task. Defaults to ICON_DOWNLOAD_TIMEOUT_SECONDS.
    """

    api_url = f"{repo_url}/contents/{repo_path}?ref={repo_commit}"
    headers = {"Accept": "application/vnd.github.v3+json"}
    req = urllib.request.Request(api_url, headers=headers)
    with urllib.request.urlopen(req) as response:
        coins = []
        data = json.loads(response.read())
        for item in data:
            if item["type"] == "file":
                coins.append(item)

        with concurrent.futures.ThreadPoolExecutor(
            max_workers=max_concurrency
        ) as executor:
            futures = {
                executor.submit(
                    download_icon,
                    coin,
                    local_dir,
                )
                for coin in coins
            }
            for future in concurrent.futures.as_completed(futures):
                # Exceptions that occur in the threads are allowed to propagate
                # to the main thread, so that the program can exit with a non-zero
                # exit code. This is useful for CI/CD pipelines.
                future.result(timeout=timeout)


def download_icon(item: dict[str, str], local_dir: str) -> None:
    """Download a single coin icon from the coins repo

    Args:
        item (dict[str, str]): GitHub API response for a single file in the coins repo
        local_dir (str): local directory to save the icon

    Raises:
        e: Any exception that occurs during the download
    """
    file_url = item["download_url"]
    file_name = item["name"]
    coin_name = os.path.splitext(file_name)[0]
    try:
        file_response: bytes = urllib.request.urlopen(file_url).read()
        with open(os.path.join(local_dir, file_name), "wb") as f:
            f.write(file_response)
    except Exception as e:
        print(f"Failed to download icon for {coin_name}: {e}")
        raise e


def init_argparse() -> argparse.ArgumentParser:
    """Initialize argparse

    Returns:
        argparse.ArgumentParser: parser
    """
    parser = argparse.ArgumentParser(
        usage="%(prog)s [OPTION]...",
        description="Download the latest coin configs and icons.",
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help=(
            "Force download the latest coin configs and icons. "
            + " NOTE: This will delete the existing files."
        ),
    )
    return parser


def clean_coin_assets() -> None:
    """Remove existing coin config files and icons."""
    if os.path.exists(COINS_PATH):
        os.remove(COINS_PATH)

    if os.path.exists(COINS_CONFIG_PATH):
        os.remove(COINS_CONFIG_PATH)

    if os.path.exists(COIN_ICONS_PATH):
        shutil.rmtree(COIN_ICONS_PATH, ignore_errors=True)


if __name__ == "__main__":
    main()
