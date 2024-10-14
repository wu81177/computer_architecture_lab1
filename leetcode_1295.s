    .data
msg_pass: .asciz ": Test Pass.\n"
msg_fail: .asciz ": Test Fail.\n"

nums1: .word 12, 345, 2, 6, 7896
nums2: .word 555, 901, 482, 1771
nums3: .word 1234, 56789, 0, 88, 2020, 1, 12, 425, 56436, 235457, 5415, 454, 2, 0
expect_num_result: .word 2, 1, 6
num_results: .word 0, 0, 0
    .text
main:
    # Test 1
    la a0, nums1
    li a1, 5
    addi sp, sp, -4
    sw ra, 0(sp)
    call findNumbers
    lw ra, 0(sp)
    addi sp, sp, 4
    la t0, num_results
    sw a0, 0(t0)

    # Test 2
    la a0, nums2
    li a1, 4
    addi sp, sp, -4
    sw ra, 0(sp)
    call findNumbers
    lw ra, 0(sp)
    addi sp, sp, 4
    la t0, num_results
    sw a0, 4(t0)

    # Test 3
    la a0, nums3
    li a1, 14
    addi sp, sp, -4
    sw ra, 0(sp)
    call findNumbers
    lw ra, 0(sp)
    addi sp, sp, 4
    la t0, num_results
    sw a0, 8(t0)

    # Print test results
    li s0, 0            # i = 0
    li s1, 3            # i boundary
    la s4, expect_num_result
    la s5, num_results
print_loop:
    bge s0, s1, end_loop
    lw t0, 0(s5)        # result data
    lw t1, 0(s4)        # expected data
    beq t0, t1, pass
# fail
    mv a0, s0
    addi a0, a0, 1
    li a7, 1
    ecall
    la a0, msg_fail
    li a7, 4
    ecall
    j next
pass:
    mv a0, s0
    addi a0, a0, 1
    li a7, 1
    ecall
    la a0, msg_pass
    li a7, 4
    ecall
    j next

next:
    addi s0, s0, 1
    addi s4, s4, 4
    addi s5, s5, 4
    j print_loop

end_loop:
    li a7, 93
    ecall

div_10:
    # x = (in | 1) - (in >> 2)
    ori t0, a0, 1
    srli t1, a0, 2
    sub t0, t0, t1

    # q = (x >> 4) + x
    srli t1, t0, 4
    add t0, t0, t1

    mv t1, t0

    # q = (q >> 8) + x (4 times)
    li t3, 4
loop_q:
    srli t2, t1, 8
    add t1, t0, t2
    addi t3, t3, -1
    bnez t3, loop_q

    # *div = q >> 3
    srli a0, t1, 3
    ret

log_10:
    li s1, 10
    li s4, 0    #log
while_loop:
    bge a0, s1, div_step
    mv a0, s4
    ret

div_step:
    addi sp, sp, -4
    sw ra, 0(sp)
    call div_10
    lw ra, 0(sp)
    addi sp, sp, 4
    addi s4, s4, 1
    j while_loop

findNumbers:
    li s2, 0            # count = 0
    li s0, 0            # i
    mv s3, a0           # array address

find_loop:
    bge s0, a1, end_fn

    lw a0, 0(s3)
    # digits = log_10(nums[i]) + 1
    addi sp, sp, -4
    sw ra, 0(sp)
    call log_10
    lw ra, 0(sp)
    addi sp, sp, 4

    # if (digits_m1 & 1) count++
    andi t4, a0, 1      # t4 = digits_m1 & 1
    beq t4, x0, skip_add

    addi s2, s2, 1

skip_add:
    addi s3, s3, 4      # address + 4
    addi s0, s0, 1
    j find_loop

end_fn:
    mv a0, s2
    ret
