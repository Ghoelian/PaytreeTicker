#!/bin/bash
clear

folders=("linux-amd64" "linux-arm" "linux-aarch64" "windows-amd64")

echo "clearing old builds..."
rm -rf ./build
mkdir ./build

for folder in "${folders[@]}"
do
  echo "zipping $folder..."
  tar -czf "build/$folder.tar.gz" "./$folder"
done

for folder in "${folders[@]}"
do
  echo "cleaning up $folder..."
  rm -rf "./$folder"
done

echo "done"
