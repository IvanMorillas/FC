@;----------------------------------------------------------------
@;  Q12.s: rutines aritmètiques en 
@;						 format Q12 (Coma Fixa 1:19:12). 
@;----------------------------------------------------------------
@;	santiago.romani@urv.cat
@;	pere.millan@urv.cat
@;	(Març 2021, Març 2022)
@;----------------------------------------------------------------
@;	Programador/a 1: ivan.morillas@estudiants.urv.cat
@;----------------------------------------------------------------*/

.include "Q12.i"

.bss
	.align 2
	quo: .space 4
	res: .space 4
	
.text
		.align 2
		.arm
		
	.global add_Q12
add_Q12:
		push {r3-r8, lr}
		mov r3, #0
		ldr r4, =MASK_SIGN
		add r8, r0, r1
		and r5, r0, r4
		and r6, r1, r4
		and r7, r8, r4
		cmp r5, r6
		bne .Lfiifadd
		cmp r5, r7
		beq .Lfiifadd
		mov r3, #1
.Lfiifadd:
		mov r0, r8
		strb r3, [r2]
		pop {r3-r8, pc}
	
	.global sub_Q12
sub_Q12:
		push {r3-r8, lr}
		mov r3, #0
		ldr r4, =MASK_SIGN
		sub r8, r0, r1
		and r5, r0, r4
		and r6, r1, r4
		and r7, r8, r4
		cmp r5, r6
		beq .Lfiifsub
		cmp r5, r7
		beq .Lfiifsub
		mov r3, #1
.Lfiifsub:
		mov r0, r8
		strb r3, [r2]
		pop {r3-r8, pc}
	
	.global mul_Q12
mul_Q12:
		push {r3-r7, lr}
		mov r3, #0
		ldr r4, =0xFFFFFFFF
		ldr r5, =MASK_FRAC
		smull r6, r7, r0, r1
		mov r6, r6, lsr #12
		and r5, r7, r5
		orr r0, r6, r5, lsl #20
		mov r7, r7, asr #12
		cmp r0, #0
		bge .Lelsemul
		cmp r7, r4
		beq .Lfiifmul
		mov r3, #1
		b .Lfiifmul
.Lelsemul:
		cmp r7, #0
		beq .Lfiifmul
		mov r3, #1
.Lfiifmul:
		strb r3, [r2]
		pop {r3-r7, pc}

		.global div_Q12
div_Q12:
		push {r1-r12, lr}
		mov r3, #0
		cmp r1, #0
		bne .Lelsediv
		mov r0, #0
		mov r3, #1
		b .Lfiifdiv
.Lelsediv:
		cmp r1, #0
		bge .Lcontinuediv
		mov r6, #1
		ldr r4, =0xff000	@; Q12(-1)
		mov r12, r0
		mov r0, r1
		mov r1, r4
		bl mul_Q12
		b .Ldivmod
.Lcontinuediv:
		mov r0, r1
		mov r6, #0
		b .Ldivmod
.Ldivmod:
		mov r1, r0
		ldr r5, =0x1000		@; Q12(1)
		mov r0, r5, lsl #12
		mov r2, #0
.Lfordiv:
		sub r0, r1
		add r2, #1
		cmp r0, r1
		bge .Lfordiv
		b .Ldivisio
.Ldivisio:
		mov r0, r12
		mov r1, r2
		bl mul_Q12
		cmp r6, #0
		beq .Lfiifdiv
		rsb r0, r0, #0
.Lfiifdiv:
		strb r3, [r2]
		pop {r1-r12, pc}
	
.end
