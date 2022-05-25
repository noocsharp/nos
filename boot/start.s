.set MPP_MASK, 0b1100000000000
.set S_MODE,    0b100000000000

.set UART_THR, 0x10000000
.set UART_DLL, 0x10000000
.set UART_DLM, 0x10000001
.set UART_LCR, 0x10000003
.set UART_LSR, 0x10000005
.set UART_LCR_DLAB, 0x80
.set UART_LCR_UNDLAB, 0x0B
.set UART_LSR_RI, 0x40

.globl _start
_start:
	# only run boot code on 0th hart
	csrr t0, mhartid
	lui t1, 0
	beq t0, t1, premain

wait:
	wfi
	j wait

premain:

	la sp, stack_top

	# set MPP to S-mode
	csrr t1, mstatus
	li t2, MPP_MASK
	not t2, t2
	and t1, t2, t1
	li t2, S_MODE
	or t1, t2, t1
	csrw mstatus, t1

	la t1, main
	csrw mepc, t1

	# disable paging and protection
	csrw satp, 0
	csrw pmpcfg0, 0xf
	li t1, 0xffffffff
	csrw pmpaddr0, t1

	# delegate interrupts and exceptions to S-mode
	li t1, 0xffff
	csrw mideleg, t1
	csrw medeleg, t1

	# set trap vector
	la t1, trap
	csrw mtvec, t1

	mret

main:
	# START UART WRITE
	# allow divisor write
	li t1, UART_LCR
	li t2, UART_LCR_DLAB
	sb t2, 0(t1)

	# write divisor LSB and MSB
	li t1, UART_DLL
	li t2, 1
	sb t2, 0(t1)
	li t1, UART_DLM
	li t2, 0
	sb t2, 0(t1)

	# disable divisor write
	li t1, UART_LCR
	li t2, UART_LCR_UNDLAB
	sb t2, 0(t1)

uart_notready:
	la t1, UART_LSR
	li t2, UART_LSR_RI
	and t1, t2, t1
	li t2, 0
	bne t1, t2, uart_notready

	li t1, UART_THR
	li t2, 0x61
	sb t2, 0(t1)

inf:
	wfi
	j inf

trap:
	nop
