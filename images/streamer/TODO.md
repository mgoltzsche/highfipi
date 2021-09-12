# streamer image

## TODO:

Support streaming spdif input to snapcast server using [Hifiberry DAC+ DSP](https://www.hifiberry.com/shop/boards/hifiberry-dac-dsp/).

Related docs:
* https://www.hifiberry.com/docs/software/using-the-dac-dsp-to-record-audio-from-s-pdif/
* https://github.com/hifiberry/hifiberry-dsp
* https://raspi.tv/how-to-enable-spi-on-the-raspberry-pi (1st comment in particular)

An attempt to make it work:
```sh
    {
      "type": "shell",
      "inline": [
        "apt-get install -y git python-spidev python3-spidev",
        "git clone --branch v3.4 https://github.com/doceme/py-spidev.git",
        "cd py-spidev && python3 setup.py install",
        "pip3 install --upgrade hifiberrydsp",
        "wget -O /tmp/install-dsptoolkit.sh https://raw.githubusercontent.com/hifiberry/hifiberry-dsp/{{user `hifiberry_dsp_version`}}/install-dsptoolkit",
        "bash /tmp/install-dsptoolkit.sh",
        "wget -O /user/local/bin/spdif2pi https://raw.githubusercontent.com/hifiberry/hifiberry-os/{{user `hifiberry_os_version`}}/buildroot/package/dsptoolkit/spdif2pi",
        "chmod +x /user/local/bin/spdif2pi",
        "echo dtparam=spi=on >> /boot/config.txt",
        "sed -Ei '/^source = .+/a source = alsa:\/\/?name=spdif-input\&device=default' /etc/snapserver.conf"
      ]
    },
```

The following actually needs to run live against the real board+DSP (after the sigmatcpserver has been started):
```sh
/user/local/bin/spdif2pi || (echo Failed to configure DSP >&2; false)
```
However it fails without an error message.
Apparently sigmatcpserver and/or the SPI integration don't seem to be set up properly.
