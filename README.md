# deepracer-pi
DeepRacer for RaspberryPi




## Changes

GPIO:
- `gpio1` - enable PWM (does not do anything, PWM is always on for the Waveshare board)
- `gpio495`-`gpio504` - maps to PWM7 to PWM15 on the Hat, to control three RGB leds (those originally on the side of the board)

## What does not (yet) work

- Battery gauge is not connected
- Device Info Node is looking in non-existent places
- NCS2 is known not to work with Evo, don't try. 
- OTG Network (USB Network) is disabled.
