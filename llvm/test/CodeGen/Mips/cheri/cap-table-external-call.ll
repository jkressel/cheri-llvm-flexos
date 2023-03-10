; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUNNOT: %cheri_purecap_llc -cheri-cap-table-abi=plt %s -O0 -o - -filetype=obj | llvm-dwarfdump -all -
; RUN: %cheri_purecap_llc -cheri-cap-table-abi=plt %s -O2 -o - | %cheri_FileCheck %s
; ModuleID = '/Users/alex/cheri/llvm/tools/clang/test/CodeGen/CHERI/cap-table-call-extern.c'

; Function Attrs: nounwind
define i32 @a() {
; Make sure we don't use $gp and save $cgp prior to every external call
; CHECK-LABEL: a:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; CHECK-NEXT:    .cfi_def_cfa_offset [[#STACKFRAME_SIZE]]
; CHECK-NEXT:    csd $16, $zero, [[#STACKFRAME_SIZE - 8]]($c11)
; CHECK-NEXT:    csc $c18, $zero, [[#CAP_SIZE * 1]]($c11)
; CHECK-NEXT:    csc $c17, $zero, 0($c11)
; CHECK-NEXT:    .cfi_offset 16, -8
; CHECK-NEXT:    .cfi_offset 90, -[[#CAP_SIZE * 2]]
; CHECK-NEXT:    .cfi_offset 89, -[[#CAP_SIZE * 3]]
; CHECK-NEXT:    cmove $c18, $c26
; CHECK-NEXT:    clcbi $c12, %capcall20(external_fn1)($c18)
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    move $16, $2
; CHECK-NEXT:    clcbi $c12, %capcall20(external_fn2)($c18)
; CHECK-NEXT:    cjalr $c12, $c17
; Restore $cgp before the next call since it might not actually be external (moved to delay slot)
; CHECK-NEXT:    cmove $c26, $c18
; CHECK-NEXT:    addu $2, $16, $2
; restore $cgp after return from potential external call
; CHECK-NEXT:    cmove $c26, $c18
; CHECK-NEXT:    clc $c17, $zero, 0($c11)
; CHECK-NEXT:    clc $c18, $zero, [[#CAP_SIZE * 1]]($c11)
; CHECK-NEXT:    cld $16, $zero, [[#STACKFRAME_SIZE - 8]]($c11)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    cincoffset $c11, $c11, [[#STACKFRAME_SIZE]]
entry:
  %call = call i32 (...) @external_fn1()
  %call2 = call i32 @external_fn2()
  %result = add i32 %call, %call2
  ret i32 %result
}

declare i32 @external_fn1(...)
declare i32 @external_fn2()
