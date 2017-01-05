# **C Forth based firmware for ESP32 WiFi SOC** #

A fork of Mitch Bradley's C Forth with my local build configuration for Ubuntu 14.04 amd64.

## Setting up the toolchain ##

See esp-idf.

```
git clone --recursive https://github.com/espressif/esp-idf.git
wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-59.tar.gz
```

Unpack the binaries.

## Clone this source ##

```
git clone -b esp32 https://github.com/quozl/cforth-1.git
```

## Building ##

```
cd cforth
export IDF_PATH=/path/to/esp-idf
export PATH=$PATH:/path/to/xtensa-esp32-elf/bin
XTGCCPATH=/path/to/xtensa-esp32-elf/bin/ make
```

## Flashing ##

```
make flash
```

## Serial terminal ###

```
screen /dev/ttyUSB0 115200
```

```
ets Jun  8 2016 00:22:57

rst:0x1 (POWERON_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
ets Jun  8 2016 00:22:57

rst:0x10 (RTCWDT_RTC_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
configsip: 0, SPIWP:0x00
clk_drv:0x00,q_drv:0x00,d_drv:0x00,cs0_drv:0x00,hd_drv:0x00,wp_drv:0x00
mode:DIO, clock div:2
load:0x3ffc0008,len:4
load:0x3ffc000c,len:2364
load:0x40078000,len:4504
load:0x40080000,len:260
entry 0x40080034
I (540) heap_alloc_caps: Initializing. RAM available for dynamic allocation:
I (541) heap_alloc_caps: At 3FFB6F24 len 000290DC (164 KiB): DRAM
I (543) heap_alloc_caps: At 3FFE8000 len 00018000 (96 KiB): D/IRAM
I (550) heap_alloc_caps: At 400919F4 len 0000E60C (57 KiB): IRAM
I (556) cpu_start: Pro cpu up.
I (560) cpu_start: Single core mode
I (564) cpu_start: Pro cpu start user code
I (851) phy: phy_version: 258, Nov 29 2016, 15:51:07, 1, 0
I (1007) cpu_start: Starting scheduler on PRO CPU.

CForth built 2017-01-05 07:29 from b3c5689
ok 
```
