#!/bin/bash

set -ex

# Ensure that your software packages are up to date on your instance by uing the following command to perform a quick software update:
sudo yum update -y

# Install java11
sudo amazon-linux-extras install java-openjdk11 -y
