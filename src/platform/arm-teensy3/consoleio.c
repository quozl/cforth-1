#include "kinetis.h"
#include "core_pins.h"

void tx(char c)
{
  while(!(UART0_S1 & UART_S1_TDRE)) // pause until transmit data register empty
    ;
  UART0_D = c;
}

int putchar(int c)
{
    if (c == '\n')
        tx('\r');
    tx(c);
}

int kbhit() {
  return UART0_S1 & UART_S1_RDRF;
}

int getkey()
{
  int c;
  while (!kbhit()) // pause until receive data register full
    ;
  c = UART0_D;
  return c;
}

void init_io()
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

  // TESTME, *RM.pdf, table 47-57, page 1275, 38400 baud?
  UART0_BDH = 0;
  UART0_BDL = 17;

  // transmitter enable, receiver enable
  UART0_C2 = 0xa;
}

void wfi(void)
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
