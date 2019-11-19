addi $t0, $zero, 6 #initial a value
addi $t1, $zero, 4 # initial b value

add $t2, $zero, $t0 # sets a, will change
add $t3, $zero, $t1 # sets b, will change 

while:
beq $t2, $t3, exit # once the two are equal, stop 
addi $zero, $zero, 0 #NO OP	#9 (36)

slt $t4, $t2, $t3 # If a is less than be, write that down
addi $zero, $zero, 0 #NO OP	#9 (36)
beq $t4, 1, a_case
addi $zero, $zero, 0 #NO OP	#9 (36)
#b is smaller 
add $t3, $t3, $t1
j skip_else
addi $zero, $zero, 0 #NO OP	#9 (36)


a_case:# a is smaller
add $t2, $t2, $t0
skip_else:

j while
addi $zero, $zero, 0 #NO OP	#9 (36)
exit:
add $v0, $t2, $zero
