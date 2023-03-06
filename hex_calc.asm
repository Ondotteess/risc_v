.text
.macro exit %ecode
  li a0, %ecode
  li a7, 93
  ecall
.end_macro
.macro read_char %dst
  li a7, 12
  ecall
  mv %dst, a0
.end_macro
.macro print_char %src
  mv a0, %src
  li a7, 11
  ecall
.end_macro

.macro read_number %src
  li t2, 10				# ascii code 'enter'
  li t0, 0				# result
  cycle_read_number:
    read_char t1			# read char
    beq t1, t2, end_read_number		# check enter
    li  s1, '0'				# to take int		
    sub t1, t1, s1			# convert to int
    bgt t2, t1, add_to_result		# not in 0-9
    li  s1, 7				# for 0-9 to take int
    sub t1, t1, s1
  add_to_result:
    li  s2, 4
    sll t0, t0, s2  			# t0 * 2^4
    add t0, t0, t1			# result + current
    j   cycle_read_number
  end_read_number:
    mv %src, t0
.end_macro

main:
  read_number a1
  read_number a2
  read_char a3
  
  li a4, '+'  
  beq  a3, a4, plus
  li a4, '-'
  beq  a3, a4, minus
  li a4, '&'
  beq  a3, a4, _and
  li a4, '|'
  beq  a3, a4, _or
  
plus:
  add a4, a1, a2
  j exit
minus:
  sub a4, a1, a2
  j exit
_and:
  and a4, a1, a2
  j exit
_or:
  or a4, a1, a2
  j exit

exit:
  li a2, 28	            	    #  32 - 28 = 4 :   higher digit
  li a3, 4			    #  for decrease shift
  li a6, 10			    #  for check 0-9 or A-F
  li t0, -1			    #  for exit
  cycle_exit:
    srl  a5, a4, a2    	            #  take higher digit
    mv   t2, a5
    sll  t2, t2, a2
    bgt  a6, a5, print_char_mark    #  check in A-F
    addi a5, a5, 7		    #  if in 0-9 -> +7
  print_char_mark:
    li  a1, '0'
    add a5, a5, a1	 	    #  take ascii code
    print_char a5		    #  print
    sub a4, a4, t2		    #  next digit
    sub a2, a2, a3  		    #  a2 -= 4
    blt t0, a2, cycle_exit	    #  exit
    exit 0
