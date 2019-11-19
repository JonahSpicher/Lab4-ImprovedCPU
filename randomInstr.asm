addi $t1, $zero, 5
addi $t0, $zero, 5
addi $zero, $zero, 0 #NO OP	#5 (20)
addi $zero, $zero, 0 #NO OP	#5 (20)
addi $zero, $zero, 0 #NO OP	#5 (20)
beq $t1, $t0, exit
addi $zero, $zero, 0 #NO OP	#5 (20)
j no

exit:
slt $t4, $t0, $t2
no: