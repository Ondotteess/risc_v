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
  li t4, 4				# << 4
  li t2, 10				# ascii code 'enter'
  li t3, 45			  	# ascii code '-'
  li t0, 0				# result
  li t5, 43				# ascii code '+'
  cycle_read_number:
    read_char t1			# read char
    beq t1, t3, add_plus		# add sign
    beq t1, t5, add_minus
    beq t1, t2, end_read_number		# check enter
    li  s1, '0'				# to take int		
    sub t1, t1, s1			# convert to int
    bgt t2, t1, add_to_result		# not in 0-9
    li  s1, 7				# for 0-9 to take int
    sub t1, t1, s1
  add_to_result:
    sll t0, t0, t4			# t0 << 4
    add t0, t0, t1			# result + current
    j   cycle_read_number
    
  add_minus:				# add sign
    addi t0, t0, 10
    sll  t0, t0, t4 
    j cycle_read_number
    
  add_plus:
    addi t0, t0, 11
    j cycle_read_number
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
  li  t4, 0			#  to add extra one
  li  a4, 0			#  return value
  li  t0, 15 			#  mask
  li  t3, 10			#  to check if sum >= 10
  li  t5, 0			#  to shift taken nums
  
  plus_algo:
    and  t1, a1, t0		#  take num of 1st
    srl  t1, t1, t5		#  shift num of 1st
    and  t2, a2, t0		#  take num of 2nd
    srl  t2, t2, t5		#  shift num of 2nd
    
    add  t1, t1, t2		#  sum 1st and 2nd younger digits
    add  t1, t1, t4		#  add extra one
    li   t4, 0			#  update extra one register
  
    blt  t1, t3, do_not_add_extra_one

    li  t4, 1			#  add 1 if sum >= 10
    sub t1, t1, t3		#  sum - 10 if sum >= 10
    do_not_add_extra_one:
      sll  t1, t1, t5		#  shift sum of taken nums
  
      add   a4, a4, t1 		#  add sum and shifted result 
      addi  t5, t5, 4		#  shift += 4
    
      slli  t0, t0, 4		#  shift mask
      
      blez t0, exit
    
      j plus_algo
 
  
minus:
  li  a4, 0 		#  result
  li  t3, 28		#  to shift
  bgt a1, a2, cycle_minus
  
  mv  a3, a1
  mv  a1, a2
  mv  a2, a3
  li  a3, 0
  
  cycle_minus:
    slli a4, a4, 4	#  shift result
    
    srl  a5, a1, t3     #  take first num of first
    srl  a6, a2, t3	#  take first num of second
    
    sub  t1, a5, a6	#  calc difference
    
    bgez t1, minus1	
    addi t1, t1, -6	#  if less than zero -6
    
    minus1:
    sll  a5, a5, t3	#  shift taken nums
    sll  a6, a6, t3	
    
    add  a4, a4, t1	 #  add difference to result
    sub  a1, a1, a5	 #  sub shifted taken num from first
    sub  a2, a2, a6	 #  sub shifted taken num from first
    addi t3, t3, -4	 #  sub 4 from shift register
    bgez t3, cycle_minus 
  j exit
    
    
    
_and:
  and a4, a1, a2
  j exit
_or:
  or a4, a1, a2
  j exit

exit:
  

  li s10, 70
  li s9, 13
  li a2, 28	            	    #  32 - 28 = 4 :   higher digit
  li a3, 4			    #  for decrease shift
  li a6, 10			    #  for check 0-9 or A-F
  li t0, -1			    #  for exit
  li a7, 15
  cycle_exit:
    srl  a5, a4, a2    	            #  take higher digit
    mv   t2, a5
    sll  t2, t2, a2
    bgt  a6, a5, print_char         #  check in A-F
    addi a5, a5, 7		    #  if in 0-9 -> +7
  print_char:
    li  a1, '0'
    add a5, a5, a1	 	    #  take ascii code
    bne a5, s10, some_mark
    sub a5, a5, s9
    some_mark:
      print_char a5		    #  print
      sub a4, a4, t2		    #  next digit
      sub a2, a2, a3  		    #  a2 -= 4
      blt t0, a2, cycle_exit	    #  exit
      exit 0
 
