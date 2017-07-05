#include "forth.h"
#include "kinetis.h"
#include "core_pins.h"
#include "usb_serial.h"

#define TIB_SIZE	255

static unsigned char tib[TIB_SIZE + 1];
static unsigned char *tib_ptr = tib, *first_chr_ptr = tib;

char * ultoa(unsigned long val, char *buf, int radix)
{
  unsigned digit;
  int i=0, j;
  char t;

  while (1) {
    digit = val % radix;
    buf[i] = ((digit < 10) ? '0' + digit : 'A' + digit - 10);
    val /= radix;
    if (val == 0) break;
    i++;
  }
  buf[i + 1] = 0;
  for (j=0; j < i; j++, i--) {
    t = buf[j];
    buf[j] = buf[i];
    buf[i] = t;
  }
  return buf;
}

int seen_usb; /* data has been received from the USB host */
int sent_usb; /* data has been sent to the USB layer that is not yet flushed */

void tx(char c)
{
  while(!(UART0_S1 & UART_S1_TDRE)) // pause until transmit data register empty
    ;
  UART0_D = c;
  if (seen_usb) {
    usb_serial_putchar(c);
    sent_usb++;
  }
}

int putchar(int c)
{
  if (c == '\n')
    tx('\r');
  tx(c);
}

#if 0
// early debug
const char hexen[] = "0123456789ABCDEF";

void put8(uint32_t c)
{
  putchar(hexen[(c >> 4) & 0xf]);
  putchar(hexen[c & 0xf]);
}

void put32(uint32_t n)
{
  put8(n >> 24);
  put8(n >> 16);
  put8(n >> 8);
  put8(n);
}

void putline(char *str)
{
  while (*str)
    putchar((int)*str++);
}
#endif

int kbhit()
{
  if (UART0_RCFIFO > 0) return 1;
  if (usb_serial_peekchar() != -1) return 1;
  return 0;
}

static int char_push(unsigned char ch)
{
     // Never fail to push, but warn when it's the last push possible.
     *(tib_ptr++) = ch;
     if ((tib_ptr - tib) == TIB_SIZE)
	  return 1;
     else
	  return 0;
}

static unsigned char char_pop(void)
{
     unsigned char ch = (char)0;
     
     // If there's a saved character in the TIB, return it.
     if (first_chr_ptr < tib_ptr)
	  ch = *(first_chr_ptr++);
     // If we have read all of the characters out of the buffer, we can now reset both ptrs.
     if (first_chr_ptr == tib_ptr)
	  first_chr_ptr = tib_ptr = tib;
     return ch;
}

static int char_peek(void)
{
     if (tib_ptr == tib)
	  return 0;
     return 1;
}

static unsigned char char_get(void)
{
     unsigned char c;
	
     if (sent_usb) {
	  usb_serial_flush_output();
	  sent_usb = 0;
     }
     if (UART0_RCFIFO > 0) {
	  c = UART0_D;
	  return c;
     }
     c = usb_serial_getchar();
     if (c != -1) {
	  seen_usb++;
	  return c;
     }
}

int getkey()
{
     unsigned char ch;

     // If there's a buffered character, return it immediately.
     if (char_peek())
	  return char_pop();
     // Wait for a character to be available.
     while (!kbhit())
	  ;
     // Always push the character because we don't know how many more there will be in the buffered sequence.
     ch = char_get();
     char_push(ch);
     while (kbhit()) {
	  // If our buffer fills up, char_push() returns true so we know to immediately stop buffering.
	  ch = char_get();
	  if (char_push(ch))
	       return char_pop();
     }
     return char_pop();
}

void init_io(int argc, char **argv, cell *up)
{
  // turn on clock
  SIM_SCGC4 |= SIM_SCGC4_UART0;

  // configure receive pin
  // pfe - passive input filter
  // ps - pull select, enable pullup, p229
  // pe - pull enable, on, p229
  CORE_PIN0_CONFIG = PORT_PCR_PE | PORT_PCR_PS | PORT_PCR_PFE | PORT_PCR_MUX(3);

  // configure transmit pin
  // dse - drive strength enable, high, p228
  // sre - slew rate enable, slow, p229
  CORE_PIN1_CONFIG = PORT_PCR_DSE | PORT_PCR_SRE | PORT_PCR_MUX(3);

  // baud rate generator, 115200, derived from test build
  // reference, *RM.pdf, table 47-57, page 1275, 38400 baud?
  UART0_BDH = 0;
  UART0_BDL = 0x1a;
  UART0_C4 = 0x1;

  // fifo enable
  UART0_PFIFO = UART_PFIFO_TXFE | UART_PFIFO_RXFE;

  // transmitter enable, receiver enable
  UART0_C2 = UART_C2_TE | UART_C2_RE;

  seen_usb = 0;
  sent_usb = 0;
  usb_init();
  analog_init();
}

void wfi(void)
{
  asm("wfi"); // __WFI();
}

void yield(void)
{
  asm("wfi"); // __WFI();
}

volatile uint32_t systick_millis_count = 0;
int get_msecs(void)
{
  return systick_millis_count;
}

int spins(int i)
{
  while(i--)
    asm("");  // The asm("") prevents optimize-to-nothing
}

void pfprint_input_stack(void) {}
void pfmarkinput(void *fp, cell *up) {}

cell pfflush(cell f, cell *up)
{
    return -1;
}

cell pfsize(cell f, u_cell *high, u_cell *low, cell *up)
{
    *high = 0;
    *low = 0;
    return SIZEFAIL;
}

cell isstandalone() { return 1; }

#include <stdio.h>

size_t strlen(const char *s)
{
    const char *p = s;
    while (*p) { p++; }
    return p-s;
}
