; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -O3 -S -mtriple=x86_64-- -mattr=avx | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

; TODO: Ideally, this should reach the backend with 1 fsub, 1 fadd, and 1 shuffle.
; That may require some coordination between VectorCombine, SLP, and other passes.
; The end goal is to get a single "vaddsubps" instruction for x86 with AVX.
 
define <4 x float> @PR45015(<4 x float> %arg, <4 x float> %arg1) {
; CHECK-LABEL: @PR45015(
; CHECK-NEXT:    [[TMP1:%.*]] = fsub <4 x float> [[ARG:%.*]], [[ARG1:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = fadd <4 x float> [[ARG]], [[ARG1]]
; CHECK-NEXT:    [[T8:%.*]] = shufflevector <4 x float> [[TMP1]], <4 x float> [[TMP2]], <4 x i32> <i32 0, i32 5, i32 undef, i32 undef>
; CHECK-NEXT:    [[TMP3:%.*]] = fsub <4 x float> [[ARG]], [[ARG1]]
; CHECK-NEXT:    [[T12:%.*]] = shufflevector <4 x float> [[T8]], <4 x float> [[TMP3]], <4 x i32> <i32 0, i32 1, i32 6, i32 undef>
; CHECK-NEXT:    [[TMP4:%.*]] = fadd <4 x float> [[ARG]], [[ARG1]]
; CHECK-NEXT:    [[T16:%.*]] = shufflevector <4 x float> [[T12]], <4 x float> [[TMP4]], <4 x i32> <i32 0, i32 1, i32 2, i32 7>
; CHECK-NEXT:    ret <4 x float> [[T16]]
;
  %t = extractelement <4 x float> %arg, i32 0
  %t2 = extractelement <4 x float> %arg1, i32 0
  %t3 = fsub float %t, %t2
  %t4 = insertelement <4 x float> undef, float %t3, i32 0
  %t5 = extractelement <4 x float> %arg, i32 1
  %t6 = extractelement <4 x float> %arg1, i32 1
  %t7 = fadd float %t5, %t6
  %t8 = insertelement <4 x float> %t4, float %t7, i32 1
  %t9 = extractelement <4 x float> %arg, i32 2
  %t10 = extractelement <4 x float> %arg1, i32 2
  %t11 = fsub float %t9, %t10
  %t12 = insertelement <4 x float> %t8, float %t11, i32 2
  %t13 = extractelement <4 x float> %arg, i32 3
  %t14 = extractelement <4 x float> %arg1, i32 3
  %t15 = fadd float %t13, %t14
  %t16 = insertelement <4 x float> %t12, float %t15, i32 3
  ret <4 x float> %t16
}
