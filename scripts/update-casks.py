#!/usr/bin/env python3
"""Update the Homebrew Casks from the latest stable GitHub releases."""

from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import Request, urlopen


API_VERSION = "2026-03-10"
API_BASE_URL = os.environ.get("GITHUB_API_URL", "https://api.github.com").rstrip("/")
ROOT = Path(__file__).resolve().parents[1]
CASKS_DIR = ROOT / "Casks"
SEMVER_RE = re.compile(r"^v?(?P<version>\d+\.\d+\.\d+)$")
VERSION_FIELD_RE = re.compile(r'(?m)^(?P<prefix>\s*version\s+)"[^"\n]+"(?P<suffix>\s*)$')
SHA256_FIELD_RE = re.compile(r'(?m)^(?P<prefix>\s*sha256\s+)"[^"\n]+"(?P<suffix>\s*)$')
MULTI_ARCH_SHA256_FIELD_RE = re.compile(
    r'(?m)^(?P<prefix>\s*sha256\s+arm:\s+)"[^"\n]+"'
    r'(?P<separator>,\s*\n\s*intel:\s+)"[^"\n]+"(?P<suffix>\s*)$'
)
URL_FIELD_RE = re.compile(
    r'(?m)^(?P<prefix>\s*url\s+)"(?P<url>[^"\n]+)"(?P<suffix>,?\s*)$'
)
ARCH_FIELD_RE = re.compile(
    r'(?m)^\s*arch\s+arm:\s+"(?P<arm>[^"\n]+)",\s*'
    r'intel:\s+"(?P<intel>[^"\n]+)"\s*$'
)
CURRENT_VERSION_RE = re.compile(r'(?m)^\s*version\s+"(?P<value>[^"]+)"\s*$')
CURRENT_SHA256_RE = re.compile(r'(?m)^\s*sha256\s+"(?P<value>[^"]+)"\s*$')
CURRENT_MULTI_ARCH_SHA256_RE = re.compile(
    r'(?m)^\s*sha256\s+arm:\s+"(?P<arm>[^"]+)",\s*\n\s*'
    r'intel:\s+"(?P<intel>[^"]+)"\s*$'
)
CURRENT_URL_RE = re.compile(r'(?m)^\s*url\s+"(?P<value>[^"]+)"')
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


APPS = [
    {
        "token": "subtitle-translator-electron",
        "repository": "gnehs/subtitle-translator-electron",
        "asset_strategy": "versioned",
        "asset_template": "subtitle-translator_{version}.dmg",
    },
    {
        "token": "qwenasr-studio",
        "repository": "gnehs/QwenASR-tauri",
        "asset_strategy": "exact",
        # The first name is the documented fixed name. The second is the
        # currently published name and remains an exact, version-derived
        # candidate rather than a broad filename search.
        "asset_name": "qwenasr-studio-macos-arm64-app.dmg",
        "compatibility_asset_templates": ("QwenASR.Studio_{version}_aarch64.dmg",),
    },
    {
        "token": "moss-transcribe-studio",
        "repository": "gnehs/moss-transcribe-tauri",
        "asset_strategy": "unique_dmg",
    },
    {
        "token": "bearwarden",
        "repository": "gnehs/BearWarden",
        "asset_strategy": "multi_arch_versioned",
        "asset_templates": {
            "arm": "bearwarden-{version}-arm64.dmg",
            "intel": "bearwarden-{version}-x64.dmg",
        },
        "cask_arches": {"arm": "arm64", "intel": "x64"},
    },
]


class UpdateError(RuntimeError):
    """Raised when a release or Cask cannot be updated safely."""


@dataclass(frozen=True)
class ReleaseAsset:
    name: str
    size: int
    download_url: str


@dataclass(frozen=True)
class UpdateResult:
    token: str
    old_version: str
    new_version: str
    changed: bool
    content: str
    path: Path


def api_request(repository: str) -> dict[str, Any]:
    url = f"{API_BASE_URL}/repos/{repository}/releases/latest"
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "gnehs-homebrew-tap-cask-updater",
        "X-GitHub-Api-Version": API_VERSION,
    }
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"

    try:
        with urlopen(Request(url, headers=headers), timeout=60) as response:
            payload = json.load(response)
    except HTTPError as error:
        raise UpdateError(
            f"GitHub API request failed for {repository}: HTTP {error.code}"
        ) from error
    except (URLError, TimeoutError, json.JSONDecodeError) as error:
        raise UpdateError(f"GitHub API request failed for {repository}: {error}") from error

    if not isinstance(payload, dict):
        raise UpdateError(f"GitHub API returned an invalid release for {repository}")
    if payload.get("draft") is True:
        raise UpdateError(f"Latest release for {repository} is a draft")
    if payload.get("prerelease") is True:
        raise UpdateError(f"Latest release for {repository} is a prerelease")
    if not isinstance(payload.get("tag_name"), str) or not payload["tag_name"].strip():
        raise UpdateError(f"Latest release for {repository} has no valid tag")
    if not isinstance(payload.get("assets"), list) or not payload["assets"]:
        raise UpdateError(f"Latest release for {repository} has no assets")
    return payload


def parse_version(tag_name: str, repository: str) -> str:
    match = SEMVER_RE.fullmatch(tag_name.strip())
    if not match:
        raise UpdateError(
            f"Release tag {tag_name!r} for {repository} is not a supported SemVer "
            "(expected N.N.N or vN.N.N)"
        )
    return match.group("version")


def candidate_asset_names(app: dict[str, Any], version: str) -> set[str]:
    names: set[str] = set()
    if isinstance(app.get("asset_name"), str):
        names.add(app["asset_name"])
    for template in app.get("compatibility_asset_templates", ()):
        if not isinstance(template, str):
            raise UpdateError(f"Invalid asset template for {app['token']}")
        names.add(template.format(version=version))
    return names


def select_asset(app: dict[str, Any], release: dict[str, Any], version: str) -> ReleaseAsset:
    raw_assets = release.get("assets")
    if not isinstance(raw_assets, list):
        raise UpdateError(f"Release for {app['token']} has invalid assets")
    if not all(isinstance(asset, dict) for asset in raw_assets):
        raise UpdateError(f"Release for {app['token']} has a malformed asset entry")

    strategy = app["asset_strategy"]
    if strategy == "versioned":
        expected_name = app["asset_template"].format(version=version)
        matching = [asset for asset in raw_assets if asset.get("name") == expected_name]
        description = f"asset {expected_name!r}"
    elif strategy == "exact":
        expected_names = candidate_asset_names(app, version)
        matching = [asset for asset in raw_assets if asset.get("name") in expected_names]
        description = f"one of the exact assets {sorted(expected_names)!r}"
    elif strategy == "unique_dmg":
        matching = [
            asset
            for asset in raw_assets
            if isinstance(asset.get("name"), str)
            and asset["name"].lower().endswith(".dmg")
        ]
        description = "one unique .dmg asset"
    else:
        raise UpdateError(f"Unsupported asset strategy {strategy!r} for {app['token']}")

    if len(matching) != 1:
        raise UpdateError(
            f"Expected {description} for {app['token']}, found {len(matching)}"
        )

    return release_asset_from_api(asset=matching[0], app=app)


def release_asset_from_api(asset: dict[str, Any], app: dict[str, Any]) -> ReleaseAsset:
    name = asset.get("name")
    size = asset.get("size")
    download_url = asset.get("browser_download_url")
    if not isinstance(name, str) or not name:
        raise UpdateError(f"Release asset for {app['token']} has no valid name")
    if not isinstance(size, int) or size <= 0:
        raise UpdateError(f"Release asset {name!r} for {app['token']} is empty")
    if not isinstance(download_url, str) or not download_url:
        raise UpdateError(f"Release asset {name!r} for {app['token']} has no download URL")
    validate_download_url(download_url, app["repository"])
    return ReleaseAsset(name=name, size=size, download_url=download_url)


def select_multi_arch_assets(
    app: dict[str, Any], release: dict[str, Any], version: str
) -> dict[str, ReleaseAsset]:
    raw_assets = release.get("assets")
    if not isinstance(raw_assets, list) or not all(
        isinstance(asset, dict) for asset in raw_assets
    ):
        raise UpdateError(f"Release for {app['token']} has invalid assets")

    templates = app.get("asset_templates")
    if not isinstance(templates, dict):
        raise UpdateError(f"Multi-arch app {app['token']} has invalid asset templates")
    expected_names: dict[str, str] = {}
    for architecture in ("arm", "intel"):
        template = templates.get(architecture)
        if not isinstance(template, str):
            raise UpdateError(
                f"Multi-arch app {app['token']} has no {architecture} asset template"
            )
        expected_names[architecture] = template.format(version=version)
    if len(set(expected_names.values())) != len(expected_names):
        raise UpdateError(f"Multi-arch app {app['token']} has duplicate asset templates")

    selected: dict[str, ReleaseAsset] = {}
    for architecture, expected_name in expected_names.items():
        matching = [asset for asset in raw_assets if asset.get("name") == expected_name]
        if len(matching) != 1:
            raise UpdateError(
                f"Expected asset {expected_name!r} for {app['token']}, found {len(matching)}"
            )
        selected[architecture] = release_asset_from_api(asset=matching[0], app=app)
    return selected


def validate_download_url(download_url: str, repository: str) -> None:
    parsed = urlsplit(download_url)
    if parsed.scheme != "https" or parsed.hostname != "github.com":
        raise UpdateError(f"Asset URL is not an HTTPS GitHub release asset: {download_url}")
    owner, repo = repository.split("/", 1)
    expected_prefix = f"/{owner}/{repo}/releases/download/"
    if not parsed.path.startswith(expected_prefix):
        raise UpdateError(f"Asset URL is not for {repository}: {download_url}")


def download_sha256(asset: ReleaseAsset) -> str:
    digest = hashlib.sha256()
    downloaded_size = 0
    try:
        with urlopen(Request(asset.download_url, headers={"User-Agent": "gnehs-homebrew-tap-cask-updater"}), timeout=120) as response:
            while chunk := response.read(1024 * 1024):
                digest.update(chunk)
                downloaded_size += len(chunk)
    except (HTTPError, URLError, TimeoutError) as error:
        raise UpdateError(f"Failed to download asset {asset.name!r}: {error}") from error

    if downloaded_size <= 0:
        raise UpdateError(f"Downloaded asset {asset.name!r} is empty")
    if downloaded_size != asset.size:
        raise UpdateError(
            f"Downloaded asset {asset.name!r} has size {downloaded_size}, "
            f"expected {asset.size}"
        )
    return digest.hexdigest()


def parse_cask(path: Path, token: str) -> tuple[str, str, str, str]:
    if not path.is_file():
        raise UpdateError(f"Cask not found: {path}")
    content = path.read_text(encoding="utf-8")
    version_matches = list(CURRENT_VERSION_RE.finditer(content))
    sha_matches = list(CURRENT_SHA256_RE.finditer(content))
    url_matches = list(CURRENT_URL_RE.finditer(content))
    if len(version_matches) != 1:
        raise UpdateError(f"Cask {path} must have exactly one parseable version field")
    if len(sha_matches) != 1:
        raise UpdateError(f"Cask {path} must have exactly one parseable sha256 field")
    if len(url_matches) != 1:
        raise UpdateError(f"Cask {path} must have exactly one parseable url field")
    version_match = version_matches[0]
    sha_match = sha_matches[0]
    url_match = url_matches[0]
    if not SHA256_RE.fullmatch(sha_match.group("value")):
        raise UpdateError(f"Cask {path} has an invalid sha256 field")
    if not re.fullmatch(r"\d+\.\d+\.\d+", version_match.group("value")):
        raise UpdateError(f"Cask {path} has an invalid explicit version")
    if f'cask "{token}"' not in content:
        raise UpdateError(f"Cask {path} does not declare token {token!r}")
    return content, version_match.group("value"), sha_match.group("value"), url_match.group("value")


def evaluate_url(url_expression: str, version: str) -> str:
    return url_expression.replace("#{version}", version)


def evaluate_multi_arch_url(url_expression: str, version: str, architecture: str) -> str:
    return evaluate_url(url_expression, version).replace("#{arch}", architecture)


def replace_field(pattern: re.Pattern[str], content: str, value: str, field: str) -> str:
    replacement_count = 0

    def replace(match: re.Match[str]) -> str:
        nonlocal replacement_count
        replacement_count += 1
        return f'{match.group("prefix")}"{value}"{match.group("suffix")}'

    updated = pattern.sub(replace, content, count=1)
    if replacement_count != 1:
        raise UpdateError(f"Cask has an invalid or duplicated {field} field")
    return updated


def replace_multi_arch_sha256(
    content: str, sha256: dict[str, str]
) -> str:
    replacement_count = 0

    def replace(match: re.Match[str]) -> str:
        nonlocal replacement_count
        replacement_count += 1
        return (
            f'{match.group("prefix")}"{sha256["arm"]}"'
            f'{match.group("separator")}"{sha256["intel"]}"{match.group("suffix")}'
        )

    updated = MULTI_ARCH_SHA256_FIELD_RE.sub(replace, content, count=1)
    if replacement_count != 1:
        raise UpdateError("Cask has an invalid or duplicated multi-arch sha256 field")
    return updated


def validate_cask_text(
    content: str, token: str, version: str, sha256: str, expected_url: str
) -> None:
    if not re.search(rf'^\s*cask\s+"{re.escape(token)}"\s+do\s*$', content, re.MULTILINE):
        raise UpdateError(f"Updated Cask does not declare token {token!r}")
    version_matches = list(CURRENT_VERSION_RE.finditer(content))
    sha_matches = list(CURRENT_SHA256_RE.finditer(content))
    url_matches = list(CURRENT_URL_RE.finditer(content))
    if len(version_matches) != 1 or version_matches[0].group("value") != version:
        raise UpdateError(f"Updated Cask {token} has an invalid version")
    if len(sha_matches) != 1 or sha_matches[0].group("value") != sha256 or not SHA256_RE.fullmatch(sha256):
        raise UpdateError(f"Updated Cask {token} has an invalid sha256")
    if len(url_matches) != 1 or evaluate_url(url_matches[0].group("value"), version) != expected_url:
        raise UpdateError(f"Updated Cask {token} URL does not match the release asset")


def parse_multi_arch_cask(
    path: Path, token: str, cask_arches: dict[str, str]
) -> tuple[str, str, dict[str, str], str]:
    if not path.is_file():
        raise UpdateError(f"Cask not found: {path}")
    content = path.read_text(encoding="utf-8")
    version, sha256, url_expression = parse_multi_arch_cask_text(
        content, token, cask_arches, str(path)
    )
    return content, version, sha256, url_expression


def parse_multi_arch_cask_text(
    content: str, token: str, cask_arches: dict[str, str], cask_name: str
) -> tuple[str, dict[str, str], str]:
    version_matches = list(CURRENT_VERSION_RE.finditer(content))
    sha_matches = list(CURRENT_MULTI_ARCH_SHA256_RE.finditer(content))
    url_matches = list(CURRENT_URL_RE.finditer(content))
    arch_matches = list(ARCH_FIELD_RE.finditer(content))
    if len(version_matches) != 1:
        raise UpdateError(f"Cask {cask_name} must have exactly one parseable version field")
    if len(sha_matches) != 1:
        raise UpdateError(
            f"Cask {cask_name} must have exactly one parseable multi-arch sha256 field"
        )
    if len(url_matches) != 1:
        raise UpdateError(f"Cask {cask_name} must have exactly one parseable url field")
    if len(arch_matches) != 1:
        raise UpdateError(f"Cask {cask_name} must have exactly one parseable arch field")
    version_match = version_matches[0]
    sha_match = sha_matches[0]
    arch_match = arch_matches[0]
    if not re.fullmatch(r"\d+\.\d+\.\d+", version_match.group("value")):
        raise UpdateError(f"Cask {cask_name} has an invalid explicit version")
    sha256 = {"arm": sha_match.group("arm"), "intel": sha_match.group("intel")}
    if not all(SHA256_RE.fullmatch(value) for value in sha256.values()):
        raise UpdateError(f"Cask {cask_name} has an invalid multi-arch sha256 field")
    if {"arm": arch_match.group("arm"), "intel": arch_match.group("intel")} != cask_arches:
        raise UpdateError(f"Cask {cask_name} has unexpected multi-arch values")
    if f'cask "{token}"' not in content:
        raise UpdateError(f"Cask {cask_name} does not declare token {token!r}")
    return version_match.group("value"), sha256, url_matches[0].group("value")


def validate_multi_arch_cask_text(
    content: str,
    token: str,
    version: str,
    sha256: dict[str, str],
    assets: dict[str, ReleaseAsset],
    cask_arches: dict[str, str],
) -> None:
    parsed_version, parsed_sha256, url_expression = parse_multi_arch_cask_text(
        content, token, cask_arches, token
    )
    if parsed_version != version:
        raise UpdateError(f"Updated Cask {token} has an invalid version")
    if parsed_sha256 != sha256:
        raise UpdateError(f"Updated Cask {token} has an invalid multi-arch sha256")
    for architecture, asset in assets.items():
        if (
            evaluate_multi_arch_url(url_expression, version, cask_arches[architecture])
            != asset.download_url
        ):
            raise UpdateError(
                f"Updated Cask {token} URL does not match the {architecture} release asset"
            )


def validate_ruby_syntax(content: str, token: str) -> None:
    ruby = shutil.which("ruby")
    if ruby is None:
        raise UpdateError("Ruby is required to validate Cask syntax")
    temporary_path: str | None = None
    try:
        with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=f"-{token}.rb", delete=False) as temporary:
            temporary.write(content)
            temporary_path = temporary.name
        result = subprocess.run(
            [ruby, "-c", temporary_path], capture_output=True, text=True, check=False
        )
        if result.returncode != 0:
            detail = (result.stderr or result.stdout).strip()
            raise UpdateError(f"Updated Cask {token} has invalid Ruby syntax: {detail}")
    finally:
        if temporary_path:
            Path(temporary_path).unlink(missing_ok=True)


def prepare_update(app: dict[str, Any]) -> UpdateResult:
    token = app["token"]
    repository = app["repository"]
    release = api_request(repository)
    version = parse_version(release["tag_name"], repository)
    if app["asset_strategy"] == "multi_arch_versioned":
        return prepare_multi_arch_update(app, release, version)
    asset = select_asset(app, release, version)
    sha256 = download_sha256(asset)
    path = CASKS_DIR / f"{token}.rb"
    content, old_version, old_sha256, old_url_expression = parse_cask(path, token)
    old_url = evaluate_url(old_url_expression, old_version)
    changed = old_version != version or old_sha256 != sha256 or old_url != asset.download_url

    updated = content
    if old_version != version:
        updated = replace_field(VERSION_FIELD_RE, updated, version, "version")
    if old_sha256 != sha256:
        updated = replace_field(SHA256_FIELD_RE, updated, sha256, "sha256")
    if evaluate_url(old_url_expression, version) != asset.download_url:
        updated = replace_field(URL_FIELD_RE, updated, asset.download_url, "url")

    validate_cask_text(updated, token, version, sha256, asset.download_url)
    validate_ruby_syntax(updated, token)
    return UpdateResult(
        token=token,
        old_version=old_version,
        new_version=version,
        changed=changed,
        content=updated,
        path=path,
    )


def prepare_multi_arch_update(
    app: dict[str, Any], release: dict[str, Any], version: str
) -> UpdateResult:
    token = app["token"]
    cask_arches = app.get("cask_arches")
    if not isinstance(cask_arches, dict) or set(cask_arches) != {"arm", "intel"} or not all(
        isinstance(value, str) and value for value in cask_arches.values()
    ):
        raise UpdateError(f"Multi-arch app {token} has invalid Cask architectures")
    assets = select_multi_arch_assets(app, release, version)
    sha256 = {
        architecture: download_sha256(asset)
        for architecture, asset in assets.items()
    }
    path = CASKS_DIR / f"{token}.rb"
    content, old_version, old_sha256, _ = parse_multi_arch_cask(
        path, token, cask_arches
    )
    changed = old_version != version or old_sha256 != sha256

    updated = content
    if old_version != version:
        updated = replace_field(VERSION_FIELD_RE, updated, version, "version")
    if old_sha256 != sha256:
        updated = replace_multi_arch_sha256(updated, sha256)

    validate_multi_arch_cask_text(
        updated, token, version, sha256, assets, cask_arches
    )
    validate_ruby_syntax(updated, token)
    return UpdateResult(
        token=token,
        old_version=old_version,
        new_version=version,
        changed=changed,
        content=updated,
        path=path,
    )


def main() -> int:
    results: list[UpdateResult] = []
    try:
        for app in APPS:
            result = prepare_update(app)
            results.append(result)
            print(
                f"{result.token}: {result.old_version} -> {result.new_version} "
                f"({'changed' if result.changed else 'unchanged'})"
            )

        for result in results:
            if result.changed:
                result.path.write_text(result.content, encoding="utf-8")
    except (OSError, UpdateError) as error:
        print(f"update-casks.py: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
