# docker-reclaim-disk-space

Reclaim disk space by removing stale and unused Docker data.

This is the bash script, that does the following:

- prints the Docker disk usage information
- interactively prompts you for confirmation
- removes stopped containers
- removes orphan (dangling) images layers
- removes unused volumes
- removes Docker build cache
- shrinks the `Docker.raw` file on MacOS
- restarts the Docker engine (through launchctl on macOS or systemctl on Linux). Waits until the Docker is up and running after the restart.
- prints Docker disk usage once again

Read more in my blog post: [Reclaim disk space by removing stale and unused Docker data](https://medium.com/@alexeysamoshkin/reclaim-disk-space-by-removing-stale-and-unused-docker-data-a4c3bd1e4001)

## Usage

Using `curl`:

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/samoshkin/docker-reclaim-disk-space/master/script.sh)"
```

Or using `wget`:

```
bash -c "$(wget -qO - https://raw.githubusercontent.com/samoshkin/docker-reclaim-disk-space/master/script.sh)"
```

Or just clone the repo and execute the script:

```
git clone https://github.com/samoshkin/docker-reclaim-disk-space
./docker-reclaim-disk-space/script.sh
```

If you want to suppress interactive prompts, pass `-y` flag.

If you don't want to restart the Docker engine, pass the `--no-restart` flag.
