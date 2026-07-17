#!/usr/bin/env sh
set -eu

MOQUI_HOME="${MOQUI_HOME:-/opt/moqui}"
VENV_DIR="${VENV_DIR:-$MOQUI_HOME/runtime/python_venv}"
PORT="${PORT:-80}"
PYBIN="$VENV_DIR/bin/python"
REQUIRE_JEP="${REQUIRE_JEP:-true}"

if [ ! -x "$PYBIN" ]; then
    if [ "$REQUIRE_JEP" = "true" ]; then
        echo "ERROR: Python virtual environment not found at $VENV_DIR" >&2
        exit 1
    fi
    exec java -cp . MoquiStart "port=$PORT" "$@"
fi

unset PYTHONPATH
export PYTHONNOUSERSITE=1

JEP_INFO="$("$PYBIN" - <<'PY'
import os
import sysconfig

site = sysconfig.get_paths().get("purelib") or ""
jep_dir = os.path.join(site, "jep")
candidates = [
    os.path.join(jep_dir, "libjep.so"),
    os.path.join(jep_dir, "libjep.dylib"),
]
jep_lib = next((path for path in candidates if os.path.isfile(path)), "")
print(jep_lib)
print(site)
PY
)"

JEP_LIB=$(printf '%s\n' "$JEP_INFO" | sed -n '1p')
SITE_PKGS=$(printf '%s\n' "$JEP_INFO" | sed -n '2p')

if [ -z "$JEP_LIB" ] || [ ! -f "$JEP_LIB" ]; then
    if [ "$REQUIRE_JEP" = "true" ]; then
        echo "ERROR: JEP native library not found in $VENV_DIR" >&2
        exit 1
    fi
    exec java -cp . MoquiStart "port=$PORT" "$@"
fi

export LD_LIBRARY_PATH="$(dirname "$JEP_LIB")${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec java -Djep.lib="$JEP_LIB" -Djep_site_pkgs="$SITE_PKGS" -cp . MoquiStart "port=$PORT" "$@"
