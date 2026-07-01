#!/usr/bin/env sh

# Send 'stop' command to the Minecraft server via its console socket,
# then wait for the process to exit cleanly before systemd kills it.

SERVICE_NAME="minecraft_server_1"
TIMEOUT=60

echo "Sending stop command to ${SERVICE_NAME}..."

# If you later add mcrcon or a named pipe for console access, replace this block.
# For now we signal the JVM to shut down gracefully via SIGTERM,
# which Minecraft's built-in shutdown hook handles correctly.
kill -SIGTERM "$(systemctl show --property MainPID --value ${SERVICE_NAME})"

echo "Waiting up to ${TIMEOUT}s for server to shut down..."
ELAPSED=0
while systemctl is-active --quiet "${SERVICE_NAME}"; do
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "Server did not stop within ${TIMEOUT}s — systemd will force kill."
        exit 1
    fi
done

echo "Server stopped cleanly."