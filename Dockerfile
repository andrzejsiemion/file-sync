FROM alpine:latest

WORKDIR /app

# Install required packages
RUN apk add --no-cache git openssh openrc busybox-extras rsync

# Copy sync and push scripts
COPY sync.sh /app/sync.sh
COPY git-push.sh /app/git-push.sh
COPY rsync-to-nas.sh /app/rsync-to-nas.sh
RUN chmod +x /app/sync.sh /app/git-push.sh /app/rsync-to-nas.sh

# Set default cron schedule
ENV CRON_SCHEDULE="*/10 * * * *"

# Ensure `sync.sh` starts on container boot
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/app/sync.sh"]