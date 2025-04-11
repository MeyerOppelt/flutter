#!/bin/bash
set -e

# This script fetches the latest Flutter stable and beta versions
# and updates the GitHub Actions build matrix with them.

GH_ACTIONS_FILE=".github/workflows/build.yml"
releases_json=$(curl -s https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json)

# Fetch latest version of a specific channel (stable)
get_latest_version_in_channel() {
    local channel=$1
    local channel_hash=$(echo "$releases_json" | jq -r ".current_release.\"$channel\"")
    local version=$(echo "$releases_json" | jq -r --arg hash "$channel_hash" '.releases[] | select(.hash == $hash) | .version')

    if [ -z "$version" ]; then
        echo "Error fetching latest version for $channel"
        exit 1
    fi

    echo "$version"
}

# Update the GitHub Actions workflow matrix
update_version_in_github_actions() {
  local docker_tag=$1
  local version=$2

  # Use yq to update the Flutter version in the matrix for the matching docker_tag
  yq -i '
    .jobs["docker_builder"].strategy.matrix.include |= map(
      select(.DOCKER_TAG == "'"$docker_tag"'") |= .FLUTTER_VERSION = "'"$version"'"
    )
  ' "$GH_ACTIONS_FILE"
}

# Get latest versions
stable_version=$(get_latest_version_in_channel "stable")

echo "Latest stable version: $stable_version"

# Update build matrix in GitHub Actions workflow
update_version_in_github_actions "stable" "$stable_version"
update_version_in_github_actions "latest" "$stable_version"

echo "✅ Flutter versions updated in $GH_ACTIONS_FILE"
