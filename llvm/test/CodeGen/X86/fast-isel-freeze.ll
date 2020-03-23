; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s                               -mtriple=x86_64-unknown-linux | FileCheck %s --check-prefix=SDAG
; RUN: llc < %s -fast-isel -fast-isel-abort=1 -mtriple=x86_64-unknown-linux | FileCheck %s --check-prefix=FAST

define i32 @freeze(i32 %t) {
; SDAG-LABEL: freeze:
; SDAG:       # %bb.0:
; SDAG-NEXT:    movl $10, %eax
; SDAG-NEXT:    xorl %edi, %eax
; SDAG-NEXT:    retq
;
; FAST-LABEL: freeze:
; FAST:       # %bb.0:
; FAST-NEXT:    movl $10, %eax
; FAST-NEXT:    xorl %edi, %eax
; FAST-NEXT:    retq
  %1 = freeze i32 %t
  %2 = freeze i32 10
  %3 = xor i32 %1, %2
  ret i32 %3
}
