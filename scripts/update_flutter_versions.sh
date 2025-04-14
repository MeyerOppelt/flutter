#!/bin/bash
set -e

# This script fetches the latest Flutter stable version
# and writes it to scripts/flutter_stable.

VERSION_FILE="scripts/flutter_stable"
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

# Get latest stable version
stable_version=$(get_latest_version_in_channel "stable")

echo "Latest stable version: $stable_version"

# Write version to file
mkdir -p "$(dirname "$VERSION_FILE")"
echo "$stable_version" > "$VERSION_FILE"

echo "✅ Flutter stable version written to $VERSION_FILE"