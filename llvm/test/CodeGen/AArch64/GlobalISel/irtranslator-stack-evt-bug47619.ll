; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -global-isel -mtriple=aarch64-unknown-unknown -stop-after=irtranslator %s -o - | FileCheck %s

; Make sure the i3 %arg8 value is correctly handled. This was trying
; to use MVT for EVT values passed on the stack and asserting before
; b98f902f1877c3d679f77645a267edc89ffcd5d6
define i3 @bug47619(i64 %arg, i64 %arg1, i64 %arg2, i64 %arg3, i64 %arg4, i64 %arg5, i64 %arg6, i64 %arg7, i3 %arg8) {
  ; CHECK-LABEL: name: bug47619
  ; CHECK: bb.1.bb:
  ; CHECK:   liveins: $x0, $x1, $x2, $x3, $x4, $x5, $x6, $x7
  ; CHECK:   [[COPY:%[0-9]+]]:_(s64) = COPY $x0
  ; CHECK:   [[COPY1:%[0-9]+]]:_(s64) = COPY $x1
  ; CHECK:   [[COPY2:%[0-9]+]]:_(s64) = COPY $x2
  ; CHECK:   [[COPY3:%[0-9]+]]:_(s64) = COPY $x3
  ; CHECK:   [[COPY4:%[0-9]+]]:_(s64) = COPY $x4
  ; CHECK:   [[COPY5:%[0-9]+]]:_(s64) = COPY $x5
  ; CHECK:   [[COPY6:%[0-9]+]]:_(s64) = COPY $x6
  ; CHECK:   [[COPY7:%[0-9]+]]:_(s64) = COPY $x7
  ; CHECK:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %fixed-stack.0
  ; CHECK:   [[LOAD:%[0-9]+]]:_(s3) = G_LOAD [[FRAME_INDEX]](p0) :: (invariant load 4 from %fixed-stack.0, align 16)
  ; CHECK:   [[ANYEXT:%[0-9]+]]:_(s32) = G_ANYEXT [[LOAD]](s3)
  ; CHECK:   $w0 = COPY [[ANYEXT]](s32)
  ; CHECK:   RET_ReallyLR 0, implicit $w0
bb:
  ret i3 %arg8
}
