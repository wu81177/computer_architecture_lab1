#include <stdint.h>
#include <stdio.h>
#include <math.h>
#include <stdbool.h>

typedef struct {
    uint16_t bits;
} bf16_t;

static inline float bf16_to_fp32(bf16_t h)
{
    union {
        float f;
        uint32_t i;
    } u = {.i = (uint32_t)h.bits << 16};
    return u.f;
}

static inline bf16_t fp32_to_bf16(float s)
{
    bf16_t h;
    union {
        float f;
        uint32_t i;
    } u = {.f = s};
    if ((u.i & 0x7fffffff) > 0x7f800000) { /* NaN */
        h.bits = (u.i >> 16) | 64;         /* force to quiet */
        return h;                                
    }
    h.bits = (u.i + (0x7fff + ((u.i >> 0x10) & 1))) >> 0x10;
    return h;
}

int main() {
    float test_values[3] = {2.718f, INFINITY, 0.0f / 0.0f}; //0x402DF3B6, 0x7F800000, 0xFFC00000
    uint16_t expected_bf16[3] = {0x402E, 0x7f80, 0xFFC0};
    uint32_t expected_recovered[3] = {0x402E0000, 0x7F800000, 0xFFC00000};
    bool result[6] = {0};
    for (int i = 0; i < 3; i++) {
        float original = test_values[i];
        bf16_t bf16_value = fp32_to_bf16(original);
        if(bf16_value.bits == expected_bf16[i]) result[2*i] = 1;
        float recovered = bf16_to_fp32(bf16_value);
        if(*(uint32_t*)&recovered == expected_recovered[i]) result[2*i+1] =1;
    }
    for (int i = 0; i < 6; i++) printf("%d",result[i]);
    return 0;
}