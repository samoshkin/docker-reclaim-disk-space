#!/usr/bin/env bash

# Set shell options:
#   -e, exit immediately if a command exits with a non-zero status
#   -o pipefail, means that if any element of the pipeline fails, then the pipeline as a whole will fail.
#   -u, treat unset variables as an error when substituting.
set -e
set -u
set -o pipefail

DONT_RESTART_DOCKER_ENGINE=0
DONT_ASK_CONFIRMATION=0

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --no-restart)
      DONT_RESTART_DOCKER_ENGINE=1
      shift
      ;;
    -y)
      DONT_ASK_CONFIRMATION=1
      shift
      ;;
    *)
      echo "Unknown parameter passed: $1";
      exit 1;
      ;;
  esac
done


# Asks user for confirmation interactively
ask_user_for_confirmation () {

cat << EOF

==============================================
This script reclaims disk space by removing stale and unused Docker data:
  > removes stopped containers
  > removes orphan (dangling) images layers
  > removes unused volumes
  > removes Docker build cache
  > shrinks the "Docker.raw" file on MacOS
  > restarts the Docker engine
  > prints Docker disk usage
==============================================

EOF

  if [ $DONT_ASK_CONFIRMATION -eq 1 ]; then
    return
  fi

  read -p "Would you like to proceed (y/n)? " confirmation

  # Stop if answer is anything but "Y" or "y"
  if [ "$confirmation" == "${confirmation#[Yy]}" ]; then
    exit 1;
  fi
}

# On MacOS, stopping Docker Desktop for Mac might take a long time
poll_for_docker_shutdown() {
  printf 'Waiting for docker engine to stop:\n'

  local i=0
  while docker system info > /dev/null 2>&1;
  do
    printf '.%.0s' {1..$i}
    i=$((i + 1))
    sleep 1
    tput el
  done
  sleep 1

  printf '\n'
}

# On MacOS, restarting Docker Desktop for Mac might take a long time
poll_for_docker_readiness() {
  # TODO: add new line at the end of polling
  printf 'Waiting for docker engine to start:\n'

  local i=0
  while ! docker system info > /dev/null 2>&1;
  do
    printf '.%.0s' {1..$i}
    i=$((i + 1))
    sleep 1
    tput el
  done

  printf '\n'
}

# Checks if a particular program is installed
is_program_installed () {
  command -v "$1" &>/dev/null
}

# Restarts the Docker engine
restart_docker_engine () {
  if [ $DONT_RESTART_DOCKER_ENGINE -eq 1 ]; then
    return
  fi

  echo "👉 Restarting Docker engine"

  # On MacOS, restart through "launchd"
  if [ "$(uname)" == "Darwin" ] && is_program_installed "launchctl"; then
    local docker_service=$(launchctl list | grep "com.docker.docker" | awk '$0 != "-" { print $3 }')
    if [ -n "$docker_service" ]; then
      launchctl stop "$docker_service" || true;
      poll_for_docker_shutdown;
    fi
    launchctl start com.docker.helper
    sleep 1
    poll_for_docker_readiness

  # On Linux, restart through "systemd"
  elif [ "$(uname)" == "Linux" ] && is_program_installed "systemctl"; then
    sudo systemctl stop docker.service || true
    sudo systemctl start docker.service

  # Other platforms are not supported
  else
    printf "Platform type $(uname) is not supported\n" >&2
  fi
}


echo "👉 Docker disk usage"
docker system df

ask_user_for_confirmation

echo "👉 Remove all stopped containers"
docker ps --filter "status=exited" -q | xargs -r docker rm --force

echo "👉 Remove all orphan image layers"
docker images -f "dangling=true" -q | xargs -r docker rmi -f

echo "👉 Remove all unused volumes"
docker volume ls -qf dangling=true | xargs -r docker volume rm

echo "👉 Remove Docker builder cache"
DOCKER_BUILDKIT=1 docker builder prune --all --force

echo "👉 Remove networks not used by at least one container"
docker network prune --force

echo "👉 Shrink the Docker.raw file"
# Uses a cross platform version of docker/desktop-reclaim-space - runs on ARM
docker run --rm --privileged --pid=host ifullgaz/desktop-reclaim-space

echo "👉 Docker disk usage (after cleanup)"
docker system df

restart_docker_engine

echo "🤘 Done"
