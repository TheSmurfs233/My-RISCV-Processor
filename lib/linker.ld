OUTPUT_ARCH( "riscv" ) 	/* rsicv架构 */
ENTRY( _start )	/* 程序入口地址 */

MEMORY {
  imem : ORIGIN = 0x00400000, LENGTH = 2K   /* 指令存储器地址范围 */
  dmem : ORIGIN = 0x10010000, LENGTH = 32K    /* 数据存储器地址范围 */
}

SECTIONS {

  /* 代码段放在指令存储器 */
    .text : {
    *(.text.init)      /* 启动代码 */
    *(.text .text.*)   /* 其他代码 */
  } > imem


  /* 只读数据（跳转表）和数据段均放在数据存储器 */
  .rodata : {
    *(.rodata .rodata.*)  /* 跳转表和其他只读数据 */
  } > dmem

  .data : {
    *(.data .data.*)      /* 全局变量和静态变量 */
  } > dmem

  .bss : {
    *(.bss .bss.*)        /* BSS段 */
  } > dmem
}