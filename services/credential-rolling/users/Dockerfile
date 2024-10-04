# Use an official MySQL client image
FROM mysql:latest

# Install curl, jq, and cron
RUN apt-get update && \
    apt-get install -y curl jq openssl cron && \
    rm -rf /var/lib/apt/lists/*

# Copy the script into the container
COPY rolling.sh /usr/local/bin/rolling.sh

# Make the script executable
RUN chmod +x /usr/local/bin/rolling.sh

# Add a cron job to run every xx time
RUN echo "0 */4 * * * /usr/local/bin/rolling.sh" >> /etc/crontab

# Start cron in the foreground
CMD ["cron", "-f"]