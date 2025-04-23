.data
.align 12
stack_end:
	.skip 4096
stack:

.text

.global _start

_start:
	csrci ustatus,1 	#½ûÖ¹ÖĞ¶Ï
	la sp,stack	#ÉèÖÃ¶ÑÕ»
	call main
	j .
	