#Chuong trinh: Selection Sort
#Data segment
	.data
#Cac dinh nghia bien
	arr: .space 40 # Du lieu cua mang 10 phan tu
	size: .word 10 # So phan tu trong mang
#Cac cau nhac nhap du lieu
	waiting: .asciiz "Dang doc du lieu...\n"
	result: .asciiz "Mang sau khi sap xep la: "
	filename: .asciiz "INT10.BIN"
	space: .asciiz " "
	newline: .asciiz "\n"
	successMsg: .asciiz "Mo file thanh cong!\n"
	errorMsg: .asciiz "Co loi, hay thu lai!\n"
	
#Code segment
	.text
main:	
#Nhap (syscall)
	# Mo file
openFile:
	li $v0, 4
	la $a0, waiting
	syscall
	addi $v0, $zero, 13
	la $a0, filename
	li $a1, 0 # Che do doc
	li $a2, 0 # Quyen truy cap mac dinh
	syscall
	move $t0, $v0 #T0 chua dia chi file 
	
	bltz $t0, errorOpenFile #T0 < 0 thi mo file loi
	bgez $t0, successOpenFile #  T0 >= 0 thi mo thanh cong
	
readFile:	# Doc file
	addi $v0, $zero, 14
	move $a0, $t0
	la $a1, arr
	li $a2, 40
	syscall
	move $t1, $v0	
	
	bltz $t1, errorOpenFile  # Neu T1 < 0 thi doc loi
	beqz $t1, closeFile # T1 == 0 thi doc thanh cong
	
	# Dong file sau khi doc thanh cong
closeFile:
	li $v0, 16
	move $a0, $t0
	syscall
#Xu ly
	
	    # Print array before sorting
    move $s4, $zero            # i = 0
    la $t0, arr                # Base address of array

printArrayBeforeSort:
    bge $s4, $t1, endPrintArrayBeforeSort # If i >= size, exit print loop

    sll $t2, $s4, 2            # i * 4
    add $t3, $t0, $t2          # Address of arr[i]
    lw $a0, 0($t3)             # Load arr[i]
    li $v0, 1
    syscall                    # Print arr[i]

    # Print space between elements
    la $a0, space
    li $v0, 4
    syscall

    addi $s4, $s4, 1           # i++
    j printArrayBeforeSort

endPrintArrayBeforeSort:
    # Print newline after array
    la $a0, newline
    li $v0, 4
    syscall



	# Goi Selection Sort sau khi doc mang
	la $a0, arr             # base address cua mang
	la $a1, size            # kích thuoc mang
	lw $a1, 0($a1)          # load kich thuoc mang vào $a1
	
	
	
	jal selectionSort	# Goi hàm Selection Sort
	

#ket thuc chuong trinh (syscall)
Kthuc:	addi	$v0, $zero, 10
		syscall
# -------------------------------	
# Cac chuong trinh khac
# -------------------------------

# Thong bao mo file thanh cong
successOpenFile:   addi $v0, $zero, 4
			la $a0, newline
			syscall
    			la $a0, successMsg
    			syscall
    			j readFile

# Thong bao loi
errorOpenFile:   addi $v0, $zero, 4
    			la $a0, errorMsg
    			syscall
    			j Kthuc	

# -------------------------------
# Selection Sort 
# -------------------------------
selectionSort:   
	addi $sp, $sp, -20        # Tao khong gian tren stack
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	move $s0, $a0            # Base address cua mang
	move $s1, $zero           # i = 0
	subi $s2, $a1, 1          # size - 1

iFor:
	bge $s1, $s2, iForExit  # Neu i >= size - 1 thì thoát

	move $a0, $s0            # base address
	move $a1, $s1            # i
	move $a2, $s2            # size - 1
	jal mini

	move $s3, $v0            # return value cua mini

	move $a0, $s0            # mang
	move $a1, $s1            # i
	move $a2, $s3            # mini
	jal swap

	# Xuat ket qua
	la $a0, result          # "Mang sau khi sap xep la: "
	li $v0, 4
	syscall	
			
# In ra mang sau khi sap xep
	move $s4, $zero          # i = 0
	la $t0, arr	
	printArray:
		la $t0, arr
		bge $s4, $a1, endPrintArray
		
		sll $t2, $s4, 2         # i * 4
		add $t3, $t0, $t2       # T3 = &arr[i]
		lw $a0, 0($t3)          # lay gia tri arr[i]
		
		li $v0, 1
		syscall
		
		la $a0, space
		li $v0, 4
		syscall
		
		addi $s4, $s4, 1         # i++
		j printArray
	endPrintArray:	
		la $a0, newline
		li $v0, 4
		syscall

	addi $s1, $s1, 1          # i++
	j iFor               # quay lai vong lap

iForExit:
	lw $ra, 0($sp)            # Khoi phuc gia tri tu stack
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20         # Khoi phuc stack pointer
	jr $ra                    # Tra ve

# -------------------------------
# Ham tim index phan tu nho nhat (mini)
# -------------------------------
mini:   
	move $t0, $a0            # base cua mang
	move $t1, $a1            # mini = first = i
	move $t2, $a2            # last

	sll $t3, $t1, 2          # first * 4
	add $t3, $t3, $t0        # index = base array + first * 4
	lw $t4, 0($t3)           # min = v[first]

	addi $t5, $t1, 1          # i = 0
miniFor:
	bgt $t5, $t2, miniEnd    # Neu i > last thì thoat

	sll $t6, $t5, 2          # i * 4
	add $t6, $t6, $t0        # index = base array + i * 4
	lw $t7, 0($t6)           # v[index]

	bge $t7, $t4, miniIfExit # Neu v[i] >= min thì bo qua

	move $t1, $t5            # mini = i
	move $t4, $t7            # min = v[i]

miniIfExit:
	addi $t5, $t5, 1          # i++
	j miniFor

miniEnd:
	move $v0, $t1            # tro ve mini
	jr $ra

# -------------------------------
# Ham hoan doi phan tu (swap)
# -------------------------------
swap:   
	sll $t1, $a1, 2          # i * 4
	add $t1, $a0, $t1        # v + i * 4
	
	sll $t2, $a2, 2          # j * 4
	add $t2, $a0, $t2        # v + j * 4

	lw $t0, 0($t1)           # v[i]
	lw $t3, 0($t2)           # v[j]

	sw $t3, 0($t1)           # v[i] = v[j]
	sw $t0, 0($t2)           # v[j] = $t0

	jr $ra
