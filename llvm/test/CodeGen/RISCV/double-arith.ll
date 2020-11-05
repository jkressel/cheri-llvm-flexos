; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+d -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32IFD %s
; RUN: llc -mtriple=riscv64 -mattr=+d -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV64IFD %s

; These tests are each targeted at a particular RISC-V FPU instruction. Most
; other files in this folder exercise LLVM IR instructions that don't directly
; match a RISC-V instruction.

define double @fadd_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: fadd_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    fadd.d ft0, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fadd_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fadd.d ft0, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = fadd double %a, %b
  ret double %1
}

define double @fsub_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: fsub_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    fsub.d ft0, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fsub_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fsub.d ft0, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = fsub double %a, %b
  ret double %1
}

define double @fmul_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: fmul_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    fmul.d ft0, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fmul_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fmul.d ft0, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = fmul double %a, %b
  ret double %1
}

define double @fdiv_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: fdiv_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    fdiv.d ft0, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fdiv_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fdiv.d ft0, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = fdiv double %a, %b
  ret double %1
}

declare double @llvm.sqrt.f64(double)

define double @fsqrt_d(double %a) nounwind {
; RV32IFD-LABEL: fsqrt_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    fsqrt.d ft0, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fsqrt_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a0
; RV64IFD-NEXT:    fsqrt.d ft0, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = call double @llvm.sqrt.f64(double %a)
  ret double %1
}

declare double @llvm.copysign.f64(double, double)

define double @fsgnj_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: fsgnj_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    fsgnj.d ft0, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fsgnj_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fsgnj.d ft0, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = call double @llvm.copysign.f64(double %a, double %b)
  ret double %1
}

; This function performs extra work to ensure that
; DAGCombiner::visitBITCAST doesn't replace the fneg with an xor.
define i32 @fneg_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: fneg_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    fadd.d ft0, ft0, ft0
; RV32IFD-NEXT:    fneg.d ft1, ft0
; RV32IFD-NEXT:    feq.d a0, ft0, ft1
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fneg_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a0
; RV64IFD-NEXT:    fadd.d ft0, ft0, ft0
; RV64IFD-NEXT:    fneg.d ft1, ft0
; RV64IFD-NEXT:    feq.d a0, ft0, ft1
; RV64IFD-NEXT:    ret
  %1 = fadd double %a, %a
  %2 = fneg double %1
  %3 = fcmp oeq double %1, %2
  %4 = zext i1 %3 to i32
  ret i32 %4
}

define double @fsgnjn_d(double %a, double %b) nounwind {
; TODO: fsgnjn.s isn't selected on RV64 because DAGCombiner::visitBITCAST will
; convert (bitconvert (fneg x)) to a xor.
;
; RV32IFD-LABEL: fsgnjn_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    fsgnjn.d ft0, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fsgnjn_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    addi a2, zero, -1
; RV64IFD-NEXT:    slli a2, a2, 63
; RV64IFD-NEXT:    xor a1, a1, a2
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fsgnj.d ft0, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = fsub double -0.0, %b
  %2 = call double @llvm.copysign.f64(double %a, double %1)
  ret double %2
}

declare double @llvm.fabs.f64(double)

; This function performs extra work to ensure that
; DAGCombiner::visitBITCAST doesn't replace the fabs with an and.
define double @fabs_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: fabs_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    fadd.d ft0, ft1, ft0
; RV32IFD-NEXT:    fabs.d ft1, ft0
; RV32IFD-NEXT:    fadd.d ft0, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fabs_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fadd.d ft0, ft1, ft0
; RV64IFD-NEXT:    fabs.d ft1, ft0
; RV64IFD-NEXT:    fadd.d ft0, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = fadd double %a, %b
  %2 = call double @llvm.fabs.f64(double %1)
  %3 = fadd double %2, %1
  ret double %3
}

declare double @llvm.minnum.f64(double, double)

define double @fmin_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: fmin_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    fmin.d ft0, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fmin_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fmin.d ft0, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = call double @llvm.minnum.f64(double %a, double %b)
  ret double %1
}

declare double @llvm.maxnum.f64(double, double)

define double @fmax_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: fmax_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    fmax.d ft0, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fmax_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fmax.d ft0, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = call double @llvm.maxnum.f64(double %a, double %b)
  ret double %1
}

define i32 @feq_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: feq_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    feq.d a0, ft1, ft0
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: feq_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    feq.d a0, ft1, ft0
; RV64IFD-NEXT:    ret
  %1 = fcmp oeq double %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @flt_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: flt_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    flt.d a0, ft1, ft0
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: flt_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    flt.d a0, ft1, ft0
; RV64IFD-NEXT:    ret
  %1 = fcmp olt double %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @fle_d(double %a, double %b) nounwind {
; RV32IFD-LABEL: fle_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    fle.d a0, ft1, ft0
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fle_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fle.d a0, ft1, ft0
; RV64IFD-NEXT:    ret
  %1 = fcmp ole double %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

declare double @llvm.fma.f64(double, double, double)

define double @fmadd_d(double %a, double %b, double %c) nounwind {
; RV32IFD-LABEL: fmadd_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a4, 8(sp)
; RV32IFD-NEXT:    sw a5, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft2, 8(sp)
; RV32IFD-NEXT:    fmadd.d ft0, ft2, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fmadd_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a2
; RV64IFD-NEXT:    fmv.d.x ft1, a1
; RV64IFD-NEXT:    fmv.d.x ft2, a0
; RV64IFD-NEXT:    fmadd.d ft0, ft2, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %1 = call double @llvm.fma.f64(double %a, double %b, double %c)
  ret double %1
}

define double @fmsub_d(double %a, double %b, double %c) nounwind {
; RV32IFD-LABEL: fmsub_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    sw a4, 8(sp)
; RV32IFD-NEXT:    sw a5, 12(sp)
; RV32IFD-NEXT:    fld ft2, 8(sp)
; RV32IFD-NEXT:    fcvt.d.w ft3, zero
; RV32IFD-NEXT:    fadd.d ft2, ft2, ft3
; RV32IFD-NEXT:    fmsub.d ft0, ft1, ft0, ft2
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fmsub_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fmv.d.x ft2, a2
; RV64IFD-NEXT:    fmv.d.x ft3, zero
; RV64IFD-NEXT:    fadd.d ft2, ft2, ft3
; RV64IFD-NEXT:    fmsub.d ft0, ft1, ft0, ft2
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %c_ = fadd double 0.0, %c ; avoid negation using xor
  %negc = fsub double -0.0, %c_
  %1 = call double @llvm.fma.f64(double %a, double %b, double %negc)
  ret double %1
}

define double @fnmadd_d(double %a, double %b, double %c) nounwind {
; RV32IFD-LABEL: fnmadd_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a4, 8(sp)
; RV32IFD-NEXT:    sw a5, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft2, 8(sp)
; RV32IFD-NEXT:    fcvt.d.w ft3, zero
; RV32IFD-NEXT:    fadd.d ft2, ft2, ft3
; RV32IFD-NEXT:    fadd.d ft1, ft1, ft3
; RV32IFD-NEXT:    fnmadd.d ft0, ft2, ft0, ft1
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fnmadd_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a1
; RV64IFD-NEXT:    fmv.d.x ft1, a2
; RV64IFD-NEXT:    fmv.d.x ft2, a0
; RV64IFD-NEXT:    fmv.d.x ft3, zero
; RV64IFD-NEXT:    fadd.d ft2, ft2, ft3
; RV64IFD-NEXT:    fadd.d ft1, ft1, ft3
; RV64IFD-NEXT:    fnmadd.d ft0, ft2, ft0, ft1
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %a_ = fadd double 0.0, %a
  %c_ = fadd double 0.0, %c
  %nega = fsub double -0.0, %a_
  %negc = fsub double -0.0, %c_
  %1 = call double @llvm.fma.f64(double %nega, double %b, double %negc)
  ret double %1
}

define double @fnmadd_d_2(double %a, double %b, double %c) nounwind {
; RV32IFD-LABEL: fnmadd_d_2:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a4, 8(sp)
; RV32IFD-NEXT:    sw a5, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft2, 8(sp)
; RV32IFD-NEXT:    fcvt.d.w ft3, zero
; RV32IFD-NEXT:    fadd.d ft2, ft2, ft3
; RV32IFD-NEXT:    fadd.d ft1, ft1, ft3
; RV32IFD-NEXT:    fnmadd.d ft0, ft0, ft2, ft1
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fnmadd_d_2:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a0
; RV64IFD-NEXT:    fmv.d.x ft1, a2
; RV64IFD-NEXT:    fmv.d.x ft2, a1
; RV64IFD-NEXT:    fmv.d.x ft3, zero
; RV64IFD-NEXT:    fadd.d ft2, ft2, ft3
; RV64IFD-NEXT:    fadd.d ft1, ft1, ft3
; RV64IFD-NEXT:    fnmadd.d ft0, ft0, ft2, ft1
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %b_ = fadd double 0.0, %b
  %c_ = fadd double 0.0, %c
  %negb = fsub double -0.0, %b_
  %negc = fsub double -0.0, %c_
  %1 = call double @llvm.fma.f64(double %a, double %negb, double %negc)
  ret double %1
}

define double @fnmsub_d(double %a, double %b, double %c) nounwind {
; RV32IFD-LABEL: fnmsub_d:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a4, 8(sp)
; RV32IFD-NEXT:    sw a5, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft2, 8(sp)
; RV32IFD-NEXT:    fcvt.d.w ft3, zero
; RV32IFD-NEXT:    fadd.d ft2, ft2, ft3
; RV32IFD-NEXT:    fnmsub.d ft0, ft2, ft1, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fnmsub_d:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a2
; RV64IFD-NEXT:    fmv.d.x ft1, a1
; RV64IFD-NEXT:    fmv.d.x ft2, a0
; RV64IFD-NEXT:    fmv.d.x ft3, zero
; RV64IFD-NEXT:    fadd.d ft2, ft2, ft3
; RV64IFD-NEXT:    fnmsub.d ft0, ft2, ft1, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %a_ = fadd double 0.0, %a
  %nega = fsub double -0.0, %a_
  %1 = call double @llvm.fma.f64(double %nega, double %b, double %c)
  ret double %1
}

define double @fnmsub_d_2(double %a, double %b, double %c) nounwind {
; RV32IFD-LABEL: fnmsub_d_2:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    addi sp, sp, -16
; RV32IFD-NEXT:    sw a4, 8(sp)
; RV32IFD-NEXT:    sw a5, 12(sp)
; RV32IFD-NEXT:    fld ft0, 8(sp)
; RV32IFD-NEXT:    sw a0, 8(sp)
; RV32IFD-NEXT:    sw a1, 12(sp)
; RV32IFD-NEXT:    fld ft1, 8(sp)
; RV32IFD-NEXT:    sw a2, 8(sp)
; RV32IFD-NEXT:    sw a3, 12(sp)
; RV32IFD-NEXT:    fld ft2, 8(sp)
; RV32IFD-NEXT:    fcvt.d.w ft3, zero
; RV32IFD-NEXT:    fadd.d ft2, ft2, ft3
; RV32IFD-NEXT:    fnmsub.d ft0, ft1, ft2, ft0
; RV32IFD-NEXT:    fsd ft0, 8(sp)
; RV32IFD-NEXT:    lw a0, 8(sp)
; RV32IFD-NEXT:    lw a1, 12(sp)
; RV32IFD-NEXT:    addi sp, sp, 16
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: fnmsub_d_2:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    fmv.d.x ft0, a2
; RV64IFD-NEXT:    fmv.d.x ft1, a0
; RV64IFD-NEXT:    fmv.d.x ft2, a1
; RV64IFD-NEXT:    fmv.d.x ft3, zero
; RV64IFD-NEXT:    fadd.d ft2, ft2, ft3
; RV64IFD-NEXT:    fnmsub.d ft0, ft1, ft2, ft0
; RV64IFD-NEXT:    fmv.x.d a0, ft0
; RV64IFD-NEXT:    ret
  %b_ = fadd double 0.0, %b
  %negb = fsub double -0.0, %b_
  %1 = call double @llvm.fma.f64(double %a, double %negb, double %c)
  ret double %1
}
