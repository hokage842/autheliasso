#!/bin/bash
logfile=${logdir}/ec2_setup.log

# Ensure the log directory exists
mkdir -p $logdir

# Redirect all output to the log file
exec >> $logfile 2>&1

echo "Starting EC2 instance setup at $(date)..."

# Create a hello_world.txt file with some content
echo "Hello, World! This is ${instance_name}." > /home/ubuntu/hello_world.txt

echo "EC2 instance setup completed at $(date)."