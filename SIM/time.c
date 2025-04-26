/*
 * @Author       : Xu Xiaokang
 * @Email        :
 * @Date         : 2025-04-26 14:10:20
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2025-04-26 22:51:49
 * @Filename     :
 * @Description  :
 */

#include <stdio.h>

#if defined(_WIN32)
#include <windows.h>
#else
#include <sys/time.h>
#endif

long long get_system_time() {
    #if defined(_WIN32)
        FILETIME ft;
        GetSystemTimeAsFileTime(&ft);
        ULARGE_INTEGER uli;
        uli.LowPart = ft.dwLowDateTime;
        uli.HighPart = ft.dwHighDateTime;
        // 转换为 1970-01-01 基准的微秒数
        const long long EPOCH_OFFSET = 116444736000000000LL; // 1601至1970的100ns间隔
        return (uli.QuadPart - EPOCH_OFFSET) / 10; // 100ns -> μs
    #else
        struct timeval tv;
        gettimeofday(&tv, NULL);
        return (long long)tv.tv_sec * 1000000 + tv.tv_usec;
    #endif
}