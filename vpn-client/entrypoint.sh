#!/usr/bin/env bash
set -Eeuo pipefail

readonly CONFIG=/etc/openvpn/client.ovpn
readonly RUNTIME_DIR=/run/openvpn

if [[ ! -r "$CONFIG" ]]; then
  echo "OpenVPN profile is missing: $CONFIG" >&2
  exit 64
fi

mkdir -p "$RUNTIME_DIR" /run/dbus
rm -f "$RUNTIME_DIR/connected"

cleanup() {
  openvpn3 sessions-list 2>/dev/null | awk '/Path:/ { print $2 }' | while read -r session_path; do
    openvpn3 session-manage --path "$session_path" --disconnect 2>/dev/null || true
  done
  kill "${dbus_pid:-}" "${hostname_pid:-}" "${vpn_pid:-}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

/usr/bin/dbus-daemon --nofork --nopidfile --system &
dbus_pid=$!

 # D-Bus activation for hostname1 delegates through systemd on Debian, which
 # is deliberately absent from this single-process container.  Run the small
 # provider directly; the OpenVPN backend queries it during registration.
/lib/systemd/systemd-hostnamed &
hostname_pid=$!

for _ in {1..20}; do
  openvpn3 sessions-list >/dev/null 2>&1 && break
  sleep 1
done

# The vendor client imports the profile, starts its D-Bus-managed backend and
# emits the one-time web-auth URL on stdout when the server requires it.
openvpn3 session-start --config "$CONFIG" 2>&1 &
vpn_pid=$!

last_status=''
while true; do
  status="$(openvpn3 sessions-list 2>&1 || true)"
  if [[ "$status" != "$last_status" ]]; then
    printf '%s\n' "$status"
    last_status="$status"
  fi
  if grep -Eqi 'Status:.*(connected|connection, connected)' <<<"$status"; then
    touch "$RUNTIME_DIR/connected"
  fi
  sleep 3
done
