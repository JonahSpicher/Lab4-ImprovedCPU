addi $sp, $zero, 0x3ffc
addi $t0, $zero, 4
addi $t1, $zero, 7
addi $zero, $zero, 0
addi $zero, $zero, 0
addi $zero, $zero, 0
addi $zero, $zero, 0
sub $t3, $t1, $t0
addi $zero, $zero, 0
addi $zero, $zero, 0
addi $zero, $zero, 0
addi $zero, $zero, 0
addi $sp, $sp, -4
sw $t3, 0($sp)
j skip
addi $t0, $zero, 15
addi $t1, $zero, 15
skip:
add $t4, $t0, $t3
addi $zero, $zero, 0
addi $zero, $zero, 0
lw $t4, 0($sp)
addi $sp, $sp, 4
