#!/bin/sh
set -eu

marker_file="/var/lib/docker-webmin/bootstrap-complete"
default_hash_file="/usr/local/share/docker-webmin/default-miniserv.users.sha256"
users_file="/etc/webmin/miniserv.users"
users_tmp_file="${users_file}.tmp"

current_users_hash() {
  if [ -f "$users_file" ]; then
    sha256sum "$users_file" | cut -d" " -f1
  else
    echo absent
  fi
}

has_existing_state() {
  if [ -f "$marker_file" ]; then
    return 0
  fi

  if [ ! -f "$default_hash_file" ]; then
    return 1
  fi

  [ "$(cat "$default_hash_file")" != "$(current_users_hash)" ]
}

pem_file="/etc/webmin/miniserv.pem"
if [ ! -f "$pem_file" ]; then
  pem_key="$(mktemp)"
  pem_crt="$(mktemp)"
  openssl req -newkey rsa:2048 -x509 -nodes -days 3650 \
    -keyout "$pem_key" \
    -out "$pem_crt" \
    -subj "/CN=localhost" 2>/dev/null
  cat "$pem_key" "$pem_crt" > "$pem_file"
  chmod 0600 "$pem_file"
  rm -f "$pem_key" "$pem_crt"
fi

if ! has_existing_state; then
  if [ -n "${WEBMIN_INITIAL_ROOT_PASSWORD:-}" ] && [ -n "${WEBMIN_INITIAL_ROOT_PASSWORD_FILE:-}" ]; then
    echo "Set only one of WEBMIN_INITIAL_ROOT_PASSWORD or WEBMIN_INITIAL_ROOT_PASSWORD_FILE on first boot." >&2
    exit 1
  fi

  bootstrap_password="${WEBMIN_INITIAL_ROOT_PASSWORD:-}"
  if [ -n "${WEBMIN_INITIAL_ROOT_PASSWORD_FILE:-}" ]; then
    if [ ! -r "$WEBMIN_INITIAL_ROOT_PASSWORD_FILE" ]; then
      echo "WEBMIN_INITIAL_ROOT_PASSWORD_FILE must point to a readable file." >&2
      exit 1
    fi
    bootstrap_password="$(cat "$WEBMIN_INITIAL_ROOT_PASSWORD_FILE")"
  fi

  if [ -z "$bootstrap_password" ]; then
    echo "WEBMIN_INITIAL_ROOT_PASSWORD or WEBMIN_INITIAL_ROOT_PASSWORD_FILE is required on first boot when no existing Webmin credentials are present." >&2
    exit 1
  fi

  password_hash="$(webmin passwd --stdout --user root --password "$bootstrap_password")"
  WEBMIN_PASSWORD_HASH="$password_hash" perl -F: -lane 'if ($F[0] eq "root") { $F[1] = $ENV{"WEBMIN_PASSWORD_HASH"}; $F[6] = time() if defined $F[6]; } print join(":", @F);' "$users_file" > "$users_tmp_file"
  chmod --reference="$users_file" "$users_tmp_file"
  mv "$users_tmp_file" "$users_file"
  touch "$marker_file"
fi

# ── BIND DNS module configuration ────────────────────────────────
# Runs every boot so env var changes take effect on container restart.
if [ -n "${BIND_SERVER:-}" ]; then
  _bind_rndc_port="${BIND_RNDC_PORT:-953}"
  _bind_rndc_key="${BIND_RNDC_KEY:-/etc/bind/rndc.key}"
  _bind_named_conf="${BIND_NAMED_CONF:-/etc/bind/named.conf}"
  _bind_zone_dir="${BIND_ZONE_DIR:-/var/cache/bind}"

  # Extract key name from rndc.key (e.g. key "rndc-key" { ... })
  _rndc_key_name="rndc-key"
  if [ -f "$_bind_rndc_key" ]; then
    _kn="$(awk '/^key /{gsub(/"/, "", $2); print $2; exit}' "$_bind_rndc_key")"
    [ -n "$_kn" ] && _rndc_key_name="$_kn"
  fi

  printf 'include "%s";\noptions {\n  default-server %s;\n  default-port %s;\n  default-key "%s";\n};\n' \
    "$_bind_rndc_key" "$BIND_SERVER" "$_bind_rndc_port" "$_rndc_key_name" \
    > /etc/rndc.conf
  chmod 0640 /etc/rndc.conf

  mkdir -p /etc/webmin/bind8
  _b8=/etc/webmin/bind8/config

  # Insert or replace a key=value line in the webmin module config.
  set_b8() {
    if grep -q "^${1}=" "$_b8" 2>/dev/null; then
      perl -i -pe "s|^${1}=.*|${1}=${2}|" "$_b8"
    else
      printf '%s=%s\n' "$1" "$2" >> "$_b8"
    fi
  }

  set_b8 named_conf   "$_bind_named_conf"
  set_b8 named_path   /usr/sbin/named
  set_b8 master_dir   "$_bind_zone_dir"
  set_b8 rndc_cmd     /usr/sbin/rndc
  set_b8 rndc_conf    /etc/rndc.conf
  set_b8 checkzone    /usr/sbin/named-checkzone
  set_b8 checkconf    /usr/sbin/named-checkconf
  # named runs in the bind9 container — disable start/stop, map restart to rndc reload
  set_b8 start_cmd    true
  set_b8 stop_cmd     true
  set_b8 restart_cmd  "/usr/sbin/rndc -c /etc/rndc.conf reload"
  set_b8 no_chroot    1
fi

exec /usr/share/webmin/miniserv.pl --nofork /etc/webmin/miniserv.conf
