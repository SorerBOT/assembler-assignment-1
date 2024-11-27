.section .data
user_seed:
	.quad 0
current_rnd_number:
	.quad 0
user_guess:
	.quad 0
rounds_won:
	.quad 0
is_easy_mode_char:
	.byte 0
space_eater_char:
	.byte 0
is_double_or_nothing_char:
	.byte 0
# miscellaneous
N:
	.quad 10
M:
	.quad 5

.section .rodata
# game-texts
welcome_str:
	.string "Enter configuration seed: "
easy_mode_str:
	.string "Would you like to play in easy mode? (y/n) "
what_is_your_guess_str:
	.string "What is your guess? "
incorrect_str:
	.string "Incorrect. "
game_over_lost_str:
	.string "Incorrect.\nGame over, you lost :(. The correct answer was %ld\n"
game_over_win_str:
	.string "Congratz! You won %ld rounds!\n"
double_or_nothing_str:
	.string "Double or nothing! Would you like to continue to another round? (y/n) "
lower_str:
	.string "Your guess was below the actual number ...\n"
higher_str:
	.string "Your guess was above the actual number ...\n"
# formats
quad_fmt:
	.string "%ld"
uint_fmt:
	.string "%u"
long_fmt:
	.string "%d"
char_fmt:
	.string "%c"
# constants
yes_variable:
	.byte 'y'
.section .text
.globl  main
.type	main, @function
main:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# Welcome Prompt
	movq	$welcome_str, %rdi
	xorq	%rax, %rax
	call	printf

	# Seed Prompt
	movq	$quad_fmt, %rdi
	leaq	user_seed(%rip), %rsi
	xorq	%rax, %rax
	call	scanf

	# Easy Mode Prompt
	movq	$easy_mode_str, %rdi
	xorq	%rax, %rax
	call	printf
	# Read Easy Mode Answer
	# Eating space
	xorq	%rax, %rax
	call	eat_space
	# Reading Easy Mode Answer
	movq	$char_fmt, %rdi
	leaq	is_easy_mode_char(%rip), %rsi
	xorq	%rax, %rax
	call	scanf
	# initialise current_random_number
	call	initialise_current_random_number
	# play round
	xorq	%rax, %rax
	call	play_game
	# test
	# movq	$quad_fmt, %rdi
	# movq	%rax, %rsi
	# xorq	%rax, %rax
	# call	printf

	movq	%rbp, %rsp
	popq	%rbp
	ret

.globl	eat_space
.type	eat_space, @function
eat_space:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	movq	$char_fmt, %rdi
	leaq	space_eater_char(%rip), %rsi
	xorq	%rax, %rax
	call	scanf

	# epilogue
	xorq	%rax, %rax
	movq	%rbp, %rsp
	popq	%rbp
	ret

.globl	get_mod_N
.type	get_mod_N, @function
get_mod_N:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# Prepare for division
	movq	%rdi, %rax
	xorq	%rdx, %rdx
	divq	N(%rip)

	# Return remainder
	movq	%rdx, %rax

	# Epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret

.globl	get_rand_number_under_N
.type	get_rand_number_under_N, @function
get_rand_number_under_N:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# Generating a Random Number
	movq	user_seed(%rip), %rdi
	xorq	%rax, %rax
	call	srand
	# Retrieving Random Number
	xorq	%rax, %rax
	call	rand
	# Get mod N
	movq	%rax, %rdi
	xorq	%rax, %rax
	call	get_mod_N
	# Increment by ONE
	incq	%rax
	# Epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret

.globl	play_game
.type	play_game, @function
play_game:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	game_loop:
		cmpq	$0, M(%rip)
		je		game_over_lose
		jl		game_over_win
		jg		another_guess

	game_over_lose:
		movq	$game_over_lost_str, %rdi
		movq	current_rnd_number, %rsi
		call	printf
		jmp		epilogue

	game_over_win:
		movq	$game_over_win_str, %rdi
		movq	rounds_won(%rip), %rsi
		call	printf
		jmp		epilogue
	another_guess:
		call	play_guess
		jmp		game_loop

	# epilogue
	epilogue:
		movq	%rbp, %rsp
		popq	%rbp
		ret

.globl	play_guess
.type	play_guess, @function
play_guess:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# decrement M
	decq	M(%rip)
	# Prompting User to Guess
	movq	$what_is_your_guess_str, %rdi
	xorq	%rax, %rax
	call	printf
	# Reading User Guess
	movq	$quad_fmt, %rdi
	leaq	user_guess(%rip), %rsi
	xorq	%rax, %rax
	call	scanf

	movq	current_rnd_number(%rip), %rdi
	movq	user_guess(%rip), %rsi

	cmpq	%rdi, %rsi
	je		equal_case
	jmp		not_equal_case

	equal_case:
		incq	rounds_won
		call	double_or_nothing
		jmp		epilogue_1

	not_equal_case:
		cmpq	$0, M(%rip)
		je		epilogue_1
		movq	$incorrect_str, %rdi
		call	printf
		call	easy_mode

	# epilogue
	epilogue_1:
		movq	%rbp, %rsp
		popq	%rbp
		ret

.globl double_or_nothing
.type  double_or_nothing, @function
double_or_nothing:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	movq	$double_or_nothing_str, %rdi
	call	printf

	# eat space
	call	eat_space
	# scan result
	movq	$char_fmt, %rdi
	leaq	is_double_or_nothing_char(%rip), %rsi
	call	scanf
	# compare
	movb	is_double_or_nothing_char(%rip), %al
	cmpb	$'y', %al
	je		yes
	jmp		no

	yes:
		movq	$5, M(%rip)
		# multiply N
		movq	N(%rip), %rax
		movq	$2, %rbx
		mulq	%rbx
		movq	%rax, N(%rip)
		# multiply seed
		movq	user_seed(%rip), %rax
		movq	$2, %rbx
		mulq	%rbx
		movq	%rax, user_seed(%rip)
		# generate new current_random_number
		call	initialise_current_random_number
		jmp		epilogue_3
	no:
		movq	$-1, M(%rip)

	epilogue_3:
		movq	%rbp, %rsp
		popq	%rbp
		ret

.globl initialise_current_random_number
.type  initialise_current_random_number, @function
initialise_current_random_number:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp
	# Get Random Number Between 1 and N
	xorq	%rax, %rax
	call	get_rand_number_under_N
	movq	%rax, current_rnd_number(%rip)
	# reset %rax
	xorq	%rax, %rax
	# epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret

.globl	easy_mode
.type	easy_mode, @function
easy_mode:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	movb	is_easy_mode_char(%rip), %al
	cmpb	$'y', %al
	je		yes_2
	jmp 	epilogue_4

	yes_2:
		movq	current_rnd_number(%rip), %rax
		cmpq	user_guess(%rip), %rax
		jg		printLower
		jl		printHigher

		printLower:
			movq	$lower_str, %rdi
			call	printf
			jmp epilogue_4
		printHigher:
			movq	$higher_str, %rdi
			call	printf
			jmp epilogue_4
	# epilogue
	epilogue_4:
		movq	%rbp, %rsp
		popq	%rbp
		ret
