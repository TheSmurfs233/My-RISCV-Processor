.data
.align 12
stack_end:
	.skip 4096
stack:

.text

.global _start

_start:
	#csrci ustatus,1 	#禁止中断
	la sp,stack	        #设置堆栈
    call main
	j .
	