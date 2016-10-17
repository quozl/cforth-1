C Forth for Teensy 3.1
======================

C Forth is a Forth implementation by Mitch Bradley, optimised for embedded use in semi-constrained systems such as System-on-Chip processors.  See https://github.com/MitchBradley/cforth.git

The Teensy 3.1 is a Freescale MK20DX256 ARM Cortex-M4 with a Nuvoton MINI54 ARM Cortex-M0 management controller.  Paul Stoffregen maintains a build environment, which can be used with or without an IDE.  See https://github.com/PaulStoffregen/cores.git

This repository you are looking at is an initial build of C Forth, without removing unnecessary features, which used 51 kB out of the available 256 kB FLASH.  It requires UART0 at 115200 baud.

See also https://github.com/lowfatcomputing/mecrisp-stellaris for Mecrisp-Stellaris, a port of Mecrisp to the ARM Cortex M architecture.
