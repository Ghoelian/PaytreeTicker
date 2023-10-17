## Paytree ticker
A little Processing program that displays a graph showing the amount of transactions per 10 minutes over the past 8 hours,
and the total turnover over the entire history of Paytree.

### Screenshot
![Screenshot](https://github.com/Ghoelian/PaytreeTicker/blob/master/data/screenshot.png?raw=true&v=2)

The indicator to the right of the total indicates wether the total turnover has increased since the last refresh. If so, it displays a ^ and records a streak. If not, it displays a - and resets the streak back to 0.
The colour of the indicator is mapped from 0 to the max streak the program has recorded, to hsv(0), hsv(120) for red to yellow to green.

These values are saved to a file, so the max streak is remembered.

CPU usage when idle is pretty low on a Raspberry Pi  4, averaging around 0.5 CPU%, and spiking to 10-20 CPU% when getting data.

## Start/update scripts
To run, you need to place `variables.json` in `PatreeTicker/data/`, with the following content:

```json
{
	"apiKey": "Paytree API key"
}
```

These scripts were built for a headless install of Raspberry Pi OS, but should work with any headless distro with X11 and systemd.

On a headless Raspberry Pi, you should disable screen blanking in `raspi-config` to prevent the X server from sleeping after a while.

### Start ticker as x server
```bash
#!/bin/bash
# Start ticker as X server on screen 0
xinit /home/{user}/PaytreeTicker/linux-aarch64/PaytreeTicker $* -- :0
```

### Update to latest release
```bash
#!/bin/bash
variant=linux-aarch64

clear

echo "backing up streaks"
cp "$variant/streak" ./streak

echo "getting latest release..."
latest_release=$(curl -L -H 'Authorization: Bearer {github pat}' 'https://api.github.com/repos/Ghoelian/PaytreeTicker/releases/latest')

asset=$(echo $latest_release | jq ".assets[] | select(.name == \"$variant.tar.gz\")")
name=$(echo $asset | jq -r '.name')
id=$(echo $asset | jq -r '.id')

rm -rf $variant

echo "getting $name..."
curl -LOJ -H 'Authorization: Bearer {github pat}' -H 'Accept: application/octet-stream' "https://api.github.com/repos/Ghoelian/PaytreeTicker/releases/assets/$id" -o "$name"

echo "unpacking $name..."
tar -xzf $name
rm $name

cp variables.json "$variant/data/variables.json"

echo "restoring backed up streak"
mv ./streak "$variant/streak"

echo "attempting to restart paytree ticker..."
sudo systemctl restart PaytreeTicker.service

echo "done!"
```

### systemd service
```
[Unit]
Description=Paytree ticker
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/home/julian/PaytreeTicker/start.sh

[Install]
WantedBy=multi-user.target
```
