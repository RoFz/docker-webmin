# docker-webmin

Container image packaging for [Webmin](https://www.webmin.com/) on Debian
Bookworm Slim.

The image:

- installs Webmin from the upstream Webmin APT repository
- listens on HTTPS port `10000`
- runs Webmin as `root` intentionally, matching upstream expectations
- publishes a container healthcheck against `https://127.0.0.1:10000/`

## Quick Start

On first boot, you must provide the initial Webmin `root` password. The
recommended approach is a mounted secret file via
`WEBMIN_INITIAL_ROOT_PASSWORD_FILE`.

```bash
docker volume create webmin-etc
docker volume create webmin-state
printf '%s' 'ChangeMeNow!' > webmin-root-password
chmod 600 webmin-root-password

docker run -d \
  --name webmin \
  -p 10000:10000 \
  -e WEBMIN_INITIAL_ROOT_PASSWORD_FILE=/run/secrets/webmin-root-password \
  -v webmin-etc:/etc/webmin \
  -v webmin-state:/var/lib/docker-webmin \
  -v "$(pwd)/webmin-root-password:/run/secrets/webmin-root-password:ro" \
  <image>
```

After startup, open `https://localhost:10000/` and sign in as `root` with the
bootstrap password.

`WEBMIN_INITIAL_ROOT_PASSWORD` is also supported when a secret file mount is not
practical:

```bash
docker run -d \
  --name webmin \
  -p 10000:10000 \
  -e WEBMIN_INITIAL_ROOT_PASSWORD='ChangeMeNow!' \
  -v webmin-etc:/etc/webmin \
  -v webmin-state:/var/lib/docker-webmin \
  <image>
```

## First-Boot Behavior

Bootstrap only happens when no existing Webmin credential state is present. Once
the container has initialized successfully, restarts of that same persisted
installation keep the existing password.

If you recreate the container without preserving both `/etc/webmin` and
`/var/lib/docker-webmin`, the image treats that as a fresh install and requires
bootstrap again.

The container exits with an error on first boot if:

- neither `WEBMIN_INITIAL_ROOT_PASSWORD` nor `WEBMIN_INITIAL_ROOT_PASSWORD_FILE` is set
- both variables are set at the same time
- `WEBMIN_INITIAL_ROOT_PASSWORD_FILE` does not point to a readable file

## Persistence

Persist these paths for normal usage:

- `/etc/webmin` for Webmin configuration and credential data
- `/var/lib/docker-webmin` for the bootstrap marker used by the image entrypoint

Without those mounts or volumes, every replacement container behaves like a new
instance.

## Development

Open the repository in a devcontainer using VS Code's **Dev Containers: Reopen
in Container** command.

The devcontainer includes:

- Node.js and npm
- GitHub CLI (`gh`)
- Claude Code and Codex CLI
- `pre-commit`

## CI And Releases

Pull requests and pushes to `main` run CI that:

- validates the Dockerfile with `docker build --check` and Hadolint
- builds the image and runs a smoke test against the HTTPS endpoint
- scans the resulting image with Trivy

Pushes to `main` also run Release Please. When a GitHub release is published,
the CD workflow builds and pushes the image to Docker Hub with semver tags for
the full version and `major.minor`, plus `latest` on the default branch.

## Contributing

See [CONTRIBUTING.md](.github/CONTRIBUTING.md).

## Security

See [SECURITY.md](.github/SECURITY.md).

## License

Apache 2.0 — see [LICENSE](LICENSE).

## Image Licensing

This repository's own source code and packaging files are licensed under Apache 2.0.

The published container image also includes Webmin, which upstream documents as
BSD-3-Clause licensed. Because the built image contains material under both
licenses, the OCI image metadata uses the SPDX expression `Apache-2.0 AND BSD-3-Clause`.

GitHub's repository license detection reflects the repository `LICENSE` file for
this source repository. It does not fully represent the licensing of all software
bundled into the published container image.
