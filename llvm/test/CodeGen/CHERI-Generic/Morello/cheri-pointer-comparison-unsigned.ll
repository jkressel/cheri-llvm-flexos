; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes --force-update
; DO NOT EDIT -- This file was generated from test/CodeGen/CHERI-Generic/Inputs/cheri-pointer-comparison-unsigned.ll
; RUN: llc -mtriple=aarch64 --relocation-model=pic -target-abi aapcs -mattr=+morello,-c64 %s -o - | FileCheck %s --check-prefix=HYBRID
; RUN: llc -mtriple=aarch64 --relocation-model=pic -target-abi purecap -mattr=+morello,+c64 %s -o - | FileCheck %s --check-prefix=PURECAP
; Check that selects and branches using capability compares use unsigned comparisons.
; NGINX has a loop with (void*)-1 as a sentinel value which was never entered due to this bug.
; Original issue: https://github.com/CTSRD-CHERI/llvm/issues/199
; Fixed upstream in https://reviews.llvm.org/D70917 (be15dfa88fb1ed94d12f374797f98ede6808f809)
;
; Original source code showing this surprising behaviour (for CHERI-MIPS):
; int
; main(void)
; {
;         void *a, *b;
;
;         a = (void *)0x12033091e;
;         b = (void *)0xffffffffffffffff;
;
;         if (a < b) {
;                 printf("ok\n");
;                 return (0);
;         }
;
;         printf("surprising result\n");
;         return (1);
; }
;
; Morello had a similar code generation issue for selects, where a less than
; generated a csel instruction using a singed predicate instead of the unsigned one:
; void *select_lt(void *p1, void *p2) {
;   return p1 < p2 ? p1 : p2;
; }
; See https://git.morello-project.org/morello/llvm-project/-/issues/22


define i32 @lt(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind {
; HYBRID-LABEL: lt:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    cset w0, lo
; HYBRID-NEXT:    ret
;
; PURECAP-LABEL: lt:
; PURECAP:       .Lfunc_begin0:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    cset w0, lo
; PURECAP-NEXT:    ret c30
entry:
  %cmp = icmp ult i8 addrspace(200)* %a, %b
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @le(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind {
; HYBRID-LABEL: le:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    cset w0, ls
; HYBRID-NEXT:    ret
;
; PURECAP-LABEL: le:
; PURECAP:       .Lfunc_begin1:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    cset w0, ls
; PURECAP-NEXT:    ret c30
entry:
  %cmp = icmp ule i8 addrspace(200)* %a, %b
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @gt(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind {
; HYBRID-LABEL: gt:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    cset w0, hi
; HYBRID-NEXT:    ret
;
; PURECAP-LABEL: gt:
; PURECAP:       .Lfunc_begin2:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    cset w0, hi
; PURECAP-NEXT:    ret c30
entry:
  %cmp = icmp ugt i8 addrspace(200)* %a, %b
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @ge(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind {
; HYBRID-LABEL: ge:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    cset w0, hs
; HYBRID-NEXT:    ret
;
; PURECAP-LABEL: ge:
; PURECAP:       .Lfunc_begin3:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    cset w0, hs
; PURECAP-NEXT:    ret c30
entry:
  %cmp = icmp uge i8 addrspace(200)* %a, %b
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i8 addrspace(200)* @select_lt(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind {
; HYBRID-LABEL: select_lt:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    csel c0, c0, c1, lo
; HYBRID-NEXT:    ret
;
; PURECAP-LABEL: select_lt:
; PURECAP:       .Lfunc_begin4:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    csel c0, c0, c1, lo
; PURECAP-NEXT:    ret c30
entry:
  %cmp = icmp ult i8 addrspace(200)* %a, %b
  %cond = select i1 %cmp, i8 addrspace(200)* %a, i8 addrspace(200)* %b
  ret i8 addrspace(200)* %cond
}

define i8 addrspace(200)* @select_le(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind {
; HYBRID-LABEL: select_le:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    csel c0, c0, c1, ls
; HYBRID-NEXT:    ret
;
; PURECAP-LABEL: select_le:
; PURECAP:       .Lfunc_begin5:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    csel c0, c0, c1, ls
; PURECAP-NEXT:    ret c30
entry:
  %cmp = icmp ule i8 addrspace(200)* %a, %b
  %cond = select i1 %cmp, i8 addrspace(200)* %a, i8 addrspace(200)* %b
  ret i8 addrspace(200)* %cond
}

define i8 addrspace(200)* @select_gt(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind {
; HYBRID-LABEL: select_gt:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    csel c0, c0, c1, hi
; HYBRID-NEXT:    ret
;
; PURECAP-LABEL: select_gt:
; PURECAP:       .Lfunc_begin6:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    csel c0, c0, c1, hi
; PURECAP-NEXT:    ret c30
entry:
  %cmp = icmp ugt i8 addrspace(200)* %a, %b
  %cond = select i1 %cmp, i8 addrspace(200)* %a, i8 addrspace(200)* %b
  ret i8 addrspace(200)* %cond
}

define i8 addrspace(200)* @select_ge(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind {
; HYBRID-LABEL: select_ge:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    csel c0, c0, c1, hs
; HYBRID-NEXT:    ret
;
; PURECAP-LABEL: select_ge:
; PURECAP:       .Lfunc_begin7:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    csel c0, c0, c1, hs
; PURECAP-NEXT:    ret c30
entry:
  %cmp = icmp uge i8 addrspace(200)* %a, %b
  %cond = select i1 %cmp, i8 addrspace(200)* %a, i8 addrspace(200)* %b
  ret i8 addrspace(200)* %cond
}

declare i32 @func1() nounwind noreturn
declare i32 @func2() nounwind noreturn

define i32 @branch_lt(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind noreturn {
; HYBRID-LABEL: branch_lt:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    b.hs .LBB8_2
; HYBRID-NEXT:  // %bb.1: // %if.then
; HYBRID-NEXT:    bl func1
; HYBRID-NEXT:  .LBB8_2: // %if.end
; HYBRID-NEXT:    bl func2
;
; PURECAP-LABEL: branch_lt:
; PURECAP:       .Lfunc_begin8:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    b.hs .LBB8_2
; PURECAP-NEXT:  // %bb.1: // %if.then
; PURECAP-NEXT:    bl func1
; PURECAP-NEXT:  .LBB8_2: // %if.end
; PURECAP-NEXT:    bl func2
entry:
  %cmp = icmp ult i8 addrspace(200)* %a, %b
  br i1 %cmp, label %if.then, label %if.end
if.then:
  %retval1 = tail call i32 @func1()
  ret i32 %retval1
if.end:
  %retval2 = tail call i32 @func2()
  ret i32 %retval2
}

define i32 @branch_le(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind noreturn {
; HYBRID-LABEL: branch_le:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    b.hi .LBB9_2
; HYBRID-NEXT:  // %bb.1: // %if.then
; HYBRID-NEXT:    bl func1
; HYBRID-NEXT:  .LBB9_2: // %if.end
; HYBRID-NEXT:    bl func2
;
; PURECAP-LABEL: branch_le:
; PURECAP:       .Lfunc_begin9:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    b.hi .LBB9_2
; PURECAP-NEXT:  // %bb.1: // %if.then
; PURECAP-NEXT:    bl func1
; PURECAP-NEXT:  .LBB9_2: // %if.end
; PURECAP-NEXT:    bl func2
entry:
  %cmp = icmp ule i8 addrspace(200)* %a, %b
  br i1 %cmp, label %if.then, label %if.end
if.then:
  %retval1 = tail call i32 @func1()
  ret i32 %retval1
if.end:
  %retval2 = tail call i32 @func2()
  ret i32 %retval2
}

define i32 @branch_gt(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind noreturn {
; HYBRID-LABEL: branch_gt:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    b.ls .LBB10_2
; HYBRID-NEXT:  // %bb.1: // %if.then
; HYBRID-NEXT:    bl func1
; HYBRID-NEXT:  .LBB10_2: // %if.end
; HYBRID-NEXT:    bl func2
;
; PURECAP-LABEL: branch_gt:
; PURECAP:       .Lfunc_begin10:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    b.ls .LBB10_2
; PURECAP-NEXT:  // %bb.1: // %if.then
; PURECAP-NEXT:    bl func1
; PURECAP-NEXT:  .LBB10_2: // %if.end
; PURECAP-NEXT:    bl func2
entry:
  %cmp = icmp ugt i8 addrspace(200)* %a, %b
  br i1 %cmp, label %if.then, label %if.end
if.then:
  %retval1 = tail call i32 @func1()
  ret i32 %retval1
if.end:
  %retval2 = tail call i32 @func2()
  ret i32 %retval2
}

define i32 @branch_ge(i8 addrspace(200)* %a, i8 addrspace(200)* %b) nounwind noreturn {
; HYBRID-LABEL: branch_ge:
; HYBRID:       // %bb.0: // %entry
; HYBRID-NEXT:    cmp x0, x1
; HYBRID-NEXT:    b.lo .LBB11_2
; HYBRID-NEXT:  // %bb.1: // %if.then
; HYBRID-NEXT:    bl func1
; HYBRID-NEXT:  .LBB11_2: // %if.end
; HYBRID-NEXT:    bl func2
;
; PURECAP-LABEL: branch_ge:
; PURECAP:       .Lfunc_begin11:
; PURECAP-NEXT:  // %bb.0: // %entry
; PURECAP-NEXT:    cmp x0, x1
; PURECAP-NEXT:    b.lo .LBB11_2
; PURECAP-NEXT:  // %bb.1: // %if.then
; PURECAP-NEXT:    bl func1
; PURECAP-NEXT:  .LBB11_2: // %if.end
; PURECAP-NEXT:    bl func2
entry:
  %cmp = icmp uge i8 addrspace(200)* %a, %b
  br i1 %cmp, label %if.then, label %if.end
if.then:
  %retval1 = tail call i32 @func1()
  ret i32 %retval1
if.end:
  %retval2 = tail call i32 @func2()
  ret i32 %retval2
}
