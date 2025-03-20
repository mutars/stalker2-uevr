# STALKER 2 UEVR Plugin

A plugin for UEVR (Unreal Engine VR) that enhances the VR experience in S.T.A.L.K.E.R. 2.

## Current Features

- Fixed weapon origin alignment to ensure bullets shoot correctly from the muzzle position
- Basic VR implementation for weapon handling
- Holster System and Weapon Interaction Zones
- Full Recoil effects
## HOW TO - Holster System, Weapon Interaction Zones:

1. This mod features a holster system that replaces the default gamepad buttons or offers an optional method to interact with the game mechanics:
   
     **Holster Zones**: Hover over a zone and you will get a haptic feedback, pressing the Grip button will interact with the zone.
  
   |      VR Button         | Zone                          | Action                         |
   |----------------|-------------------------------|-----------------------------|
   |   Press Right Grip   |   Rigth Shoulder      |    Primary Slot Weapon    |
   |      |   Left Shoulder   |    2nd Primary Slot Weapon   |
   |      |   Right Hip Area     |   Sidearm Slot Weapon    |
   |      |   Left Lower Area       |   Melee Slot Weapon    |
   |      |   Left Chest  |    Nail   |
   |                     |  Right Chest  |     Grenade Slot  |
   |      |   Top Head, if AimMethod Head  |    Toggle Flashlight   |
   |   Press Left Grip   |   Left Shoulder  |  Open Inventory      |
   |                     |   Right Shoulder |   Simulates Dpad Left aka QuickSlot for item usage  |
   |                     |   Left Chest |  Scanner  |
   |                     |   Right Chest |      PDA    |
   |      |   Top Head, if AimMethod Head  |    Toggle Flashlight   |

![Alt text](./vr-controls-holster-system.svg)
  
3. **Weapon Interaction zones**: These zones are around your right controller (or weapon basically) and can be triggered with your left controller
   |      VR Button         | Zone                          | Action                         |
   |----------------|-------------------------------|-----------------------------|
   |   Press Left Grip   |   Underneath your weapon    |    Reloading  |
   |    Press Left Thumb   |   Front area of your weapon, if Aim Method Right Hand   |    Toggle Flashlight   |
   |    Press Left Trigger  |  Left controller slightly above your right controller (you can touch them)     |   FireMode Switch    |

![Alt text](./vr-controls-weapon-interaction.svg)

## VR Button layout changes 
- Some buttons have been changed from the normal XBOX gamepad bindings:
   |VR Button| Action  | 
   |---------|-- |
   |Right Stick Up| Jump |
   |Right Stick Down| Crouch |
   |  Left Grip   |  Sprinting  |
## Work in Progress

Currently, the plugin is in early development with limited functionality. The following features are pending implementation:

### Priority Tasks

1. Weapon FOV & Animation Handling
   - Either prevent animations from changing weapon FOV
   - OR implement forced scope state changes when animation state is frozen to final position

2. Scope Implementation
   - Add foveated screen capture in front of scope to provide proper zoomed experience in VR

## Installation

1. Install UEVR following the official instructions from [UEVR's website](https://uevr.io)
2. Install this plugin according to UEVR's plugin installation guidelines

## Known Issues

- Limited feature set as this is an early development version
- Scope functionality not yet fully implemented
- Weapon FOV may be affected by animations

## Contributing

This is a work in progress project. Contributions and suggestions are welcome.

## Disclaimer

This is an unofficial modification for S.T.A.L.K.E.R. 2. Not affiliated with GSC Game World.

## License

MIT License

Copyright (c) 2025 mutars

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---
Last updated: 2025-02-19 04:33:57 UTC
