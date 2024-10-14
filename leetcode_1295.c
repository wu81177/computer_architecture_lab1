#include <stdint.h>
#include <stdio.h>

uint32_t div_10(uint32_t in)
{
    uint32_t x = (in | 1) - (in >> 2); /* div = in/10 ==> div = 0.75*in/8 */
    uint32_t q = (x >> 4) + x;
    x = q;
    q = (q >> 8) + x;
    q = (q >> 8) + x;
    q = (q >> 8) + x;
    q = (q >> 8) + x;

    uint32_t div = (q >> 3);
    return div;
}

int log_10(int num) {
    int log = 0;
    while (num >= 10) {
        uint32_t div = div_10(num);
        num = div;
        log++;
    }
    return log;
}

int findNumbers(int* nums, int numsSize) {
    int count = 0;
    for (int i = 0; i < numsSize; i++) {
        int digits_m1 = log_10(nums[i]);
        if (digits_m1 & 1) count++;
    }
    return count;
}

int main() {
    int nums1[] = {12, 345, 2, 6, 7896};
    int nums2[] = {555, 901, 482, 1771};
    int nums3[] = {1234, 56789, 0, 88, 2020, 1, 12, 425, 56436, 235457, 5415, 454, 2, 0};
    int expect_num_result[] = {2, 1, 6};
    int num_results[3];

    int numsSize1 = 5;
    num_results[0] = findNumbers(nums1, numsSize1);

    int numsSize2 = 4;
    num_results[1] = findNumbers(nums2, numsSize2);

    int numsSize3 = 14;
    num_results[2] = findNumbers(nums3, numsSize3);

    for (int i = 0; i < 3; i++) {
        if (num_results[i] != expect_num_result[i]) {
            printf("Test #%d Fail.\n",i+1);
        } else {
            printf("Test #%d Pass.\n",i+1);
        }
    }

    return 0;
}