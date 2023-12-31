/*----------------------------------------------------------------
|   Q12.c: rutines aritm�tiques en format Coma Fixa 1:19:12. 
| ----------------------------------------------------------------
|	pere.millan@urv.cat
|	santiago.romani@urv.cat
|	(Abril 2021, Mar� 2022)
| ----------------------------------------------------------------*/

#include "Q12.h"	/* Q12: tipus Coma Fixa 1:19:11
					   MAKE_Q12(real): codifica un valor real en format Q12
					   MASK_SIGN: m�scara per obtenir el bit de signe
					*/
#include "divmod.h"		/* rutina div_mod() de divisi� entera */

	/* M�SCARA per als 33 bits alts d'una multiplicaci� llarga */
#define MASK_SIGN_64	0xFFFFFFFF80000000	/* bits 63..31 */


/* Operacions aritm�tiques b�siques en Coma Fixa 1:19:12 */

/* add_Q12():	calcula i retorna la suma dels 2 primers operands,
  (num1 + num2)	codificats en Coma fixa 1:19:12.
				El 3r par�metre (per refer�ncia) retorna l'overflow:
				0: no s'ha produ�t overflow, resultat correcte.
				1: hi ha overflow (resultat massa gran) i el que es
				   retorna s�n els bits baixos del resultat.
*/
Q12 add_Q12(Q12 num1, Q12 num2, unsigned char * overflow)
{
	Q12 suma;
	unsigned char ov = 0;	// inicialment assumeix que no hi ha overflow
	
	suma = num1 + num2;
	
		// Detecci� overflow
	if (((MASK_SIGN & num1) == (MASK_SIGN & num2)) 
			&& ((MASK_SIGN & num1) != (MASK_SIGN & suma)))
		ov = 1;
	
	*overflow = ov;
	return(suma);
}


/* sub_Q12():	calcula i retorna la resta dels 2 primers operands,
  (num1 - num2) codificats en Coma fixa 1:19:12.
				El 3r par�metre (per refer�ncia) retorna l'overflow:
				0: no s'ha produ�t overflow, resultat correcte.
				1: hi ha overflow (resultat massa gran) i el que es
				   retorna s�n els bits baixos del resultat.
*/
Q12 sub_Q12(Q12 num1, Q12 num2, unsigned char * overflow)
{
	Q12 resta;
	unsigned char ov = 0;	// inicialment assumeix que no hi ha overflow
	
	resta = num1 - num2;
	
		// Detecci� overflow
	if (((MASK_SIGN & num1) != (MASK_SIGN & num2)) 
			&& ((MASK_SIGN & num1) != (MASK_SIGN & resta)))
		ov = 1;
	
	*overflow = ov;
	return(resta);
}


/* mul_Q12():	calcula i retorna el producte dels 2 primers operands,
  (num1 * num2)	codificats en Coma fixa 1:19:12.
				El 3r par�metre (per refer�ncia) retorna l'overflow:
				0: no s'ha produ�t overflow, resultat correcte.
				1: hi ha overflow (resultat massa gran) i el que es
				   retorna s�n els bits baixos del resultat.
*/
Q12 mul_Q12(Q12 num1, Q12 num2, unsigned char * overflow)
{
	Q12 producte;
	unsigned char ov = 0;	// inicialment assumeix que no hi ha overflow

	long long prod64;		// Resultat de la multiplicaci� (64 bits)

		// Calcular resultat (64 bits), ajustant bits fracci�
	prod64 = (((long long) num1) * num2) >> 12;

		// Detecci� overflow
	if (prod64 < 0)
	{		// Si resultat negatiu, els bits 63..31 haurien de ser tots 1
		if ((prod64 & MASK_SIGN_64) != MASK_SIGN_64)
			ov = 1;
	}
	else
	{		// Si resultat positiu, els bits 63..31 haurien de ser tots 0
		if ((prod64 & MASK_SIGN_64) != 0)
			ov = 1;
	}

	producte = (Q12) prod64;		// Retornar nom�s els 32 bits baixos

	*overflow = ov;
	return(producte);
}


/* div_Q12():	calcula i retorna la divisi� dels 2 primers operands,
  (num1 / num2) codificats en Coma fixa 1:19:12.
				El 3r par�metre (per refer�ncia) retorna l'overflow:
				0: no s'ha produ�t overflow, resultat correcte.
				1: hi ha overflow (resultat massa gran) i el que es
				   retorna s�n els bits baixos del resultat.
*/
Q12 div_Q12(Q12 num1, Q12 num2, unsigned char * overflow)
{
	Q12 divisio;
	unsigned char ov = 0;	// inicialment assumeix que no hi ha overflow
	unsigned int quo, res;	// Quocient i residu de div_mod()
	unsigned char op2neg;	// El segon operand �s negatiu?
	unsigned int abs2;		// Valor absolut del segon operand

		// En cas de divisi� entre 0, resultat 0 i Overflow
	if (num2 == 0)
	{
		divisio = 0;
		ov = 1;
	}
	else
	{	// Calcular divisi� amb valor invers: a/b = a * (1/b)
			
			// Calcular valor absolut del segon operand
		op2neg = (num2 < 0);
		abs2 = (op2neg ? -num2 : num2);
			
			// Calcular valor invers Q12: quo = 1.0/den (ajustant bits numerador)
		div_mod( MAKE_Q12(1.0) << 12, abs2, &quo, &res);
			
			// Calcular resultat num1 * 1.0/num2, fixant overflow
		divisio = mul_Q12(num1, quo, &ov);
			
			// Canviar signe del resultat
		if (op2neg)
			divisio = -divisio;
	}

	*overflow = ov;
	return(divisio);
}

