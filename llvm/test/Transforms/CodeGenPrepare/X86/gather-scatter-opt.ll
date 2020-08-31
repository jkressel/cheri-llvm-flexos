; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -codegenprepare < %s | FileCheck %s

target datalayout =
"e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128"
target triple = "x86_64-unknown-linux-gnu"

%struct.a = type { i32, i32 }
@c = external dso_local global %struct.a, align 4
@glob_array = internal unnamed_addr constant [16 x i32] [i32 1, i32 1, i32 2, i32 3, i32 5, i32 8, i32 13, i32 21, i32 34, i32 55, i32 89, i32 144, i32 233, i32 377, i32 610, i32 987], align 16

define <4 x i32> @splat_base(i32* %base, <4 x i64> %index) {
; CHECK-LABEL: @splat_base(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr i32, i32* [[BASE:%.*]], <4 x i64> [[INDEX:%.*]]
; CHECK-NEXT:    [[RES:%.*]] = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> [[TMP1]], i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
; CHECK-NEXT:    ret <4 x i32> [[RES]]
;
  %broadcast.splatinsert = insertelement <4 x i32*> undef, i32* %base, i32 0
  %broadcast.splat = shufflevector <4 x i32*> %broadcast.splatinsert, <4 x i32*> undef, <4 x i32> zeroinitializer
  %gep = getelementptr i32, <4 x i32*> %broadcast.splat, <4 x i64> %index
  %res = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> %gep, i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
  ret <4 x i32> %res
}

define <4 x i32> @splat_struct(%struct.a* %base) {
; CHECK-LABEL: @splat_struct(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr [[STRUCT_A:%.*]], %struct.a* [[BASE:%.*]], i64 0, i32 1
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr i32, i32* [[TMP1]], <4 x i64> zeroinitializer
; CHECK-NEXT:    [[RES:%.*]] = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> [[TMP2]], i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
; CHECK-NEXT:    ret <4 x i32> [[RES]]
;
  %gep = getelementptr %struct.a, %struct.a* %base, <4 x i64> zeroinitializer, i32 1
  %res = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> %gep, i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
  ret <4 x i32> %res
}

define <4 x i32> @scalar_index(i32* %base, i64 %index) {
; CHECK-LABEL: @scalar_index(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr i32, i32* [[BASE:%.*]], i64 [[INDEX:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr i32, i32* [[TMP1]], <4 x i64> zeroinitializer
; CHECK-NEXT:    [[RES:%.*]] = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> [[TMP2]], i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
; CHECK-NEXT:    ret <4 x i32> [[RES]]
;
  %broadcast.splatinsert = insertelement <4 x i32*> undef, i32* %base, i32 0
  %broadcast.splat = shufflevector <4 x i32*> %broadcast.splatinsert, <4 x i32*> undef, <4 x i32> zeroinitializer
  %gep = getelementptr i32, <4 x i32*> %broadcast.splat, i64 %index
  %res = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> %gep, i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
  ret <4 x i32> %res
}

define <4 x i32> @splat_index(i32* %base, i64 %index) {
; CHECK-LABEL: @splat_index(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr i32, i32* [[BASE:%.*]], i64 [[INDEX:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr i32, i32* [[TMP1]], <4 x i64> zeroinitializer
; CHECK-NEXT:    [[RES:%.*]] = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> [[TMP2]], i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
; CHECK-NEXT:    ret <4 x i32> [[RES]]
;
  %broadcast.splatinsert = insertelement <4 x i64> undef, i64 %index, i32 0
  %broadcast.splat = shufflevector <4 x i64> %broadcast.splatinsert, <4 x i64> undef, <4 x i32> zeroinitializer
  %gep = getelementptr i32, i32* %base, <4 x i64> %broadcast.splat
  %res = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> %gep, i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
  ret <4 x i32> %res
}

define <4 x i32> @test_global_array(<4 x i64> %indxs) {
; CHECK-LABEL: @test_global_array(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr i32, i32* getelementptr inbounds ([16 x i32], [16 x i32]* @glob_array, i64 0, i64 0), <4 x i64> [[INDXS:%.*]]
; CHECK-NEXT:    [[G:%.*]] = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> [[TMP1]], i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
; CHECK-NEXT:    ret <4 x i32> [[G]]
;
  %p = getelementptr inbounds [16 x i32], [16 x i32]* @glob_array, i64 0, <4 x i64> %indxs
  %g = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> %p, i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
  ret <4 x i32> %g
}

define <4 x i32> @global_struct_splat() {
; CHECK-LABEL: @global_struct_splat(
; CHECK-NEXT:    [[TMP1:%.*]] = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> <i32* getelementptr inbounds (%struct.a, %struct.a* @c, i64 0, i32 1), i32* getelementptr inbounds (%struct.a, %struct.a* @c, i64 0, i32 1), i32* getelementptr inbounds (%struct.a, %struct.a* @c, i64 0, i32 1), i32* getelementptr inbounds (%struct.a, %struct.a* @c, i64 0, i32 1)>, i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
; CHECK-NEXT:    ret <4 x i32> [[TMP1]]
;
  %1 = insertelement <4 x %struct.a*> undef, %struct.a* @c, i32 0
  %2 = shufflevector <4 x %struct.a*> %1, <4 x %struct.a*> undef, <4 x i32> zeroinitializer
  %3 = getelementptr %struct.a, <4 x %struct.a*> %2, <4 x i64> zeroinitializer, i32 1
  %4 = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> %3, i32 4, <4 x i1> <i1 true, i1 true, i1 true, i1 true>, <4 x i32> undef)
  ret <4 x i32> %4
}

define <4 x i32> @splat_ptr_gather(i32* %ptr, <4 x i1> %mask, <4 x i32> %passthru) {
; CHECK-LABEL: @splat_ptr_gather(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <4 x i32*> undef, i32* [[PTR:%.*]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32*> [[TMP1]], <4 x i32*> undef, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP3:%.*]] = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> [[TMP2]], i32 4, <4 x i1> [[MASK:%.*]], <4 x i32> [[PASSTHRU:%.*]])
; CHECK-NEXT:    ret <4 x i32> [[TMP3]]
;
  %1 = insertelement <4 x i32*> undef, i32* %ptr, i32 0
  %2 = shufflevector <4 x i32*> %1, <4 x i32*> undef, <4 x i32> zeroinitializer
  %3 = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> %2, i32 4, <4 x i1> %mask, <4 x i32> %passthru)
  ret <4 x i32> %3
}

define void @splat_ptr_scatter(i32* %ptr, <4 x i1> %mask, <4 x i32> %val) {
; CHECK-LABEL: @splat_ptr_scatter(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <4 x i32*> undef, i32* [[PTR:%.*]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32*> [[TMP1]], <4 x i32*> undef, <4 x i32> zeroinitializer
; CHECK-NEXT:    call void @llvm.masked.scatter.v4i32.v4p0i32(<4 x i32> [[VAL:%.*]], <4 x i32*> [[TMP2]], i32 4, <4 x i1> [[MASK:%.*]])
; CHECK-NEXT:    ret void
;
  %1 = insertelement <4 x i32*> undef, i32* %ptr, i32 0
  %2 = shufflevector <4 x i32*> %1, <4 x i32*> undef, <4 x i32> zeroinitializer
  call void @llvm.masked.scatter.v4i32.v4p0i32(<4 x i32> %val, <4 x i32*> %2, i32 4, <4 x i1> %mask)
  ret void
}

declare <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*>, i32, <4 x i1>, <4 x i32>)
declare void @llvm.masked.scatter.v4i32.v4p0i32(<4 x i32>, <4 x i32*>, i32, <4 x i1>)
