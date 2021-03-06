#!/usr/bin/env bash
# Docker build hooks
# https://docs.docker.com/docker-cloud/builds/advanced/

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# Load environment
# shellcheck disable=1090
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/.env"

# VARs
GIT_TAG="$(git describe --always --tags)"

# Build hook
run_build_hook(){
  deepen_git_repo
  build_image
}

# Post-Push hook
run_post_push_hook(){
  tag_image
  notify_microbadger
}

# Deepen repository history
# When Docker Cloud pulls a branch from a source code repository, it performs a shallow clone (only the tip of the specified branch). This has the advantage of minimizing the amount of data transfer necessary from the repository and speeding up the build because it pulls only the minimal code necessary.
# Because of this, if you need to perform a custom action that relies on a different branch (such as a post_push hook), you won’t be able checkout that branch, unless you do one of the following:
#    $ git pull --depth=50
#    $ git fetch --unshallow origin
deepen_git_repo(){
  echo 'Deepen repository history'
  git fetch --unshallow origin
}

# Build the image with the specified arguments
build_image(){
  echo 'Build the image with the specified arguments'
  docker build \
    --build-arg VERSION="${GIT_TAG}" \
    --build-arg VCS_URL="$(git config --get remote.origin.url)" \
    --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
    --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    -t "$IMAGE_NAME" .
}

# Generate semantic version style tags
generate_semantic_version(){
  local IFS=$' ' # required by the version components below

  # If tag matches semantic version
  if [[ "$GIT_TAG" != v* ]]; then
    echo "Version (${GIT_TAG}) does not match semantic version; Skipping..."
    return
  fi

  echo "Using version ${GIT_TAG}"

  # Break the version into components
  semver="${GIT_TAG#v}" # Remove the 'v' prefix
  semver="${semver%%-*}" # Remove the commit number
  semver=( ${semver//./ } ) # Create an array with version numbers

  export major="${semver[0]}"
  export minor="${semver[1]}"
  export patch="${semver[2]}"
}

# Tag image
# This creates semantic version style tags from latest (built just once).
# An alternative approach would be to use build rules (however, this triggers multiple builds for each tag, which is inefficient).
#
#     Type    Name                                  Location    Tag
#     Tag     /^v([0-9]+)\.([0-9]+)\.([0-9]+)$/     /           {\1}.{\2}.{\3}
#     Tag     /^v([0-9]+)\.([0-9]+)\.([0-9]+)$/     /           {\1}.{\2}
#     Tag     /^v([0-9]+)\.([0-9]+)\.([0-9]+)$/     /           {\1}
tag_image(){
  generate_semantic_version

  for version in "${major}.${minor}.${patch}" "${major}.${minor}" "${major}"; do
    # Publish semantic versions based on latest only
    if [[ "$DOCKER_TAG" == 'latest' ]]; then
      echo "Pushing version (${DOCKER_REPO}:${version})"
      docker tag "$IMAGE_NAME" "${DOCKER_REPO}:${version}"
      docker push "${DOCKER_REPO}:${version}"
    fi
  done
}

notify_microbadger(){
  local repo="${DOCKER_REPO#*/}"
  local token="${MICROBADGER_TOKENS[${repo:-}]:-}"
  local url="https://hooks.microbadger.com/images/${repo}/${token}"

  if [[ -n "$token" ]]; then
    echo "Notify MicroBadger: $(curl -X POST "$url")"
  fi
}
