	.file	"random.c"
gcc2_compiled.:
___gnu_compiled_c:
.text
LC0:
	.ascii "usage: random [-s seed] -r range states... \12 Generate a random number 0.. range-1, given the input states.\12 Prints the random number to the stdout followed by state\12 information sufficient to continue generating numbers in\12 the sequence.  Pass the state information to successive\12 invocations of this program.\12\0"
	.align 2
.globl _Usage
	.type	 _Usage,@function
_Usage:
	pushl %ebp
	movl %esp,%ebp
	pushl $LC0
	pushl $___sF+176
	call _fprintf
	addl $8,%esp
	pushl $1
	call _exit
	addl $4,%esp
	.align 2,0x90
L5:
	leave
	ret
Lfe1:
	.size	 _Usage,Lfe1-_Usage
LC1:
	.ascii "s:r:\0"
LC2:
	.ascii "random: numStates must be 8... 256, NOT: %d\12\0"
LC3:
	.ascii "%u %u\0"
LC4:
	.ascii " %u\0"
	.align 2
.globl _main
	.type	 _main,@function
_main:
	pushl %ebp
	movl %esp,%ebp
	subl $568,%esp
	pushl %ebx
	call ___main
	movl $0,-12(%ebp)
	movl $0,-16(%ebp)
	movl $-1,-20(%ebp)
	movl $0,-28(%ebp)
	leal -292(%ebp),%ebx
	movl %ebx,-560(%ebp)
	leal -556(%ebp),%ebx
	movl %ebx,-564(%ebp)
	movl $1,_opterr
L7:
	pushl $LC1
	movl 12(%ebp),%eax
	pushl %eax
	movl 8(%ebp),%eax
	pushl %eax
	call _getopt
	addl $12,%esp
	movl %eax,%eax
	movl %eax,-4(%ebp)
	cmpl $-1,-4(%ebp)
	jne L9
	jmp L8
	.align 2,0x90
L9:
	movl -4(%ebp),%eax
	cmpl $114,%eax
	je L12
	cmpl $115,%eax
	je L11
	jmp L13
	.align 2,0x90
L11:
	pushl $0
	leal -8(%ebp),%eax
	pushl %eax
	movl _optarg,%eax
	pushl %eax
	call _strtoul
	addl $12,%esp
	movl %eax,-12(%ebp)
	movl $1,-16(%ebp)
	jmp L10
	.align 2,0x90
L12:
	pushl $0
	leal -8(%ebp),%eax
	pushl %eax
	movl _optarg,%eax
	pushl %eax
	call _strtoul
	addl $12,%esp
	movl %eax,-20(%ebp)
	jmp L10
	.align 2,0x90
L13:
	call _Usage
L10:
	jmp L7
	.align 2,0x90
L8:
	movl _optind,%eax
	cmpl %eax,8(%ebp)
	jg L15
	call _Usage
L15:
	cmpl $0,-16(%ebp)
	jne L16
	pushl $0
	leal -8(%ebp),%eax
	pushl %eax
	movl _optind,%eax
	movl %eax,%edx
	leal 0(,%edx,4),%eax
	movl 12(%ebp),%edx
	movl (%edx,%eax),%eax
	pushl %eax
	incl _optind
	call _strtoul
	addl $12,%esp
	movl %eax,-12(%ebp)
L16:
	nop
L17:
	movl _optind,%eax
	cmpl %eax,8(%ebp)
	jle L21
	cmpl $255,-28(%ebp)
	jle L20
	jmp L21
	.align 2,0x90
L21:
	jmp L18
	.align 2,0x90
L20:
	pushl $0
	leal -8(%ebp),%eax
	pushl %eax
	movl _optind,%eax
	movl %eax,%edx
	leal 0(,%edx,4),%eax
	movl 12(%ebp),%edx
	movl (%edx,%eax),%eax
	pushl %eax
	call _strtol
	addl $12,%esp
	movl %eax,%eax
	movl -560(%ebp),%edx
	addl -28(%ebp),%edx
	movl %edx,%ecx
	movb %al,(%ecx)
L19:
	incl _optind
	incl -28(%ebp)
	jmp L17
	.align 2,0x90
L18:
	cmpl $7,-28(%ebp)
	jle L23
	cmpl $256,-28(%ebp)
	jg L23
	jmp L22
	.align 2,0x90
L23:
	movl -28(%ebp),%eax
	pushl %eax
	pushl $LC2
	pushl $___sF+176
	call _fprintf
	addl $12,%esp
	pushl $1
	call _exit
	addl $4,%esp
	.align 2,0x90
L22:
	cmpl $0,-16(%ebp)
	jne L24
	sarl $1,-28(%ebp)
L24:
	movl -28(%ebp),%eax
	pushl %eax
	movl -560(%ebp),%eax
	pushl %eax
	movl -564(%ebp),%eax
	pushl %eax
	call _memcpy
	addl $12,%esp
	movl -28(%ebp),%eax
	pushl %eax
	movl -560(%ebp),%eax
	pushl %eax
	movl -12(%ebp),%eax
	pushl %eax
	call _initstate
	addl $12,%esp
	cmpl $0,-16(%ebp)
	jne L25
	movl -560(%ebp),%eax
	addl -28(%ebp),%eax
	pushl %eax
	call _setstate
	addl $4,%esp
L25:
	call _random
	movl %eax,-24(%ebp)
	movl -12(%ebp),%eax
	pushl %eax
	movl -24(%ebp),%ecx
	movl %ecx,%eax
	xorl %edx,%edx
	divl -20(%ebp)
	pushl %edx
	pushl $LC3
	call _printf
	addl $12,%esp
	movl $0,-568(%ebp)
L26:
	movl -568(%ebp),%eax
	cmpl %eax,-28(%ebp)
	jg L29
	jmp L27
	.align 2,0x90
L29:
	movl -564(%ebp),%eax
	addl -568(%ebp),%eax
	movl %eax,%edx
	movsbl (%edx),%eax
	pushl %eax
	pushl $LC4
	call _printf
	addl $8,%esp
L28:
	incl -568(%ebp)
	jmp L26
	.align 2,0x90
L27:
	movl -560(%ebp),%eax
	pushl %eax
	call _setstate
	addl $4,%esp
	movl %eax,%eax
	movl %eax,-8(%ebp)
L30:
	movl -8(%ebp),%eax
	movsbl (%eax),%edx
	movzbl %dl,%eax
	pushl %eax
	incl -8(%ebp)
	pushl $LC4
	call _printf
	addl $8,%esp
L32:
	decl -28(%ebp)
	cmpl $0,-28(%ebp)
	jne L33
	jmp L31
	.align 2,0x90
L33:
	jmp L30
	.align 2,0x90
L31:
L6:
	movl -572(%ebp),%ebx
	leave
	ret
Lfe2:
	.size	 _main,Lfe2-_main
