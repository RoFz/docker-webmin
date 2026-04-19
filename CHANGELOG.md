# Changelog

## 1.0.0 (2026-04-19)


### Features

* **deps:** add Dependabot version update configuration ([e7abc40](https://github.com/RoFz/docker-webmin/commit/e7abc40db3c4e7cd8b731b2e48b986b26205de1d))
* **deps:** add pre-commit Dependabot updates and hadolint hook ([bce1212](https://github.com/RoFz/docker-webmin/commit/bce12128e2c9da76fb8b4f63da7480be7ca28e2e))
* **image:** implement webmin Docker image with full CI/CD pipeline ([ab85801](https://github.com/RoFz/docker-webmin/commit/ab858014ee7f01ef28ba5c64918ea5f48a7a1c74))


### Bug Fixes

* **image:** move miniserv.pem deletion into install layer to prevent secret leakage ([5ff371e](https://github.com/RoFz/docker-webmin/commit/5ff371e2cbe690180f0f3e1d3bb56a74f295df96))
* **image:** remove baked-in TLS key and generate cert at container start ([1f9b76b](https://github.com/RoFz/docker-webmin/commit/1f9b76b732da068c33afc5ed4095ad8a2b9b782c))
* **release:** configure manifest root package ([55d9c20](https://github.com/RoFz/docker-webmin/commit/55d9c2000c7385341ecda2f0800676c917b55fd3))
* **workflows:** authenticate release-please via GitHub App token ([c095d18](https://github.com/RoFz/docker-webmin/commit/c095d181cc9877a966d2764846059f6a36dffcb6))
* **workflows:** fix release workflow and add version tracking ([87637c6](https://github.com/RoFz/docker-webmin/commit/87637c69bc1ccc670a91bd55fe3998aa213b5388))
