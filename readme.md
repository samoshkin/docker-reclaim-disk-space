# docker-reclaim-disk-space

Reclaim disk space by removing stale and unused Docker data.

This is the bash script, that does the following:

- removes stopped containers
- removes orphan (dangling) images layers
- removes unused volumes
- removes Docker build cache
- shrinks the `Docker.raw` file on MacOS
- restarts the Docker engine (through `launchd` or `systemd`)
- prints Docker disk usage


## Usage

```
```
