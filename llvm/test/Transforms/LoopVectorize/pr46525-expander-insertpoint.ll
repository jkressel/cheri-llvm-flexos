; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -loop-vectorize -force-vector-width=2 -S -prefer-predicate-over-epilogue=predicate-dont-vectorize %s | FileCheck %s


; Test case for PR46525. There are two candidates to pick for
; `udiv i64 %y, %add` when expanding SCEV expressions. Make sure we pick %div,
; which dominates the vector loop.

define void @test(i16 %x, i64 %y, i32* %ptr) {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CONV19:%.*]] = sext i16 [[X:%.*]] to i64
; CHECK-NEXT:    [[ADD:%.*]] = add i64 [[CONV19]], 492802768830814067
; CHECK-NEXT:    br label [[LOOP_PREHEADER:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    [[DIV:%.*]] = udiv i64 [[Y:%.*]], [[ADD]]
; CHECK-NEXT:    [[INC:%.*]] = add i64 [[DIV]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = add nuw nsw i64 [[DIV]], 4
; CHECK-NEXT:    [[TMP1:%.*]] = udiv i64 [[TMP0]], [[INC]]
; CHECK-NEXT:    [[TMP2:%.*]] = add nuw nsw i64 [[TMP1]], 1
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_RND_UP:%.*]] = add i64 [[TMP2]], 1
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N_RND_UP]], 2
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N_RND_UP]], [[N_MOD_VF]]
; CHECK-NEXT:    [[IND_END:%.*]] = mul i64 [[N_VEC]], [[INC]]
; CHECK-NEXT:    [[TRIP_COUNT_MINUS_1:%.*]] = sub i64 [[TMP2]], 1
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <2 x i64> undef, i64 [[TRIP_COUNT_MINUS_1]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <2 x i64> [[BROADCAST_SPLATINSERT]], <2 x i64> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[PRED_STORE_CONTINUE6:%.*]] ]
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = mul i64 [[INDEX]], [[INC]]
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT1:%.*]] = insertelement <2 x i64> undef, i64 [[OFFSET_IDX]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT2:%.*]] = shufflevector <2 x i64> [[BROADCAST_SPLATINSERT1]], <2 x i64> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[DOTSPLATINSERT:%.*]] = insertelement <2 x i64> undef, i64 [[INC]], i32 0
; CHECK-NEXT:    [[DOTSPLAT:%.*]] = shufflevector <2 x i64> [[DOTSPLATINSERT]], <2 x i64> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP3:%.*]] = mul <2 x i64> <i64 0, i64 1>, [[DOTSPLAT]]
; CHECK-NEXT:    [[INDUCTION:%.*]] = add <2 x i64> [[BROADCAST_SPLAT2]], [[TMP3]]
; CHECK-NEXT:    [[TMP4:%.*]] = mul i64 0, [[INC]]
; CHECK-NEXT:    [[TMP5:%.*]] = add i64 [[OFFSET_IDX]], [[TMP4]]
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT3:%.*]] = insertelement <2 x i64> undef, i64 [[INDEX]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT4:%.*]] = shufflevector <2 x i64> [[BROADCAST_SPLATINSERT3]], <2 x i64> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[VEC_IV:%.*]] = add <2 x i64> [[BROADCAST_SPLAT4]], <i64 0, i64 1>
; CHECK-NEXT:    [[TMP6:%.*]] = icmp ule <2 x i64> [[VEC_IV]], [[BROADCAST_SPLAT]]
; CHECK-NEXT:    [[TMP7:%.*]] = extractelement <2 x i1> [[TMP6]], i32 0
; CHECK-NEXT:    br i1 [[TMP7]], label [[PRED_STORE_IF:%.*]], label [[PRED_STORE_CONTINUE:%.*]]
; CHECK:       pred.store.if:
; CHECK-NEXT:    store i32 0, i32* [[PTR:%.*]], align 4
; CHECK-NEXT:    br label [[PRED_STORE_CONTINUE]]
; CHECK:       pred.store.continue:
; CHECK-NEXT:    [[TMP8:%.*]] = extractelement <2 x i1> [[TMP6]], i32 1
; CHECK-NEXT:    br i1 [[TMP8]], label [[PRED_STORE_IF5:%.*]], label [[PRED_STORE_CONTINUE6]]
; CHECK:       pred.store.if5:
; CHECK-NEXT:    store i32 0, i32* [[PTR]], align 4
; CHECK-NEXT:    br label [[PRED_STORE_CONTINUE6]]
; CHECK:       pred.store.continue6:
; CHECK-NEXT:    [[OFFSET_IDX7:%.*]] = mul i64 [[INDEX]], [[INC]]
; CHECK-NEXT:    [[TMP9:%.*]] = trunc i64 [[OFFSET_IDX7]] to i8
; CHECK-NEXT:    [[TMP10:%.*]] = trunc i64 [[INC]] to i8
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT8:%.*]] = insertelement <2 x i8> undef, i8 [[TMP9]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT9:%.*]] = shufflevector <2 x i8> [[BROADCAST_SPLATINSERT8]], <2 x i8> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[DOTSPLATINSERT10:%.*]] = insertelement <2 x i8> undef, i8 [[TMP10]], i32 0
; CHECK-NEXT:    [[DOTSPLAT11:%.*]] = shufflevector <2 x i8> [[DOTSPLATINSERT10]], <2 x i8> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP11:%.*]] = mul <2 x i8> <i8 0, i8 1>, [[DOTSPLAT11]]
; CHECK-NEXT:    [[INDUCTION12:%.*]] = add <2 x i8> [[BROADCAST_SPLAT9]], [[TMP11]]
; CHECK-NEXT:    [[TMP12:%.*]] = mul i8 0, [[TMP10]]
; CHECK-NEXT:    [[TMP13:%.*]] = add i8 [[TMP9]], [[TMP12]]
; CHECK-NEXT:    [[TMP14:%.*]] = add i8 [[TMP13]], 1
; CHECK-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 2
; CHECK-NEXT:    [[TMP15:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP15]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop !0
;
entry:
  %conv19 = sext i16 %x to i64
  %add = add i64 %conv19, 492802768830814067
  br label %loop.preheader

loop.preheader:
  %div = udiv i64 %y, %add
  %inc = add i64 %div, 1
  br label %loop

loop:
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %loop.preheader ]
  store i32 0, i32* %ptr, align 4
  %v2 = trunc i64 %iv to i8
  %v3 = add i8 %v2, 1
  %cmp15 = icmp slt i8 %v3, 5
  %iv.next = add i64 %iv, %inc
  br i1 %cmp15, label %loop, label %loop.exit

loop.exit:
  %div.1 = udiv i64 %y, %add
  %v1 = add i64 %div.1, 1
  br label %loop.2

loop.2:
  %iv.1 = phi i64 [ %iv.next.1, %loop.2 ], [ 0, %loop.exit ]
  %iv.next.1 = add i64 %iv.1, %v1
  call void @use(i64 %iv.next.1)
  %ec = icmp ult i64 %iv.next.1, 200
  br i1 %ec, label %loop.2, label %loop.2.exit

loop.2.exit:
  %c = call i1 @cond()
  br i1 %c, label %loop.preheader, label %exit

exit:
  ret void
}

declare void @use(i64)
declare i1 @cond()
