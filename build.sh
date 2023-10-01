#!/bin/bash
mkdir ./build

rm build/linux-aarch64.tar.gz
rm build/linux-amd64.tar.gz
rm build/linux-arm.tar.gz
rm build/windows-amd64.tar.gz

tar -czf build/linux-aarch64.tar.gz ./linux-aarch64
tar -czf build/linux-amd64.tar.gz ./linux-amd64
tar -czf buildlinux-arm.tar.gz ./linux-arm
tar -czf build/windows-amd64.tar.gz ./windows-amd64
