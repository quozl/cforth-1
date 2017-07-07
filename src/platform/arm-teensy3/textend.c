// Edit this file to include C routines that can be called as Forth words.
// See "ccalls" below.

#include "forth.h"

// Prototypes

cell get_msecs();
cell wfi();
cell spins();
cell analogWrite();
cell analogRead();
cell digitalWrite();
cell digitalRead();
cell pinMode();
cell micros();
cell delay();
cell _reboot_Teensyduino_();
cell eeprom_size();
cell eeprom_base();
cell eeprom_length();
cell eeprom_read_byte();
cell eeprom_write_byte();
unsigned long rtc_get(void);
void rtc_set(unsigned long t);
void rtc_compensate(int adjust);

cell version_adr(void)
{
    extern char version[];
    return (cell)version;
}

cell build_date_adr(void)
{
    extern char build_date[];
    return (cell)build_date;
}

cell ((* const ccalls[])()) = {
        C(spins)                //c spins               { i.nspins -- }
        C(wfi)                  //c wfi                 { -- }
        C(get_msecs)            //c get-msecs           { -- n }
        C(analogWrite)          //c a!                  { i.val i.pin -- }
        C(analogRead)           //c a@                  { i.pin -- n }
        C(digitalWrite)         //c p!                  { i.val i.pin -- }
        C(digitalRead)          //c p@                  { i.pin -- n }
        C(pinMode)              //c m!                  { i.mode i.pin -- }
        C(micros)               //c get-usecs           { -- n }
        C(delay)                //c ms                  { i.#ms -- }
        C(_reboot_Teensyduino_) //c bye
        C(eeprom_size)          //c /nv                 { -- n }
        C(eeprom_base)          //c nv-base             { -- n }
        C(eeprom_length)        //c nv-length           { -- n }
        C(eeprom_read_byte)     //c nv@                 { i.adr -- i.val }
        C(eeprom_write_byte)    //c nv!                 { i.val i.adr -- }
        C(build_date_adr)       //c 'build-date         { -- a.value }
        C(version_adr)          //c 'version            { -- a.value }
        C(rtc_get)              //c rtc@                { -- i.val }
        C(rtc_set)              //c rtc!                { i.val -- }
        C(rtc_compensate)       //c rtc_compensate      { i.adjust -- }
};
