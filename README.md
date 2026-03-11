# Automotive Digital Instrument Cluster
A digital instrument cluster simulation developed using Qt/QML and C++ 
running on Raspberry Pi. The system reads driver inputs from Logitech G29 
and displays vehicle information on a digital cluster UI.

## Project Overview

This project simulates a vehicle digital instrument cluster system.
It reads steering, throttle, brake, and gear inputs from Logitech G29 
and processes them through a C++ backend to update a graphical cluster UI.

The system demonstrates how automotive HMI systems work in real vehicles.

## System Architecture

Driver Input (Logitech G29)
        ↓
Linux HID Driver
        ↓
Input Handling Layer (C++)
        ↓
UI Layer (QML)
        ↓
Digital Instrument Cluster Display


## Features

- Digital speedometer
- Tachometer (RPM)
- Gear position display
- Real-time UI updates
- Dual-screen display support

## Hardware Requirements

- Raspberry Pi 4
- Logitech G29 Steering Wheel
- Dual 10-inch displays
- USB connection

  ## Software Requirements

- Linux OS
- Qt Framework
- C++ Compiler
- Git
