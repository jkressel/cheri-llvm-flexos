; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; SROA would previously remove the memcpy and replace it with a single store. This is not safe if it is an unaligned capability store

; RUN: %cheri128_purecap_opt -sroa %s -o - -S -data-layout="E-m:e-pf200:128:128:128:64-i8:8:32-i16:16:32-i64:64-n32:64-S128-A200-P200-G200" | FileCheck %s -check-prefix SROA
; RUN: %cheri128_purecap_opt -sroa %s -o - -S -data-layout="E-m:e-pf200:128:128:128:64-i8:8:32-i16:16:32-i64:64-n32:64-S128-A200-P200-G200" | %cheri128_purecap_llc -O2 - -o - | FileCheck %s


@b = common addrspace(200) global i8 addrspace(200)* null, align 16
@nocaps = common addrspace(200) global [2 x i64] zeroinitializer, align 16

; Function Attrs: nounwind readnone
declare i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)*, i64) addrspace(200) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* nocapture writeonly, i8 addrspace(200)* nocapture readonly, i64, i1) addrspace(200) #2

; Function Attrs: noinline nounwind
define void @spgFormLeafTuple() addrspace(200) #0 {
; SROA-LABEL: @spgFormLeafTuple(
; SROA-NEXT:  entry:
; SROA-NEXT:    [[C:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
; SROA-NEXT:    [[TMP0:%.*]] = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 0)
; SROA-NEXT:    store i8 addrspace(200)* [[TMP0]], i8 addrspace(200)* addrspace(200)* [[C]], align 16
; SROA-NEXT:    [[TMP1:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* @b, align 16
; SROA-NEXT:    [[C_0__SROA_CAST:%.*]] = bitcast i8 addrspace(200)* addrspace(200)* [[C]] to i8 addrspace(200)*
; This should not be turned into a store since the target is not aligned!
; SROA-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 1 [[TMP1]], i8 addrspace(200)* align 16 [[C_0__SROA_CAST]], i64 16, i1 false)
; SROA-NEXT:    ret void
;
entry:
  %c = alloca i8 addrspace(200)*, align 16, addrspace(200)
  %0 = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 0)
  store i8 addrspace(200)* %0, i8 addrspace(200)* addrspace(200)* %c, align 16
  %1 = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* @b, align 16
  %2 = bitcast i8 addrspace(200)* addrspace(200)* %c to i8 addrspace(200)*
  call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 1 %1, i8 addrspace(200)* align 16 %2, i64 16, i1 false)
  ret void

  ; CHECK-LABEL: spgFormLeafTuple:
  ; CHECK: clcbi $c12, %capcall20(memcpy)($c1)
}

define void @copy_nocaps() addrspace(200) #0 {
; SROA-LABEL: @copy_nocaps(
; SROA-NEXT:  entry:
; SROA-NEXT:    [[C:%.*]] = alloca [2 x i64], align 8, addrspace(200)
; SROA-NEXT:    [[GLOBAL_CAST:%.*]] = bitcast [2 x i64] addrspace(200)* @nocaps to i8 addrspace(200)*
; SROA-NEXT:    [[C_CAST:%.*]] = bitcast [2 x i64] addrspace(200)* [[C]] to i8 addrspace(200)*
; This should not be turned into a store since the target is not aligned!
; SROA-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 8 [[C_CAST]], i8 addrspace(200)* align 8 [[GLOBAL_CAST]], i64 16, i1 false)
; SROA-NEXT:    ret void
;
entry:
  %c = alloca [2 x i64], align 8, addrspace(200)
  %src = bitcast [2 x i64] addrspace(200)* @nocaps to i8 addrspace(200)*
  %dst = bitcast [2 x i64] addrspace(200)* %c to i8 addrspace(200)*
  call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 8 %dst, i8 addrspace(200)* align 8 %src, i64 16, i1 false)
  ret void

  ; CHECK-LABEL: copy_nocaps:
  ; TODO: they type doesn't contain capabilities -> could use inlined memcpy()
  ; CHECK: clcbi $c12, %capcall20(memcpy)($c1)
}

define void @align2_should_call_memcpy() addrspace(200) #0 {
; SROA-LABEL: @align2_should_call_memcpy(
; SROA-NEXT:  entry:
; SROA-NEXT:    [[C:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
; SROA-NEXT:    [[TMP0:%.*]] = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 0)
; SROA-NEXT:    store i8 addrspace(200)* [[TMP0]], i8 addrspace(200)* addrspace(200)* [[C]], align 16
; SROA-NEXT:    [[TMP1:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* @b, align 16
; SROA-NEXT:    [[C_0__SROA_CAST:%.*]] = bitcast i8 addrspace(200)* addrspace(200)* [[C]] to i8 addrspace(200)*
; This should not be turned into a store since the target is not aligned!
; SROA-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 2 [[TMP1]], i8 addrspace(200)* align 16 [[C_0__SROA_CAST]], i64 16, i1 false)
; SROA-NEXT:    ret void
;
entry:
  %c = alloca i8 addrspace(200)*, align 16, addrspace(200)
  %0 = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 0)
  store i8 addrspace(200)* %0, i8 addrspace(200)* addrspace(200)* %c, align 16
  %1 = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* @b, align 16
  %2 = bitcast i8 addrspace(200)* addrspace(200)* %c to i8 addrspace(200)*
  call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 2 %1, i8 addrspace(200)* align 16 %2, i64 16, i1 false)
  ret void

  ; CHECK-LABEL: align2_should_call_memcpy:
  ; CHECK: clcbi $c12, %capcall20(memcpy)($c
}


; Function Attrs: noinline nounwind
define void @align4_should_call_memcpy() addrspace(200) #0 {
; SROA-LABEL: @align4_should_call_memcpy(
; SROA-NEXT:  entry:
; SROA-NEXT:    [[C:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
; SROA-NEXT:    [[TMP0:%.*]] = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 0)
; SROA-NEXT:    store i8 addrspace(200)* [[TMP0]], i8 addrspace(200)* addrspace(200)* [[C]], align 16
; SROA-NEXT:    [[TMP1:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* @b, align 16
; SROA-NEXT:    [[C_0__SROA_CAST:%.*]] = bitcast i8 addrspace(200)* addrspace(200)* [[C]] to i8 addrspace(200)*
; This should not be turned into a store since the target is not aligned!
; SROA-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 4 [[TMP1]], i8 addrspace(200)* align 16 [[C_0__SROA_CAST]], i64 16, i1 false)
; SROA-NEXT:    ret void
;
entry:
  %c = alloca i8 addrspace(200)*, align 16, addrspace(200)
  %0 = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 0)
  store i8 addrspace(200)* %0, i8 addrspace(200)* addrspace(200)* %c, align 16
  %1 = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* @b, align 16
  %2 = bitcast i8 addrspace(200)* addrspace(200)* %c to i8 addrspace(200)*
  call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 4 %1, i8 addrspace(200)* align 16 %2, i64 16, i1 false)
  ret void

  ; CHECK-LABEL: align4_should_call_memcpy:
  ; CHECK: clcbi $c12, %capcall20(memcpy)($c
}

define void @align8_should_call_memcpy() addrspace(200) #0 {
; SROA-LABEL: @align8_should_call_memcpy(
; SROA-NEXT:  entry:
; SROA-NEXT:    [[C:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
; SROA-NEXT:    [[TMP0:%.*]] = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 0)
; SROA-NEXT:    store i8 addrspace(200)* [[TMP0]], i8 addrspace(200)* addrspace(200)* [[C]], align 16
; SROA-NEXT:    [[TMP1:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* @b, align 16
; SROA-NEXT:    [[C_0__SROA_CAST:%.*]] = bitcast i8 addrspace(200)* addrspace(200)* [[C]] to i8 addrspace(200)*
; This should not be turned into a store since the target is not aligned!
; SROA-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 8 [[TMP1]], i8 addrspace(200)* align 16 [[C_0__SROA_CAST]], i64 16, i1 false)
; SROA-NEXT:    ret void
;
entry:
  %c = alloca i8 addrspace(200)*, align 16, addrspace(200)
  %0 = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 0)
  store i8 addrspace(200)* %0, i8 addrspace(200)* addrspace(200)* %c, align 16
  %1 = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* @b, align 16
  %2 = bitcast i8 addrspace(200)* addrspace(200)* %c to i8 addrspace(200)*
  call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 8 %1, i8 addrspace(200)* align 16 %2, i64 16, i1 false)
  ret void

  ; CHECK-LABEL: align8_should_call_memcpy:
  ; CHECK: clcbi $c12, %capcall20(memcpy)($c
}


; Here SROA can rewrite the memcpy to a single store:
define void @align16_can_be_inlined() addrspace(200) #0 {
; SROA-LABEL: @align16_can_be_inlined(
; SROA-NEXT:  entry:
; SROA-NEXT:    [[TMP0:%.*]] = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 0)
; SROA-NEXT:    [[TMP1:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* @b, align 16
; SROA-NEXT:    [[C_0__SROA_CAST:%.*]] = bitcast i8 addrspace(200)* [[TMP1]] to i8 addrspace(200)* addrspace(200)*
; The memcpy can be turned into a store by sroa:
; SROA-NEXT:    store i8 addrspace(200)* [[TMP0]], i8 addrspace(200)* addrspace(200)* [[C_0__SROA_CAST]], align 16
; SROA-NEXT:    ret void
;
entry:
  %c = alloca i8 addrspace(200)*, align 16, addrspace(200)
  %0 = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 0)
  store i8 addrspace(200)* %0, i8 addrspace(200)* addrspace(200)* %c, align 16
  %1 = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* @b, align 16
  %2 = bitcast i8 addrspace(200)* addrspace(200)* %c to i8 addrspace(200)*
  call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 16 %1, i8 addrspace(200)* align 16 %2, i64 16, i1 false)
  ret void
; CHECK-LABEL: align16_can_be_inlined:
; CHECK-NOT: %capcall20(memcpy)
; CHECK: clcbi $c1, %captab20(b)
; $c1 <- global void*
; CHECK: clc $c1, $zero, 0($c1)
; TODO: this could be folded:
; CHECK: cincoffset $c2, $cnull, 0
; CHECK: csc $c2, $zero, 0($c1)
}

attributes #0 = { noinline nounwind }
attributes #1 = { nounwind readnone }
attributes #2 = { argmemonly nounwind }
