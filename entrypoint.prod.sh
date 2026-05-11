#!/bin/bash

set -e

echo "Starting RomM production entrypoint..."

# Create symlinks for frontend assets
for subfolder in assets resources; do
	if [[ -L /app/frontend/assets/romm/${subfolder} ]]; then
		target=$(readlink "/app/frontend/assets/romm/${subfolder}")
		if [[ ${target} != "${ROMM_BASE_PATH}/${subfolder}" ]]; then
			rm "/app/frontend/assets/romm/${subfolder}"
			ln -s "${ROMM_BASE_PATH}/${subfolder}" "/app/frontend/assets/romm/${subfolder}"
		fi
	elif [[ ! -e /app/frontend/assets/romm/${subfolder} ]]; then
		mkdir -p "/app/frontend/assets/romm"
		ln -s "${ROMM_BASE_PATH}/${subfolder}" "/app/frontend/assets/romm/${subfolder}"
	fi
done

# Signal handler
function handle_termination() {
	echo "Terminating child processes..."
	kill -TERM $(jobs -p) 2>/dev/null
}
trap handle_termination SIGTERM SIGINT

# Set ROMM_AUTH_SECRET_KEY if not already set
if [[ -z ${ROMM_AUTH_SECRET_KEY} ]]; then
	ROMM_AUTH_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
	export ROMM_AUTH_SECRET_KEY
fi

# Start backend
echo "Starting backend..."
cd /app/backend
uv run python main.py &

# Start RQ scheduler
echo "Starting RQ scheduler..."
RQ_REDIS_HOST=${REDIS_HOST:-127.0.0.1} \
	RQ_REDIS_PORT=${REDIS_PORT:-6379} \
	RQ_REDIS_USERNAME=${REDIS_USERNAME:-""} \
	RQ_REDIS_PASSWORD=${REDIS_PASSWORD:-""} \
	RQ_REDIS_DB=${REDIS_DB:-0} \
	RQ_REDIS_SSL=${REDIS_SSL:-0} \
	rqscheduler \
	--path /app/backend \
	--pid /tmp/rq_scheduler.pid &

# Start RQ worker
echo "Starting RQ worker..."
if [[ -n ${REDIS_PASSWORD-} ]]; then
	REDIS_URL="redis${REDIS_SSL:+s}://${REDIS_USERNAME-}:${REDIS_PASSWORD}@${REDIS_HOST:-127.0.0.1}:${REDIS_PORT:-6379}/${REDIS_DB:-0}"
elif [[ -n ${REDIS_USERNAME-} ]]; then
	REDIS_URL="redis${REDIS_SSL:+s}://${REDIS_USERNAME}@${REDIS_HOST:-127.0.0.1}:${REDIS_PORT:-6379}/${REDIS_DB:-0}"
else
	REDIS_URL="redis${REDIS_SSL:+s}://${REDIS_HOST:-127.0.0.1}:${REDIS_PORT:-6379}/${REDIS_DB:-0}"
fi

PYTHONPATH="/app/backend:${PYTHONPATH-}" rq worker \
	--path /app/backend \
	--pid /tmp/rq_worker.pid \
	--url "${REDIS_URL}" \
	--logging_level "${LOGLEVEL:-INFO}" \
	high default low &

# Start watcher
echo "Starting watcher..."
watchfiles \
	--target-type command \
	'uv run python watcher.py' \
	/app/romm/library &

if [[ ${ENABLE_SYNC_FOLDER_WATCHER:-false} == "true" ]]; then
	echo "Starting sync folder watcher..."
	watchfiles \
		--target-type command \
		'uv run python sync_watcher.py' \
		/app/romm/sync &
fi

# In production, serve the built frontend via the backend (Gunicorn)
# No npm dev server needed

# Wait for all background processes
wait
