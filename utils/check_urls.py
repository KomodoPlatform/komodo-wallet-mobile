#!/usr/bin/env python3
from os.path import dirname, abspath
import re
import requests

PROJECT_PATH = dirname(dirname(abspath(__file__)))

with open(f"{PROJECT_PATH}/lib/app_config/app_config.dart", "r") as f:
    dart_file = f.read()
urls = re.findall(
    r"http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|/|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+",
    dart_file,
)
for url in urls:
    try:
        if (
            "discord" in url
            or "github.com" in url
            or url.endswith("?")
            or "/api/" in url
        ):
            continue
        cleaned_url = url.rstrip(".,;'\"")
        response = requests.head(cleaned_url, allow_redirects=True)
        if response.status_code >= 400 and response.status_code != 405:
            raise AssertionError(
                f"{cleaned_url} is unreachable (HTTP {response.status_code})"
            )
    except requests.ConnectionError:
        raise AssertionError(f"{cleaned_url} is unreachable (Connection Error)")
