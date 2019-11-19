addi $t0, $zero, 5 #a=5 	#0
addi $t1, $zero, 5 #b=5 	#1 (4)
addi $t2, $zero, 0 #sum=0	#2 (8)
addi $t3, $zero, 0 #i=0		#3 (12)




loop:
    beq $t3, $t1, exit# 	#4 (16)
    addi $zero, $zero, 0 #NO OP	#5 (20)
    add $t2, $t2, $t0 #sum += a	#6 (24)
    addi $t3, $t3, 1 #i = i+1	#7 (28)
    j loop			#8 (32)
    addi $zero, $zero, 0 #NO OP	#9 (36)
exit:
   add $v0, $zero, $t2		#10 (40)
