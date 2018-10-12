# cloudchefs/docker-defect-dojo

Run DefectDojo in a "stateless" fashion.

## Run with `docker-compose`
```bash
$ VERSION="..." RELEASE="..." docker-compose up --build
```

Once the containers are ready, you should have a docker container running against the "remote" database.

```bash
https://localhost admin/admin
```

## Supported versions
- 1.3.0
- 1.5.2
- 1.5.3

## Caveats
- Upgrading from `1.3.0` to `1.5.2` does NOT work!

## Development
```bash
VERSION="..." DOJO_HOST="dojo" docker-compose -f docker-compose.dev.yaml up --build

```
