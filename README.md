C Forth for Teensy 3.1
======================

C Forth is a Forth implementation by Mitch Bradley, optimised for embedded use in semi-constrained systems such as System-on-Chip processors.  See https://github.com/MitchBradley/cforth.git

The Teensy 3.1 is a Freescale MK20DX256 ARM Cortex-M4 with a Nuvoton MINI54 ARM Cortex-M0 management controller.  Paul Stoffregen maintains a build environment, which can be used with or without an IDE.  See https://github.com/PaulStoffregen/cores.git

See also https://github.com/lowfatcomputing/mecrisp-stellaris for Mecrisp-Stellaris, a port of Mecrisp to the ARM Cortex M architecture.

Install Dependencies
--------------------

* install dependencies,

`sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi git`

* if you are using a 64-bit build system (where `uname -m` returns x86_64), install further dependencies,

`sudo apt install lib32gcc-5-dev libc6-dev-i386`

Building
--------

```
cd build/arm-teensy3
make
```

Loading
-------

```
make burn
```

See also
https://quozl.linux.org.au/cforth-on-teensy/
