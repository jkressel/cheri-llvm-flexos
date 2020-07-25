; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+sse4.1 -O3 | FileCheck %s --check-prefixes=SSE41,SSE41-X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 -O3 | FileCheck %s --check-prefixes=SSE41,SSE41-X64
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx -O3 | FileCheck %s --check-prefixes=AVX-X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx -O3 | FileCheck %s --check-prefixes=AVX-X64
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx512f -O3 | FileCheck %s --check-prefixes=AVX-X86,AVX512-X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f -O3 | FileCheck %s --check-prefixes=AVX-X64,AVX512-X64

declare float @llvm.experimental.constrained.ceil.f32(float, metadata)
declare double @llvm.experimental.constrained.ceil.f64(double, metadata)
declare float @llvm.experimental.constrained.floor.f32(float, metadata)
declare double @llvm.experimental.constrained.floor.f64(double, metadata)
declare float @llvm.experimental.constrained.trunc.f32(float, metadata)
declare double @llvm.experimental.constrained.trunc.f64(double, metadata)
declare float @llvm.experimental.constrained.rint.f32(float, metadata, metadata)
declare double @llvm.experimental.constrained.rint.f64(double, metadata, metadata)
declare float @llvm.experimental.constrained.nearbyint.f32(float, metadata, metadata)
declare double @llvm.experimental.constrained.nearbyint.f64(double, metadata, metadata)
declare float @llvm.experimental.constrained.round.f32(float, metadata)
declare double @llvm.experimental.constrained.round.f64(double, metadata)
declare float @llvm.experimental.constrained.roundeven.f32(float, metadata)
declare double @llvm.experimental.constrained.roundeven.f64(double, metadata)

define float @fceil32(float %f) #0 {
; SSE41-X86-LABEL: fceil32:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE41-X86-NEXT:    roundss $10, %xmm0, %xmm0
; SSE41-X86-NEXT:    movss %xmm0, (%esp)
; SSE41-X86-NEXT:    flds (%esp)
; SSE41-X86-NEXT:    wait
; SSE41-X86-NEXT:    popl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: fceil32:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    roundss $10, %xmm0, %xmm0
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: fceil32:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-X86-NEXT:    vroundss $10, %xmm0, %xmm0, %xmm0
; AVX-X86-NEXT:    vmovss %xmm0, (%esp)
; AVX-X86-NEXT:    flds (%esp)
; AVX-X86-NEXT:    wait
; AVX-X86-NEXT:    popl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: fceil32:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    vroundss $10, %xmm0, %xmm0, %xmm0
; AVX-X64-NEXT:    retq
  %res = call float @llvm.experimental.constrained.ceil.f32(
                        float %f, metadata !"fpexcept.strict") #0
  ret float %res
}

define double @fceilf64(double %f) #0 {
; SSE41-X86-LABEL: fceilf64:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    .cfi_offset %ebp, -8
; SSE41-X86-NEXT:    movl %esp, %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa_register %ebp
; SSE41-X86-NEXT:    andl $-8, %esp
; SSE41-X86-NEXT:    subl $8, %esp
; SSE41-X86-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE41-X86-NEXT:    roundsd $10, %xmm0, %xmm0
; SSE41-X86-NEXT:    movsd %xmm0, (%esp)
; SSE41-X86-NEXT:    fldl (%esp)
; SSE41-X86-NEXT:    wait
; SSE41-X86-NEXT:    movl %ebp, %esp
; SSE41-X86-NEXT:    popl %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa %esp, 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: fceilf64:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    roundsd $10, %xmm0, %xmm0
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: fceilf64:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %ebp
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    .cfi_offset %ebp, -8
; AVX-X86-NEXT:    movl %esp, %ebp
; AVX-X86-NEXT:    .cfi_def_cfa_register %ebp
; AVX-X86-NEXT:    andl $-8, %esp
; AVX-X86-NEXT:    subl $8, %esp
; AVX-X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-X86-NEXT:    vroundsd $10, %xmm0, %xmm0, %xmm0
; AVX-X86-NEXT:    vmovsd %xmm0, (%esp)
; AVX-X86-NEXT:    fldl (%esp)
; AVX-X86-NEXT:    wait
; AVX-X86-NEXT:    movl %ebp, %esp
; AVX-X86-NEXT:    popl %ebp
; AVX-X86-NEXT:    .cfi_def_cfa %esp, 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: fceilf64:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    vroundsd $10, %xmm0, %xmm0, %xmm0
; AVX-X64-NEXT:    retq
  %res = call double @llvm.experimental.constrained.ceil.f64(
                        double %f, metadata !"fpexcept.strict") #0
  ret double %res
}

define float @ffloor32(float %f) #0 {
; SSE41-X86-LABEL: ffloor32:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE41-X86-NEXT:    roundss $9, %xmm0, %xmm0
; SSE41-X86-NEXT:    movss %xmm0, (%esp)
; SSE41-X86-NEXT:    flds (%esp)
; SSE41-X86-NEXT:    wait
; SSE41-X86-NEXT:    popl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: ffloor32:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    roundss $9, %xmm0, %xmm0
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: ffloor32:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-X86-NEXT:    vroundss $9, %xmm0, %xmm0, %xmm0
; AVX-X86-NEXT:    vmovss %xmm0, (%esp)
; AVX-X86-NEXT:    flds (%esp)
; AVX-X86-NEXT:    wait
; AVX-X86-NEXT:    popl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: ffloor32:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    vroundss $9, %xmm0, %xmm0, %xmm0
; AVX-X64-NEXT:    retq
  %res = call float @llvm.experimental.constrained.floor.f32(
                        float %f, metadata !"fpexcept.strict") #0
  ret float %res
}

define double @ffloorf64(double %f) #0 {
; SSE41-X86-LABEL: ffloorf64:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    .cfi_offset %ebp, -8
; SSE41-X86-NEXT:    movl %esp, %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa_register %ebp
; SSE41-X86-NEXT:    andl $-8, %esp
; SSE41-X86-NEXT:    subl $8, %esp
; SSE41-X86-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE41-X86-NEXT:    roundsd $9, %xmm0, %xmm0
; SSE41-X86-NEXT:    movsd %xmm0, (%esp)
; SSE41-X86-NEXT:    fldl (%esp)
; SSE41-X86-NEXT:    wait
; SSE41-X86-NEXT:    movl %ebp, %esp
; SSE41-X86-NEXT:    popl %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa %esp, 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: ffloorf64:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    roundsd $9, %xmm0, %xmm0
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: ffloorf64:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %ebp
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    .cfi_offset %ebp, -8
; AVX-X86-NEXT:    movl %esp, %ebp
; AVX-X86-NEXT:    .cfi_def_cfa_register %ebp
; AVX-X86-NEXT:    andl $-8, %esp
; AVX-X86-NEXT:    subl $8, %esp
; AVX-X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-X86-NEXT:    vroundsd $9, %xmm0, %xmm0, %xmm0
; AVX-X86-NEXT:    vmovsd %xmm0, (%esp)
; AVX-X86-NEXT:    fldl (%esp)
; AVX-X86-NEXT:    wait
; AVX-X86-NEXT:    movl %ebp, %esp
; AVX-X86-NEXT:    popl %ebp
; AVX-X86-NEXT:    .cfi_def_cfa %esp, 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: ffloorf64:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    vroundsd $9, %xmm0, %xmm0, %xmm0
; AVX-X64-NEXT:    retq
  %res = call double @llvm.experimental.constrained.floor.f64(
                        double %f, metadata !"fpexcept.strict") #0
  ret double %res
}

define float @ftrunc32(float %f) #0 {
; SSE41-X86-LABEL: ftrunc32:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE41-X86-NEXT:    roundss $11, %xmm0, %xmm0
; SSE41-X86-NEXT:    movss %xmm0, (%esp)
; SSE41-X86-NEXT:    flds (%esp)
; SSE41-X86-NEXT:    wait
; SSE41-X86-NEXT:    popl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: ftrunc32:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    roundss $11, %xmm0, %xmm0
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: ftrunc32:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-X86-NEXT:    vroundss $11, %xmm0, %xmm0, %xmm0
; AVX-X86-NEXT:    vmovss %xmm0, (%esp)
; AVX-X86-NEXT:    flds (%esp)
; AVX-X86-NEXT:    wait
; AVX-X86-NEXT:    popl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: ftrunc32:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    vroundss $11, %xmm0, %xmm0, %xmm0
; AVX-X64-NEXT:    retq
  %res = call float @llvm.experimental.constrained.trunc.f32(
                        float %f, metadata !"fpexcept.strict") #0
  ret float %res
}

define double @ftruncf64(double %f) #0 {
; SSE41-X86-LABEL: ftruncf64:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    .cfi_offset %ebp, -8
; SSE41-X86-NEXT:    movl %esp, %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa_register %ebp
; SSE41-X86-NEXT:    andl $-8, %esp
; SSE41-X86-NEXT:    subl $8, %esp
; SSE41-X86-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE41-X86-NEXT:    roundsd $11, %xmm0, %xmm0
; SSE41-X86-NEXT:    movsd %xmm0, (%esp)
; SSE41-X86-NEXT:    fldl (%esp)
; SSE41-X86-NEXT:    wait
; SSE41-X86-NEXT:    movl %ebp, %esp
; SSE41-X86-NEXT:    popl %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa %esp, 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: ftruncf64:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    roundsd $11, %xmm0, %xmm0
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: ftruncf64:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %ebp
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    .cfi_offset %ebp, -8
; AVX-X86-NEXT:    movl %esp, %ebp
; AVX-X86-NEXT:    .cfi_def_cfa_register %ebp
; AVX-X86-NEXT:    andl $-8, %esp
; AVX-X86-NEXT:    subl $8, %esp
; AVX-X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-X86-NEXT:    vroundsd $11, %xmm0, %xmm0, %xmm0
; AVX-X86-NEXT:    vmovsd %xmm0, (%esp)
; AVX-X86-NEXT:    fldl (%esp)
; AVX-X86-NEXT:    wait
; AVX-X86-NEXT:    movl %ebp, %esp
; AVX-X86-NEXT:    popl %ebp
; AVX-X86-NEXT:    .cfi_def_cfa %esp, 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: ftruncf64:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    vroundsd $11, %xmm0, %xmm0, %xmm0
; AVX-X64-NEXT:    retq
  %res = call double @llvm.experimental.constrained.trunc.f64(
                        double %f, metadata !"fpexcept.strict") #0
  ret double %res
}

define float @frint32(float %f) #0 {
; SSE41-X86-LABEL: frint32:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE41-X86-NEXT:    roundss $4, %xmm0, %xmm0
; SSE41-X86-NEXT:    movss %xmm0, (%esp)
; SSE41-X86-NEXT:    flds (%esp)
; SSE41-X86-NEXT:    wait
; SSE41-X86-NEXT:    popl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: frint32:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    roundss $4, %xmm0, %xmm0
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: frint32:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-X86-NEXT:    vroundss $4, %xmm0, %xmm0, %xmm0
; AVX-X86-NEXT:    vmovss %xmm0, (%esp)
; AVX-X86-NEXT:    flds (%esp)
; AVX-X86-NEXT:    wait
; AVX-X86-NEXT:    popl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: frint32:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    vroundss $4, %xmm0, %xmm0, %xmm0
; AVX-X64-NEXT:    retq
  %res = call float @llvm.experimental.constrained.rint.f32(
                        float %f,
                        metadata !"round.dynamic", metadata !"fpexcept.strict") #0
  ret float %res
}

define double @frintf64(double %f) #0 {
; SSE41-X86-LABEL: frintf64:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    .cfi_offset %ebp, -8
; SSE41-X86-NEXT:    movl %esp, %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa_register %ebp
; SSE41-X86-NEXT:    andl $-8, %esp
; SSE41-X86-NEXT:    subl $8, %esp
; SSE41-X86-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE41-X86-NEXT:    roundsd $4, %xmm0, %xmm0
; SSE41-X86-NEXT:    movsd %xmm0, (%esp)
; SSE41-X86-NEXT:    fldl (%esp)
; SSE41-X86-NEXT:    wait
; SSE41-X86-NEXT:    movl %ebp, %esp
; SSE41-X86-NEXT:    popl %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa %esp, 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: frintf64:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    roundsd $4, %xmm0, %xmm0
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: frintf64:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %ebp
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    .cfi_offset %ebp, -8
; AVX-X86-NEXT:    movl %esp, %ebp
; AVX-X86-NEXT:    .cfi_def_cfa_register %ebp
; AVX-X86-NEXT:    andl $-8, %esp
; AVX-X86-NEXT:    subl $8, %esp
; AVX-X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-X86-NEXT:    vroundsd $4, %xmm0, %xmm0, %xmm0
; AVX-X86-NEXT:    vmovsd %xmm0, (%esp)
; AVX-X86-NEXT:    fldl (%esp)
; AVX-X86-NEXT:    wait
; AVX-X86-NEXT:    movl %ebp, %esp
; AVX-X86-NEXT:    popl %ebp
; AVX-X86-NEXT:    .cfi_def_cfa %esp, 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: frintf64:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    vroundsd $4, %xmm0, %xmm0, %xmm0
; AVX-X64-NEXT:    retq
  %res = call double @llvm.experimental.constrained.rint.f64(
                        double %f,
                        metadata !"round.dynamic", metadata !"fpexcept.strict") #0
  ret double %res
}

define float @fnearbyint32(float %f) #0 {
; SSE41-X86-LABEL: fnearbyint32:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE41-X86-NEXT:    roundss $12, %xmm0, %xmm0
; SSE41-X86-NEXT:    movss %xmm0, (%esp)
; SSE41-X86-NEXT:    flds (%esp)
; SSE41-X86-NEXT:    wait
; SSE41-X86-NEXT:    popl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: fnearbyint32:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    roundss $12, %xmm0, %xmm0
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: fnearbyint32:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-X86-NEXT:    vroundss $12, %xmm0, %xmm0, %xmm0
; AVX-X86-NEXT:    vmovss %xmm0, (%esp)
; AVX-X86-NEXT:    flds (%esp)
; AVX-X86-NEXT:    wait
; AVX-X86-NEXT:    popl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: fnearbyint32:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    vroundss $12, %xmm0, %xmm0, %xmm0
; AVX-X64-NEXT:    retq
  %res = call float @llvm.experimental.constrained.nearbyint.f32(
                        float %f,
                        metadata !"round.dynamic", metadata !"fpexcept.strict") #0
  ret float %res
}

define double @fnearbyintf64(double %f) #0 {
; SSE41-X86-LABEL: fnearbyintf64:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    .cfi_offset %ebp, -8
; SSE41-X86-NEXT:    movl %esp, %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa_register %ebp
; SSE41-X86-NEXT:    andl $-8, %esp
; SSE41-X86-NEXT:    subl $8, %esp
; SSE41-X86-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE41-X86-NEXT:    roundsd $12, %xmm0, %xmm0
; SSE41-X86-NEXT:    movsd %xmm0, (%esp)
; SSE41-X86-NEXT:    fldl (%esp)
; SSE41-X86-NEXT:    wait
; SSE41-X86-NEXT:    movl %ebp, %esp
; SSE41-X86-NEXT:    popl %ebp
; SSE41-X86-NEXT:    .cfi_def_cfa %esp, 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: fnearbyintf64:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    roundsd $12, %xmm0, %xmm0
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: fnearbyintf64:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %ebp
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    .cfi_offset %ebp, -8
; AVX-X86-NEXT:    movl %esp, %ebp
; AVX-X86-NEXT:    .cfi_def_cfa_register %ebp
; AVX-X86-NEXT:    andl $-8, %esp
; AVX-X86-NEXT:    subl $8, %esp
; AVX-X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-X86-NEXT:    vroundsd $12, %xmm0, %xmm0, %xmm0
; AVX-X86-NEXT:    vmovsd %xmm0, (%esp)
; AVX-X86-NEXT:    fldl (%esp)
; AVX-X86-NEXT:    wait
; AVX-X86-NEXT:    movl %ebp, %esp
; AVX-X86-NEXT:    popl %ebp
; AVX-X86-NEXT:    .cfi_def_cfa %esp, 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: fnearbyintf64:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    vroundsd $12, %xmm0, %xmm0, %xmm0
; AVX-X64-NEXT:    retq
  %res = call double @llvm.experimental.constrained.nearbyint.f64(
                        double %f,
                        metadata !"round.dynamic", metadata !"fpexcept.strict") #0
  ret double %res
}

define float @fround32(float %f) #0 {
; SSE41-X86-LABEL: fround32:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE41-X86-NEXT:    movss %xmm0, (%esp)
; SSE41-X86-NEXT:    calll roundf
; SSE41-X86-NEXT:    popl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: fround32:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    pushq %rax
; SSE41-X64-NEXT:    .cfi_def_cfa_offset 16
; SSE41-X64-NEXT:    callq roundf
; SSE41-X64-NEXT:    popq %rax
; SSE41-X64-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: fround32:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-X86-NEXT:    vmovss %xmm0, (%esp)
; AVX-X86-NEXT:    calll roundf
; AVX-X86-NEXT:    popl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: fround32:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    pushq %rax
; AVX-X64-NEXT:    .cfi_def_cfa_offset 16
; AVX-X64-NEXT:    callq roundf
; AVX-X64-NEXT:    popq %rax
; AVX-X64-NEXT:    .cfi_def_cfa_offset 8
; AVX-X64-NEXT:    retq
  %res = call float @llvm.experimental.constrained.round.f32(
                        float %f, metadata !"fpexcept.strict") #0
  ret float %res
}

define double @froundf64(double %f) #0 {
; SSE41-X86-LABEL: froundf64:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    subl $8, %esp
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 12
; SSE41-X86-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE41-X86-NEXT:    movsd %xmm0, (%esp)
; SSE41-X86-NEXT:    calll round
; SSE41-X86-NEXT:    addl $8, %esp
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: froundf64:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    pushq %rax
; SSE41-X64-NEXT:    .cfi_def_cfa_offset 16
; SSE41-X64-NEXT:    callq round
; SSE41-X64-NEXT:    popq %rax
; SSE41-X64-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: froundf64:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    subl $8, %esp
; AVX-X86-NEXT:    .cfi_def_cfa_offset 12
; AVX-X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-X86-NEXT:    vmovsd %xmm0, (%esp)
; AVX-X86-NEXT:    calll round
; AVX-X86-NEXT:    addl $8, %esp
; AVX-X86-NEXT:    .cfi_def_cfa_offset 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: froundf64:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    pushq %rax
; AVX-X64-NEXT:    .cfi_def_cfa_offset 16
; AVX-X64-NEXT:    callq round
; AVX-X64-NEXT:    popq %rax
; AVX-X64-NEXT:    .cfi_def_cfa_offset 8
; AVX-X64-NEXT:    retq
  %res = call double @llvm.experimental.constrained.round.f64(
                        double %f, metadata !"fpexcept.strict") #0
  ret double %res
}

define float @froundeven32(float %f) #0 {
; SSE41-X86-LABEL: froundeven32:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    pushl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X86-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE41-X86-NEXT:    movss %xmm0, (%esp)
; SSE41-X86-NEXT:    calll roundevenf
; SSE41-X86-NEXT:    popl %eax
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: froundeven32:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    pushq %rax
; SSE41-X64-NEXT:    .cfi_def_cfa_offset 16
; SSE41-X64-NEXT:    callq roundevenf
; SSE41-X64-NEXT:    popq %rax
; SSE41-X64-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: froundeven32:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    pushl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 8
; AVX-X86-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-X86-NEXT:    vmovss %xmm0, (%esp)
; AVX-X86-NEXT:    calll roundevenf
; AVX-X86-NEXT:    popl %eax
; AVX-X86-NEXT:    .cfi_def_cfa_offset 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: froundeven32:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    pushq %rax
; AVX-X64-NEXT:    .cfi_def_cfa_offset 16
; AVX-X64-NEXT:    callq roundevenf
; AVX-X64-NEXT:    popq %rax
; AVX-X64-NEXT:    .cfi_def_cfa_offset 8
; AVX-X64-NEXT:    retq
  %res = call float @llvm.experimental.constrained.roundeven.f32(
                        float %f, metadata !"fpexcept.strict") #0
  ret float %res
}

define double @froundevenf64(double %f) #0 {
; SSE41-X86-LABEL: froundevenf64:
; SSE41-X86:       # %bb.0:
; SSE41-X86-NEXT:    subl $8, %esp
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 12
; SSE41-X86-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE41-X86-NEXT:    movsd %xmm0, (%esp)
; SSE41-X86-NEXT:    calll roundeven
; SSE41-X86-NEXT:    addl $8, %esp
; SSE41-X86-NEXT:    .cfi_def_cfa_offset 4
; SSE41-X86-NEXT:    retl
;
; SSE41-X64-LABEL: froundevenf64:
; SSE41-X64:       # %bb.0:
; SSE41-X64-NEXT:    pushq %rax
; SSE41-X64-NEXT:    .cfi_def_cfa_offset 16
; SSE41-X64-NEXT:    callq roundeven
; SSE41-X64-NEXT:    popq %rax
; SSE41-X64-NEXT:    .cfi_def_cfa_offset 8
; SSE41-X64-NEXT:    retq
;
; AVX-X86-LABEL: froundevenf64:
; AVX-X86:       # %bb.0:
; AVX-X86-NEXT:    subl $8, %esp
; AVX-X86-NEXT:    .cfi_def_cfa_offset 12
; AVX-X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-X86-NEXT:    vmovsd %xmm0, (%esp)
; AVX-X86-NEXT:    calll roundeven
; AVX-X86-NEXT:    addl $8, %esp
; AVX-X86-NEXT:    .cfi_def_cfa_offset 4
; AVX-X86-NEXT:    retl
;
; AVX-X64-LABEL: froundevenf64:
; AVX-X64:       # %bb.0:
; AVX-X64-NEXT:    pushq %rax
; AVX-X64-NEXT:    .cfi_def_cfa_offset 16
; AVX-X64-NEXT:    callq roundeven
; AVX-X64-NEXT:    popq %rax
; AVX-X64-NEXT:    .cfi_def_cfa_offset 8
; AVX-X64-NEXT:    retq
  %res = call double @llvm.experimental.constrained.roundeven.f64(
                        double %f, metadata !"fpexcept.strict") #0
  ret double %res
}

attributes #0 = { strictfp }
