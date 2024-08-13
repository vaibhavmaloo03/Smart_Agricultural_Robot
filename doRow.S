        .arch armv7
        .cpu cortex-a53
        .equ 	NUL, 0

        .global asm_doRow
	.syntax unified	

	// Set offsets for incoming parameters 5 and 6
	.equ	IARG6, 8 	// new life parameter
	.equ    IARG5, 4 	// number columns parameter
        .equ    LOCAL_SPACE, 24        //TODO
        .equ    PARAM_SPACE, 8        //TODO	

        // !!! SET FP_OFFSET TO THE NUMBER OF (SAVED REGISTERS -1 * 4)	
        .equ 	FP_OFFSET, 16 //TODO	// (# of saved regs - 1) * 4

	// Add any local variables used
	.equ	c_OFFSET, FP_OFFSET + 4  // local variable c
	.equ  	currCell_OFFSET, c_OFFSET + 4   // current cell we are iterating 
	.equ 	currColPlusOne_OFFSET, currCell_OFFSET + 4  // local comparision currColPlusOne
	.equ 	currRowPlusOne_OFFSET, currColPlusOne_OFFSET + 4 //local comparision in for loop for currRowPlusOne
	.equ 	count_OFFSET, currRowPlusOne_OFFSET + 4 	// count for alive neighbors
	.equ 	index_OFFSET, count_OFFSET + 4			//local variable that holds the index_offset of current cell

	// asm_doRow(belem *dest,    // r0
	//           belem *src,     // r1
	//           size_t curRow,  // r2
	//           size_t nRows,   // r3
	//           size_t nCols,   // fp + 4
	//	     int *newLife)   // fp + 8


asm_doRow:	
	push {r4 - r6, fp, lr} 	//TODO: Push any preserved registers
	add fp, sp, #FP_OFFSET
	sub sp, sp, #(LOCAL_SPACE + PARAM_SPACE) 
	
	
	// Write body of asm_doRow here
        
        push {r0-r1, lr}
        mov r0, r3 //set param1 for setNRowsNCols
        ldr r4, [fp, IARG5]     // r4 = number of cols
        mov r1, r4 //set param2 for setNRowsNCols
        bl setNRowsNCols // function call
        pop {r0-r1, lr}

 	mov r6, #0  // current column (c) = 0
  	str r6, [fp, -c_OFFSET] // c = 0
        .LWhile: ldr r6, [fp, -c_OFFSET] // store value of c in r6 to compare
 	ldr r4, [fp, IARG5]     // store value of number of columns in r4
 	cmp r6, r4  // compare c to number of cols
	bge .LSkipWhileLoop     //skip while loop if c >= nCols
        
	ldr r4, [fp, -c_OFFSET]  // retrieve for loop c
	sub r4, r4, #1		// c = current_col - 1 
	add r5, r4, #1		// current_col + 1
	str r5, [fp, -currColPlusOne_OFFSET] 
	.LForLoop1: ldr r5, [fp, -currColPlusOne_OFFSET] //retrieve constant curr_col + 1
	cmp r4, r5		// compare c and curr_col + 1 
	bge .LEndForLoop1	// if c > current_col + 1, end of for

	
	mov r4, r2  // retrieve currRow from parameter 2 in r2
	sub r4, r4, #1		// r = current_row - 1 
	add r5, r4, #1		// current_row + 1
	str r5, [fp, -currRowPlusOne_OFFSET] 
	.LForLoop2: ldr r5, [fp, -currRowPlusOne_OFFSET] //retrieve curr_row + 1
	cmp r4, r5		// compare r and curr_row + 1 
	bge .LEndForLoop2	// if r > curr_Row + 1, end of for
	
	ldr r5, [fp, -c_OFFSET]	// retrieve c  (r is already in r4)
	push {r0-r1, lr}
        mov r0, r4   //set parameter 1 as current row
	mov r1, r5   //set paramter 2 as current column (c)
	bl nGetIndexRC
	str r0, [fp, -index_OFFSET] // store the index offset of the current cell
	pop {r0-r1, lr}
	
	ldr r4, [r1, index_OFFSET] // store the value of src[index] in r4 for comparision 
	cmp r4, #0		 	// Checking if the current cell is alive
	bne .LSkipCount
	ldr r5, [fp, -count_OFFSET]	// retrieve count
	add r5, r5, #1			// increment count
	str r5, [fp, -count_OFFSET]	// store count	
	.LSkipCount:
	
	b .LForLoop2	
	.LEndForLoop2:
	b .LForLoop1
	.LEndForLoop1:


	ldr r4, [fp, -index_OFFSET]	// retrieve index of current cell
	ldr r5, [r1, r4]		// retrieve src[curr_cell] in r5
	cmp r5, #1			// check if already alive
	bne .LNotAlive
	ldr r6, [fp, -count_OFFSET]	//retrieve count
	sub r6, r6, #1 			// account for case where current cell is counted as an alive neighbor
	str r6, [fp, -count_OFFSET]	// store new count
	
	cmp r6, #3			//compare count with 3
	bgt .LYES			// count > 3
	cmp r6, #2
	bge .LNO                        // checks for second part of or (count < 2)
	.LYES:
	mov r6, #0
	ldr r4, [fp, -index_OFFSET]	// retrieve index of current cell
	str r6, [r0, r4]		// make current cell in destination board dead
	b .LSkipNO		
	.LNO:	
	ldr r4, [fp, -index_OFFSET]	// retrieve index of current cell	
	mov r6, #1
	str r6, [r0, r4]		// make current cell in destination board alive (maintain alive)
	.LSkipNO:
	
	b .LSkipNotAlive
	.LNotAlive:
	ldr r6, [fp, -count_OFFSET]	//retrieve count	
	cmp r6, #3			//compare count with 3
	bne .LCellDead
	ldr r4, [fp, -index_OFFSET]	// retrieve index of current cell	
	mov r6, #1
	str r6, [r0, r4]		// make current cell in destination board alive (new alive)	
	ldr r5, [fp, IARG6]		// retrieve new life parameter
	ldr r6, [r5]			// since new life is a pointer we dereference it
	add r6, r6, #1			// increment new life variable
	str r6, [r5]			// store in address stored in r5 currently
	str r5, [fp, IARG6]		// store address back into IARG6		

	b .LSkipNotAlive

	.LCellDead:
	ldr r4, [fp, -index_OFFSET]	// retrieve index of current cell	
	mov r6, #0
	str r6, [r0, r4]		// make current cell in destination board dead 		

	.LSkipNotAlive:

	ldr r4, [fp, -c_OFFSET] 	//retrieve current column
	add r4, r4, #1			// move to next column (c++)
	str r4, [fp, -c_OFFSET]		//store c

	b .LWhile        
	.LSkipWhileLoop:
	sub sp, fp, #FP_OFFSET
	pop {r4-r6, fp, lr} //TODO: Pop preserved registers
	bx lr
	
