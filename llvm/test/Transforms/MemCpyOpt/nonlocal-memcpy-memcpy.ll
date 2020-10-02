; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -memcpyopt -S -enable-memcpyopt-memoryssa=0 | FileCheck %s --check-prefixes=CHECK,NO_MSSA
; RUN: opt < %s -memcpyopt -S -enable-memcpyopt-memoryssa=1 -verify-memoryssa | FileCheck %s --check-prefixes=CHECK,MSSA

; Test whether memcpy-memcpy dependence is optimized across
; basic blocks (conditional branches and invokes).
; TODO: This is not supported yet.

%struct.s = type { i32, i32 }

@s_foo = private unnamed_addr constant %struct.s { i32 1, i32 2 }, align 4
@s_baz = private unnamed_addr constant %struct.s { i32 1, i32 2 }, align 4
@i = external constant i8*

declare void @qux()
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1)
declare void @__cxa_throw(i8*, i8*, i8*)
declare i32 @__gxx_personality_v0(...)
declare i8* @__cxa_begin_catch(i8*)

; A simple partial redundancy. Test that the second memcpy is optimized
; to copy directly from the original source rather than from the temporary.

define void @wobble(i8* noalias %dst, i8* %src, i1 %some_condition) {
; CHECK-LABEL: @wobble(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TEMP:%.*]] = alloca i8, i32 64, align 1
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 [[TEMP]], i8* nonnull align 8 [[SRC:%.*]], i64 64, i1 false)
; CHECK-NEXT:    br i1 [[SOME_CONDITION:%.*]], label [[MORE:%.*]], label [[OUT:%.*]]
; CHECK:       out:
; CHECK-NEXT:    call void @qux()
; CHECK-NEXT:    unreachable
; CHECK:       more:
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 [[DST:%.*]], i8* align 8 [[TEMP]], i64 64, i1 false)
; CHECK-NEXT:    ret void
;
bb:
  %temp = alloca i8, i32 64
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %temp, i8* nonnull align 8%src, i64 64, i1 false)
  br i1 %some_condition, label %more, label %out

out:
  call void @qux()
  unreachable

more:
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %dst, i8* align 8 %temp, i64 64, i1 false)
  ret void
}

; A CFG triangle with a partial redundancy targeting an alloca. Test that the
; memcpy inside the triangle is optimized to copy directly from the original
; source rather than from the temporary.

define i32 @foo(i1 %t3) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[S:%.*]] = alloca [[STRUCT_S:%.*]], align 4
; CHECK-NEXT:    [[T:%.*]] = alloca [[STRUCT_S]], align 4
; CHECK-NEXT:    [[S1:%.*]] = bitcast %struct.s* [[S]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 [[S1]], i8* align 4 bitcast (%struct.s* @s_foo to i8*), i64 8, i1 false)
; CHECK-NEXT:    br i1 [[T3:%.*]], label [[BB4:%.*]], label [[BB7:%.*]]
; CHECK:       bb4:
; CHECK-NEXT:    [[T5:%.*]] = bitcast %struct.s* [[T]] to i8*
; CHECK-NEXT:    [[S6:%.*]] = bitcast %struct.s* [[S]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 [[T5]], i8* align 4 [[S6]], i64 8, i1 false)
; CHECK-NEXT:    br label [[BB7]]
; CHECK:       bb7:
; CHECK-NEXT:    [[T8:%.*]] = getelementptr [[STRUCT_S]], %struct.s* [[T]], i32 0, i32 0
; CHECK-NEXT:    [[T9:%.*]] = load i32, i32* [[T8]], align 4
; CHECK-NEXT:    [[T10:%.*]] = getelementptr [[STRUCT_S]], %struct.s* [[T]], i32 0, i32 1
; CHECK-NEXT:    [[T11:%.*]] = load i32, i32* [[T10]], align 4
; CHECK-NEXT:    [[T12:%.*]] = add i32 [[T9]], [[T11]]
; CHECK-NEXT:    ret i32 [[T12]]
;
bb:
  %s = alloca %struct.s, align 4
  %t = alloca %struct.s, align 4
  %s1 = bitcast %struct.s* %s to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %s1, i8* align 4 bitcast (%struct.s* @s_foo to i8*), i64 8, i1 false)
  br i1 %t3, label %bb4, label %bb7

bb4:                                              ; preds = %bb
  %t5 = bitcast %struct.s* %t to i8*
  %s6 = bitcast %struct.s* %s to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %t5, i8* align 4 %s6, i64 8, i1 false)
  br label %bb7

bb7:                                              ; preds = %bb4, %bb
  %t8 = getelementptr %struct.s, %struct.s* %t, i32 0, i32 0
  %t9 = load i32, i32* %t8, align 4
  %t10 = getelementptr %struct.s, %struct.s* %t, i32 0, i32 1
  %t11 = load i32, i32* %t10, align 4
  %t12 = add i32 %t9, %t11
  ret i32 %t12
}

; A CFG diamond with an invoke on one side, and a partially redundant memcpy
; into an alloca on the other. Test that the memcpy inside the diamond is
; optimized to copy ; directly from the original source rather than from the
; temporary. This more complex test represents a relatively common usage
; pattern.

define i32 @baz(i1 %t5) personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: @baz(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[S:%.*]] = alloca [[STRUCT_S:%.*]], align 4
; CHECK-NEXT:    [[T:%.*]] = alloca [[STRUCT_S]], align 4
; CHECK-NEXT:    [[S3:%.*]] = bitcast %struct.s* [[S]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 [[S3]], i8* align 4 bitcast (%struct.s* @s_baz to i8*), i64 8, i1 false)
; CHECK-NEXT:    br i1 [[T5:%.*]], label [[BB6:%.*]], label [[BB22:%.*]]
; CHECK:       bb6:
; CHECK-NEXT:    invoke void @__cxa_throw(i8* null, i8* bitcast (i8** @i to i8*), i8* null)
; CHECK-NEXT:    to label [[BB25:%.*]] unwind label [[BB9:%.*]]
; CHECK:       bb9:
; CHECK-NEXT:    [[T10:%.*]] = landingpad { i8*, i32 }
; CHECK-NEXT:    catch i8* null
; CHECK-NEXT:    br label [[BB13:%.*]]
; CHECK:       bb13:
; CHECK-NEXT:    [[T15:%.*]] = call i8* @__cxa_begin_catch(i8* null)
; CHECK-NEXT:    br label [[BB23:%.*]]
; CHECK:       bb22:
; CHECK-NEXT:    [[T23:%.*]] = bitcast %struct.s* [[T]] to i8*
; CHECK-NEXT:    [[S24:%.*]] = bitcast %struct.s* [[S]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 [[T23]], i8* align 4 [[S24]], i64 8, i1 false)
; CHECK-NEXT:    br label [[BB23]]
; CHECK:       bb23:
; CHECK-NEXT:    [[T17:%.*]] = getelementptr inbounds [[STRUCT_S]], %struct.s* [[T]], i32 0, i32 0
; CHECK-NEXT:    [[T18:%.*]] = load i32, i32* [[T17]], align 4
; CHECK-NEXT:    [[T19:%.*]] = getelementptr inbounds [[STRUCT_S]], %struct.s* [[T]], i32 0, i32 1
; CHECK-NEXT:    [[T20:%.*]] = load i32, i32* [[T19]], align 4
; CHECK-NEXT:    [[T21:%.*]] = add nsw i32 [[T18]], [[T20]]
; CHECK-NEXT:    ret i32 [[T21]]
; CHECK:       bb25:
; CHECK-NEXT:    unreachable
;
bb:
  %s = alloca %struct.s, align 4
  %t = alloca %struct.s, align 4
  %s3 = bitcast %struct.s* %s to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %s3, i8* align 4 bitcast (%struct.s* @s_baz to i8*), i64 8, i1 false)
  br i1 %t5, label %bb6, label %bb22

bb6:                                              ; preds = %bb
  invoke void @__cxa_throw(i8* null, i8* bitcast (i8** @i to i8*), i8* null)
  to label %bb25 unwind label %bb9

bb9:                                              ; preds = %bb6
  %t10 = landingpad { i8*, i32 }
  catch i8* null
  br label %bb13

bb13:                                             ; preds = %bb9
  %t15 = call i8* @__cxa_begin_catch(i8* null)
  br label %bb23

bb22:                                             ; preds = %bb
  %t23 = bitcast %struct.s* %t to i8*
  %s24 = bitcast %struct.s* %s to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %t23, i8* align 4 %s24, i64 8, i1 false)
  br label %bb23

bb23:                                             ; preds = %bb22, %bb13
  %t17 = getelementptr inbounds %struct.s, %struct.s* %t, i32 0, i32 0
  %t18 = load i32, i32* %t17, align 4
  %t19 = getelementptr inbounds %struct.s, %struct.s* %t, i32 0, i32 1
  %t20 = load i32, i32* %t19, align 4
  %t21 = add nsw i32 %t18, %t20
  ret i32 %t21

bb25:                                             ; preds = %bb6
  unreachable
}
