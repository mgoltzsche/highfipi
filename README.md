# highfipi

An SD card image to run Raspberry Pi based wireless Hifi speakers for multi-room audio.  

It runs a [snapcast](https://github.com/badaix/snapcast) client on a [Raspberry Pi](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/) with a [Hifiberry Amp2](https://www.hifiberry.com/shop/boards/hifiberry-amp2/) or [DAC+ Standard](https://www.hifiberry.com/shop/boards/hifiberry-dacplus-rca-version/)/Pro.  

The image(s) defined here are built using [Packer](https://github.com/hashicorp/packer) with the [arm-image builder](https://github.com/solo-io/packer-builder-arm-image).


## Build the image

Build the [snapcast](https://github.com/badaix/snapcast) client image (requires `golang`, `qemu-user-static` and `kpartx`; eg. on Debian-based distros, call  `sudo apt-get install golang qemu-user-static kpartx`):

```sh
sudo make build-speaker
```

Alternatively you can build the image using `docker`:

```sh
make docker-build-speaker WIFI_SSID=<YOUR_WIFI_NAME> WIFI_PASSWORD=<YOUR_WIFI_PASSWORD>
```

_(While this does not require dependencies other than `docker`, it fails randomly due to asynchronously populated loopback devices within the container.)_  

Both commands write the image to `./output-arm-image/image`.


## Flash the image to an SD card

You can write the image to an SD card as follows:

```sh
TARGET_DEVICE=/dev/sdX
sudo umount ${TARGET_DEVICE}* || true
sudo dd bs=4M if=./output-arm-image/image of="$TARGET_DEVICE"
sync
```

**ATTENTION:** Please replace `/dev/sdX` carefully with the path to the device you want to write the image to - specifying the wrong device can cause data loss!
To find the correct device path, you can use `lsblk`.  

If you boot your Raspberry Pi from that SD card, it will connect to a [snapcast](https://github.com/badaix/snapcast) server within your local network automatically.


## Set up a server/player

You could make a server run on another Raspberry Pi or on your workstation or laptop.
[This example](https://gist.github.com/mgoltzsche/8a08cd11c5d1dad76096a5d139322446) shows how you can make pulseaudio stream into snapcast, allowing you to select "Snapcast" as a virtual device within pulseaudio's `pavucontrol` GUI in order to play audio from your machine on all connected snapcast clients / speakers synchronously.
_(However the audio is not in sync with locally playing video unfortunately.)_
