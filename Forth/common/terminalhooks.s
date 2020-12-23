@
@    Mecrisp-Stellaris - A native code Forth implementation for ARM-Cortex M microcontrollers
@    Copyright (C) 2013  Matthias Koch
@
@    This program is free software: you can redistribute it and/or modify
@    it under the terms of the GNU General Public License as published by
@    the Free Software Foundation, either version 3 of the License, or
@    (at your option) any later version.
@
@    This program is distributed in the hope that it will be useful,
@    but WITHOUT ANY WARRANTY; without even the implied warranty of
@    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
@    GNU General Public License for more details.
@
@    You should have received a copy of the GNU General Public License
@    along with this program.  If not, see <http://www.gnu.org/licenses/>.
@

@ Terminal redirection hooks.

@------------------------------------------------------------------------------
  Wortbirne Flag_visible|Flag_variable, "hook-emit" @ ( -- addr )
  CoreVariable hook_emit
@------------------------------------------------------------------------------
	pushdatos
	ldr 	tos, =hook_emit
	bx lr
.if	DEFAULT_TERMINAL == UART_TERMINAL
	.word	serial_emit		// Serial (UART) for terminal
.else
.if DEFAULT_TERMINAL == CDC_TERMINAL
	.word	cdc_emit		// USB CDC for terminal
.else
.if	DEFAULT_TERMINAL == CRS_TERMINAL
	.word	crs_emit		// BLE CRS for terminal
.endif
.endif
.endif


@------------------------------------------------------------------------------
  Wortbirne Flag_visible|Flag_variable, "hook-key" @ ( -- addr )
  CoreVariable hook_key
@------------------------------------------------------------------------------
	pushdatos
	ldr		tos, =hook_key
	bx		lr
.if	DEFAULT_TERMINAL == UART_TERMINAL
	.word	serial_key		// Serial (UART) for terminal
.else
.if DEFAULT_TERMINAL == CDC_TERMINAL
	.word	cdc_key			// USB CDC for terminal
.else
.if	DEFAULT_TERMINAL == CRS_TERMINAL
	.word	crs_key			// BLE CRS for terminal
.endif
.endif
.endif

@------------------------------------------------------------------------------
  Wortbirne Flag_visible|Flag_variable, "hook-emit?" @ ( -- addr )
  CoreVariable hook_qemit
@------------------------------------------------------------------------------
	pushdatos
	ldr		tos, =hook_qemit
	bx		lr
.if	DEFAULT_TERMINAL == UART_TERMINAL
	.word	serial_qemit		// Serial (UART) for terminal
.else
.if DEFAULT_TERMINAL == CDC_TERMINAL
	.word	cdc_qemit		// USB CDC for terminal
.else
.if	DEFAULT_TERMINAL == CRS_TERMINAL
	.word	crs_qemit		// BLE CRS for terminal
.endif
.endif
.endif

@------------------------------------------------------------------------------
  Wortbirne Flag_visible|Flag_variable, "hook-key?" @ ( -- addr )
  CoreVariable hook_qkey
@------------------------------------------------------------------------------
	pushdatos
	ldr		tos, =hook_qkey
	bx		lr
.if	DEFAULT_TERMINAL == UART_TERMINAL
	.word	serial_qkey		// Serial (UART) for terminal
.else
.if DEFAULT_TERMINAL == CDC_TERMINAL
	.word	cdc_qkey		// USB CDC for terminal
.else
.if	DEFAULT_TERMINAL == CRS_TERMINAL
	.word	crs_qkey		// BLE CRS for terminal
.endif
.endif
.endif

@------------------------------------------------------------------------------
  Wortbirne Flag_visible|Flag_variable, "hook-pause" @ ( -- addr )
  CoreVariable hook_pause
@------------------------------------------------------------------------------
	pushdatos
	ldr		tos, =hook_pause
	bx		lr
//  .word nop_vektor  @ No Pause defined for default
	.word	osDelay		// CMSIS-RTOS

@------------------------------------------------------------------------------
  Wortbirne Flag_visible, "emit" @ ( c -- )
emit:
@------------------------------------------------------------------------------
	push	{r0, r1, r2, r3, lr} @ Used in core, registers have to be saved !
	ldr		r0, =hook_emit
	bl		hook_intern
	pop		{r0, r1, r2, r3, pc}

@------------------------------------------------------------------------------
  Wortbirne Flag_visible, "key" @ ( -- c )
key:
@------------------------------------------------------------------------------
	push	{r0, r1, r2, r3, lr} @ Used in core, registers have to be saved !
	ldr		r0, =hook_key
	bl		hook_intern
	pop		{r0, r1, r2, r3, pc}

@------------------------------------------------------------------------------
  Wortbirne Flag_visible, "emit?" @ ( -- ? )
qemit:
@------------------------------------------------------------------------------
	ldr		r0, =hook_qemit
	ldr		r0, [r0]
	mov		pc, r0

@------------------------------------------------------------------------------
  Wortbirne Flag_visible, "key?" @ ( -- ? )
qkey:
@------------------------------------------------------------------------------
	ldr		r0, =hook_qkey
	ldr		r0, [r0]
	mov		pc, r0

@------------------------------------------------------------------------------
  Wortbirne Flag_visible, "pause" @ ( -- ? )
pause:
@------------------------------------------------------------------------------
	ldr		r0, =1			// parameter for osDelay
 	ldr		r1, =hook_pause
	ldr		r1, [r1]
	mov		pc, r1


@------------------------------------------------------------------------------
  Wortbirne Flag_visible, "uart" @ ( -- )
@------------------------------------------------------------------------------
.global		uart_terminal
uart_terminal:
	ldr		r1, =serial_emit
	ldr		r0, =hook_emit
	str		r1, [r0]

	ldr		r1, =serial_qemit
	ldr		r0, =hook_qemit
	str		r1, [r0]

	ldr		r1, =serial_key
	ldr		r0, =hook_key
	str		r1, [r0]

	ldr		r1, =serial_qkey
	ldr		r0, =hook_qkey
	str		r1, [r0]
	bx		lr

@------------------------------------------------------------------------------
  Wortbirne Flag_visible, "cdc" @ ( -- )
@------------------------------------------------------------------------------
.global		cdc_terminal
cdc_terminal:
	ldr		r1, =cdc_emit
	ldr		r0, =hook_emit
	str		r1, [r0]

	ldr		r1, =cdc_qemit
	ldr		r0, =hook_qemit
	str		r1, [r0]

	ldr		r1, =cdc_key
	ldr		r0, =hook_key
	str		r1, [r0]

	ldr		r1, =cdc_qkey
	ldr		r0, =hook_qkey
	str		r1, [r0]
	bx		lr

@------------------------------------------------------------------------------
  Wortbirne Flag_visible, "crs" @ ( -- )
@------------------------------------------------------------------------------
.global		crs_terminal
crs_terminal:
	ldr		r1, =crs_emit
	ldr		r0, =hook_emit
	str		r1, [r0]

	ldr		r1, =crs_qemit
	ldr		r0, =hook_qemit
	str		r1, [r0]

	ldr		r1, =crs_key
	ldr		r0, =hook_key
	str		r1, [r0]

	ldr		r1, =crs_qkey
	ldr		r0, =hook_qkey
	str		r1, [r0]
	bx		lr


// Redirect emit to key
//*********************

@------------------------------------------------------------------------------
  Wortbirne Flag_visible, "redirect" @ ( -- )
@------------------------------------------------------------------------------
.global 	TERMINAL_redirect
TERMINAL_redirect:
	ldr		r0, =hook_emit
	ldr		r0, [r0]
	ldr		r1, =RedirectStore
	str		r0, [r1]			// store old hook
	ldr		r1, =cdc_emit
	cmp		r0, r1
	bne		1f
	ldr		r1, =cdc_emit2key
	b		3f
1:
	ldr		r1, =serial_emit
	cmp		r0, r1
	bne		2f
	ldr		r1, =serial_emit2key
	b		3f
2:
//	ldr		r1, =crs_emit
	ldr		r1, =crs_emit2key
3:
	ldr		r0, =hook_emit
	str		r1, [r0]
	bx		lr

// status = osMessageQueuePut(UART_RxQueueId, &UART_RxBuffer, 0, 100);

@------------------------------------------------------------------------------
  Wortbirne Flag_visible, "unredirect" @ ( -- )
@------------------------------------------------------------------------------
.global		TERMINAL_unredirect
TERMINAL_unredirect:
	ldr		r1, =RedirectStore
	ldr		r0, [r1]
	ldr		r1, =hook_emit		// restore old hook
	str		r0, [r1]
	bx		lr


cdc_emit2key:
	push	{lr}
	movs	r0, tos		// c
	drop
	bl		CDC_putkey
	pop		{pc}

serial_emit2key:
	push	{lr}
	movs	r0, tos		// c
	drop
	bl		UART_putkey
	pop		{pc}

crs_emit2key:
	push	{lr}
	movs	r0, tos		// c
	drop
	bl		CRSAPP_putkey
	pop		{pc}


@------------------------------------------------------------------------------
hook_intern:
 	ldr		r0, [r0]
	mov		pc, r0



.macro Debug_Terminal_Init

  @ A special initialisation sequence intended for debugging
  @ Necessary when you wish to use the terminal before running catchflashpointers.

  @ Kurzschluss-Initialisierung für die Terminalvariablen

   @ Return stack pointer already set up. Time to set data stack pointer !
   @ Normaler Stackpointer bereits gesetzt. Setze den Datenstackpointer:
   ldr psp, =datenstackanfang

   @ TOS setzen, um Pufferunterläufe gut erkennen zu können
   @ TOS magic number to see spurious stack underflows in .s
   @ ldr tos, =0xAFFEBEEF
   movs tos, #42

   ldr r1, =serial_emit
   ldr r0, =hook_emit
   str r1, [r0]

   ldr r1, =serial_qemit
   ldr r0, =hook_qemit
   str r1, [r0]

   ldr r1, =serial_key
   ldr r0, =hook_key
   str r1, [r0]

   ldr r1, =serial_qkey
   ldr r0, =hook_qkey
   str r1, [r0]

   ldr r1, =nop_vektor
   ldr r0, =hook_pause
   str r1, [r0]

.endm
