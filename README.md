# highfipi

Raspbian based SD card images to run a wireless multi-room audio system using [mopidy](https://mopidy.com/) and [snapcast](https://github.com/badaix/snapcast) on [Raspberry Pi](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/)s.


## Build the images

The images defined within this repository are built using [Packer](https://github.com/hashicorp/packer) along with the [arm-image builder](https://github.com/solo-io/packer-builder-arm-image).  

The `Makefile` specifies a build target for each image.
Each of these build targets writes an image into `./output-arm-image/image`.

### Prerequisites

To build the SD card images, you need to have the following tools installed on your host:

* Golang >=1.16
* qemu-user-static
* kpartx

For instance on Debian-based Linux distributions you can do so as follows:

```sh
sudo apt-get install golang qemu-user-static kpartx
```

Alternatively you can build the images using `docker`.
While this does not require additional dependencies, it fails randomly due to asynchronously populated loopback devices within the container.


### Build the speaker image

The speaker image comes with a [snapcast](https://github.com/badaix/snapcast) client and is meant to be run on a [Raspberry Pi 3](https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus/) with a [Hifiberry Amp2](https://www.hifiberry.com/shop/boards/hifiberry-amp2/) or [DAC+ Standard](https://www.hifiberry.com/shop/boards/hifiberry-dacplus-rca-version/)/Pro.
You can build it as follows:

```sh
sudo make build-speaker WIFI_SSID=<WIFI_NAME> WIFI_PASSWORD='<PASSWORD>' WIFI_COUNTRY=<TWO_LETTER_COUNTRY_CODE> SPEAKER_HOSTNAME=<HOSTNAME>
```

Alternatively you can build the image using `docker`:

```sh
make docker-build-speaker WIFI_SSID=<WIFI_NAME> WIFI_PASSWORD='<PASSWORD>' WIFI_COUNTRY=<TWO_LETTER_COUNTRY_CODE> SPEAKER_HOSTNAME=<HOSTNAME>
```

If you boot your Raspberry Pi from that image, it will connect to a [snapcast](https://github.com/badaix/snapcast) server within your local network automatically.


### Build the streamer image

The streamer image comes with a [snapcast](https://github.com/badaix/snapcast) server and [mopidy](https://mopidy.com/) preinstalled.
It does not necessarily require any sound card attached to the Raspberry Pi since mopidy is configured to send audio to the snapcast server directly currently.
You can build it as follows:

```sh
sudo make build-streamer
```

Alternatively you can build the image using `docker`:

```sh
make docker-build-streamer
```

Please note that the streamer should be connected via ethernet in order to free WLAN bandwidth for the speakers.
Correspondingly the streamer disables WLAN by default.  

Once you booted a Raspberry Pi from that image, you can access [Iris](https://github.com/jaedb/iris) (a mopidy web UI) at [http://highfipi-streamer:6680/iris](http://highfipi-streamer:6680/iris) within your local network.  

You may wish to install additional mopidy plugins and configure authentication for them, as it is needed for eg. [mopidy-soundcloud](https://github.com/mopidy/mopidy-soundcloud) and [mopidy-youtube](https://github.com/natumbri/mopidy-youtube).
You'd have to do that manually after booting a Raspberry Pi from the image by placing a corresponding configuration file into `/usr/share/mopidy/conf.d/` and restarting mopidy using `sudo systemctl restart mopidy`.  
You can check the mopidy logs for configuration errors using the command `sudo journalctl -u mopidy`.


## Flash the image to an SD card

You can write a previously built image to an SD card as follows:

```sh
TARGET_DEVICE=/dev/sdX
sudo umount ${TARGET_DEVICE}* || true
sudo dd bs=4M if=./output-arm-image/image of="$TARGET_DEVICE"
sync
```

**ATTENTION:** Please replace `/dev/sdX` carefully with the path to the device you want to write the image to - specifying the wrong device can cause data loss!
To find the correct device path, you can use `lsblk`.  


## Stream audio from your workstation or laptop

You don't need to use a dedicated Raspberry Pi as snapcast server/streamer.
You could as well install a snapcast server on your workstation or laptop.
[This example](https://gist.github.com/mgoltzsche/8a08cd11c5d1dad76096a5d139322446) shows how you can make pulseaudio stream into snapcast, allowing you to select "Snapcast" as a virtual device within pulseaudio's `pavucontrol` GUI in order to play audio from your machine on all connected snapcast clients / speakers synchronously.
However the audio is not in sync with locally playing video unfortunately.
Also a snapcast client only connects to a single snapcast server so that you either need to stream your machine's audio to a central snapcast server within your local network which distributes it to the snapcast clients (adds additional latency!) or you need to make sure that the snapcast clients are connected to the right snapcast server (by turning off other snapcast servers).
