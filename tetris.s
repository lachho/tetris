# This program was written 09/10/2023
#
# This program is an implementation of the video game Tetris. 
# This program can take in user input and the user can play Tetris
# Limitations of this program is the program does not have gravity for the current piece
# to fall on its own, shape randomisation nor colour
#
#
# Version 1.0 (2023-09-25): Team COMP1521 <cs1521@cse.unsw.edu.au>
#
########################################################################

#![tabsize(8)]

# ##########################################################
# ####################### Constants ########################
# ##########################################################

# C constants
FIELD_WIDTH  = 9
FIELD_HEIGHT = 15
PIECE_SIZE   = 4
NUM_SHAPES   = 7

FALSE = 0
TRUE  = 1

EMPTY = ' '

# NULL is defined in <stdlib.h>
NULL  = 0

# Other useful constants
SIZEOF_INT = 4

COORDINATE_X_OFFSET = 0
COORDINATE_Y_OFFSET = 4
SIZEOF_COORDINATE = 8

SHAPE_SYMBOL_OFFSET = 0
SHAPE_COORDINATES_OFFSET = 4
SIZEOF_SHAPE = SHAPE_COORDINATES_OFFSET + SIZEOF_COORDINATE * PIECE_SIZE


	.data
# ##########################################################
# #################### Global variables ####################
# ##########################################################

# !!! DO NOT ADD, REMOVE, OR MODIFY ANY OF THESE DEFINITIONS !!!

shapes:				# struct shape shapes[NUM_SHAPES] = ...
	.byte 'I'
	.word -1,  0,  0,  0,  1,  0,  2,  0
	.byte 'J'
	.word -1, -1, -1,  0,  0,  0,  1,  0
	.byte 'L'
	.word -1,  0,  0,  0,  1,  0,  1, -1
	.byte 'O'
	.word  0,  0,  0,  1,  1,  1,  1,  0
	.byte 'S'
	.word  0,  0, -1,  0,  0, -1,  1, -1
	.byte 'T'
	.word  0,  0,  0, -1, -1,  0,  1,  0
	.byte 'Z'
	.word  0,  0,  1,  0,  0, -1, -1, -1

# Note that semantically global variables without
# an explicit initial value should be be zero-initialised.
# However to make testing earlier functions in this
# assignment easier, some global variables have been
# initialised with other values. Correct translations
# will always write to those variables befor reading,
# meaning the difference shouldn't matter to a finished
# translation.

next_shape_index:		# int next_shape_index = 0;
	.word 0

shape_coordinates:		# struct coordinate shape_coordinates[PIECE_SIZE];
	.word -1,  0,  0,  0,  1,  0,  2,  0

piece_symbol:			# char piece_symbol;
	.byte	'I'

piece_x:			# int piece_x;
	.word	3

piece_y:			# int piece_y;
	.word	1

piece_rotation:			# int piece_rotation;
	.word	0

score:				# int score = 0;
	.word	0

game_running:			# int game_running = TRUE;
	.word	TRUE

field:				# char field[FIELD_HEIGHT][FIELD_WIDTH];
	.byte	0:FIELD_HEIGHT * FIELD_WIDTH


# ##########################################################
# ######################### Strings ########################
# ##########################################################

# !!! DO NOT ADD, REMOVE, OR MODIFY ANY OF THESE STRINGS !!! 

str__print_field__header:
	.asciiz	"\n/= Field =\\    SCORE: "
str__print_field__next:
	.asciiz	"     NEXT: "
str__print_field__footer:
	.asciiz	"\\=========/\n"

str__new_piece__game_over:
	.asciiz	"Game over :[\n"
str__new_piece__appeared:
	.asciiz	"A new piece has appeared: "

str__compute_points_for_line__tetris:
	.asciiz	"\n*** TETRIS! ***\n\n"

str__choose_next_shape__prompt:
	.asciiz	"Enter new next shape: "
str__choose_next_shape__not_found:
	.asciiz	"No shape found for "

str__main__welcome:
	.asciiz	"Welcome to 1521 tetris!\n"

str__show_debug_info__next_shape_index:
	.asciiz	"next_shape_index = "
str__show_debug_info__piece_symbol:
	.asciiz	"piece_symbol     = "
str__show_debug_info__piece_x:
	.asciiz	"piece_x          = "
str__show_debug_info__piece_y:
	.asciiz	"piece_y          = "
str__show_debug_info__game_running:
	.asciiz	"game_running     = "
str__show_debug_info__piece_rotation:
	.asciiz	"piece_rotation   = "
str__show_debug_info__coordinates_1:
	.asciiz	"coordinates["
str__show_debug_info__coordinates_2:
	.asciiz	"]   = { "
str__show_debug_info__coordinates_3:
	.asciiz	", "
str__show_debug_info__coordinates_4:
	.asciiz	" }\n"
str__show_debug_info__field:
	.asciiz	"\nField:\n"
str__show_debug_info__field_indent:
	.asciiz	":  "

str__game_loop__prompt:
	.asciiz	"  > "
str__game_loop__quitting:
	.asciiz	"Quitting...\n"
str__game_loop__unknown_command:
	.asciiz	"Unknown command!\n"
str__game_loop__goodbye:
	.asciiz	"\nGoodbye!\n"

# !!! Reminder to not not add to or modify any of the above !!!
# !!! strings or any other part of the data segment.        !!!



############################################################
####                                                    ####
####   Your journey begins here, intrepid adventurer!   ####
####                                                    ####
############################################################

################################################################################
#
# Implement the following functions,
# and check these boxes as you finish implementing each function.
#
#  SUBSET 0
#  - [ ] main
#  - [ ] rotate_left
#  - [ ] move_piece
#  SUBSET 1
#  - [ ] compute_points_for_line
#  - [ ] setup_field
#  - [ ] choose_next_shape
#  SUBSET 2
#  - [ ] print_field
#  - [ ] piece_hit_test
#  - [ ] piece_intersects_field
#  - [ ] rotate_right
#  SUBSET 3
#  - [ ] place_piece
#  - [ ] new_piece
#  - [ ] consume_lines
#  PROVIDED
#  - [X] show_debug_info
#  - [X] game_loop
#  - [X] read_char

# Frame:    registered you've pushed into the stack
# Uses:     any registered you've used
# Clobbers: all the registered you've used but NOT RESTORE


################################################################################
# .TEXT <main>
        .text
main:
	# This function is ran at the beginning of the program to start the game.
        # Subset:   0
        #
        # Args:     None
        #
        # Returns:  $v0: int
        #
        # Frame:    []
        # Uses:     [$a0, $v0]
        # Clobbers: [$v0]
        #
        # Locals:
        #   - $t1: int num ...
        #
        # Structure:
        #   main
        #   -> [prologue]
        #       -> body
        #   -> [epilogue]

main__prologue:
	begin
	push	$ra

main__body:
	li	$v0, 4						# syscall 4: print_string
	la	$a0, str__main__welcome				#
	syscall							# printf("Welcome to 1521 tetris!\n");

	jal	setup_field					# setup_field();
	li	$a0, FALSE					# should_announce = 0;
	jal	new_piece					# new_piece(/* should_announce = */ FALSE);
	jal	game_loop					# game_loop();

main__epilogue:
	pop	$ra
	end

	li	$v0, 0
	jr	$ra

################################################################################
# .TEXT <rotate_left>
        .text
rotate_left:
	# This function rotates the current piece 90 degrees left.
	#
        # Subset:   0
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    []
        # Uses:     []
        # Clobbers: []
        #
        # Locals:
        #   - ...
        #
        # Structure:
        #   rotate_left
        #   -> [prologue]
        #       -> body
        #   -> [epilogue]

rotate_left__prologue:
	begin
	push	$ra

rotate_left__body:
	jal	rotate_right					# rotate_right();
	jal	rotate_right					# rotate_right();
	jal	rotate_right					# rotate_right();

rotate_left__epilogue:
	pop	$ra
	end

	jr	$ra


################################################################################
# .TEXT <move_piece>
        .text
move_piece:
	# This function translates the current piece across the board.  
	#
        # Subset:   0
        #
        # Args:
        #    - $a0: int dx
        #    - $a1: int dy
        #
        # Returns:  $v0: int
        #
        # Frame:    [$s0, $s1]
        # Uses:     [$a0, $a1, $t0, $t1, $v0]
        # Clobbers: [$t0, $t1, $v0]
        #
        # Locals:
        #   - $t0: piece_x
	#   - $t1: piece_y
        #
        # Structure:
        #   move_piece
        #   -> [prologue]
        #       -> body
	# 	  -> accept
        #   -> [epilogue]
	

move_piece__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1

move_piece__body:
	move	$s0, $a0					# dx
	move	$s1, $a1					# dy

	lw	$t0, piece_x
	add	$t0, $s0
	sw	$t0, piece_x					# piece_x += dx;

	lw	$t1, piece_y
	add	$t1, $s1
	sw	$t1, piece_y					# piece_y += dy;

	jal	piece_intersects_field				# if (!piece_intersect_field())
	beqz	$v0, move_piece__accept				# goto move_piece_accept

	lw	$t0, piece_x
	sub	$t0, $s0
	sw	$t0, piece_x					# piece_x -= dx;

	lw	$t1, piece_y
	sub	$t1, $s1
	sw	$t1, piece_y					# piece_y -= dy;

	li	$v0, FALSE					# return FALSE;
	b	move_piece__epilogue

move_piece__accept:
	li	$v0, TRUE					# return TRUE;

move_piece__epilogue:
	pop	$s1
	pop	$s0
	pop	$ra
	end

	jr	$ra

################################################################################
# .TEXT <compute_points_for_line>
        .text
compute_points_for_line:
	# This function calculates the number of points for clearing 1 or more lines. 
	#
        # Subset:   1
        #
        # Args:
        #    - $a0: int bonus
        #
        # Returns:  $v0: int
        #
        # Frame:    []
        # Uses:     [$a0, $t0, $t1, $v0]
        # Clobbers: [$t0, $t1, $v0]
        #
        # Locals:
        #   - ...
        #
        # Structure:
        #   compute_points_for_line
        #   -> [prologue]
        #       -> body
	#   	  -> tetris
        #   -> [epilogue]

compute_points_for_line__prologue:
	begin
	push	$ra

compute_points_for_line__body:
	move	$t1, $a0					# int bonus
							
	bne	$a0, 4, compute_points_for_line__tetris		# if (bonus == 4) {
	li	$v0, 4						# syscall 4: print_string
	la	$a0, str__compute_points_for_line__tetris
	syscall							# printf("\n*** TETRIS! ***\n\n");

compute_points_for_line__tetris:
	sub	$t0, $t1, 1
	mul	$t0, $t0
	mul	$t0, 40
	addi	$t0, 100
	move	$v0, $t0					# return temp; // 100 + 40 * (bonus - 1) * (bonus - 1);

compute_points_for_line__epilogue:
	pop	$ra
	end

	jr	$ra

################################################################################
# .TEXT <setup_field>
        .text
setup_field:
	# This function creates the field and sets the field to EMPTY space.
	#
        # Subset:   1
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    []
        # Uses:     [$t0, $t1, $t2, $t3]
        # Clobbers: [$t0, $t1, $t2, $t3]
        #
        # Locals:
        #   - $t0: row
	#   - $t1: col
	#   - $t2: temp field array address
	#   - $t3: EMPTY
        #
        # Structure:
        #   setup_field
        #   -> [prologue]
        #       -> body
	#     	-> row_loop
	#         -> row_loop__init
	#         -> row_loop__cond
	#         -> row_loop__body
	#           -> col_loop
	#             -> col_loop__init
	#             -> col_loop__cond
	#             -> col_loop__body
	#             -> col_loop__step
	#             -> col_loop__end
	#         -> row_loop__step
	#         -> row_loop__end
        #   -> [epilogue]

setup_field__prologue:
	begin
	push	$ra

setup_field__body:
setup_field__row_loop_init:
    	li	$t0, 0						# row = 0;

setup_field__row_loop_cond:
    	bge	$t0, FIELD_HEIGHT, setup_field__row_loop_end 	# if (row >= FIELD_HEIGHT) goto row_loop_end;

setup_field__row_loop_body:
setup_field__col_loop_init:
        li	$t1, 0						# col = 0;

setup_field__col_loop_cond:
        bge	$t1, FIELD_WIDTH, setup_field__col_loop_end	# if (col >= FIELD_WIDTH) goto col_loop_end;

setup_field__col_loop_body:
	mul	$t2, $t0, FIELD_WIDTH
	add	$t2, $t1
	li	$t3, EMPTY
	sb	$t3, field($t2)					# field[row][col] = EMPTY;

setup_field__col_loop_step:
        addi	$t1, 1 						# col += 1;
        b	setup_field__col_loop_cond			# goto col_loop_cond;


setup_field__col_loop_end:


setup_field__row_loop_step:
    	addi	$t0, 1						# row += 1;
    	b	setup_field__row_loop_cond			# goto row_loop_cond;

setup_field__row_loop_end:
setup_field__epilogue:
	pop	$ra
	end

	jr	$ra

################################################################################
# .TEXT <choose_next_shape>
        .text
choose_next_shape:
	# This function changes the shape of the next piece to be played in the field. 
	#
        # Subset:   1
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    []
        # Uses:     [$t0, $t1, $t2, $t3, $a0, $v0]
        # Clobbers: [$t0, $t1, $t2, $t3]
        #
        # Locals:
        #   - $t0: i
	#   - $t1: symbol
	#   - $t2: temp array address
	#   - $t3: shapes[i].symbol
        #
        # Structure:
        #   choose_next_shape
        #   -> [prologue]
        #       -> body
	#     	-> loop
	#         -> loop__init
	#         -> loop__cond
	#         -> loop__body
	#         -> loop__step
	#         -> loop__end
        #   -> [epilogue]

choose_next_shape__prologue:
	begin
	push	$ra

choose_next_shape__body:
	# Hint for translating shapes[i].symbol:
	#    You can compute the address of shapes[i] by using
	#      `i`, the address of `shapes`, and SHAPE_SIZE.
	#    You can then use that address to find the address of
	#      shapes[i].symbol with SHAPE_SYMBOL_OFFSET.
	#    Once you have the address of shapes[i].symbol you
	#      can use a memory load instruction to find its value.

	li	$v0, 4						# syscall 4: print_string
	la	$a0, str__choose_next_shape__prompt
	syscall							# printf("Enter new next shape: ");
    
    	jal	read_char				
	move	$t1, $v0					# char symbol = read_char();

choose_next_shape__loop_init:
  	li	$t0, 0						# i = 0;

choose_next_shape__loop_cond:
   	beq	$t0, NUM_SHAPES, choose_next_shape__loop_end	# if (i == NUM_SHAPES) goto loop_end;

	mul	$t2, $t0, SIZEOF_SHAPE
	add	$t2, SHAPE_SYMBOL_OFFSET
	lb	$t3, shapes($t2)				# shapes[i].symbol
   	beq	$t3, $t1, choose_next_shape__loop_end		# if (shapes[i].symbol == symbol) goto loop_end;

choose_next_shape__loop_body:
choose_next_shape__loop_step:
    	addi	$t0, 1						# i += 1;
    	b	choose_next_shape__loop_cond			# goto loop_cond;

choose_next_shape__loop_end:
	bne	$t0, NUM_SHAPES, choose_next_shape__end_shape	# if (i != NUM_SHAPES) goto end_shape;
    
    	li	$v0, 4						# syscall 4: print_string
	la	$a0, str__choose_next_shape__not_found
	syscall							# printf("No shape found for ");
    
	li	$v0, 11						# syscall 11: print_char
	move	$a0, $t1					#
	syscall							# printf("%c", symbol);
	
	li	$v0, 11						# syscall 11: print_char
	li	$a0, '\n'					#
	syscall							# printf("%c", '\n');

    	b	choose_next_shape__epilogue			# goto end;

choose_next_shape__end_shape:
    	sw	$t0, next_shape_index				# next_shape_index = i;


choose_next_shape__epilogue:
	pop	$ra
	end

	jr	$ra

################################################################################
# .TEXT <print_field>
        .text
print_field:
	# THis function updates the front end field as the pieces move
	#
        # Subset:   2
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [$s0, $s1]
        # Uses:     [$a0, $a1, $a2, $t0, $v0]
        # Clobbers: [$t0, $v0]
        #
        # Locals:
        #   - $s0: row
	#   - $s1: col
	#   - $t0: temp array 
        #
        # Structure:
        #   print_field
        #   -> [prologue]
        #       -> body
	#     	-> row_loop
	#         -> row_loop__init
	#         -> row_loop__cond
	#         -> row_loop__body
	#           -> col_loop
	#             -> col_loop__init
	#             -> col_loop__cond
	#             -> col_loop__body
	#             -> piece_hit
	#             -> col_loop__step
	#             -> col_loop__end
	#	  -> skip_print
	#         -> row_loop__step
	#         -> row_loop__end
        #   -> [epilogue]

print_field__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1

print_field__body:
    	li	$v0, 4						# syscall 4: print_string
	la	$a0, str__print_field__header
	syscall							# printf("\n/= Field =\\    SCORE: ");
    
	li	$v0, 1						# syscall 1: print_int
	lw	$a0, score					#
	syscall							# printf("%d", score);
	
	li	$v0, 11						# syscall 11: print_char
	li	$a0, '\n'					#
	syscall							# printf("%c", '\n');

print_field__row_loop_init:
    	li	$s0, 0						# row = 0;

print_field__row_loop_cond:
    	bge	$s0, FIELD_HEIGHT, print_field__row_loop_end	# if (row >= FIELD_HEIGHT) goto row_loop_end;

print_field__row_loop_body:
	li	$v0, 11						# syscall 11: print_char
	li	$a0, '|'					#
	syscall							# putchar('|');

print_field__col_loop_init:
        li	$s1, 0						# col = 0;

print_field__col_loop_cond:
        bge	$s1, FIELD_WIDTH, print_field__col_loop_end	# if (col >= FIELD_WIDTH) goto col_loop_end;

print_field__col_loop_body:
        la	$a0, shape_coordinates
	move	$a1, $s0
	move	$a2, $s1
	jal 	piece_hit_test					# if (piece_hit_test(shape_coordinates, row, col))
	bnez	$v0, print_field__piece_hit			# goto piece_hit;
        
	mul	$t0, $s0, FIELD_WIDTH
	add	$t0, $s1
	lb	$a0, field($t0)					# field[row][col]	
	
	li	$v0, 11						# syscall 11: print_char
	syscall							# putchar(field[row][col]); // else conditon
        
	b	print_field__col_loop_step			# goto col_loop_step;

print_field__piece_hit:
        li	$v0, 11						# syscall 11: print_char
	lb	$a0, piece_symbol				#
	syscall							# putchar(piece_symbol);

print_field__col_loop_step:
        addi	$s1, 1						# col += 1;
        b	print_field__col_loop_cond			# goto col_loop_cond;

print_field__col_loop_end:
	li	$v0, 11						# syscall 11: print_char
	li	$a0, '|'					#
	syscall							# putchar('|');
    
    	bne	$s0, 1, print_field__skip_print			# if (row != 1) goto skip_print;
    
    	li	$v0, 4						# syscall 4: print_string
	la	$a0, str__print_field__next
	syscall							# printf("     NEXT: ");

	lw	$t0, next_shape_index
	mul	$t0, SIZEOF_SHAPE
	add	$t0, SHAPE_SYMBOL_OFFSET
	lb	$a0, shapes($t0)				# shapes[next_shape_index].symbol

	li	$v0, 11						# syscall 11: print_char
	syscall							# printf("%c", shapes[next_shape_index].symbol);

print_field__skip_print:
	li	$v0, 11						# syscall 11: print_char
	li	$a0, '\n'					#
	syscall							# putchar('\n');
    

print_field__row_loop_step:
    	addi	$s0, 1						# row += 1;
	b	print_field__row_loop_cond			# goto row_loop_cond;

print_field__row_loop_end:
    	li	$v0, 4						# syscall 4: print_string
	la	$a0, str__print_field__footer
	syscall							# printf("\\=========/\n");

print_field__epilogue:
	pop 	$s1
	pop	$s0
	pop	$ra
	end

	jr	$ra

################################################################################
# .TEXT <piece_hit_test>
        .text
piece_hit_test:
	# This function checks if the current piece has touched the other pieces.
	# and if so returns a pointer to that matching coordinate
	#
        # Subset:   2
        #
        # Args:
        #    - $a0: struct coordinate coordinates[PIECE_SIZE]
        #    - $a1: int row
        #    - $a2: int col
        #
        # Returns:  $v0: struct coordinate *
        #
        # Frame:    [...]
        # Uses:     [$a0, $a1, $a2, $t0, $t2, $t3, $t4, $t5, $t6, $v0]
        # Clobbers: [$t0, $t2, $t3, $t4, $t5, $t6, $v0]
        #
        # Locals:
        #   - $t0: int i
	#   - $t1: unused oops
	#   - $t2: temp struct address
	#   - $t3: int coordinates[i].x
	#   - $t4: int coordinates[i].y
	#   - $t5: int piece_x
	#   - $ty: int piece_y
        #
        # Structure:
        #   piece_hit_test
        #   -> [prologue]
        #       -> body
	#     	-> loop
	#         -> loop__init
	#         -> loop__cond
	#         -> loop__body
	#         -> loop__step
	#         -> loop__end
        #   -> [epilogue]

piece_hit_test__prologue:
	begin
	push	$ra

piece_hit_test__body:
piece_hit_test__loop_init:
   	li	$t0, 0						# i = 0;

piece_hit_test__loop_cond:
	bge	$t0, PIECE_SIZE, piece_hit_test__loop_end	# if (i >= PIECE_SIZE) goto loop_end;

piece_hit_test__loop_body:
	mul	$t2, $t0, SIZEOF_COORDINATE
	add	$t2, COORDINATE_X_OFFSET
	add	$t2, $a0					
	lw	$t3, ($t2)					# coordinates[i].x

	lw	$t5, piece_x
	add	$t3, $t5					# coordinates[i].x + piece_x

    	bne	$t3, $a2, piece_hit_test__loop_step		# if (coordinates[i].x + piece_x != col) goto loop_step;
    	
	mul	$t2, $t0, SIZEOF_COORDINATE
	add	$t2, COORDINATE_Y_OFFSET
	add	$t2, $a0
	lw	$t4, ($t2)					# coordinates[i].y

	lw	$t6, piece_y
	add	$t4, $t6					# coordinates[i].y + piece_y

	bne	$t4, $a1, piece_hit_test__loop_step		# if (coordinates[i].y + piece_y != row) goto loop_step;
	
	sub	$t2, COORDINATE_Y_OFFSET
	move	$v0, $t2					# return coordinates + i; 
	b	piece_hit_test__epilogue			# goto loop_end

piece_hit_test__loop_step:
   	addi	$t0, 1						# i += 1;
    	b	piece_hit_test__loop_cond			# goto loop_cond;

piece_hit_test__loop_end:
	li	$v0, NULL					# return NULL

piece_hit_test__epilogue:
	pop	$ra
	end

	jr	$ra

################################################################################
# .TEXT <piece_intersects_field>
        .text
piece_intersects_field:
	# This function checks if the current piece has touched the edges of the field. 
	#
        # Subset:   2
        #
        # Args:     None
        #
        # Returns:  $v0: int
        #
        # Frame:    []
        # Uses:     [$t0, $t2, $t3, $t4, $t5, $t6, $v0]
        # Clobbers: [$t0, $t2, $t3, $t4, $t5, $t6, $v0]
        #
        # Locals:
        #   - $t0: int i
	#   - $t1: field[row][col]
	#   - $t2: temp struct address
	#   - $t3: int x = shape_coordinates[i].x = piece_x
	#   - $t4: int y = shape_coordinates[i].y + piece_y
	#   - $t5: int piece_x
	#   - $t6: int piece_y
	#   - $t7: temp address
        #
        # Structure:
        #   piece_intersects_field
        #   -> [prologue]
        #       -> body
	#     	-> loop
	#         -> loop__init
	#         -> loop__cond
	#         -> loop__body
	#         -> intersect_true
	#         -> loop__step
	#         -> loop__end
        #   -> [epilogue]

piece_intersects_field__prologue:
	begin
	push	$ra

piece_intersects_field__sects_field__body:
loop_init:
    	li	$t0, 0						# i = 0;

piece_intersects_field__loop_cond:				# if (i >= PIECE_SIZE) goto loop_end;
    	bge	$t0, PIECE_SIZE, piece_intersects_field__loop_end

piece_intersects_field__loop_body:
	mul	$t2, $t0, SIZEOF_COORDINATE
	add	$t2, COORDINATE_X_OFFSET					
	lw	$t3, shape_coordinates($t2)			# shape_coordinates[i].x

	lw	$t5, piece_x
	add	$t3, $t5					# x = shape_coordinates[i].x + piece_x
    	
	mul	$t2, $t0, SIZEOF_COORDINATE
	add	$t2, COORDINATE_Y_OFFSET
	lw	$t4, shape_coordinates($t2)			# shape_coordinates[i].y

	lw	$t6, piece_y
	add	$t4, $t6					# y = shape_coordinates[i].y + piece_y

	bltz	$t3, piece_intersects_field__true		# if (x < 0) goto intersect_true;
	bge	$t3, FIELD_WIDTH, piece_intersects_field__true	# if (x >= FIELD_WIDTH) goto intersect_true;
	bltz	$t4, piece_intersects_field__true		# if (y < 0) goto intersect_true;
	bge	$t4, FIELD_HEIGHT, piece_intersects_field__true	# if (y >= FIELD_HEIGHT) goto intersect_true;

	mul	$t7, $t4, FIELD_WIDTH
	add	$t7, $t3
	lb	$t1, field($t7)					# field[row][col]
	bne	$t1, EMPTY, piece_intersects_field__true	# if (field[y][x] != EMPTY) goto intersect_true;			
	b	piece_intersects_field__loop_step		# goto loop_step;

piece_intersects_field__true:
    	li	$v0, TRUE					# result = TRUE;
    	b	piece_intersects_field__epilogue		# goto epilogue;

piece_intersects_field__loop_step:
    	addi	$t0, 1						# i += 1;
	b	piece_intersects_field__loop_cond		# goto loop_cond;

piece_intersects_field__loop_end:
	li	$v0, FALSE					# return FALSE
piece_intersects_field__epilogue:
	pop	$ra
	end

	jr	$ra

################################################################################
# .TEXT <rotate_right>
        .text
rotate_right:
	# THis function rotates the current piece 90 degrees right. 
	#
        # Subset:   2
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    []
        # Uses:     [$t0, $t2, $t3, $t4, $t5]
        # Clobbers: [$t0, $t2, $t3, $t4, $t5]
        #
        # Locals:
        #   - $t0: int i
	#   - $t1: temp struct address
	#   - $t2: temp struct address
	#   - $t3: int x = shape_coordinates[i].x + piece_x
	#   - $t4: int y = shape_coordinates[i].y + piece_y
	#   - $t5: int piece_symbol
        #
        # Structure:
        #   rotate_right
        #   -> [prologue]
        #       -> body
	#     	-> rotate_loop
	#         -> rotate_loop__init
	#         -> rotate_loop__cond
	#         -> rotate_loop__body
	#         -> rotate_loop__step
	#         -> rotate_loop__end
	#     	-> nudge_loop
	#         -> nudge_loop__init
	#         -> nudge_loop__cond
	#         -> nudge_loop__body
	#         -> nudge_loop__step
	#         -> nudge_loop__end
        #   -> [epilogue]

rotate_right__prologue:
	begin
	push	$ra

rotate_right__body:
	# The following 3 instructions are provided, although you can
	# discard them if you want. You still need to add appropriate
	# comments.
	lw	$t0, piece_rotation
	addi	$t0, $t0, 1
	sw	$t0, piece_rotation				# piece_rotation += 1;

rotate_right__rotate_loop_init:
    	li	$t0, 0						# i = 0;

rotate_right__rotate_loop_cond:
    	bge	$t0, PIECE_SIZE, rotate_right__rotate_loop_end	# if (i >= PIECE_SIZE) goto rotate_loop_end;

rotate_right__rotate_loop_body:
    	# This negate-y-and-swap operation rotates 90 degrees clockwise.
	mul	$t1, $t0, SIZEOF_COORDINATE
	add	$t1, COORDINATE_X_OFFSET					
	lw	$t3, shape_coordinates($t1)			# shape_coordinates[i].x
    	
	mul	$t2, $t0, SIZEOF_COORDINATE
	add	$t2, COORDINATE_Y_OFFSET
	lw	$t4, shape_coordinates($t2)			# 
	mul	$t4, -1						# -coordinates[i].y

	# we can swap both simultaneously in Mipsy, not C
	sw	$t4, shape_coordinates($t1)			# shape_coordinates[i].x = -shape_coordinates[i].y;
	sw	$t3, shape_coordinates($t2)			# shape_coordinates[i].y = shape_coordinates[i].x;
    

rotate_right__rotate_loop_step:
    	addi 	$t0, 1						# i += 1;
    	b	rotate_right__rotate_loop_cond			# goto rotate_loop_cond;

rotate_right__rotate_loop_end:
    	# The `I` and `O` pieces aren't centered on the middle
    	# of a cell, and so need a nudge after being rotated.
	lb	$t5, piece_symbol
    	beq	$t5, 'I', rotate_right__nudge_loop_init		# if (piece_symbol == 'I') goto nudge_loop_init;
    	beq	$t5, 'O', rotate_right__nudge_loop_init		# if (piece_symbol == 'O') goto nudge_loop_init;
 	b	rotate_right__epilogue				#  goto end;

rotate_right__nudge_loop_init:
    	li	$t0, 0						# i = 0;

rotate_right__nudge_loop_cond:
     	bge	$t0, PIECE_SIZE, rotate_right__nudge_loop_end	# if (i >= PIECE_SIZE) goto nudge_loop_end;

rotate_right__nudge_loop_body:
    	mul	$t1, $t0, SIZEOF_COORDINATE
	add	$t1, COORDINATE_X_OFFSET					
	lw	$t3, shape_coordinates($t1)			# shape_coordinates[i].x
    	addi	$t3, 1
	sw	$t3, shape_coordinates($t1)			# shape_coordinates[i].x += 1;

rotate_right__nudge_loop_step:
    	addi 	$t0, 1						# i += 1;
    	b	rotate_right__nudge_loop_cond			# goto nudge_loop_cond;

rotate_right__nudge_loop_end:
rotate_right__epilogue:
	pop	$ra
	end

	jr	$ra

################################################################################
# .TEXT <place_piece>
        .text
place_piece:
	# Handles a block hitting the bottom and converts that piece to the field
	#
        # Subset:   3
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    []
        # Uses:     [$a0, $t0, $t2, $t3, $t4, $t5, $t6, $t7]
        # Clobbers: [$a0, $t0, $t2, $t3, $t4, $t5, $t6, $t7]
        #
        # Locals:
        #   - $t0: int i
	#   - $t1: field[row][col]
	#   - $t2: temp struct address
	#   - $t3: int x = shape_coordinates[i].x + piece_x
	#   - $t4: int y = shape_coordinates[i].y + piece_y
	#   - $t5: int piece_x
	#   - $t6: int piece_y
	#   - $t7: temp address
        #
        # Structure:
        #   place_piece
        #   -> [prologue]
        #       -> body
	#     	-> loop
	#         -> loop__init
	#         -> loop__cond
	#         -> loop__body
	#         -> loop__step
	#         -> loop__end
        #   -> [epilogue]

place_piece__prologue:
	begin
	push	$ra

place_piece__body:
place_piece__loop_init:
   	li	$t0, 0						# i = 0;

place_piece__loop_cond:
	bge	$t0, PIECE_SIZE, place_piece__loop_end		# if (i >= PIECE_SIZE) goto loop_end;

place_piece__loop_body:
	mul	$t2, $t0, SIZEOF_COORDINATE
	add	$t2, COORDINATE_X_OFFSET					
	lw	$t3, shape_coordinates($t2)			# shape_coordinates[i].x

	lw	$t5, piece_x
	add	$t3, $t5					# shape_coordinates[i].x + piece_x
    	
	mul	$t2, $t0, SIZEOF_COORDINATE
	add	$t2, COORDINATE_Y_OFFSET
	lw	$t4, shape_coordinates($t2)			# shape_coordinates[i].y

	lw	$t6, piece_y
	add	$t4, $t6					# shape_coordinates[i].x + piece_x

	lb	$t1, piece_symbol				# char piece_symbol;
	mul	$t7, $t4, FIELD_WIDTH
	add	$t7, $t3
	sb	$t1, field($t7)					# field[row][col] = piece_symbol;	

place_piece__loop_step:
   	addi	$t0, 1						# i += 1;
    	b	place_piece__loop_cond				# goto loop_cond;

place_piece__loop_end:
	jal 	consume_lines					# consume_lines();
	li	$a0, TRUE					# 
	jal	new_piece					# new_piece(/* should_announce = */ TRUE);

place_piece__epilogue:
	pop	$ra
	end

	jr	$ra

################################################################################
# .TEXT <new_piece>
        .text
new_piece:
	# Sets the current piece to the top of the field
	#
        # Subset:   3
        #
        # Args:
        #    - $a0: int should_announce
        #
        # Returns:  None
        #
        # Frame:    []
        # Uses:     [$a0, $v0, $t0, $t2, $t3, $t4, $t5, $t6, $t7]
        # Clobbers: [$a0, $v0, $t0, $t2, $t3, $t4, $t5, $t6, $t7]
        #
        # Locals:
        #   - $t0: int i / game_running
	#   - $t1: int next_shape_index
	#   - $t2: temp struct address
	#   - $t3: int piece_x
	#   - $t4: int piece_y
	#   - $t5: int piece_rotation / temp address
	#   - $t6: char piece_symbol
	#   - $t7: new_coordinates x and y
        #
        # Structure:
        #   new_piece
        #   -> [prologue]
        #       -> body
	#     	-> loop
	#         -> loop__init
	#         -> loop__cond
	#         -> loop__body
	#         -> loop__step
	#         -> loop__end
        #   -> [epilogue]

new_piece__prologue:
	begin
	push	$ra

new_piece__body:
	li	$t3, 4
	sw	$t3, piece_x					# piece_x = 4;

	li	$t4, 1
	sw	$t4, piece_y					# piece_y = 1;

	li	$t5, 0
	sw	$t5, piece_rotation				# piece_rotation = 0;	

	lw	$t2, next_shape_index
	mul	$t2, SIZEOF_SHAPE
	add	$t2, SHAPE_SYMBOL_OFFSET		
	lb	$t6, shapes($t2)
	sb	$t6, piece_symbol				# piece_symbol = shapes[next_shape_index].symbol;

	beq	$t6, 'O', new_piece__change_o			# if (piece_symbol == 'O') {
	beq	$t6, 'I', new_piece__change_i			# else if (piece_symbol == 'I') {
	b	new_piece__no_change

new_piece__change_o:
	sub	$t3, 1
	sw	$t3, piece_x					# piece_x -= 1;

new_piece__change_i:
	sub	$t4, 1
	sw	$t4, piece_y					# piece_y -= 1;

new_piece__no_change:
new_piece__loop_init:
    	li	$t0, 0						# i = 0;

new_piece__loop_cond:
     	bge	$t0, PIECE_SIZE, new_piece__loop_end		# if (i >= PIECE_SIZE) goto loop_end;

new_piece__loop_body:
	lw	$t2, next_shape_index
	mul	$t2, SIZEOF_SHAPE
	add	$t2, SHAPE_COORDINATES_OFFSET
	mul	$t5, $t0, SIZEOF_COORDINATE
	add	$t2, $t5
	add	$t2, COORDINATE_X_OFFSET
	lw	$t7, shapes($t2)				# new_x = shapes[next_shape_index].coordinates[i].x

	mul	$t2, $t0, SIZEOF_COORDINATE
	add	$t2, COORDINATE_X_OFFSET					
	sw	$t7, shape_coordinates($t2)			# shape_coordinates[i].x = new_x

	lw	$t2, next_shape_index
	mul	$t2, SIZEOF_SHAPE
	add	$t2, SHAPE_COORDINATES_OFFSET
	mul	$t5, $t0, SIZEOF_COORDINATE
	add	$t2, $t5
	add	$t2, COORDINATE_Y_OFFSET
	lw	$t7, shapes($t2)				# new_y = shapes[next_shape_index].coordinates[i].y
    	
	mul	$t2, $t0, SIZEOF_COORDINATE
	add	$t2, COORDINATE_Y_OFFSET
	sw	$t7, shape_coordinates($t2)			# shape_coordinates[i].y = new_y

new_piece__loop_step:
    	addi 	$t0, 1						# i += 1;
    	b	new_piece__loop_cond				# goto nudge_loop_cond;

new_piece__loop_end:
	lw	$t1, next_shape_index
	addi	$t1, 1						# next_shape_index += 1;
	rem	$t1, NUM_SHAPES					# next_shape_index %= NUM_SHAPES;
	sw	$t1, next_shape_index

	jal	piece_intersects_field			
	beqz	$v0, new_piece__announce			# if (!piece_intersects_field()) goto announce
	jal 	print_field					# print_field();

	li	$v0, 4						# syscall 4: print_string
	la	$a0, str__new_piece__game_over
	syscall							# printf("Game over :[\n");

	li	$t0, FALSE
	sw	$t0, game_running				# game_running = FALSE;
	b	new_piece__epilogue

new_piece__announce: 
	beqz	$a0, new_piece__epilogue			# else if (!should_announce) goto epilogue;

	li	$v0, 4						# syscall 4: print_string
	la	$a0, str__new_piece__appeared
	syscall							# printf("A new piece has appeared: ");

	li	$v0, 11						# sycall 1: print_int
	lb	$a0, piece_symbol				# next_shape_index
	syscall							# printf("%d", piece_symbol);

	li	$v0, 11						# syscall 11: print_char
	li	$a0, '\n'
	syscall							# putchar('\n');

new_piece__epilogue:
	pop	$ra
	end

	jr	$ra

################################################################################
# .TEXT <consume_lines>
        .text
consume_lines:
	# This consumes lines that are filled with blocks and adds points
	# If consumed, moves all the pieces down. 
	#
        # Subset:   3
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [$s0]
        # Uses:     [$a0, $v0, $t0, $t2, $t3, $t4, $t5, $t6, $t7]
        # Clobbers: [$a0, $v0, $t0, $t2, $t3, $t4, $t5, $t6, $t7]
        #
        # Locals:
        #   - $s0: int row
	#   - $t0: int score
	#   - $t1: int col
	#   - $t2: temp array
	#   - $t3: temp array 
	#   - $t4: field[row][col]
	#   - $t5: int row_to_copy
	#   - $t6: int line_is_full
	#   - $t7: int lines_cleared
        #
        # Structure:
        #   consume_lines
        #   -> [prologue]
        #       -> body
	#         -> row_loop_init
	#         -> row_loop_cond
	#         -> row_loop_body
	#           -> col_loop_init
	#           -> col_loop_cond
	#           -> col_loop_body
	#           -> col_loop_step
	#           -> col_loop_end
	#           -> row_to_copy_loop_init
	#           -> row_to_copy_loop_cond
	#           -> row_to_copy_loop_body
	#              -> col_to_copy_loop_init
	#              -> col_to_copy_loop_cond
	#              -> col_to_copy_loop_body
	#              -> col_to_copy_loop_step
	#              -> col_to_copy_loop_end
	#              -> row_to_copy_loop_step
	#              -> row_to_copy_loop_end
	#         -> row_loop_step
	#         -> row_loop_end
        #   -> [epilogue]

consume_lines__prologue:
	begin
	push	$ra
	push	$s0

consume_lines__body:
    	li	$t7, 0						#lines_cleared = 0; 

consume_lines__row_loop_init:
	li	$s0, FIELD_HEIGHT			
	sub	$s0, 1						# row = FIELD_HEIGHT - 1;

consume_lines__row_loop_cond:
	bltz	$s0, consume_lines__row_loop_end		# if (row < 0) goto row_loop_end;

consume_lines__row_loop_body:
	li	$t6, TRUE					# line_is_full = TRUE;

consume_lines__col_loop_init:
	li	$t1, 0						# col = 0;

consume_lines__col_loop_cond:
        bge	$t1, FIELD_WIDTH, consume_lines__col_loop_end	#if (col >= FIELD_WIDTH) goto col_loop_end;

consume_lines__col_loop_body:
	mul	$t2, $s0, FIELD_WIDTH
	add	$t2, $t1
	lb	$t4, field($t2)					# field[row][col];
	bne	$t4, EMPTY, consume_lines__col_loop_step	# if (field[row][col] != EMPTY) goto col_loop_step;
        
        li	$t6, FALSE					# line_is_full = FALSE;

consume_lines__col_loop_step:
        addi	$t1, 1						# col += 1;
        b	consume_lines__col_loop_cond			# goto col_loop_cond;

consume_lines__col_loop_end:
	beqz	$t6, consume_lines__row_loop_step		# if (!line_is_full) goto row_loop_step;

consume_lines__row_to_copy_loop_init:
        move	$t5, $s0 					# row_to_copy = row;

consume_lines__row_to_copy_loop_cond:
	bltz	$t5, consume_lines__row_to_copy_loop_end        # if (row_to_copy < 0) goto row_to_copy_loop_end;

consume_lines__row_to_copy_loop_body:
consume_lines__col_to_copy_loop_init:
        li	$t1, 0						# col = 0;

consume_lines__col_to_copy_loop_cond:				# if (col >= FIELD_WIDTH) goto col_to_copy_loop_end;
	bge	$t1, FIELD_WIDTH, consume_lines__col_to_copy_loop_end

consume_lines__col_to_copy_loop_body:
	mul	$t2, $t5, FIELD_WIDTH
	add	$t2, $t1					# field[row_to_copy][col]

	beqz	$t5, consume_lines__row_to_copy_zero		# if (row_to_copy != 0) goto row_to_copy_zero;
        sub	$t3, $t5, 1
	mul	$t3, FIELD_WIDTH
	add	$t3, $t1	
	lb	$t4, field($t3)					# field[row_to_copy - 1][col]
	
	sb	$t4, field($t2)					# field[row_to_copy][col] = field[row_to_copy - 1][col];
	b	consume_lines__col_to_copy_loop_step

consume_lines__row_to_copy_zero:
	li	$t4, EMPTY
	sb	$t4, field($t2)					# field[row_to_copy][col] = EMPTY;

consume_lines__col_to_copy_loop_step:
        addu	$t1, 1						# col += 1;
        b	consume_lines__col_to_copy_loop_cond		# goto col_to_copy_loop_cond;

consume_lines__col_to_copy_loop_end:

consume_lines__row_to_copy_loop_step:
        sub	$t5, 1						# row_to_copy--;
        b	consume_lines__row_to_copy_loop_cond		# goto row_to_copy_loop_cond;

consume_lines__row_to_copy_loop_end:
	addi	$s0, 1						# row++;
    	addi 	$t7, 1						# lines_cleared++;
	move	$a0, $t7
	jal	compute_points_for_line				# compute_points_for_line(lines_cleared)

    	lw	$t0, score
	add	$t0, $v0
	sw	$t0, score					# score += compute_points_for_line(lines_cleared);


consume_lines__row_loop_step:
    	sub	$s0, 1						# row--;
    	b	consume_lines__row_loop_cond			# goto row_loop_cond;

consume_lines__row_loop_end:

consume_lines__epilogue:
	pop	$s0
	pop	$ra
	end

	jr	$ra

################################################################################
################################################################################
###                   PROVIDED FUNCTIONS — DO NOT CHANGE                     ###
################################################################################
################################################################################

################################################################################
# .TEXT <show_debug_info>
        .text
show_debug_info:
	# Args:     None
        #
        # Returns:  None
	#
	# Frame:    []
	# Uses:     [$a0, $v0, $t0, $t1, $t2, $t3]
	# Clobbers: [$a0, $v0, $t0, $t1, $t2, $t3]
	#
	# Locals:
	#   - $t0: i
	#   - $t1: coordinates address calculations
	#   - $t2: row
	#   - $t3: col
	#   - $t4: field address calculations
	#
	# Structure:
	#   print_board
	#   -> [prologue]
	#   -> body
	#     -> coord_loop
	#       -> coord_loop__init
	#       -> coord_loop__cond
	#       -> coord_loop__body
	#       -> coord_loop__step
	#       -> coord_loop__end
	#     -> row_loop
	#       -> row_loop__init
	#       -> row_loop__cond
	#       -> row_loop__body
	#         -> col_loop
	#           -> col_loop__init
	#           -> col_loop__cond
	#           -> col_loop__body
	#           -> col_loop__step
	#           -> col_loop__end
	#       -> row_loop__step
	#       -> row_loop__end
	#   -> [epilogue]

show_debug_info__prologue:

show_debug_info__body:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__next_shape_index
	syscall					# printf("next_shape_index = ");

	li	$v0, 1				# sycall 1: print_int
	lw	$a0, next_shape_index		# next_shape_index
	syscall					# printf("%d", next_shape_index);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__piece_symbol
	syscall					# printf("piece_symbol     = ");

	li	$v0, 1				# sycall 1: print_int
	lb	$a0, piece_symbol		# piece_symbol
	syscall					# printf("%d", piece_symbol);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__piece_x
	syscall					# printf("piece_x          = ");

	li	$v0, 1				# sycall 1: print_int
	lw	$a0, piece_x			# piece_x
	syscall					# printf("%d", piece_x);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__piece_y
	syscall					# printf("piece_y          = ");

	li	$v0, 1				# sycall 1: print_int
	lw	$a0, piece_y			# piece_y
	syscall					# printf("%d", piece_y);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__game_running
	syscall					# printf("game_running     = ");

	li	$v0, 1				# sycall 1: print_int
	lw	$a0, game_running		# game_running
	syscall					# printf("%d", game_running);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__piece_rotation
	syscall					# printf("piece_rotation   = ");

	li	$v0, 1				# sycall 1: print_int
	lw	$a0, piece_rotation		# piece_rotation
	syscall					# printf("%d", piece_rotation);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


show_debug_info__coord_loop:
show_debug_info__coord_loop__init:
	li	$t0, 0				# int i = 0;

show_debug_info__coord_loop__cond:		# while (i < PIECE_SIZE) {
	bge	$t0, PIECE_SIZE, show_debug_info__coord_loop__end

show_debug_info__coord_loop__body:
	li	$v0, 4				#   syscall 4: print_string
	la	$a0, str__show_debug_info__coordinates_1
	syscall					#   printf("coordinates[");

	li	$v0, 1				#   syscall 1: print_int
	move	$a0, $t0
	syscall					#   printf("%d", i);

	li	$v0, 4				#   syscall 4: print_string
	la	$a0, str__show_debug_info__coordinates_2
	syscall					#   printf("]   = { ");

	mul	$t1, $t0, SIZEOF_COORDINATE	#   i * sizeof(struct coordinate)
	addi	$t1, $t1, shape_coordinates	#   &shape_coordinates[i]

	li	$v0, 1				#   syscall 1: print_int
	lw	$a0, COORDINATE_X_OFFSET($t1)	#   shape_coordinates[i].x
	syscall					#   printf("%d", shape_coordinates[i].x);

	li	$v0, 4				#   syscall 4: print_string
	la	$a0, str__show_debug_info__coordinates_3
	syscall					#   printf(", ");

	li	$v0, 1				#   syscall 1: print_int
	lw	$a0, COORDINATE_Y_OFFSET($t1)	#   shape_coordinates[i].y
	syscall					#   printf("%d", shape_coordinates[i].y);

	li	$v0, 4				#   syscall 4: print_string
	la	$a0, str__show_debug_info__coordinates_4
	syscall					#   printf(" }\n");

show_debug_info__coord_loop__step:
	addi	$t0, $t0, 1			#   i++;
	b	show_debug_info__coord_loop__cond

show_debug_info__coord_loop__end:		# }

	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__field
	syscall					# printf("\nField:\n");

show_debug_info__row_loop:
show_debug_info__row_loop__init:
	li	$t2, 0				# int row = 0;

show_debug_info__row_loop__cond:		# while (row < FIELD_HEIGHT) {
	bge	$t2, FIELD_HEIGHT, show_debug_info__row_loop__end

show_debug_info__row_loop__body:
	bge	$t2, 10, show_debug_info__print_row
	li	$v0, 11				#  if (row < 10) {
	li	$a0, ' '
	syscall					#     putchar(' ');

show_debug_info__print_row:			#   }
	li	$v0, 1				#   syscall 1: print_int
	move	$a0, $t2
	syscall					#   printf("%d", row);


	li	$v0, 4				#   syscall 4: print_string
	la	$a0, str__show_debug_info__field_indent
	syscall					#   printf(":  ");

show_debug_info__col_loop:
show_debug_info__col_loop__init:
	li	$t3, 0				#   int col = 0;

show_debug_info__col_loop__cond:		#   while (col < FIELD_WIDTH) {
	bge	$t3, FIELD_WIDTH, show_debug_info__col_loop__end

show_debug_info__col_loop__body:
	mul	$t4, $t2, FIELD_WIDTH		#     row * FIELD_WIDTH
	add	$t4, $t4, $t3			#     row * FIELD_WIDTH + col
	addi	$t4, $t4, field			#     &field[row][col]

	li	$v0, 1				#     syscall 1: print_int
	lb	$a0, ($t4)			#     field[row][col]
	syscall					#     printf("%d", field[row][col]);

	li	$v0, 11				#     syscall 11: print_char
	li	$a0, ' '
	syscall					#     putchar(' ');

	lb	$a0, ($t4)			#     field[row][col]
	syscall					#     printf("%c", field[row][col]);

	li	$v0, 11				#     syscall 11: print_char
	li	$a0, ' '
	syscall					#     putchar(' ');

show_debug_info__col_loop__step:
	addi	$t3, $t3, 1			#     i++;
	b	show_debug_info__col_loop__cond

show_debug_info__col_loop__end:			#   }

	li	$v0, 11				#   syscall 11: print_char
	li	$a0, '\n'
	syscall					#   putchar('\n');

show_debug_info__row_loop__step:
	addi	$t2, $t2, 1			#   row++;
	b	show_debug_info__row_loop__cond

show_debug_info__row_loop__end:			# }

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');

show_debug_info__epilogue:
	jr	$ra


################################################################################
# .TEXT <game_loop>
        .text
game_loop:
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [$ra]
        # Uses:     [$t0, $t1, $v0, $a0]
        # Clobbers: [$t0, $t1, $v0, $a0]
        #
        # Locals:
        #   - $t0: copy of game_running
        #   - $t1: char command
        #
        # Structure:
        #   game_loop
        #   -> [prologue]
        #       -> body
        #   -> [epilogue]

game_loop__prologue:
	begin
	push	$ra

game_loop__body:
game_loop__big_loop__cond:
	lw	$t0, game_running
	beqz	$t0, game_loop__big_loop__end		# while (game_running) {

game_loop__big_loop__body:
	jal	print_field				#   print_field();

	li	$v0, 4					#   syscall 4: print_string
	la	$a0, str__game_loop__prompt
	syscall						#   printf("  > ");

	jal	read_char
	move	$t1, $v0				#   command = read_char();

	beq	$t1, 'r', game_loop__command_r		#   if (command == 'r') { ...
	beq	$t1, 'R', game_loop__command_R		#   } else if (command == 'R') { ...
	beq	$t1, 'n', game_loop__command_n		#   } else if (command == 'n') { ...
	beq	$t1, 's', game_loop__command_s		#   } else if (command == 's') { ...
	beq	$t1, 'S', game_loop__command_S		#   } else if (command == 'S') { ...
	beq	$t1, 'a', game_loop__command_a		#   } else if (command == 'a') { ...
	beq	$t1, 'd', game_loop__command_d		#   } else if (command == 'd') { ...
	beq	$t1, 'p', game_loop__command_p		#   } else if (command == 'p') { ...
	beq	$t1, 'c', game_loop__command_c		#   } else if (command == 'c') { ...
	beq	$t1, '?', game_loop__command_question	#   } else if (command == '?') { ...
	beq	$t1, 'q', game_loop__command_q		#   } else if (command == 'q') { ...
	b	game_loop__unknown_command		#   } else { ... }

game_loop__command_r:					#   if (command == 'r') {
	jal	rotate_right				#     rotate_right();

	jal	piece_intersects_field			#     call piece_intersects_field();
	beqz	$v0, game_loop__big_loop__cond		#     if (piece_intersects_field())
	jal	rotate_left				#       rotate_left();

	b	game_loop__big_loop__cond		#   }

game_loop__command_R:					#   else if (command == 'R') {
	jal	rotate_left				#     rotate_left();

	jal	piece_intersects_field			#     call piece_intersects_field();
	beqz	$v0, game_loop__big_loop__cond		#     if (piece_intersects_field())
	jal	rotate_right				#       rotate_right();

	b	game_loop__big_loop__cond		#   }

game_loop__command_n:					#   else if (command == 'n') {
	li	$a0, FALSE				#     argument 0: FALSE
	jal	new_piece				#     new_piece(FALSE);

	b	game_loop__big_loop__cond		#   }

game_loop__command_s:					#   else if (command == 's') {
	li	$a0, 0					#     argument 0: 0
	li	$a1, 1					#     argument 1: 1
	jal	move_piece				#     call move_piece(0, 1);

	bnez	$v0, game_loop__big_loop__cond		#     if (!piece_intersects_field())
	jal	place_piece				#       rotate_left();

	b	game_loop__big_loop__cond		#   }

game_loop__command_S:					#   else if (command == 'S') {
game_loop__hard_drop_loop:
	li	$a0, 0					#     argument 0: 0
	li	$a1, 1					#     argument 1: 1
	jal	move_piece				#     call move_piece(0, 1);
	bnez	$v0, game_loop__hard_drop_loop		#     while (move_piece(0, 1));

	jal	place_piece				#     place_piece();

	b	game_loop__big_loop__cond		#   }

game_loop__command_a:					#   else if (command == 'a') {
	li	$a0, -1					#     argument 0: -1
	li	$a1, 0					#     argument 1: 0
	jal	move_piece				#     move_piece(-1, 0);

	b	game_loop__big_loop__cond		#   }

game_loop__command_d:					#   else if (command == 'd') {
	li	$a0, 1					#     argument 0: 1
	li	$a1, 0					#     argument 1: 0
	jal	move_piece				#     move_piece(1, 0);

	b	game_loop__big_loop__cond		#   }

game_loop__command_p:					#   else if (command == 'p') {
	jal	place_piece				#     place_piece();

	b	game_loop__big_loop__cond		#   }

game_loop__command_c:					#   else if (command == 'c') {
	jal	choose_next_shape			#     choose_next_shape();

	b	game_loop__big_loop__cond		#   }

game_loop__command_question:				#   else if (command == '?') {
	jal	show_debug_info				#     show_debug_info();

	b	game_loop__big_loop__cond		#   }

game_loop__command_q:					#   else if (command == 'q') {
	li	$v0, 4					#     syscall 4: print_string
	la	$a0, str__game_loop__quitting
	syscall						#     printf("Quitting...\n");

	b	game_loop__big_loop__end		#     break;

game_loop__unknown_command:				#   } else {
	li	$v0, 4					#     syscall 4: print_string
	la	$a0, str__game_loop__unknown_command
	syscall						#     printf("Unknown command!\n");

game_loop__big_loop__step:				#   }
	b	game_loop__big_loop__cond

game_loop__big_loop__end:				# }
	li	$v0, 4					# syscall 4: print_string
	la	$a0, str__game_loop__goodbye
	syscall						# printf("\nGoodbye!\n");

game_loop__epilogue:
	pop	$ra
	end

	jr	$ra					# return;


################################################################################
# .TEXT <show_debug_info>
        .text
read_char:
	# NOTE: The implementation of this function is
	#       DIFFERENT from the C code! This is
	#       because mipsy handles input differently
	#       compared to `scanf`. You do not need to
	#       worry about this difference as you will
	#       only be calling this function.
	#
        # Args:     None
        #
        # Returns:  $v0: char
        #
        # Frame:    []
        # Uses:     [$v0]
        # Clobbers: [$v0]
        #
        # Locals:
	#   - $v0: char command
        #
        # Structure:
        #   read_char
        #   -> [prologue]
        #       -> body
        #   -> [epilogue]

read_char__prologue:

read_char__body:
	li	$v0, 12				# syscall 12: read_char
	syscall					# scanf("%c", &command);

read_char__epilogue:
	jr	$ra				# return command;
