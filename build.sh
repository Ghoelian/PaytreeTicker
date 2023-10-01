#!/bin/bash
rm -rf ./build
mkdir ./build

tar -czf build/linux-aarch64.tar.gz ./linux-aarch64
tar -czf build/linux-amd64.tar.gz ./linux-amd64
tar -czf build/linux-arm.tar.gz ./linux-arm
tar -czf build/windows-amd64.tar.gz ./windows-amd64
