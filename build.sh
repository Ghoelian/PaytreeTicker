#!/bin/bash
rm "linux-aarch64.tar.gz"
rm "linux-amd64.tar.gz"
rm "linux-arm.tar.gz"
rm "windows-amd64.tar.gz"

tar -czf "linux-aarch64.tar.gz" "./linux-aarch64"
tar -czf "linux-amd64.tar.gz" "./linux-amd64"
tar -czf "linux-arm.tar.gz" "./linux-arm"
tar -czf "windows-amd64.tar.gz" "./windows-amd64"
