.text
#mult( a,b) unsign
# args; a0 -- a
#       a1 -- b
# res a0 -- a*b
mult:
  li   a1, 342
  li   a0, 436
  li   t0, 0 
 m_loop:
  andi t1, a1, 1 
  beqz t1, m_nonset 
  add  t0, t0, a0 
 
 m_nonset:
  slli a0, a0, 1 
  srai a1, a1, 1 
  bnez a1, m_loop 
  mv a0, t0 
  ret 
