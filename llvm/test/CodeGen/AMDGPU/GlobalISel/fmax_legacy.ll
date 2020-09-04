; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -global-isel -mtriple=amdgcn-mesa-mesa3d -mcpu=tahiti < %s | FileCheck -check-prefix=GFX6 %s
; RUN: llc -global-isel -mtriple=amdgcn-mesa-mesa3d -mcpu=hawaii < %s | FileCheck -check-prefix=GFX6 %s
; RUN: llc -global-isel -mtriple=amdgcn-mesa-mesa3d -mcpu=fiji < %s | FileCheck -check-prefix=GFX8 %s

define float @v_test_fmax_legacy_ogt_f32(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_ogt_f32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e32 v0, v0, v1
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_ogt_f32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_gt_f32_e32 vcc, v0, v1
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ogt float %a, %b
  %val = select i1 %cmp, float %a, float %b
  ret float %val
}

define float @v_test_fmax_legacy_oge_f32(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_oge_f32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e32 v0, v0, v1
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_oge_f32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_ge_f32_e32 vcc, v0, v1
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp oge float %a, %b
  %val = select i1 %cmp, float %a, float %b
  ret float %val
}

define float @v_test_fmax_legacy_uge_f32(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_uge_f32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e32 v0, v1, v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_uge_f32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_nlt_f32_e32 vcc, v0, v1
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp uge float %a, %b
  %val = select i1 %cmp, float %a, float %b
  ret float %val
}

define float @v_test_fmax_legacy_ugt_f32(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_ugt_f32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e32 v0, v1, v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_ugt_f32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_nle_f32_e32 vcc, v0, v1
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ugt float %a, %b
  %val = select i1 %cmp, float %a, float %b
  ret float %val
}

define float @v_test_fmax_legacy_ole_f32(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_ole_f32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e32 v0, v1, v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_ole_f32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_le_f32_e32 vcc, v0, v1
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ole float %a, %b
  %val = select i1 %cmp, float %b, float %a
  ret float %val
}

define float @v_test_fmax_legacy_olt_f32(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_olt_f32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e32 v0, v1, v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_olt_f32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_lt_f32_e32 vcc, v0, v1
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp olt float %a, %b
  %val = select i1 %cmp, float %b, float %a
  ret float %val
}

define float @v_test_fmax_legacy_ule_f32(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_ule_f32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e32 v0, v0, v1
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_ule_f32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_ngt_f32_e32 vcc, v0, v1
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ule float %a, %b
  %val = select i1 %cmp, float %b, float %a
  ret float %val
}

define float @v_test_fmax_legacy_ult_f32(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_ult_f32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e32 v0, v0, v1
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_ult_f32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_nge_f32_e32 vcc, v0, v1
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ult float %a, %b
  %val = select i1 %cmp, float %b, float %a
  ret float %val
}

define float @v_test_fmax_legacy_oge_f32_fneg_lhs(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_oge_f32_fneg_lhs:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e64 v0, -v0, v1
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_oge_f32_fneg_lhs:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_ge_f32_e64 s[4:5], -v0, v1
; GFX8-NEXT:    v_cndmask_b32_e64 v0, v1, -v0, s[4:5]
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %a.neg = fneg float %a
  %cmp = fcmp oge float %a.neg, %b
  %val = select i1 %cmp, float %a.neg, float %b
  ret float %val
}

define float @v_test_fmax_legacy_oge_f32_fneg_rhs(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_oge_f32_fneg_rhs:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e64 v0, v0, -v1
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_oge_f32_fneg_rhs:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_ge_f32_e64 s[4:5], v0, -v1
; GFX8-NEXT:    v_cndmask_b32_e64 v0, -v1, v0, s[4:5]
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %b.neg = fneg float %b
  %cmp = fcmp oge float %a, %b.neg
  %val = select i1 %cmp, float %a, float %b.neg
  ret float %val
}

define float @v_test_fcmp_select_ord(float %a, float %b) {
; GFX6-LABEL: v_test_fcmp_select_ord:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_cmp_o_f32_e32 vcc, v0, v1
; GFX6-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fcmp_select_ord:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_o_f32_e32 vcc, v0, v1
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ord float %a, %b
  %val = select i1 %cmp, float %a, float %b
  ret float %val
}

define float @v_test_fmax_legacy_ule_f32_multi_use(float %a, float %b) {
; GFX6-LABEL: v_test_fmax_legacy_ule_f32_multi_use:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_cmp_gt_f32_e32 vcc, v0, v1
; GFX6-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX6-NEXT:    v_cndmask_b32_e64 v1, 0, 1, vcc
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    ds_write_b32 v0, v1
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_ule_f32_multi_use:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_gt_f32_e32 vcc, v0, v1
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX8-NEXT:    v_cndmask_b32_e64 v1, 0, 1, vcc
; GFX8-NEXT:    s_mov_b32 m0, -1
; GFX8-NEXT:    ds_write_b32 v0, v1
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ogt float %a, %b
  %val0 = select i1 %cmp, float %a, float %b
  %val1 = zext i1 %cmp to i32
  store i32 %val1, i32 addrspace(3)* undef
  ret float %val0
}

define double @v_test_fmax_legacy_ult_f64(double %a, double %b) {
; GFX6-LABEL: v_test_fmax_legacy_ult_f64:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_cmp_nge_f64_e32 vcc, v[0:1], v[2:3]
; GFX6-NEXT:    v_cndmask_b32_e32 v0, v0, v2, vcc
; GFX6-NEXT:    v_cndmask_b32_e32 v1, v1, v3, vcc
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_ult_f64:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_nge_f64_e32 vcc, v[0:1], v[2:3]
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v0, v2, vcc
; GFX8-NEXT:    v_cndmask_b32_e32 v1, v1, v3, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ult double %a, %b
  %val = select i1 %cmp, double %b, double %a
  ret double %val
}

define <2 x float> @v_test_fmax_legacy_ogt_v2f32(<2 x float> %a, <2 x float> %b) {
; GFX6-LABEL: v_test_fmax_legacy_ogt_v2f32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_max_legacy_f32_e32 v0, v0, v2
; GFX6-NEXT:    v_max_legacy_f32_e32 v1, v1, v3
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_test_fmax_legacy_ogt_v2f32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_cmp_gt_f32_e32 vcc, v0, v2
; GFX8-NEXT:    v_cndmask_b32_e32 v0, v2, v0, vcc
; GFX8-NEXT:    v_cmp_gt_f32_e32 vcc, v1, v3
; GFX8-NEXT:    v_cndmask_b32_e32 v1, v3, v1, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ogt <2 x float> %a, %b
  %val = select <2 x i1> %cmp, <2 x float> %a, <2 x float> %b
  ret <2 x float> %val
}
