# Builds CForth for Teensy 3

TOPDIR=../..

EXTRA_CLEAN += main.map	tdate.c app.hex version
#DEFS += -DBUFFERED_CONSOLEIO

include $(TOPDIR)/src/app/arm-teensy3/targets.mk

default: app.elf app.hex app.nm app.dump
