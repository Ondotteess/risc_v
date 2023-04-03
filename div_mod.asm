.text
main:
	call readDecimal# a0=x
	second_fun:
		addi sp,sp,-4
		sw a0, 4(sp)
		addi sp,sp,-4
	  call  div10  #a0=div10(x)
	  call printDecimal
	  addi,sp,sp,4
	  lw a0, 4(sp)
	  call mod10
	  call printDecimal
	  li a7, 93
		ecall


#a0=readDecimal
readDecimal:
	#a3=0 result
	li a7,12 #a0=c
	ecall
	li a1,10# a1=enter||a1=10
	bne  a0,a1, continue# c=enter?
	mv a0,a3
	j second_fun
continue:
	mv t1,a0 #t1=c
	li t6,48# символ в йифру
	sub t1,t1,t6
	mv s11,t1
	mv a0,a3 #a0=0,a*10,a*100+b*10
	call mult
	add a3, a0,s11
	call readDecimal
	
	
#printDecimal(a0)
printDecimal:
	sw a0, 4(sp)
	addi sp,sp,-4
	li a1,10 #a1=10
	bgeu a0,a1,first# if x>=10
	j second# if x<10
	addi sp,sp,4
	lw a0,4(sp)
	ret
first:
		sw a0, 4(sp)
		addi sp,sp,-4
		sw ra,4(sp)
		addi sp,sp,-4
		call mod10
		addi sp,sp,4
		lw ra,4(sp)
		call second
		addi sp,sp,4
		lw a0, 4(sp)
		sw ra,4(sp)
		addi sp,sp,-4
		call div10 #a0=x/10
		addi sp,sp,4
		lw ra,4(sp)
		
		sw ra,4(sp)
		addi sp,sp,-4
		call printDecimal
		addi sp,sp,4
		lw ra,4(sp)
		ret
second:
  li s11,48
  add a0,a0,s11
	li a7,11
	ecall
	sub a0,a0,s11
	ret
#mod10(x)
mod10:
	sw a0,4(sp)
	addi,sp,sp,-4
	
	sw ra, 4(sp)
  addi, sp,sp,-4
  call div10 #a0= f(x/2)
  addi sp,sp,4
  lw ra,4(sp)
	
	li a1,10 
	#a= x/10, b=10
	sw ra, 4(sp)
  addi, sp,sp,-4
  call mult #a0= f(x/2) a0=10 * div10(x)
  addi sp,sp,4
  lw ra,4(sp)
  mv t0,a0
  addi sp,sp,4
  lw a0,4(sp)
	sub a0,a0,t0
	ret
#div( a,10) unsign
# args; a0 --?
#       a1 --10
# res   a0 -- a/b
div10:
	li a1,10
	bgeu a0,a1, recur# x>=10
  # x<10
  li a0, 0
  ret
  recur:# x>=10
  	sw a0,4(sp)
  	addi sp,sp,-4
  	srli a0,a0,1 # a0=x/2
  	sw ra, 4(sp)
  	addi, sp,sp,-4
  	call div10 #a0= f(x/2)
  	addi sp,sp,4
  	lw ra,4(sp)
  	mv t0,a0
  	addi sp,sp,4
  	lw a0,4(sp)
  	srli t1,a0,2# a0=x/4
  	sub a0,t1,t0
  	srli a0,a0,1
  	ret

#mul( a,b) unsign
# args; a0 --?
#       a1 --b
# res a0 -- a*b
mult:
  li   t0, 0 
 m_loop:
  andi t1, a1, 1 # ????????? ???? ?? ? ??? ???????? ? ?????
  beqz t1, m_nonset # ???? ? t1 ????, ?? ???? ? nonset
  add  t0, t0, a0 # 
 
 m_nonset:
  slli a0, a0, 1 #
  srai a1, a1, 1 # 
  bnez a1, m_loop # ???? ?? ???? ? ?1, ?? ??????? ? m_loop
  mv a0, t0 # ???????? ? ??????? ?0 ??????? t0
  ret # ???????????? ?? ??????? ????, ?????? ??????? (??? ??? call)
