#!/bin/bash

echo "🔧 Setting up the project..."

# Change ownership to ec2-user
sudo chown -R ec2-user:ec2-user /home/ec2-user/dev-pro

# Set correct permissions
sudo chmod -R 755 /home/ec2-user/dev-pro
