#!/bin/bash

git clone https://github.com/hysds/container-builder.git
mv -f container-builder/* .
rm -rf container-builder
cp -f /container-met.py .
chmod 755 container-met.py
