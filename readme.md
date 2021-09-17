# docker-reclaim-disk-space

Reclaim disk space by removing stale and unused Docker data.

This is the bash script, that does the following:

- removes stopped containers
- removes orphan (dangling) images layers
- removes unused volumes
- removes Docker build cache
- shrinks the `Docker.raw` file on MacOS
- restarts the Docker engine (through `launchd` on MacOS or `systemd` on Linux)
- prints Docker disk usage


## Usage

Using `curl`:

```
$ bash -c "$(curl -fsSL https://raw.githubusercontent.com/samoshkin/docker-reclaim-disk-space/master/script.sh)"
```

Or using `wget`:

```
$ bash -c "$(wget -qO - https://raw.githubusercontent.com/samoshkin/docker-reclaim-disk-space/master/script.sh)"
```

Or just clone the repo and execute the script:

```
$ git clone https://github.com/samoshkin/docker-reclaim-disk-space
./docker-reclaim-disk-space/script.sh
```
