

# **RISC-V编译全链路解析：从C语言到机器码的深度实践手记**

## 1. 编译基础概念

**编译**是将**高级编程语言（如C/C++）\**转换为\**计算机可执行的机器指令**的过程。编译器（Compiler）是实现这一转换的核心工具，主要解决以下问题：

- **可移植性**：不同硬件平台（如x86、ARM、RISC-V）的机器指令不同
- **效率优化**：将人类易读的代码转化为高效的底层指令
- **错误检查**：在转换过程中发现语法或逻辑错误

### 1.1 程序编译流程四大阶段

**1). 预处理（Preprocessing）**

- **作用**：处理源代码中的预处理指令
- **操作内容**：
  - 展开`#include`包含的头文件
  - 替换`#define`定义的宏
  - 条件编译（`#ifdef`、`#if`等）
- **输入/输出**：
  - 输入：`.c`文件
  - 输出：`.i`文件（预处理后的文本文件）

**2). 编译（Compilation）**

- **作用**：将预处理后的代码转换为**汇编语言**
- **核心任务**：
  - 语法和语义分析
  - 生成中间代码（IR）
  - 优化代码结构
- **输入/输出**：
  - 输入：`.i`文件
  - 输出：`.s`文件（汇编代码）

**3). 汇编（Assembly）**

- **作用**：将汇编代码转换为**机器指令（二进制）**
- **核心任务**：
  - 解析汇编指令
  - 生成目标文件（包含机器码和符号表）
- **输入/输出**：
  - 输入：`.s`文件
  - 输出：`.o`文件（目标文件）

**4). 链接（Linking）**

- **作用**：合并多个目标文件和库，生成可执行文件
- **核心任务**：
  - 解析符号引用（如函数调用）
  - 分配最终内存地址
  - 生成可执行格式（如ELF）
- **输入/输出**：
  - 输入：`.o`文件 + 库文件
  - 输出：可执行文件（如`.elf`）

### 1.2 交叉编译概念

交叉编译环境（Cross-Compilation Environment）是指在一台计算机（主机平台，Host）上编译生成能在另一台不同架构的计算机（目标平台，Target）上运行的程序或系统的开发环境。它的核心是交叉编译器（Cross-Compiler），将源代码转换为目标平台的可执行代码。

![image-20250406181812424](../../RISCV/doc/img/rv-img-0.png)

##### 为什么需要交叉编译环境？

1. 目标平台资源有限

   嵌入式设备（如单片机、IoT设备）通常计算能力弱、内存小，无法直接在设备上运行复杂的编 译工具链。
   示例：在树莓派（ARM）上编译程序可能很慢，而用一台高性能x86主机交叉编译会更高效。 

2. 目标平台尚未就绪

   开发操作系统或底层驱动时，目标平台可能还没有操作系统（如裸机程序），无法在目标平台 上直接编译。
   示例：开发RISC-V操作系统的内核时，必须先在主机上交叉编译。

3. 跨平台开发需求 

   需要为不同架构（如x86、ARM、RISC-V）生成可执行文件，但开发者可能只有一种开发机。 
   示例：在x86电脑上开发并编译适用于RISC-V开发板的程序。

##### 交叉编译环境核心组件

1. 交叉编译器（Cross-Compiler）

   支持从主机平台到目标平台的代码转换（如riscv64-unknown-linux-gnu-gcc）。

2. 目标平台库

   目标系统的标准库（如glibc或嵌入式系统的newlib）。

3. 链接器和调试工具

   如riscv64-unknown-elf-ld（链接器）、gdb-multiarch（跨平台调试器）。

4. 模拟器或硬件支持

   验证程序是否能在目标平台运行（如QEMU模拟器、spike、renode或真实RISC-V开发板）。

##### RISC-V交叉编译器

1.  官方 GNU 工具链（RISC-V GNU Toolchain）

    - RISC-V 社区（原由 SiFive 维护）

    - 最广泛使用的工具链，支持裸机（Bare-Metal）和 Linux 应用。

    - 提供两种标准变体：
      - riscv64-unknown-elf-*：面向裸机开发（使用 newlib 标准库）。
      - riscv64-unknown-linux-gnu-*：面向 Linux 应用（使用 glibc 标准库）。
    - 支持多库（Multilib），可编译多种 RISC-V 扩展组合（如 RV32/64、IMAFDC 等）。

2.  LLVM/Clang 工具链

    - LLVM 社区
    - 支持现代 C/C++ 标准（如 C++20）。
    - 与 GNU 工具链兼容，可替代 GCC 使用。
    - 支持 RISC-V V 扩展（向量指令）、自定义指令扩展等。
    - 适用于需要 LLVM 生态（如 Rust、Julia）的项目。

3.  SiFive 预编译工具链

    - 基于GCC，SiFive维护。
    - 针对 SiFive 硬件优化（如 HiFive 开发板）。
    - 提供裸机（Freedom-E-SDK）和 Linux 版本。
    - 支持自定义扩展（如 SiFive 的 Core IP 指令）。

4.  XPack GNU RISC-V 工具链

    - 基于GCC，xPack 社区
    - 跨平台支持（Windows、Linux、macOS）。
    - 预编译二进制，开箱即用。
    - 提供裸机（riscv-none-elf）和 Linux（riscv64-unknown-linux-gnu）版本。

##### 如何选择RISC-V交叉编译器

1. 工具链命名规则

   -  riscv64-unknown-elf-*：riscv64 指目标架构，unknown 表示厂商未知，elf 表示输出格式。
   -  riscv64-unknown-linux-gnu-*：linux-gnu 表示目标系统为 Linux。

   ![image-20250406184336383](../../RISCV/doc/img/rv-img-1.png)

2. 本文中使用预编译的gnu release版本

## 2. RISC-V环境搭建

### 2.1 Windows安装Ubuntu

嵌入式系统开发一般使用linux主机作为宿主机，这里使用WSL安装Ubuntu。 

WSL（全称 Windows Subsystem for Linux）是微软为 Windows 10/11 操作系统开发的功 能，允许用户直接在 Windows 系统中运行 Linux 二进制可执行文件（如命令行工具、脚本、 应用程序等），无需传统的虚拟机（如 VirtualBox）或双系统配置。它实现了 Windows 与  Linux 环境的深度集成，是开发者、运维人员和 Linux 学习者的高效工具。

##### 安装WSL

- 在管理员模式下打开 PowerShell 或 Windows 命令提示符，方法是右键单击并选择“以管理员身份运行”，输入 wsl --install 命令，然后重启计算机。此命令将启用运行 WSL 并安装 Linux 的 Ubuntu 发行版所需的功能。
- 默认情况下，安装的 Linux 分发版为 Ubuntu。 可以使用 -d 标志进行更改。
- 若要更改安装的发行版，请输入：`wsl --install -d <Distribution Name>` 。 将 `<Distribution Name>`替换为要安装的发行版的名称。

##### 访问WSL与windows下文件

- Windows访问Ubuntu
  文件资源管理器：Linux/Ubuntu

- Ubuntu下访问windows
  C盘： `/mnt/c`

  D盘：`/mnt/d`

### 2.2 测试

安装编译完成RISC-V交叉编译器后在终端中运行命令`riscv32-unknown-linux-gnu-gcc -v`，提示以下信息证明交叉编译环境编译安装成功

![image-20250406185706359](../../RISCV/doc/img/rv-img-2.png)

## 3. 完整编译流程

接下来以一个完整例子来介绍一些如何使用交叉编译器写一个RISC-V的嵌入式应用

C语言程序示例：按键控制LED灯

给之前在开发板上实现的五级流水线CPU编写程序，实现按键控制LED灯的功能

### 3.1 按键控制LED灯程序构成

程序包括两个程序，一个是汇编程序，另一个是C程序

##### 汇编程序

- 汇编程序用于程序引导使用，计算机首先执行汇编程序，在汇编程序中调用主程序，在主程序里面完成按键控制LED灯的点亮和熄灭
- 汇编程序主要设置一些初始的状态，比如初始化堆栈指针，默认编辑器使用sp作为堆栈指针， 当函数调用和返回时从堆栈上去保存或恢复破坏的一些数据。设置中断向量表，复制.data段到ram，跳转到main()函数

```
.data
.align 12
stack_end:
	.skip 4096
stack:

.text

.global _start

_start:
	csrci ustatus,1 	#禁止中断
	la sp,stack	#设置堆栈
	call main
	j .
```

上面代码开始声明了一个堆栈，大小为4096，在代码段里首先定义了一个全局变量 `_start` 地址，第一条指令里面去写 `ustatus`寄存器禁止中断。第二条指令把堆栈栈顶地址加载到`sp`寄存器里面。第三条指令调用C语言里面的主函数main(也可以是其他名字)。当main函数退出后进入第四条指令循环。

##### 编译

在Ubuntu中执行下面命令。

```
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -o x.elf start.s main.c
```

`-march=rv32i` 指定目标指令集架构位RISC-V 32位基础整数指令集(RV32I)

`-mabi=ilp32` 指定应用程序二进制接口(ABI)为 `ilp32`

`-nostdlib` 默认情况下GCC会链接标准启动文件(如 `crt0.o`)，负责初始化堆栈、全局变量等。在裸机开发中、需自定义启动代码（如 `start.s`），因此需禁用默认启动逻辑

`-o x.elf`  指定输出文件名为 `x.elf`

![image-20250407130348037](../../RISCV/doc/img/rv-img-3.png)

生成一个`.elf`文件，使用`file x.elf`命令查看文件类型

```
qaq@DESKTOP-I8GGJRG:~/soc$ file x.elf
x.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, soft-float ABI, version 1 (SYSV), statically linked, not stripped
qaq@DESKTOP-I8GGJRG:~/soc$ 
```

elf文件是32位可执行的，riscv指令集，这个文件在Ubuntu上是无法执行的，因为本平台是X86

- 生成的elf是什么？

  .elf 文件（Executable and Linkable Format）是一种标准的二进制文件格式，主要用于  UNIX/Linux 系统和 嵌入式开发中。它定义了程序的可执行代码、数据、符号表、调试信息等内容的组织形式。

- 查看elf文件

  ```
  readelf -a x.elf
  ```

  运行后信息输出如下

  ```
  qaq@DESKTOP-I8GGJRG:~/soc$ readelf -a x.elf
  ELF Header:
    Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00 
    Class:                             ELF32
    Data:                              2's complement, little endian
    Version:                           1 (current)
    OS/ABI:                            UNIX - System V
    ABI Version:                       0
    Type:                              EXEC (Executable file)
    Machine:                           RISC-V
    Version:                           0x1
    Entry point address:               0x10094
    Start of program headers:          52 (bytes into file)
    Start of section headers:          8776 (bytes into file)
    Flags:                             0x0
    Size of this header:               52 (bytes)
    Size of program headers:           32 (bytes)
    Number of program headers:         3
    Size of section headers:           40 (bytes)
    Number of section headers:         8
    Section header string table index: 7
  
  Section Headers:
    [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
    [ 0]                   NULL            00000000 000000 000000 00      0   0  0
    [ 1] .text             PROGBITS        00010094 000094 0000a4 00  AX  0   0  4
    [ 2] .data             PROGBITS        00012000 001000 001000 00  WA  0   0 4096
    [ 3] .comment          PROGBITS        00000000 002000 000022 01  MS  0   0  1
    [ 4] .riscv.attributes RISCV_ATTRIBUTE 00000000 002022 00001c 00      0   0  1
    [ 5] .symtab           SYMTAB          00000000 002040 000140 10      6  11  4
    [ 6] .strtab           STRTAB          00000000 002180 000083 00      0   0  1
    [ 7] .shstrtab         STRTAB          00000000 002203 000042 00      0   0  1
  Key to Flags:
    W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
    L (link order), O (extra OS processing required), G (group), T (TLS),
    C (compressed), x (unknown), o (OS specific), E (exclude),
    D (mbind), p (processor specific)
  
  There are no section groups in this file.
  
  Program Headers:
    Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
    RISCV_ATTRIBUT 0x002022 0x00000000 0x00000000 0x0001c 0x00000 R   0x1
    LOAD           0x000000 0x00010000 0x00010000 0x00138 0x00138 R E 0x1000
    LOAD           0x001000 0x00012000 0x00012000 0x01000 0x01000 RW  0x1000
  
   Section to Segment mapping:
    Segment Sections...
     00     .riscv.attributes 
     01     .text 
     02     .data 
  
  There is no dynamic section in this file.
  
  There are no relocations in this file.
  
  The decoding of unwind sections for machine type RISC-V is not currently supported.
  
  Symbol table '.symtab' contains 20 entries:
     Num:    Value  Size Type    Bind   Vis      Ndx Name
       0: 00000000     0 NOTYPE  LOCAL  DEFAULT  UND 
       1: 00010094     0 SECTION LOCAL  DEFAULT    1 .text
       2: 00012000     0 SECTION LOCAL  DEFAULT    2 .data
       3: 00000000     0 SECTION LOCAL  DEFAULT    3 .comment
       4: 00000000     0 SECTION LOCAL  DEFAULT    4 .riscv.attributes
       5: 00000000     0 FILE    LOCAL  DEFAULT  ABS cczCbJTv.o
       6: 00012000     0 NOTYPE  LOCAL  DEFAULT    2 stack_end
       7: 00013000     0 NOTYPE  LOCAL  DEFAULT    2 stack
       8: 00010094     0 NOTYPE  LOCAL  DEFAULT    1 $xrv32i2p1
       9: 00000000     0 FILE    LOCAL  DEFAULT  ABS main.c
      10: 000100a4     0 NOTYPE  LOCAL  DEFAULT    1 $xrv32i2p1
      11: 00012800     0 NOTYPE  GLOBAL DEFAULT  ABS __global_pointer$
      12: 00013000     0 NOTYPE  GLOBAL DEFAULT    2 __SDATA_BEGIN__
      13: 00010094     0 NOTYPE  GLOBAL DEFAULT    1 _start
      14: 00013000     0 NOTYPE  GLOBAL DEFAULT    2 __BSS_END__
      15: 00013000     0 NOTYPE  GLOBAL DEFAULT    2 __bss_start
      16: 000100a4   148 FUNC    GLOBAL DEFAULT    1 main
      17: 00012000     0 NOTYPE  GLOBAL DEFAULT    2 __DATA_BEGIN__
      18: 00013000     0 NOTYPE  GLOBAL DEFAULT    2 _edata
      19: 00013000     0 NOTYPE  GLOBAL DEFAULT    2 _end
  
  No version information found in this file.
  Attribute Section: riscv
  File Attributes
    Tag_RISCV_stack_align: 16-bytes
    Tag_RISCV_arch: "rv32i2p1"
  ```

  需要关注的重点有

  - 程序入口地址

    ```
    Entry point address:               0x10094
    ```

  - 各个section的大小、起始地址等信息

    ```
    Section Headers:
      [ 1] .text             PROGBITS        00010094 000094 0000a4 00  AX  0   0  4
      [ 2] .data             PROGBITS        00012000 001000 001000 00  WA  0   0 4096
    ```

  - 定义的符号

    ```
    Symbol table '.symtab' contains 20 entries:
    ```

- 反汇编elf

  ```
  objdump -d x.elf
  ```

  运行后输出信息如下

  ```
  qaq@DESKTOP-I8GGJRG:~/soc$ riscv64-unknown-elf-objdump -d x.elf
  
  x.elf:     file format elf32-littleriscv
  
  
  Disassembly of section .text:
  
  00010094 <_start>:
     10094:       00003117                auipc   sp,0x3
     10098:       f6c10113                addi    sp,sp,-148 # 13000 <__BSS_END__>
     1009c:       008000ef                jal     100a4 <main>
     100a0:       0000006f                j       100a0 <_start+0xc>
  
  000100a4 <main>:
     100a4:       fe010113                addi    sp,sp,-32
     100a8:       00812e23                sw      s0,28(sp)
     100ac:       02010413                addi    s0,sp,32
     100b0:       100307b7                lui     a5,0x10030
     100b4:       00600713                li      a4,6
     100b8:       00e7a023                sw      a4,0(a5) # 10030000 <__BSS_END__+0x1001d000>
     100bc:       100307b7                lui     a5,0x10030
     100c0:       01078793                addi    a5,a5,16 # 10030010 <__BSS_END__+0x1001d010>
     100c4:       0007a783                lw      a5,0(a5)
     100c8:       fef42623                sw      a5,-20(s0)
     100cc:       fec42783                lw      a5,-20(s0)
     100d0:       0017f793                andi    a5,a5,1
     100d4:       02078263                beqz    a5,100f8 <main+0x54>
     100d8:       100307b7                lui     a5,0x10030
     100dc:       01078793                addi    a5,a5,16 # 10030010 <__BSS_END__+0x1001d010>
     100e0:       0007a703                lw      a4,0(a5)
     100e4:       100307b7                lui     a5,0x10030
     100e8:       01078793                addi    a5,a5,16 # 10030010 <__BSS_END__+0x1001d010>
     100ec:       ffd77713                andi    a4,a4,-3
     100f0:       00e7a023                sw      a4,0(a5)
     100f4:       0200006f                j       10114 <main+0x70>
     100f8:       100307b7                lui     a5,0x10030
     100fc:       01078793                addi    a5,a5,16 # 10030010 <__BSS_END__+0x1001d010>
     10100:       0007a703                lw      a4,0(a5)
     10104:       100307b7                lui     a5,0x10030
     10108:       01078793                addi    a5,a5,16 # 10030010 <__BSS_END__+0x1001d010>
     1010c:       00276713                ori     a4,a4,2
     10110:       00e7a023                sw      a4,0(a5)
     10114:       000187b7                lui     a5,0x18
     10118:       6a078793                addi    a5,a5,1696 # 186a0 <__BSS_END__+0x56a0>
     1011c:       fef42423                sw      a5,-24(s0)
     10120:       00000013                nop
     10124:       fe842783                lw      a5,-24(s0)
     10128:       fff78713                addi    a4,a5,-1
     1012c:       fee42423                sw      a4,-24(s0)
     10130:       fe079ae3                bnez    a5,10124 <main+0x80>
     10134:       f89ff06f                j       100bc <main+0x18>
  ```

##### 如何控制 gcc 生成的 elf 中 text 、data 起始地址以及程序入口地址？

在生成的 `.elf` 文件中 `.text`起始地址为 `0x00010094` ，`.data`起始地址为 `0x00012000`

我们要求 `.text` 起始地址为 `0x0040_0000`  ，`.data` 起始地址为 `0x1001_0000`

可以通过 `-WL,` 选项来通知链接器（ld，linker），执行以下命令

```
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib \
	-Wl,--entry=_start \
	-Wl,-Ttext=0x00400000 \
	-Wl,-Tdata=0x10010000 \
	-o x.elf start.s main.c
```

重新运行 `readelf -a x.elf` 命令

```
qaq@DESKTOP-I8GGJRG:~/soc$ readelf -a x.elf
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           RISC-V
  Version:                           0x1
  Entry point address:               0x400000
  Start of program headers:          52 (bytes into file)
  Start of section headers:          12872 (bytes into file)
  Flags:                             0x0
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         3
  Size of section headers:           40 (bytes)
  Number of section headers:         8
  Section header string table index: 7

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .text             PROGBITS        00400000 001000 0000a4 00  AX  0   0  4
  [ 2] .data             PROGBITS        10010000 002000 001000 00  WA  0   0 4096
  [ 3] .comment          PROGBITS        00000000 003000 000022 01  MS  0   0  1
  [ 4] .riscv.attributes RISCV_ATTRIBUTE 00000000 003022 00001c 00      0   0  1
  [ 5] .symtab           SYMTAB          00000000 003040 000140 10      6  11  4
  [ 6] .strtab           STRTAB          00000000 003180 000083 00      0   0  1
  [ 7] .shstrtab         STRTAB          00000000 003203 000042 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), p (processor specific)

There are no section groups in this file.

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  RISCV_ATTRIBUT 0x003022 0x00000000 0x00000000 0x0001c 0x00000 R   0x1
  LOAD           0x000000 0x003ff000 0x003ff000 0x010a4 0x010a4 R E 0x1000
  LOAD           0x002000 0x10010000 0x10010000 0x01000 0x01000 RW  0x1000

 Section to Segment mapping:
  Segment Sections...
   00     .riscv.attributes 
   01     .text 
   02     .data 

There is no dynamic section in this file.

There are no relocations in this file.

The decoding of unwind sections for machine type RISC-V is not currently supported.

Symbol table '.symtab' contains 20 entries:
   Num:    Value  Size Type    Bind   Vis      Ndx Name
     0: 00000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 00400000     0 SECTION LOCAL  DEFAULT    1 .text
     2: 10010000     0 SECTION LOCAL  DEFAULT    2 .data
     3: 00000000     0 SECTION LOCAL  DEFAULT    3 .comment
     4: 00000000     0 SECTION LOCAL  DEFAULT    4 .riscv.attributes
     5: 00000000     0 FILE    LOCAL  DEFAULT  ABS ccwgvBg3.o
     6: 10010000     0 NOTYPE  LOCAL  DEFAULT    2 stack_end
     7: 10011000     0 NOTYPE  LOCAL  DEFAULT    2 stack
     8: 00400000     0 NOTYPE  LOCAL  DEFAULT    1 $xrv32i2p1
     9: 00000000     0 FILE    LOCAL  DEFAULT  ABS main.c
    10: 00400010     0 NOTYPE  LOCAL  DEFAULT    1 $xrv32i2p1
    11: 10010800     0 NOTYPE  GLOBAL DEFAULT  ABS __global_pointer$
    12: 10011000     0 NOTYPE  GLOBAL DEFAULT    2 __SDATA_BEGIN__
    13: 00400000     0 NOTYPE  GLOBAL DEFAULT    1 _start
    14: 10011000     0 NOTYPE  GLOBAL DEFAULT    2 __BSS_END__
    15: 10011000     0 NOTYPE  GLOBAL DEFAULT    2 __bss_start
    16: 00400010   148 FUNC    GLOBAL DEFAULT    1 main
    17: 10010000     0 NOTYPE  GLOBAL DEFAULT    2 __DATA_BEGIN__
    18: 10011000     0 NOTYPE  GLOBAL DEFAULT    2 _edata
    19: 10011000     0 NOTYPE  GLOBAL DEFAULT    2 _end

No version information found in this file.
Attribute Section: riscv
File Attributes
  Tag_RISCV_stack_align: 16-bytes
  Tag_RISCV_arch: "rv32i2p1"
```

可以看到，`.text` 和 `.data`入口地址已经更改，执行命令的参数起到了作用

```
  [ 1] .text             PROGBITS        00400000 001000 0000a4 00  AX  0   0  4
  [ 2] .data             PROGBITS        10010000 002000 001000 00  WA  0   0 4096
```

##### 如何将elf中text和data导出？

操作系统中由加载器（loader）将elf文件中的相关代码和数据装载到内存中

在verilog中使用的是 `$readmemh` 函数，在inital中读入 hex 格式文件

使用Linux下的objcopy工具

```
objcopy --dump-section .text=text.bin x.elf  # 导出代码段的二进制文件
objcopy --dump-section .data=data.bin x.elf  # 导出数据段的二进制文件
# text.bin 和 data.bin 均为二进制文件
```

但是二进制文件和我们需要的hex格式不一样，hex格式是ascii码，十六进制文本格式，每行一个字，使用回车分割

使用Linux下的命令 hexdump

```
hexdump -v -e '1/4 "%08x\n"'  text.bin > text.hex
hexdump -v -e '1/4 "%08x\n"'  data.bin > data.hex
```

生成的text.hex和data.hex可以由$readmemh读取

在终端中运行上面指令

![image-20250407143926958](../../RISCV/doc/img/rv-img-4.png)

成功输出两个二进制文件，运行 `od` 命令查看

```
qaq@DESKTOP-I8GGJRG:~/soc$ od text.bin
0000000 010427 007701 000423 000001 000357 000200 000157 000000
0000020 000423 177001 027043 000201 002023 001001 003667 010003
0000040 003423 000140 120043 000347 003667 010003 103623 000407
0000060 123603 000007 023043 177364 023603 177304 173623 000027
0000100 101143 001007 003667 010003 103623 000407 123403 000007
0000120 003667 010003 103623 000407 073423 177727 120043 000347
0000140 000157 001000 003667 010003 103623 000407 123403 000007
0000160 003667 010003 103623 000407 063423 000047 120043 000347
0000200 103667 000001 103623 065007 022043 177364 000023 000000
0000220 023603 177204 103423 177767 022043 177344 115343 177007
0000240 170157 174237
0000244
```

再使用上面命令将二进制文件输出为十六进制文件

![image-20250407144321752](../../RISCV/doc/img/rv-img-5.png)

将其复制到工程目录下面，这样在工程中就可以导入hex文件到指令存储器中

##### Makefile文件

使用上面的命令将源文件生成一个可执行的目标文件的过程比较繁琐。下面将上述命令写成一个makefile，然后使用make工具自动化的执行这些命令完成编译。

```
CROSS = riscv64-unknown-elf-
CC = $(CROSS)gcc
CFLAGS = -march=rv32i -mabi=ilp32 -nostdlib \
	-Wl,--entry=_start \
	-Wl,-Ttext=0x00400000 \
	-Wl,-Tdata=0x10010000 
OBJCOPY = $(CROSS)objcopy

TARGET = x.elf
SOURCE = start.s main.c

.PHONY: all clean

all: text.hex data.hex

$(TARGET):$(SOURCE)
	$(CC) $(CFLAGS) -o $@ $(SOURCE)

text.bin: $(TARGET)
	$(OBJCOPY) --dump-section .text=$@ $<
	
data.bin: $(TARGET)
	$(OBJCOPY) --dump-section .data=$@ $<

text.hex: text.bin
	hexdump -v -e '1/4 "%08x\n"'  $< > $@
data.hex: data.bin
	hexdump -v -e '1/4 "%08x\n"'  $< > $@
	
clean:
	rm -f $(TARGET) text.bin data.bin text.hex data.hex
```

运行 `make` 命令，终端输出如下

```
qaq@DESKTOP-I8GGJRG:~/soc$ make
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Wl,--entry=_start -Wl,-Ttext=0x00400000 -Wl,-Tdata=0x10010000  -o x.elf start.s main.c
riscv64-unknown-elf-objcopy --dump-section .text=text.bin x.elf
hexdump -v -e '1/4 "%08x\n"'  text.bin > text.hex
riscv64-unknown-elf-objcopy --dump-section .data=data.bin x.elf
hexdump -v -e '1/4 "%08x\n"'  data.bin > data.hex
```

同时文件也已经生成

```
qaq@DESKTOP-I8GGJRG:~/soc$ ls
data.bin  data.hex  main.c  makefile  start.s  text.bin  text.hex  x.elf
```

##### ELF文件与链接脚本

通过 GCC 命令行选项直接指定代码段（.text）、数据段（.data）的起始地址和入口符号，这种方法适用于  简单场景（如裸机开发或快速测试），但对于复杂内存布局存在局限性

- 无法处理复杂内存布局
  - 若需定义多个内存区域（如 Flash 和 RAM），或指定 .bss 段地址，仍需链接脚本。
  - 例如：.data 段的 加载地址（Load Address） 和 运行地址（Virtual Address） 不同时数据存储在  Flash，运行时复制到 RAM），命令行选项无法直接实现。
- 无法自定义段顺序
  - 默认按链接器内置规则排列段顺序，可能导致意外覆盖（如 .bss 紧接 .data 后，未预留空间）。
- 无法指定堆栈地址
  - 堆栈指针初始化需在代码中手动设置（如 la sp, _stack_top），无法通过命令行选项定义。

**链接脚本：**链接脚本（Linker Script） 是一种文本文件，用于指导链接器（如 ld）如何将目标文件链接成最终的可执行文件或库(elf)。链接脚本定义了程序的内存布局、段的组织方式及输出文件的格式等关键信息。

**ELF文件：**ELF（Executable and Linkable Format）是一种广泛使用的二进制文件格式，用于可执行文件、目标文件、共享库和核心转储（Core Dumps）。 它的设计目标是灵活、可扩展且跨平台，支持现代操作系统的动态链接和多架构需求。 

ELF文件格式与链接脚本（Linker Script）在程序编译和链接过程中紧密相关，共同决定了可执行文件或共享库的内存布局和结构。通过合理编写链接脚本，开发者可以精确控制程序的物理内存布局，优化资源使用，并确保程序在目标硬件上的正确运行。理解 ELF 文件与链接脚本的协同工作机制，是嵌入式开发和系统编程的核心技能之一。

##### **链接脚本**

链接脚本（.ld 文件）是链接器（如 GNU ld 或 LLVM lld）的配置文件，用于控制：

- 内存布局：定义不同内存区域（如 ROM、RAM）的地址范围和属性。
- 段(节区, section)分配：指定输入目标文件的节区如何合并到输出文件的节区，并分配到 特定内存区域。
- 符号处理：设置入口点、定义符号地址、处理未引用节区等。

1. **内存区域定义（MEMORY 命令）**

   链接脚本通过 MEMORY 命令定义物理内存的布局，例如：

   ```
   MEMORY {
    ROM (rx) : ORIGIN = 0x80000000, LENGTH = 256K  /* 只读执行 */
    RAM (rwx) : ORIGIN = 0x80040000, LENGTH = 128K /* 可读写 */
    }
   ```

   此定义直接影响 ELF 的 程序头部表，生成对应的加载段（LOAD segments），指定程序在内存中的加载位置。

2. **节区分配（SECTIONS 命令）**

   通过 SECTIONS 命令将输入节区映射到输出节区，并指定其内存区域。例如：

   ```
   SECTIONS {
    .text : {
    *(.text*)        
   } > ROM
    .data : {
    *(.data*)
    /* 合并所有输入文件的 .text 节区 */
    } > RAM AT> ROM      /* 数据段存储在 ROM，运行时需复制到 RAM */
    }
   ```

   输出节区（如 .text、.data）的地址由链接脚本分配，写入 ELF 的 节区头部表。

    AT> 语法指定存储位置（LMA）与加载位置（VMA）的分离，常见于嵌入式系统初始化数据加载。

3. **特殊节区处理**

   保留未引用节区：使用 KEEP 防止链接器优化掉未使用的节区（如中断向量表）：

   ```
   .vectors : {
    KEEP(*(.vectors))
    } > ROM
   ```

   空节区处理：使用 NOLOAD 标记不加载到内存的节区（如调试信息）：

   ```
   .debug : { *(.debug*) } > ROM NOLOAD
   ```

**生成的 ELF 文件结构：**

以下面链接脚本示例

```
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
```

- load段1：.text加载到imem(地址0x00400000)
- load段2：.rodata加载到dmem(地址0x10010000)
- load段3：.data加载到dmem(地址0x10010000)

**修改makefile文件**

```
CROSS = riscv64-unknown-elf-
CC = $(CROSS)gcc

# OPTIMIZATION = -Os          # 代码体积优化（嵌入式推荐）
# OPTIMIZATION = -O2       # 性能优化（可选）
# OPTIMIZATION = -O0    # 调试模式（开发阶段使用）
# $(OPTIMIZATION) \

CFLAGS = -march=rv32i -mabi=ilp32 -nostdlib 
LDFILE = linker.ld
OBJCOPY = $(CROSS)objcopy

TARGET = x.elf
SOURCE = start.s main.c
# SOURCE = start.s main.c 

.PHONY: all clean

all: text.hex data.hex

$(TARGET):$(SOURCE)
	$(CC) $(CFLAGS) -T $(LDFILE) -o $@ $(SOURCE)

text.bin: $(TARGET)
	$(OBJCOPY) --dump-section .text=$@ $<
	
# data.bin: $(TARGET)
# 	$(OBJCOPY) --dump-section .data=$@ $<
data.bin: $(TARGET)
	$(OBJCOPY) -O binary --only-section=.rodata --only-section=.data $< $@
text.hex: text.bin
	hexdump -v -e '1/4 "%08x\n"'  $< > $@
data.hex: data.bin
	hexdump -v -e '1/4 "%08x\n"'  $< > $@
	
clean:
	rm -f $(TARGET) text.bin data.bin text.hex data.hex
```

修改完后执行命令，可看到终端提示下面信息

```
qaq@DESKTOP-I8GGJRG:~/soc/seg_led$ make
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib  -T linker.ld -o x.elf start.s main.c
riscv64-unknown-elf-objcopy --dump-section .text=text.bin x.elf
hexdump -v -e '1/4 "%08x\n"'  text.bin > text.hex
riscv64-unknown-elf-objcopy -O binary --only-section=.rodata --only-section=.data x.elf data.bin
hexdump -v -e '1/4 "%08x\n"'  data.bin > data.hex
qaq@DESKTOP-I8GGJRG:~/soc/seg_led$ ls
data.bin  data.hex  linker.ld  main.c  makefile  start.s  text.bin  text.hex  x.elf
```

执行readelf命令查看生成的文件是否是我们期望的

```
qaq@DESKTOP-I8GGJRG:~/soc/seg_led$ riscv64-unknown-elf-readelf -a x.elf
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           RISC-V
  Version:                           0x1
  Entry point address:               0x400000
  Start of program headers:          52 (bytes into file)
  Start of section headers:          16892 (bytes into file)
  Flags:                             0x0
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         4
  Size of section headers:           40 (bytes)
  Number of section headers:         9
  Section header string table index: 8

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .text             PROGBITS        00400000 001000 000228 00  AX  0   0  4
  [ 2] .rodata           PROGBITS        10010000 002000 000018 00   A  0   0  4
  [ 3] .data             PROGBITS        10011000 003000 001000 00  WA  0   0 4096
  [ 4] .riscv.attributes RISCV_ATTRIBUTE 00000000 004000 00001c 00      0   0  1
  [ 5] .comment          PROGBITS        00000000 00401c 000022 01  MS  0   0  1
  [ 6] .symtab           SYMTAB          00000000 004040 000110 10      7  12  4
  [ 7] .strtab           STRTAB          00000000 004150 000061 00      0   0  1
  [ 8] .shstrtab         STRTAB          00000000 0041b1 00004a 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), p (processor specific)

There are no section groups in this file.

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  RISCV_ATTRIBUT 0x004000 0x00000000 0x00000000 0x0001c 0x00000 R   0x1
  LOAD           0x001000 0x00400000 0x00400000 0x00228 0x00228 R E 0x1000
  LOAD           0x002000 0x10010000 0x10010000 0x00018 0x00018 R   0x1000
  LOAD           0x003000 0x10011000 0x10011000 0x01000 0x01000 RW  0x1000

 Section to Segment mapping:
  Segment Sections...
   00     .riscv.attributes 
   01     .text 
   02     .rodata 
   03     .data 

There is no dynamic section in this file.

There are no relocations in this file.

The decoding of unwind sections for machine type RISC-V is not currently supported.

Symbol table '.symtab' contains 17 entries:
   Num:    Value  Size Type    Bind   Vis      Ndx Name
     0: 00000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 00400000     0 SECTION LOCAL  DEFAULT    1 .text
     2: 10010000     0 SECTION LOCAL  DEFAULT    2 .rodata
     3: 10011000     0 SECTION LOCAL  DEFAULT    3 .data
     4: 00000000     0 SECTION LOCAL  DEFAULT    4 .riscv.attributes
     5: 00000000     0 SECTION LOCAL  DEFAULT    5 .comment
     6: 00000000     0 FILE    LOCAL  DEFAULT  ABS cciNOpkG.o
     7: 10011000     0 NOTYPE  LOCAL  DEFAULT    3 stack_end
     8: 10012000     0 NOTYPE  LOCAL  DEFAULT    3 stack
     9: 00400000     0 NOTYPE  LOCAL  DEFAULT    1 $xrv32i2p1
    10: 00000000     0 FILE    LOCAL  DEFAULT  ABS main.c
    11: 00400010     0 NOTYPE  LOCAL  DEFAULT    1 $xrv32i2p1
    12: 00400188   132 FUNC    GLOBAL DEFAULT    1 demo_show_number
    13: 00400108   128 FUNC    GLOBAL DEFAULT    1 seg_init
    14: 00400000     0 NOTYPE  GLOBAL DEFAULT    1 _start
    15: 0040020c    28 FUNC    GLOBAL DEFAULT    1 main
    16: 00400010   248 FUNC    GLOBAL DEFAULT    1 seg_set_data

No version information found in this file.
Attribute Section: riscv
File Attributes
  Tag_RISCV_stack_align: 16-bytes
  Tag_RISCV_arch: "rv32i2p1"
```

可以看到链接参数已经被链接脚本正确改写

**ELF文件**

ELF 文件由以下部分组成：

- ELF 头部（ELF Header）： 描述文件类型（如可执行文件、共享库）、目标架构（RISC-V）、入口地址等元信息。
- 程序头部表（Program Header Table）：定义 段（Segments） 的布局，用于指导操作系统如何加载程序到内存（如代码段、数据段）
- 节区头部表（Section Header Table）：描述节（Sections）的元数据（如名称、类型、地址），用于链接和调试。
- 节区（Sections）：存储实际内容，如代码（.text）、数据（.data）、符号表（.symtab）、重定位信息 （.rela.text）等。

相关命令

- readelf：查看 ELF 结构

  ```
  riscv32-unknown-elf-readelf -a firmware.elf  # 查看所有段的名称、符号名和地址
  riscv32-unknown-elf-readelf -l firmware.elf  # 查看程序头部表
  riscv32-unknown-elf-readelf -S firmware.elf  # 查看节区头部表
  ```

- objdump：反汇编分析

  ```
  riscv32-unknown-elf-objdump -h firmware.elf  # 输出各个段的详细参数
  riscv32-unknown-elf-objdump -d firmware.elf  # 反汇编代码段
  ```

- objcopy：制作flash固件

  ```
  riscv32-unknown-elf-objcopy –O binary firmware.elf firmware.bin # 导出所有段的二进制文件
  riscv32-unknown-elf-objcopy –-dump-section .text=text.bin firmware.elf  # 导出代码段的二进制文件
  ```

