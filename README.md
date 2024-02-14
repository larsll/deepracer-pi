# DeepRacer for Raspberry Pi 4

This repository provides a port of the DeepRacer software stack to the Raspberry Pi 4. It runs
on Ubuntu 22.04 with ROS2 Humble, but with most of original code. To make the image smaller the server image is recommended.

## Features

Main features of the port:

- Previously trained models will work
- Uses OpenVINO (for now), to keep inference identical to original car
- Can integrate with DREM
- Single power source¹ - reduces weight and lowers center of gravity

## Parts

The following parts are needed:

- Raspberry 4 or compatible board, recommended 4Gb or 8Gb RAM, but 2Gb may also work.
- [Intel Neural Compute Stick (NCS) 2](https://www.intel.com/content/www/us/en/developer/articles/tool/neural-compute-stick.html)
- [Waveshare Servo Driver Hat](https://www.waveshare.com/product/raspberry-pi/hats/motors-relays/servo-driver-hat.htm) or compatible PCA9865 servo boards.
- USB camera with ~60 deg FOV, e.g. original DeepRacer camera or a Raspberry Pi camera.
- 4 RGB light diodes
- Misc cables

¹ The Waveshare hat comes with a step-down converter from 7.4V to 5V, and will power the Pi via the GPIO header. Other similar cards will require separate power.

**Optional**

- Fan/heat-sink kit for Raspberry PI 4

## Software Install

Installation of software is reasonably straight forward, as pre-built packages are provided:

- Flash an SD card with Ubuntu 22.04 Server for ARM64 using the Raspberry Pi Imager.
- Boot the SD card, and let it upgrade (this takes some time...)
- Run `git clone https://github.com/larsll/deepracer-pi`
- Run `sudo ./install-prerequisites.sh`
- Reboot
- Run `sudo ./install-deepracer.sh`

Once installed you can start the stack with `sudo /opt/aws/deepracer/start_ros.sh`. To ensure a smooth start a camera needs to be plugged in.
The launch log will now display in the console.

To automatically start at boot do `sudo systemctl enable deepracer-core` and to start the service in the background `sudo systemctl start deepracer-core`.

### Changes

Some changes have been made to the code to enable access to GPIO as sysfs layout is different on the Raspberry Pi than on the custom Intel board.

## PWM Outputs

| Channel | Purpose          | Notes                                    |
| ------- | ---------------- | ---------------------------------------- |
| 0       | Speed controller | Remove red cable for stock DeepRacer ESC |
| 1       | Steering servo   |
| 2       | RGB LED          | Tail light                               |
| 3       | RGB LED          | Tail light                               |
| 4       | RGB LED          | Tail light                               |
| 5       |
| 6       |
| 7       | RGB LED          |
| 8       | RGB LED          |
| 9       | RGB LED          |
| 10      | RGB LED          |
| 11      | RGB LED          |
| 12      | RGB LED          |
| 13      | RGB LED          |
| 14      | RGB LED          |
| 15      | RGB LED          |

LiPo can power both the board and car, 3 pin (balance lead) gets wired to VIN (black and red cables only) to power the board and RPi. The 2 pin power cable goes to the car as normal.

**Improvements:**

- Stripped down OS
- Runs the custom deepracer stack also seen in [deepracer-scripts](https://github.com/davidfsmith/deepracer-scripts).

**GPIO layout:**

- `gpio1` - enables PWM (does not do anything, PWM is always on for the Waveshare board)
- `gpio495`-`gpio504` - maps to PWM7 to PWM15 on the Hat, to control three RGB leds (those originally on the side of the board)

## What does not (yet) work

- Support only for single camera, as the Neural Compute Stick does not support Evo configuration(s)
- Battery gauge is not connected - red warning message persists
- Device Info Node is looking in non-existent places - no real impact
- OTG Network (USB Network) is disabled - requires testing
