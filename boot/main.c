extern void uart_putc(char c);

char *flash = (char *)0x22000000;

void main() {
	while (*flash != 0)
		uart_putc(*(flash++));
}