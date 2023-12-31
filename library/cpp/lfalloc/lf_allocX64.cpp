#include "lf_allocX64.h"

//__arm__ id defined in clang for 32-bit ARM architectures only
#if defined(__arm__) && !defined(__aarch64__)
#error This allocator does not support 32-bit architectures. Please use another allocator instead!
#endif

//////////////////////////////////////////////////////////////////////////
// hooks
#if defined(USE_INTELCC) || defined(_darwin_) || defined(_freebsd_) || defined(_STLPORT_VERSION)
#define OP_THROWNOTHING noexcept
#else
#define OP_THROWNOTHING
#endif

#ifndef _darwin_
#if !defined(YMAKE)
void* operator new(size_t size) {
    return LFAlloc(size);
}

void* operator new(size_t size, const std::nothrow_t&) OP_THROWNOTHING {
    return LFAlloc(size);
}

void operator delete(void* p)OP_THROWNOTHING {
    LFFree(p);
}

void operator delete(void* p, const std::nothrow_t&)OP_THROWNOTHING {
    LFFree(p);
}

void* operator new[](size_t size) {
    return LFAlloc(size);
}

void* operator new[](size_t size, const std::nothrow_t&) OP_THROWNOTHING {
    return LFAlloc(size);
}

void operator delete[](void* p) OP_THROWNOTHING {
    LFFree(p);
}

void operator delete[](void* p, const std::nothrow_t&) OP_THROWNOTHING {
    LFFree(p);
}
#endif

//#ifndef _MSC_VER

extern "C" void* malloc(size_t size) {
    return LFAlloc(size);
}

extern "C" void* valloc(size_t size) {
    return LFVAlloc(size);
}

extern "C" int posix_memalign(void** memptr, size_t alignment, size_t size) {
    return LFPosixMemalign(memptr, alignment, size);
}

extern "C" void* memalign(size_t alignment, size_t size) {
    void* ptr;
    int res = LFPosixMemalign(&ptr, alignment, size);
    return res ? nullptr : ptr;
}

extern "C" void* aligned_alloc(size_t alignment, size_t size) {
    return memalign(alignment, size);
}

#if !defined(_MSC_VER) && !defined(_freebsd_)
// Workaround for pthread_create bug in linux.
extern "C" void* __libc_memalign(size_t alignment, size_t size) {
    return memalign(alignment, size);
}
#endif

extern "C" void free(void* ptr) {
    LFFree(ptr);
}

extern "C" void* calloc(size_t n, size_t elem_size) {
    // Overflow check
    const size_t size = n * elem_size;
    if (elem_size != 0 && size / elem_size != n)
        return nullptr;

    void* result = LFAlloc(size);
    if (result != nullptr) {
        memset(result, 0, size);
    }
    return result;
}

extern "C" void cfree(void* ptr) {
    LFFree(ptr);
}

extern "C" void* realloc(void* old_ptr, size_t new_size) {
    if (old_ptr == nullptr) {
        void* result = LFAlloc(new_size);
        return result;
    }
    if (new_size == 0) {
        LFFree(old_ptr);
        return nullptr;
    }

    void* new_ptr = LFAlloc(new_size);
    if (new_ptr == nullptr) {
        return nullptr;
    }
    size_t old_size = LFGetSize(old_ptr);
    memcpy(new_ptr, old_ptr, ((old_size < new_size) ? old_size : new_size));
    LFFree(old_ptr);
    return new_ptr;
}

extern "C" size_t malloc_usable_size(void* ptr) {
    if (ptr == nullptr) {
        return 0;
    }
    return LFGetSize(ptr);
}

NMalloc::TMallocInfo NMalloc::MallocInfo() {
    NMalloc::TMallocInfo r;
#if defined(LFALLOC_DBG)
    r.Name = "lfalloc_dbg";
#elif defined(LFALLOC_YT)
    r.Name = "lfalloc_yt";
#else
    r.Name = "lfalloc";
#endif
    r.SetParam = &LFAlloc_SetParam;
    r.GetParam = &LFAlloc_GetParam;
    return r;
}
#else
NMalloc::TMallocInfo NMalloc::MallocInfo() {
    NMalloc::TMallocInfo r;
    r.Name = "system-darwin";
    return r;
}
#endif
