#!/bin/bash
set -ex

sudo apt-get -y --no-install-recommends install \
  build-essential \
  curl \
  gcc-multilib \
  python3-dev \
  python3-venv