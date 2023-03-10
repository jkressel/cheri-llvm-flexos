; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -o - -verify-machineinstrs -global-isel -stop-after=irtranslator -fp-contract=fast %s | FileCheck %s --check-prefix=FPFAST
; RUN: llc -o - -verify-machineinstrs -global-isel -stop-after=irtranslator -fp-contract=off %s | FileCheck %s --check-prefix=FPOFF
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "aarch64--"

define float @test_fmuladd(float %x, float %y, float %z) {
  ; FPFAST-LABEL: name: test_fmuladd
  ; FPFAST: bb.1 (%ir-block.0):
  ; FPFAST:   liveins: $s0, $s1, $s2
  ; FPFAST:   [[COPY:%[0-9]+]]:_(s32) = COPY $s0
  ; FPFAST:   [[COPY1:%[0-9]+]]:_(s32) = COPY $s1
  ; FPFAST:   [[COPY2:%[0-9]+]]:_(s32) = COPY $s2
  ; FPFAST:   [[FMA:%[0-9]+]]:_(s32) = G_FMA [[COPY]], [[COPY1]], [[COPY2]]
  ; FPFAST:   $s0 = COPY [[FMA]](s32)
  ; FPFAST:   RET_ReallyLR 0, implicit $s0
  ; FPOFF-LABEL: name: test_fmuladd
  ; FPOFF: bb.1 (%ir-block.0):
  ; FPOFF:   liveins: $s0, $s1, $s2
  ; FPOFF:   [[COPY:%[0-9]+]]:_(s32) = COPY $s0
  ; FPOFF:   [[COPY1:%[0-9]+]]:_(s32) = COPY $s1
  ; FPOFF:   [[COPY2:%[0-9]+]]:_(s32) = COPY $s2
  ; FPOFF:   [[FMUL:%[0-9]+]]:_(s32) = G_FMUL [[COPY]], [[COPY1]]
  ; FPOFF:   [[FADD:%[0-9]+]]:_(s32) = G_FADD [[FMUL]], [[COPY2]]
  ; FPOFF:   $s0 = COPY [[FADD]](s32)
  ; FPOFF:   RET_ReallyLR 0, implicit $s0
  %res = call float @llvm.fmuladd.f32(float %x, float %y, float %z)
  ret float %res
}

; Function Attrs: nounwind readnone speculatable
declare float @llvm.fmuladd.f32(float, float, float) #0

attributes #0 = { nounwind readnone speculatable }
