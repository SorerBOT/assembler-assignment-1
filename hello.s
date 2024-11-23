.section .data
user_seed:
	.quad 0
current_rnd_number:
	.quad 0
user_guess:
	.quad 0
is_easy_mode_char:
	.byte 0
space_eater_char:
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
incorrect_str_EOL:
	.string "Incorrect.\n"
game_over_lost_str:
	.string "Game over, you lost :(. The correct answer was "
game_over_win_str:
	.string "Congratz! You won 1 rounds!"
double_or_nothing_str:
	.string "Double or nothing! Would you like to continue to another round? (y/n) "
# formats
quad_fmt:
	.string "%ld"
uint_fmt:
	.string "%u"
long_fmt:
	.string "%d"
char_fmt:
	.string "%c"

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
	# Get Random Number Between 1 and N
	xorq	%rax, %rax
	call	get_rand_number_under_N
	movq	%rax, current_rnd_number(%rip)
	# Prompting User to Guess
	movq	$what_is_your_guess_str, %rdi
	xorq	%rax, %rax
	call	printf
	# Reading User Guess
	movq	$quad_fmt, %rdi
	leaq	user_guess(%rip), %rsi
	xorq	%rax, %rax
	call	scanf

	# test
	movq	$quad_fmt, %rdi
	movq	current_rnd_number(%rip), %rsi
	xorq	%rax, %rax
	call	printf

	xorq	%rax, %rax
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
	movq	%rdi, %rax         # Dividend in %rax
	xorq	%rdx, %rdx         # Clear %rdx (upper half of dividend for unsigned division)
	divq	N(%rip)            # Divide %rdx:%rax by N
	                          # Quotient in %rax, remainder in %rdx

	# Return remainder
	movq	%rdx, %rax         # Move remainder to %rax (return value)

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
