; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %cheri_purecap_llc -verify-machineinstrs -O0 -o - %s | %cheri_FileCheck %s
; REQUIRES: cheri_is_128

; Check that sret of capability tuples does not result in a memcpy
; Similar issue was found compiling rust-derived IR that was generating a LDL instruction for i128.
; Again the sret value is align 1

declare dso_local void @use_tuple_cap(i8 addrspace(200)*) unnamed_addr addrspace(200) #0
declare dso_local void @use_tuple_i64(i64) unnamed_addr addrspace(200) #0
declare dso_local void @use_huge_value(i1024) unnamed_addr addrspace(200) #0

declare dso_local { i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)* } @get_tuple_cap(i8 addrspace(200)*) unnamed_addr addrspace(200) #0
declare dso_local { i64, i64, i64, i64 } @get_tuple_i64(i8 addrspace(200)*) unnamed_addr addrspace(200) #0
declare dso_local i1024 @get_huge_type(i8 addrspace(200)*) unnamed_addr addrspace(200) #0

define internal void @test(i8 addrspace(200)* align 16 dereferenceable(16) %ctr) unnamed_addr addrspace(200) nounwind #0 {
; CHECK-LABEL: test:
; CHECK:       # %bb.0: # %start
; CHECK-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; CHECK-NEXT:    csc $c17, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    clcbi $c12, %capcall20(get_tuple_cap)($c1)
; CHECK-NEXT:    cincoffset $c2, $c11, 32
; CHECK-NEXT:    csc $c3, $zero, [[#STACKFRAME_SIZE - (6 * CAP_SIZE)]]($c11)
; CHECK-NEXT:    cmove $c3, $c2
; CHECK-NEXT:    clc $c4, $zero, [[#STACKFRAME_SIZE - (6 * CAP_SIZE)]]($c11)
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    csc $c1, $zero, 0($c11)
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    nop
; CHECK-NEXT:    clc $c3, $zero, 80($c11)
; CHECK-NEXT:    clc $c1, $zero, 0($c11)
; CHECK-NEXT:    clcbi $c12, %capcall20(use_tuple_cap)($c1)
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    nop
; CHECK-NEXT:    clc $c17, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; CHECK-NEXT:    cincoffset $c11, $c11, [[#STACKFRAME_SIZE]]
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    nop
start:
  %0 = call { i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)* } @get_tuple_cap(i8 addrspace(200)* align 16 dereferenceable(16) %ctr)
  %sret = extractvalue { i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)* } %0, 3
  call void @use_tuple_cap(i8 addrspace(200)* %sret)
  ret void
}

define internal void @test2(i8 addrspace(200)* align 16 dereferenceable(16) %ctr) unnamed_addr addrspace(200) nounwind {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0: # %start
; CHECK-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; CHECK-NEXT:    csc $c17, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    clcbi $c12, %capcall20(get_tuple_i64)($c1)
; CHECK-NEXT:    cincoffset $c2, $c11, 32
; CHECK-NEXT:    csc $c3, $zero, [[#STACKFRAME_SIZE - (4 * CAP_SIZE)]]($c11)
; CHECK-NEXT:    cmove $c3, $c2
; CHECK-NEXT:    clc $c4, $zero, [[#STACKFRAME_SIZE - (4 * CAP_SIZE)]]($c11)
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    csc $c1, $zero, 0($c11)
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    nop
; CHECK-NEXT:    cld $4, $zero, 56($c11)
; CHECK-NEXT:    clc $c1, $zero, 0($c11)
; CHECK-NEXT:    clcbi $c12, %capcall20(use_tuple_i64)($c1)
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    nop
; CHECK-NEXT:    clc $c17, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; CHECK-NEXT:    cincoffset $c11, $c11, [[#STACKFRAME_SIZE]]
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    nop
start:
  %0 = call { i64, i64, i64, i64 } @get_tuple_i64(i8 addrspace(200)* align 16 dereferenceable(16) %ctr)
  %sret = extractvalue { i64, i64, i64, i64 } %0, 3
  call void @use_tuple_i64(i64 %sret)
  ret void
}

define internal void @test3(i8 addrspace(200)* align 16 dereferenceable(16) %ctr) unnamed_addr addrspace(200) nounwind {
; CHECK-LABEL: test3:
; CHECK:       # %bb.0: # %start
; CHECK-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; CHECK-NEXT:    csc $c17, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    clcbi $c12, %capcall20(get_huge_type)($c1)
; CHECK-NEXT:    cincoffset $c2, $c11, 112
; CHECK-NEXT:    csc $c3, $zero, [[#STACKFRAME_SIZE - (10 * CAP_SIZE)]]($c11)
; CHECK-NEXT:    cmove $c3, $c2
; CHECK-NEXT:    clc $c4, $zero, [[#STACKFRAME_SIZE - (10 * CAP_SIZE)]]($c11)
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    csc $c1, $zero, [[#STACKFRAME_SIZE - (11 * CAP_SIZE)]]($c11)
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    nop
; CHECK-NEXT:    cld $11, $zero, 168($c11)
; CHECK-NEXT:    cld $10, $zero, 160($c11)
; CHECK-NEXT:    cld $9, $zero, 152($c11)
; CHECK-NEXT:    cld $8, $zero, 144($c11)
; CHECK-NEXT:    cld $7, $zero, 136($c11)
; CHECK-NEXT:    cld $6, $zero, 128($c11)
; CHECK-NEXT:    cld $5, $zero, 120($c11)
; CHECK-NEXT:    cld $1, $zero, 184($c11)
; CHECK-NEXT:    cld $2, $zero, 192($c11)
; CHECK-NEXT:    cld $3, $zero, 200($c11)
; CHECK-NEXT:    cld $4, $zero, 208($c11)
; CHECK-NEXT:    cld $12, $zero, 216($c11)
; CHECK-NEXT:    cld $13, $zero, 224($c11)
; CHECK-NEXT:    cld $14, $zero, 232($c11)
; CHECK-NEXT:    cld $15, $zero, 176($c11)
; CHECK-NEXT:    cld $24, $zero, 112($c11)
; CHECK-NEXT:    cmove $c1, $c11
; CHECK-NEXT:    csd $15, $zero, 0($c1)
; CHECK-NEXT:    csd $14, $zero, 56($c1)
; CHECK-NEXT:    csd $13, $zero, 48($c1)
; CHECK-NEXT:    csd $12, $zero, 40($c1)
; CHECK-NEXT:    csd $4, $zero, 32($c1)
; CHECK-NEXT:    csd $3, $zero, 24($c1)
; CHECK-NEXT:    csd $2, $zero, 16($c1)
; CHECK-NEXT:    csd $1, $zero, 8($c1)
; CHECK-NEXT:    csetbounds $c1, $c1, 64
; CHECK-NEXT:    ori $1, $zero, 65495
; CHECK-NEXT:    candperm $c13, $c1, $1
; CHECK-NEXT:    clc $c1, $zero, [[#STACKFRAME_SIZE - (11 * CAP_SIZE)]]($c11)
; CHECK-NEXT:    clcbi $c12, %capcall20(use_huge_value)($c1)
; CHECK-NEXT:    move $4, $24
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    nop
; CHECK-NEXT:    clc $c17, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; CHECK-NEXT:    cincoffset $c11, $c11, [[#STACKFRAME_SIZE]]
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    nop
start:
  %0 = call i1024 @get_huge_type(i8 addrspace(200)* align 16 dereferenceable(16) %ctr)
  call void @use_huge_value(i1024 %0)
  ret void
}

define internal { i64, i64, i64, i64 } @get_tuple_i64_impl() unnamed_addr addrspace(200) nounwind {
; CHECK-LABEL: get_tuple_i64_impl:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cmove $c1, $c3
; CHECK-NEXT:    daddiu $1, $zero, 40
; CHECK-NEXT:    csd $1, $zero, 24($c3)
; CHECK-NEXT:    daddiu $1, $zero, 30
; CHECK-NEXT:    csd $1, $zero, 16($c3)
; CHECK-NEXT:    daddiu $1, $zero, 20
; CHECK-NEXT:    csd $1, $zero, 8($c3)
; CHECK-NEXT:    daddiu $1, $zero, 10
; CHECK-NEXT:    csd $1, $zero, 0($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    nop
  ret { i64, i64, i64, i64 } { i64 10,  i64 20,  i64 30, i64 40 }
}

define internal { i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)* } @get_tuple_cap_impl() unnamed_addr addrspace(200) nounwind {
; CHECK-LABEL: get_tuple_cap_impl:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cmove $c1, $c3
; CHECK-NEXT:    cincoffset $c2, $cnull, 40
; CHECK-NEXT:    csc $c2, $zero, 48($c3)
; CHECK-NEXT:    cincoffset $c2, $cnull, 30
; CHECK-NEXT:    csc $c2, $zero, 32($c3)
; CHECK-NEXT:    cincoffset $c2, $cnull, 20
; CHECK-NEXT:    csc $c2, $zero, 16($c3)
; CHECK-NEXT:    cincoffset $c2, $cnull, 10
; CHECK-NEXT:    csc $c2, $zero, 0($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    nop
  ret { i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)* } {
     i8 addrspace(200)* inttoptr (i64 10 to i8 addrspace(200)*),
     i8 addrspace(200)* inttoptr (i64 20 to i8 addrspace(200)*),
     i8 addrspace(200)* inttoptr (i64 30 to i8 addrspace(200)*),
     i8 addrspace(200)* inttoptr (i64 40 to i8 addrspace(200)*)
  }
}
