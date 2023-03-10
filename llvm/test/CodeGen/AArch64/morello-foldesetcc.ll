; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -march=aarch64 -mattr=+c64,+morello -target-abi purecap -o - | FileCheck %s

target datalayout = "e-m:e-pf200:128:128:128:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-A200-P200-G200"
target triple = "aarch64-none-unknown-elf"

define void @foo() local_unnamed_addr addrspace(200) align 2 {
; CHECK-LABEL: foo:
; CHECK:       .Lfunc_begin0:
; CHECK-NEXT:    .cfi_startproc purecap
; CHECK-NEXT:  // %bb.0: // %entry
; CHECK-NEXT:    cbnz wzr, .LBB0_3
; CHECK-NEXT:  // %bb.1: // %entry
; CHECK-NEXT:    mov w8, #1
; CHECK-NEXT:    cbz w8, .LBB0_3
; CHECK-NEXT:  // %bb.2: // %vector.ph
; CHECK-NEXT:    ret c30
; CHECK-NEXT:  .LBB0_3: // %for.body21
; CHECK-NEXT:    // =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    b .LBB0_3
entry:
  %bound0165 = icmp ugt i8 addrspace(200)* undef, undef
  %bound1166 = icmp ugt i8 addrspace(200)* undef, undef
  %found.conflict167 = and i1 %bound0165, %bound1166
  %i = or i1 undef, %found.conflict167
  br i1 %i, label %for.body21, label %vector.ph

vector.ph:
  ret void

for.body21:
  br label %for.body21
}
