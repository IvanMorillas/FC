@;----------------------------------------------------------------
@;  CelsiusFahrenheit.s: rutines de conversió de temperatura en 
@;						 format Q12 (Coma Fixa 1:19:12). 
@;----------------------------------------------------------------
@;	santiago.romani@urv.cat
@;	pere.millan@urv.cat
@;	(Març 2021, Març 2022)
@;----------------------------------------------------------------
@;	Programador/a 1: ivan.morillas@estudiants.urv.cat
@;	Programador/a 2: daniel.arjona@estudiants.urv.cat
@;----------------------------------------------------------------*/

.include "Q12.i"


.text
		.align 2
		.arm


@; Celsius2Fahrenheit(): converteix una temperatura en graus Celsius a la
@;						temperatura equivalent en graus Fahrenheit, utilitzant
@;						valors codificats en Coma Fixa 1:19:12.
@;	Entrada:
@;		input 	-> R0
@;	Sortida:
@;		R0 		-> output = (input * 9/5) + 32.0;
	.global Celsius2Fahrenheit
Celsius2Fahrenheit:
		push {r1-r5, lr}
		ldr r1, =0x1CCD			@; MAKE_Q12 (9.0/5.0)
		ldr r2, =0x20000 		@; MAKE_Q12 32.0
		ldr r5, =MASK_FRAC		@; guardar mascara
		smull r3, r4, r0, r1	@; (input*(9.0/5.0))
		mov r0, r3, lsr #12 	@; r3 = r3 >> 12
		and r5, r4, r5			@; mascara per agafar bits baixos
		mov r4, r4, asr #12		@; desplaçament de bits amb signe
		orr r0, r0, r5, lsl #20 @; afegir bits restants
		add r0, r2				@; (output+=32.0)
		pop {r1-r5, pc}



@; Fahrenheit2Celsius(): converteix una temperatura en graus Fahrenheit a la
@;						temperatura equivalent en graus Celsius, utilitzant
@;						valors codificats en Coma Fixa 1:19:12.
@;	Entrada:
@;		input 	-> R0
@;	Sortida:
@;		R0 		-> output = (input - 32.0) * 5/9;
	.global Fahrenheit2Celsius
Fahrenheit2Celsius:
		push {r1-r5, lr}
		ldr r1, =0x8E4			@; MAKE_Q12 (5.0/9.0)
		ldr r2, =0x20000 		@; MAKE_Q12 32.0
		ldr r5, =MASK_FRAC		@; guardar mascara
		sub r0, r2 				@; (input-=32.0)
		smull r3, r4, r0, r1    @; (input*(5.0/9.0))
		mov r0, r3, lsr #12		@; r3 = r3 >> 12
		and r5, r4, r5			@; mascara per agafar bits baixos
		mov r4, r4, asr #12		@; desplaçament de bits amb signe
		orr r0, r0, r5, lsl #20	@; afegir bits restants
		pop {r1-r5, pc}

