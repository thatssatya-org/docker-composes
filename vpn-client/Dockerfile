FROM debian:bookworm

# Use the complete, vendor-packaged OpenVPN 3 Linux client.  Its D-Bus service
# definitions, backend helper and network configuration service are required;
# copying the CLI binary alone cannot establish a tunnel.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gpg \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://packages.openvpn.net/packages-repo.gpg \
       | gpg --dearmor -o /etc/apt/keyrings/openvpn-repo.gpg \
    && echo 'deb [signed-by=/etc/apt/keyrings/openvpn-repo.gpg] https://packages.openvpn.net/openvpn3/debian bookworm main' \
       > /etc/apt/sources.list.d/openvpn3.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       bash dbus iproute2 kmod openvpn3-client procps \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/openvpn /var/lib/openvpn3

# Containers do not run systemd as PID 1.  The stock hostname D-Bus entry
# delegates to systemd and resolves to /bin/false without it; OpenVPN 3 asks
# hostname1 for the local hostname while registering its backend.
RUN mkdir -p /etc/dbus-1/system-services \
    && printf '%s\n' \
       '[D-BUS Service]' \
       'Name=org.freedesktop.hostname1' \
       'Exec=/lib/systemd/systemd-hostnamed' \
       'User=root' \
       > /etc/dbus-1/system-services/org.freedesktop.hostname1.service

COPY entrypoint.sh /usr/local/bin/openvpn-entrypoint
RUN chmod 0555 /usr/local/bin/openvpn-entrypoint

ENTRYPOINT ["/usr/local/bin/openvpn-entrypoint"]
