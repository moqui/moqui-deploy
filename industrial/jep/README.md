# Industrial JEP Docker Profile

This profile builds an opinionated Moqui runtime image with embedded Python and
JEP support for industrial deployments that include the `moqui-jep` component.

It belongs in `moqui-deploy` because it is deployment packaging, not framework
behavior. Application services, Python scripts, and the JEP component itself
remain in `moqui-jep`.

## Relationship to other repositories

- `moqui-framework` provides the standard Moqui runtime image layout.
- `moqui-jep` provides the component, Gradle tasks, Python requirements, and
  runtime integration points for JEP-based services.
- `moqui-deploy` packages an image profile that adds the Python/JEP runtime on
  top of a normal Moqui image.

## Layout expectations

Build your base Moqui image so it already contains the runtime, components, and
configuration you want to deploy. If you use `moqui-jep`, make sure the
component is present in the base image build context before creating the JEP
variant.

## Build

Build from the profile directory:

```bash
cd industrial/jep
./docker-build.sh moqui-jep:latest moqui:latest
```

Equivalent raw `docker build` command:

```bash
docker build \
  -t moqui-jep:latest \
  --build-arg MOQUI_IMAGE=moqui:latest \
  --build-arg JEP_VERSION=4.3.1 \
  .
```

Optional build arguments:

- `MOQUI_IMAGE`: base Moqui image to extend
- `JEP_VERSION`: JEP package version, default `4.3.1`
- `NUMPY_VERSION`: optional pinned NumPy version

## Run

```bash
docker run --rm -p 8080:80 moqui-jep:latest conf=conf/MoquiProductionConf.xml
```

The entrypoint preserves normal Moqui startup and forwards all arguments to
`MoquiStart`.

## Runtime behavior

- Creates `/opt/moqui/runtime/python_venv`
- Resolves the installed `libjep.so` from the venv at startup
- Exports `LD_LIBRARY_PATH`
- Starts Java with `-Djep.lib` and `-Djep_site_pkgs`
- Fails fast if `REQUIRE_JEP=true` and the native library cannot be found

Environment variables:

- `MOQUI_HOME`: defaults to `/opt/moqui`
- `VENV_DIR`: defaults to `/opt/moqui/runtime/python_venv`
- `PORT`: defaults to `80`
- `REQUIRE_JEP`: defaults to `true`

## Verification

Build:

```bash
docker build -t moqui-jep:latest .
```

Inspect the Python/JEP installation:

```bash
docker run --rm moqui-jep:latest /bin/sh -lc '
  /opt/moqui/runtime/python_venv/bin/python -c "import jep; print(jep.__file__)" &&
  find /opt/moqui/runtime/python_venv -name "libjep.so" -o -name "libjep.dylib"
'
```

Start Moqui:

```bash
docker run --rm -p 8080:80 moqui-jep:latest conf=conf/MoquiProductionConf.xml
```

## Notes

- This profile assumes Linux/glibc style packaging and is primarily intended
  for Debian/Ubuntu based Moqui base images.
- Keep the base image aligned with the standard Moqui image so runtime layout
  changes are reflected here when needed.
