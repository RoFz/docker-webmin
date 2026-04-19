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

exec /usr/share/webmin/miniserv.pl --nofork /etc/webmin/miniserv.conf
