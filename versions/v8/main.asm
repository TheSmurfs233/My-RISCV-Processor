.data
.align 12
stack_end:
	.skip 4096
stack:

.text

.global _start

_start:
	csrci ustatus,1 	#��ֹ�ж�
	la sp,stack	#���ö�ջ
	call main
	j .
	