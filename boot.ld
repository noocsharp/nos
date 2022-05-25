ENTRY(_start)

MEMORY
{
	ram (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 128M
}

PHDRS
{
	text PT_LOAD;
}

SECTIONS
{
	.text : {
		*(.text)
	} >ram AT>ram :text

	. += 0x8000;
	stack_top = .;
}
