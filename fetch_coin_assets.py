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
ICON_DOWNLOAD_TIMEOUT_SECONDS = 10
CONCURRENCY_LIMIT = 4




def main() -> None:
    """Entry point for the script."""
    parser = init_argparse()
    args = parser.parse_args()

    coins_data = load_coins_config(force_update=args.force, check_commit_hash=True)

    # Default to cleaning existing files and redownloading the latest versions
    # Could check the sha hash of existing files and skip the download if they match
    files_to_clean = coins_data.mapped_files.keys()
    folders_to_clean = coins_data.mapped_folders.keys()
    clean_assets(files=files_to_clean, folders=folders_to_clean)  # type: ignore

    download_mapped_files(
        coins_data.coins_repo_url,
        coins_data.bundled_coins_repo_commit,
        coins_data.mapped_files,
    )

    create_folders(coins_data.mapped_folders.keys())  # type: ignore
    download_mapped_folders(
        coins_data.coins_repo_url,
        coins_data.bundled_coins_repo_commit,
        coins_data.mapped_folders,
    )


def create_folders(folders: list[str]) -> None:
    """Create a folder if it does not exist

    Args:
        folder (str): path to the folder

    Raises:
        OSError: if the folder could not be created
    """
    for folder in folders:
        if not os.path.exists(folder):
            os.makedirs(folder, exist_ok=True)


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


def download_mapped_files(
    repo_url: str,
    repo_commit: str,
    mapped_files: dict[str, str],
) -> None:
    """Download the coins.json and coins_config.json files from the coins repo

    Args:
        repo_url (str): GitHub API URL for the coins repo
        repo_commit (str): The commit hash to be used as ref
        mapped_files (dict[str, str]): A dictionary of local file paths to remote file paths
    """

    headers = {"Accept": "application/vnd.github.v3+json"}
    for local_path, remote_path in mapped_files.items():
        file_json_url = f"{repo_url}/contents/{remote_path}?ref={repo_commit}"
        file_req = urllib.request.Request(file_json_url, headers=headers)

        with urllib.request.urlopen(file_req) as response:
            print(f"Downloading {local_path}")
            response = response.read().decode("utf-8")
            response_json = json.loads(response)
            if "download_url" not in response_json:
                print(f"Failed to download {local_path}")
                exit(1)

            with urllib.request.urlopen(
                response_json["download_url"]
            ) as download_response:
                data = download_response.read().decode("utf-8")
                with open(local_path, "w") as f:
                    f.write(data)


def download_mapped_folders(
    repo_url: str,
    repo_commit: str,
    mapped_folders: dict[str, str],
    max_concurrency: int = CONCURRENCY_LIMIT,
    timeout: int = ICON_DOWNLOAD_TIMEOUT_SECONDS,
) -> None:
    """Download all files in the mapped folders from the remote repository
    to the local directory specified in the mapped_folders dictionary.

    Args:
        repo_url (str): GitHub API URL for the coins repo
        repo_commit (str): The commit hash to be used as ref
        mapped_folders (dict[str, str]): A dictionary of local folder paths to remote folder paths
        max_concurrency (int, optional): Maximum number of concurrent processes to spawn. Defaults to CONCURRENCY_LIMIT.
        timeout (int, optional): Maximum timeout in seconds per download task. Defaults to ICON_DOWNLOAD_TIMEOUT_SECONDS.
    """

    for local_path, repo_path in mapped_folders.items():
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
                        download_file,
                        coin,
                        local_path,
                    )
                    for coin in coins
                }
                for future in concurrent.futures.as_completed(futures):
                    # Exceptions that occur in the threads are allowed to propagate
                    # to the main thread, so that the program can exit with a non-zero
                    # exit code. This is useful for CI/CD pipelines.
                    future.result(timeout=timeout)


def download_file(item: dict[str, str], local_dir: str) -> None:
    """Download a single coin icon from the coins repo

    Args:
        item (dict[str, str]): GitHub API response for a single file in the coins repo
        local_dir (str): local directory to save the icon

    Raises:
        Exception: Any exception that occurs during the download
    """
    file_url = item["download_url"]
    file_name = item["name"]
    coin_name = os.path.splitext(file_name)[0]
    output_path = os.path.join(local_dir, file_name)
    try:
        print(f"Downloading icon for {coin_name} to {output_path}")
        file_response: bytes = urllib.request.urlopen(file_url).read()
        with open(output_path, "wb") as f:
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


def clean_assets(files: list[str], folders: list[str]) -> None:
    """
    Removes the specified files and folders

    Args:
        files (list[str]): list of files to remove
        folders (list[str]): list of folders to remove
    """
    for file in files:
        print(f"Cleaning file: {file}")
        if os.path.exists(file):
            os.remove(file)

    for directory in folders:
        print(f"Cleaning directory: {directory}")
        if os.path.exists(directory):
            shutil.rmtree(directory)


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
        print(f"Loading coins ci config from {path}")
        with open(path, "r") as f:
            data = json.load(f)
            return CoinCIConfig(**data)  # type: ignore

    def save(self, path: str = COINS_CI_PATH):
        print(f"Saving coins ci config to {path}")
        with open(path, "w") as f:
            json.dump(self.__dict__, f, indent=2)


def load_coins_config(
    force_update: bool = False, check_commit_hash: bool = True
) -> CoinCIConfig:
    """
    Load the coins ci config from disk

    Args:
        force_update (bool, optional): Force update the coins config. Defaults to False.
        check_commit_hash (bool, optional): Check if the latest commit hash has changed. Defaults to True.

    Returns:
        CoinCIConfig: The coins ci config
    """
    coins_data = CoinCIConfig.load()

    if check_commit_hash:
        current_commit_hash = coins_data.bundled_coins_repo_commit
        latest_commit_hash = get_latest_commit_hash(
            coins_data.coins_repo_url, coins_data.coins_repo_branch
        )
        coins_data.bundled_coins_repo_commit = latest_commit_hash
        coins_data.save()
        if not force_update and current_commit_hash != latest_commit_hash:
            print("New coins repo commit found and build_config.json has been updated.")
            print("Please run the script again or use the -f/--force flag to update.")
            print(f"Current commit: {current_commit_hash}")
            print(f"Latest commit: {latest_commit_hash}")
            exit(1)

    return coins_data


if __name__ == "__main__":
    main()
