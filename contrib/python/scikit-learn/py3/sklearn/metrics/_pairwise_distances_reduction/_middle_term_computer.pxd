from libcpp.vector cimport vector

from ...utils._typedefs cimport float64_t, float32_t, int32_t, intp_t


cdef void _middle_term_sparse_sparse_64(
    const float64_t[:] X_data,
    const int32_t[:] X_indices,
    const int32_t[:] X_indptr,
    intp_t X_start,
    intp_t X_end,
    const float64_t[:] Y_data,
    const int32_t[:] Y_indices,
    const int32_t[:] Y_indptr,
    intp_t Y_start,
    intp_t Y_end,
    float64_t * D,
) noexcept nogil



cdef class MiddleTermComputer64:
    cdef:
        intp_t effective_n_threads
        intp_t chunks_n_threads
        intp_t dist_middle_terms_chunks_size
        intp_t n_features
        intp_t chunk_size

        # Buffers for the `-2 * X_c @ Y_c.T` term computed via GEMM
        vector[vector[float64_t]] dist_middle_terms_chunks

    cdef void _parallel_on_X_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil

    cdef void _parallel_on_X_parallel_init(self, intp_t thread_num) noexcept nogil

    cdef void _parallel_on_X_init_chunk(
        self,
        intp_t thread_num,
        intp_t X_start,
        intp_t X_end,
    ) noexcept nogil

    cdef void _parallel_on_Y_init(self) noexcept nogil

    cdef void _parallel_on_Y_parallel_init(
        self,
        intp_t thread_num,
        intp_t X_start,
        intp_t X_end,
    ) noexcept nogil

    cdef void _parallel_on_Y_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef float64_t * _compute_dist_middle_terms(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil


cdef class DenseDenseMiddleTermComputer64(MiddleTermComputer64):
    cdef:
        const float64_t[:, ::1] X
        const float64_t[:, ::1] Y


    cdef void _parallel_on_X_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil

    cdef void _parallel_on_X_init_chunk(
        self,
        intp_t thread_num,
        intp_t X_start,
        intp_t X_end,
    ) noexcept nogil

    cdef void _parallel_on_Y_parallel_init(
        self,
        intp_t thread_num,
        intp_t X_start,
        intp_t X_end,
    ) noexcept nogil

    cdef void _parallel_on_Y_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef float64_t * _compute_dist_middle_terms(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil


cdef class SparseSparseMiddleTermComputer64(MiddleTermComputer64):
    cdef:
        const float64_t[:] X_data
        const int32_t[:] X_indices
        const int32_t[:] X_indptr

        const float64_t[:] Y_data
        const int32_t[:] Y_indices
        const int32_t[:] Y_indptr

    cdef void _parallel_on_X_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef void _parallel_on_Y_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef float64_t * _compute_dist_middle_terms(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil


cdef class SparseDenseMiddleTermComputer64(MiddleTermComputer64):
    cdef:
        const float64_t[:] X_data
        const int32_t[:] X_indices
        const int32_t[:] X_indptr

        const float64_t[:, ::1] Y

        # We treat the dense-sparse case with the sparse-dense case by simply
        # treating the dist_middle_terms as F-ordered and by swapping arguments.
        # This attribute is meant to encode the case and adapt the logic
        # accordingly.
        bint c_ordered_middle_term

    cdef void _parallel_on_X_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef void _parallel_on_Y_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef float64_t * _compute_dist_middle_terms(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil


cdef class MiddleTermComputer32:
    cdef:
        intp_t effective_n_threads
        intp_t chunks_n_threads
        intp_t dist_middle_terms_chunks_size
        intp_t n_features
        intp_t chunk_size

        # Buffers for the `-2 * X_c @ Y_c.T` term computed via GEMM
        vector[vector[float64_t]] dist_middle_terms_chunks

    cdef void _parallel_on_X_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil

    cdef void _parallel_on_X_parallel_init(self, intp_t thread_num) noexcept nogil

    cdef void _parallel_on_X_init_chunk(
        self,
        intp_t thread_num,
        intp_t X_start,
        intp_t X_end,
    ) noexcept nogil

    cdef void _parallel_on_Y_init(self) noexcept nogil

    cdef void _parallel_on_Y_parallel_init(
        self,
        intp_t thread_num,
        intp_t X_start,
        intp_t X_end,
    ) noexcept nogil

    cdef void _parallel_on_Y_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef float64_t * _compute_dist_middle_terms(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil


cdef class DenseDenseMiddleTermComputer32(MiddleTermComputer32):
    cdef:
        const float32_t[:, ::1] X
        const float32_t[:, ::1] Y

        # Buffers for upcasting chunks of X and Y from 32bit to 64bit
        vector[vector[float64_t]] X_c_upcast
        vector[vector[float64_t]] Y_c_upcast

    cdef void _parallel_on_X_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil

    cdef void _parallel_on_X_init_chunk(
        self,
        intp_t thread_num,
        intp_t X_start,
        intp_t X_end,
    ) noexcept nogil

    cdef void _parallel_on_Y_parallel_init(
        self,
        intp_t thread_num,
        intp_t X_start,
        intp_t X_end,
    ) noexcept nogil

    cdef void _parallel_on_Y_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef float64_t * _compute_dist_middle_terms(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil


cdef class SparseSparseMiddleTermComputer32(MiddleTermComputer32):
    cdef:
        const float64_t[:] X_data
        const int32_t[:] X_indices
        const int32_t[:] X_indptr

        const float64_t[:] Y_data
        const int32_t[:] Y_indices
        const int32_t[:] Y_indptr

    cdef void _parallel_on_X_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef void _parallel_on_Y_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef float64_t * _compute_dist_middle_terms(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil


cdef class SparseDenseMiddleTermComputer32(MiddleTermComputer32):
    cdef:
        const float64_t[:] X_data
        const int32_t[:] X_indices
        const int32_t[:] X_indptr

        const float32_t[:, ::1] Y

        # We treat the dense-sparse case with the sparse-dense case by simply
        # treating the dist_middle_terms as F-ordered and by swapping arguments.
        # This attribute is meant to encode the case and adapt the logic
        # accordingly.
        bint c_ordered_middle_term

    cdef void _parallel_on_X_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef void _parallel_on_Y_pre_compute_and_reduce_distances_on_chunks(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num
    ) noexcept nogil

    cdef float64_t * _compute_dist_middle_terms(
        self,
        intp_t X_start,
        intp_t X_end,
        intp_t Y_start,
        intp_t Y_end,
        intp_t thread_num,
    ) noexcept nogil
