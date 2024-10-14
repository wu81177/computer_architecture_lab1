    .data
test_values:
    .word 0x402DF3B6, 0x7F800000, 0xFFC00000

expected_bf16:
    .half 0x402E, 0x7F80, 0xFFC0

expected_recovered:
    .word 0x402E0000, 0x7F800000, 0xFFC00000

result:
    .byte 0, 0, 0, 0, 0, 0

    .text
main:
    la s0, test_values
    la s1, expected_bf16
    la s2, expected_recovered
    la s3, result
    li s4, 3                   # i bound
    li s5, 0                   # i init

loop:
    lw a0, 0(s0)
    call fp32_to_bf16
    lhu t1, 0(s1)
    bne a0, t1, nmatch_bf16
    li t1, 1
    sb t1, 0(s3)
    
nmatch_bf16:  
    call bf16_to_fp32
    lw t1, 0(s2)
    addi s3, s3, 1
    bne a0, t1, next_iteration
    li t1, 1
    sb t1, 0(s3) 
      
next_iteration:
    addi s0, s0, 4
    addi s1, s1, 2
    addi s2, s2, 4
    addi s3, s3, 1

    addi s5, s5, 1
    blt s5, s4, loop
    
    call print_result
    li a7, 93
    ecall
    
print_result:
    la t0, result
    addi t1, t0, 6
    
print_loop:
    lb a0, 0(t0)
    addi a0, a0, 48   # 0 or 1 in ASCII
    li a7, 11
    ecall
    addi t0, t0, 1
    bltu t0, t1, print_loop
    ret
    
bf16_to_fp32:
    slli t0, a0, 16
    mv a0, t0
    ret

fp32_to_bf16:
    mv t0, a0
    li t1, 0x7fffffff
    and t2, t0, t1

    li t1, 0x7f800000
    bltu t1, t2, nan_case

    li t1, 0x7fff
    srli t2, t0, 16
    andi t3, t2, 1
    add t1, t1, t3
    add t0, t0, t1
    srli t0, t0, 16
    mv a0, t0
    ret

nan_case:
    srli t0, t0, 16
    ori t0, t0, 64
    mv a0, t0
    ret
