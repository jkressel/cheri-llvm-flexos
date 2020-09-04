; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-amd-amdpal -mcpu=gfx900 -verify-machineinstrs < %s | FileCheck -check-prefixes=GCN,GFX9 %s
; RUN: llc -mtriple=amdgcn-amd-amdpal -mcpu=hawaii -verify-machineinstrs < %s | FileCheck -check-prefixes=GCN,GFX7 %s
; RUN: llc -mtriple=amdgcn-amd-amdpal -mcpu=tahiti -verify-machineinstrs < %s | FileCheck -check-prefixes=GCN,GFX6 %s

define <4 x i32> @load_lds_v4i32(<4 x i32> addrspace(3)* %ptr) {
; GFX9-LABEL: load_lds_v4i32:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    ds_read_b128 v[0:3], v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX7-LABEL: load_lds_v4i32:
; GFX7:       ; %bb.0:
; GFX7-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    ds_read_b128 v[0:3], v0
; GFX7-NEXT:    s_setpc_b64 s[30:31]
;
; GFX6-LABEL: load_lds_v4i32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, 8, v0
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    ds_read_b64 v[2:3], v1
; GFX6-NEXT:    ds_read_b64 v[0:1], v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
  %load = load <4 x i32>, <4 x i32> addrspace(3)* %ptr
  ret <4 x i32> %load
}

define <4 x i32> @load_lds_v4i32_align1(<4 x i32> addrspace(3)* %ptr) {
; GFX9-LABEL: load_lds_v4i32_align1:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    ds_read_u8 v1, v0
; GFX9-NEXT:    ds_read_u8 v2, v0 offset:1
; GFX9-NEXT:    ds_read_u8 v3, v0 offset:2
; GFX9-NEXT:    ds_read_u8 v4, v0 offset:3
; GFX9-NEXT:    ds_read_u8 v5, v0 offset:4
; GFX9-NEXT:    ds_read_u8 v6, v0 offset:5
; GFX9-NEXT:    ds_read_u8 v7, v0 offset:6
; GFX9-NEXT:    ds_read_u8 v8, v0 offset:7
; GFX9-NEXT:    ds_read_u8 v9, v0 offset:8
; GFX9-NEXT:    ds_read_u8 v10, v0 offset:9
; GFX9-NEXT:    ds_read_u8 v11, v0 offset:10
; GFX9-NEXT:    ds_read_u8 v12, v0 offset:11
; GFX9-NEXT:    ds_read_u8 v13, v0 offset:12
; GFX9-NEXT:    ds_read_u8 v14, v0 offset:13
; GFX9-NEXT:    ds_read_u8 v15, v0 offset:14
; GFX9-NEXT:    ds_read_u8 v16, v0 offset:15
; GFX9-NEXT:    s_waitcnt lgkmcnt(14)
; GFX9-NEXT:    v_lshl_or_b32 v0, v2, 8, v1
; GFX9-NEXT:    s_waitcnt lgkmcnt(12)
; GFX9-NEXT:    v_lshl_or_b32 v1, v4, 8, v3
; GFX9-NEXT:    v_lshl_or_b32 v0, v1, 16, v0
; GFX9-NEXT:    s_waitcnt lgkmcnt(10)
; GFX9-NEXT:    v_lshl_or_b32 v1, v6, 8, v5
; GFX9-NEXT:    s_waitcnt lgkmcnt(8)
; GFX9-NEXT:    v_lshl_or_b32 v2, v8, 8, v7
; GFX9-NEXT:    v_lshl_or_b32 v1, v2, 16, v1
; GFX9-NEXT:    s_waitcnt lgkmcnt(6)
; GFX9-NEXT:    v_lshl_or_b32 v2, v10, 8, v9
; GFX9-NEXT:    s_waitcnt lgkmcnt(4)
; GFX9-NEXT:    v_lshl_or_b32 v3, v12, 8, v11
; GFX9-NEXT:    v_lshl_or_b32 v2, v3, 16, v2
; GFX9-NEXT:    s_waitcnt lgkmcnt(2)
; GFX9-NEXT:    v_lshl_or_b32 v3, v14, 8, v13
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    v_lshl_or_b32 v4, v16, 8, v15
; GFX9-NEXT:    v_lshl_or_b32 v3, v4, 16, v3
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX7-LABEL: load_lds_v4i32_align1:
; GFX7:       ; %bb.0:
; GFX7-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    ds_read_u8 v1, v0 offset:7
; GFX7-NEXT:    ds_read_u8 v2, v0 offset:6
; GFX7-NEXT:    ds_read_u8 v3, v0 offset:5
; GFX7-NEXT:    ds_read_u8 v5, v0 offset:4
; GFX7-NEXT:    ds_read_u8 v4, v0 offset:3
; GFX7-NEXT:    ds_read_u8 v6, v0 offset:2
; GFX7-NEXT:    ds_read_u8 v7, v0 offset:1
; GFX7-NEXT:    ds_read_u8 v8, v0
; GFX7-NEXT:    s_waitcnt lgkmcnt(7)
; GFX7-NEXT:    v_lshlrev_b32_e32 v1, 8, v1
; GFX7-NEXT:    s_waitcnt lgkmcnt(3)
; GFX7-NEXT:    v_lshlrev_b32_e32 v4, 8, v4
; GFX7-NEXT:    s_waitcnt lgkmcnt(2)
; GFX7-NEXT:    v_or_b32_e32 v4, v4, v6
; GFX7-NEXT:    s_waitcnt lgkmcnt(1)
; GFX7-NEXT:    v_lshlrev_b32_e32 v7, 8, v7
; GFX7-NEXT:    v_lshlrev_b32_e32 v3, 8, v3
; GFX7-NEXT:    v_or_b32_e32 v1, v1, v2
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    v_or_b32_e32 v7, v7, v8
; GFX7-NEXT:    v_lshlrev_b32_e32 v4, 16, v4
; GFX7-NEXT:    v_or_b32_e32 v3, v3, v5
; GFX7-NEXT:    v_lshlrev_b32_e32 v1, 16, v1
; GFX7-NEXT:    v_or_b32_e32 v4, v4, v7
; GFX7-NEXT:    v_or_b32_e32 v1, v1, v3
; GFX7-NEXT:    ds_read_u8 v3, v0 offset:15
; GFX7-NEXT:    ds_read_u8 v5, v0 offset:14
; GFX7-NEXT:    ds_read_u8 v6, v0 offset:13
; GFX7-NEXT:    ds_read_u8 v7, v0 offset:12
; GFX7-NEXT:    ds_read_u8 v2, v0 offset:11
; GFX7-NEXT:    ds_read_u8 v8, v0 offset:10
; GFX7-NEXT:    ds_read_u8 v9, v0 offset:9
; GFX7-NEXT:    ds_read_u8 v0, v0 offset:8
; GFX7-NEXT:    s_waitcnt lgkmcnt(7)
; GFX7-NEXT:    v_lshlrev_b32_e32 v3, 8, v3
; GFX7-NEXT:    s_waitcnt lgkmcnt(3)
; GFX7-NEXT:    v_lshlrev_b32_e32 v2, 8, v2
; GFX7-NEXT:    s_waitcnt lgkmcnt(2)
; GFX7-NEXT:    v_or_b32_e32 v2, v2, v8
; GFX7-NEXT:    s_waitcnt lgkmcnt(1)
; GFX7-NEXT:    v_lshlrev_b32_e32 v9, 8, v9
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    v_or_b32_e32 v0, v9, v0
; GFX7-NEXT:    v_lshlrev_b32_e32 v2, 16, v2
; GFX7-NEXT:    v_or_b32_e32 v3, v3, v5
; GFX7-NEXT:    v_or_b32_e32 v2, v2, v0
; GFX7-NEXT:    v_lshlrev_b32_e32 v0, 8, v6
; GFX7-NEXT:    v_or_b32_e32 v0, v0, v7
; GFX7-NEXT:    v_lshlrev_b32_e32 v3, 16, v3
; GFX7-NEXT:    v_or_b32_e32 v3, v3, v0
; GFX7-NEXT:    v_mov_b32_e32 v0, v4
; GFX7-NEXT:    s_setpc_b64 s[30:31]
;
; GFX6-LABEL: load_lds_v4i32_align1:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, 5, v0
; GFX6-NEXT:    v_add_i32_e32 v2, vcc, 4, v0
; GFX6-NEXT:    v_add_i32_e32 v3, vcc, 7, v0
; GFX6-NEXT:    v_add_i32_e32 v4, vcc, 6, v0
; GFX6-NEXT:    v_add_i32_e32 v5, vcc, 9, v0
; GFX6-NEXT:    v_add_i32_e32 v6, vcc, 8, v0
; GFX6-NEXT:    v_add_i32_e32 v7, vcc, 11, v0
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    ds_read_u8 v2, v2
; GFX6-NEXT:    ds_read_u8 v3, v3
; GFX6-NEXT:    ds_read_u8 v4, v4
; GFX6-NEXT:    ds_read_u8 v5, v5
; GFX6-NEXT:    ds_read_u8 v6, v6
; GFX6-NEXT:    ds_read_u8 v7, v7
; GFX6-NEXT:    ds_read_u8 v1, v1
; GFX6-NEXT:    ds_read_u8 v8, v0
; GFX6-NEXT:    v_add_i32_e32 v9, vcc, 14, v0
; GFX6-NEXT:    v_add_i32_e32 v10, vcc, 3, v0
; GFX6-NEXT:    v_add_i32_e32 v11, vcc, 2, v0
; GFX6-NEXT:    s_waitcnt lgkmcnt(1)
; GFX6-NEXT:    v_lshlrev_b32_e32 v1, 8, v1
; GFX6-NEXT:    v_or_b32_e32 v1, v1, v2
; GFX6-NEXT:    v_lshlrev_b32_e32 v2, 8, v3
; GFX6-NEXT:    v_or_b32_e32 v2, v2, v4
; GFX6-NEXT:    v_lshlrev_b32_e32 v2, 16, v2
; GFX6-NEXT:    v_or_b32_e32 v1, v2, v1
; GFX6-NEXT:    v_lshlrev_b32_e32 v2, 8, v5
; GFX6-NEXT:    v_or_b32_e32 v2, v2, v6
; GFX6-NEXT:    v_lshlrev_b32_e32 v3, 8, v7
; GFX6-NEXT:    v_add_i32_e32 v4, vcc, 10, v0
; GFX6-NEXT:    v_add_i32_e32 v5, vcc, 13, v0
; GFX6-NEXT:    v_add_i32_e32 v6, vcc, 12, v0
; GFX6-NEXT:    v_add_i32_e32 v7, vcc, 15, v0
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, 1, v0
; GFX6-NEXT:    ds_read_u8 v4, v4
; GFX6-NEXT:    ds_read_u8 v5, v5
; GFX6-NEXT:    ds_read_u8 v6, v6
; GFX6-NEXT:    ds_read_u8 v7, v7
; GFX6-NEXT:    ds_read_u8 v9, v9
; GFX6-NEXT:    ds_read_u8 v10, v10
; GFX6-NEXT:    ds_read_u8 v11, v11
; GFX6-NEXT:    ds_read_u8 v0, v0
; GFX6-NEXT:    s_waitcnt lgkmcnt(7)
; GFX6-NEXT:    v_or_b32_e32 v3, v3, v4
; GFX6-NEXT:    s_waitcnt lgkmcnt(4)
; GFX6-NEXT:    v_lshlrev_b32_e32 v4, 8, v7
; GFX6-NEXT:    v_lshlrev_b32_e32 v3, 16, v3
; GFX6-NEXT:    s_waitcnt lgkmcnt(3)
; GFX6-NEXT:    v_or_b32_e32 v4, v4, v9
; GFX6-NEXT:    v_or_b32_e32 v2, v3, v2
; GFX6-NEXT:    v_lshlrev_b32_e32 v3, 8, v5
; GFX6-NEXT:    v_or_b32_e32 v3, v3, v6
; GFX6-NEXT:    v_lshlrev_b32_e32 v4, 16, v4
; GFX6-NEXT:    v_or_b32_e32 v3, v4, v3
; GFX6-NEXT:    s_waitcnt lgkmcnt(2)
; GFX6-NEXT:    v_lshlrev_b32_e32 v4, 8, v10
; GFX6-NEXT:    s_waitcnt lgkmcnt(1)
; GFX6-NEXT:    v_or_b32_e32 v4, v4, v11
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    v_lshlrev_b32_e32 v0, 8, v0
; GFX6-NEXT:    v_lshlrev_b32_e32 v4, 16, v4
; GFX6-NEXT:    v_or_b32_e32 v0, v0, v8
; GFX6-NEXT:    v_or_b32_e32 v0, v4, v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
  %load = load <4 x i32>, <4 x i32> addrspace(3)* %ptr, align 1
  ret <4 x i32> %load
}

define <4 x i32> @load_lds_v4i32_align2(<4 x i32> addrspace(3)* %ptr) {
; GFX9-LABEL: load_lds_v4i32_align2:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    ds_read_u16 v1, v0
; GFX9-NEXT:    ds_read_u16 v2, v0 offset:2
; GFX9-NEXT:    ds_read_u16 v3, v0 offset:4
; GFX9-NEXT:    ds_read_u16 v4, v0 offset:6
; GFX9-NEXT:    ds_read_u16 v5, v0 offset:8
; GFX9-NEXT:    ds_read_u16 v6, v0 offset:10
; GFX9-NEXT:    ds_read_u16 v7, v0 offset:12
; GFX9-NEXT:    ds_read_u16 v8, v0 offset:14
; GFX9-NEXT:    s_waitcnt lgkmcnt(6)
; GFX9-NEXT:    v_lshl_or_b32 v0, v2, 16, v1
; GFX9-NEXT:    s_waitcnt lgkmcnt(4)
; GFX9-NEXT:    v_lshl_or_b32 v1, v4, 16, v3
; GFX9-NEXT:    s_waitcnt lgkmcnt(2)
; GFX9-NEXT:    v_lshl_or_b32 v2, v6, 16, v5
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    v_lshl_or_b32 v3, v8, 16, v7
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX7-LABEL: load_lds_v4i32_align2:
; GFX7:       ; %bb.0:
; GFX7-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    ds_read_u16 v3, v0 offset:14
; GFX7-NEXT:    ds_read_u16 v4, v0 offset:12
; GFX7-NEXT:    ds_read_u16 v2, v0 offset:10
; GFX7-NEXT:    ds_read_u16 v5, v0 offset:8
; GFX7-NEXT:    ds_read_u16 v1, v0 offset:6
; GFX7-NEXT:    ds_read_u16 v6, v0 offset:4
; GFX7-NEXT:    ds_read_u16 v7, v0 offset:2
; GFX7-NEXT:    ds_read_u16 v0, v0
; GFX7-NEXT:    s_waitcnt lgkmcnt(5)
; GFX7-NEXT:    v_lshlrev_b32_e32 v2, 16, v2
; GFX7-NEXT:    s_waitcnt lgkmcnt(3)
; GFX7-NEXT:    v_lshlrev_b32_e32 v1, 16, v1
; GFX7-NEXT:    v_lshlrev_b32_e32 v3, 16, v3
; GFX7-NEXT:    s_waitcnt lgkmcnt(1)
; GFX7-NEXT:    v_lshlrev_b32_e32 v7, 16, v7
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    v_or_b32_e32 v0, v7, v0
; GFX7-NEXT:    v_or_b32_e32 v1, v1, v6
; GFX7-NEXT:    v_or_b32_e32 v2, v2, v5
; GFX7-NEXT:    v_or_b32_e32 v3, v3, v4
; GFX7-NEXT:    s_setpc_b64 s[30:31]
;
; GFX6-LABEL: load_lds_v4i32_align2:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, 6, v0
; GFX6-NEXT:    v_add_i32_e32 v2, vcc, 4, v0
; GFX6-NEXT:    v_add_i32_e32 v3, vcc, 10, v0
; GFX6-NEXT:    v_add_i32_e32 v4, vcc, 8, v0
; GFX6-NEXT:    v_add_i32_e32 v5, vcc, 14, v0
; GFX6-NEXT:    v_add_i32_e32 v6, vcc, 12, v0
; GFX6-NEXT:    v_add_i32_e32 v7, vcc, 2, v0
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    ds_read_u16 v2, v2
; GFX6-NEXT:    ds_read_u16 v3, v3
; GFX6-NEXT:    ds_read_u16 v4, v4
; GFX6-NEXT:    ds_read_u16 v5, v5
; GFX6-NEXT:    ds_read_u16 v6, v6
; GFX6-NEXT:    ds_read_u16 v7, v7
; GFX6-NEXT:    ds_read_u16 v1, v1
; GFX6-NEXT:    ds_read_u16 v0, v0
; GFX6-NEXT:    s_waitcnt lgkmcnt(1)
; GFX6-NEXT:    v_lshlrev_b32_e32 v1, 16, v1
; GFX6-NEXT:    v_or_b32_e32 v1, v1, v2
; GFX6-NEXT:    v_lshlrev_b32_e32 v2, 16, v3
; GFX6-NEXT:    v_lshlrev_b32_e32 v3, 16, v5
; GFX6-NEXT:    v_or_b32_e32 v2, v2, v4
; GFX6-NEXT:    v_lshlrev_b32_e32 v4, 16, v7
; GFX6-NEXT:    v_or_b32_e32 v3, v3, v6
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    v_or_b32_e32 v0, v4, v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
  %load = load <4 x i32>, <4 x i32> addrspace(3)* %ptr, align 2
  ret <4 x i32> %load
}

define <4 x i32> @load_lds_v4i32_align4(<4 x i32> addrspace(3)* %ptr) {
; GFX9-LABEL: load_lds_v4i32_align4:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v2, v0
; GFX9-NEXT:    ds_read2_b32 v[0:1], v0 offset1:1
; GFX9-NEXT:    ds_read2_b32 v[2:3], v2 offset0:2 offset1:3
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX7-LABEL: load_lds_v4i32_align4:
; GFX7:       ; %bb.0:
; GFX7-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX7-NEXT:    v_mov_b32_e32 v2, v0
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    ds_read2_b32 v[0:1], v0 offset1:1
; GFX7-NEXT:    ds_read2_b32 v[2:3], v2 offset0:2 offset1:3
; GFX7-NEXT:    s_setpc_b64 s[30:31]
;
; GFX6-LABEL: load_lds_v4i32_align4:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, 4, v0
; GFX6-NEXT:    v_add_i32_e32 v2, vcc, 8, v0
; GFX6-NEXT:    v_add_i32_e32 v3, vcc, 12, v0
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    ds_read_b32 v2, v2
; GFX6-NEXT:    ds_read_b32 v3, v3
; GFX6-NEXT:    ds_read_b32 v1, v1
; GFX6-NEXT:    ds_read_b32 v0, v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
  %load = load <4 x i32>, <4 x i32> addrspace(3)* %ptr, align 4
  ret <4 x i32> %load
}

define <4 x i32> @load_lds_v4i32_align8(<4 x i32> addrspace(3)* %ptr) {
; GFX9-LABEL: load_lds_v4i32_align8:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    ds_read_b128 v[0:3], v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX7-LABEL: load_lds_v4i32_align8:
; GFX7:       ; %bb.0:
; GFX7-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    ds_read2_b64 v[0:3], v0 offset1:1
; GFX7-NEXT:    s_setpc_b64 s[30:31]
;
; GFX6-LABEL: load_lds_v4i32_align8:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, 8, v0
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    ds_read_b64 v[2:3], v1
; GFX6-NEXT:    ds_read_b64 v[0:1], v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
  %load = load <4 x i32>, <4 x i32> addrspace(3)* %ptr, align 8
  ret <4 x i32> %load
}

define <4 x i32> @load_lds_v4i32_align16(<4 x i32> addrspace(3)* %ptr) {
; GFX9-LABEL: load_lds_v4i32_align16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    ds_read_b128 v[0:3], v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX7-LABEL: load_lds_v4i32_align16:
; GFX7:       ; %bb.0:
; GFX7-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    ds_read_b128 v[0:3], v0
; GFX7-NEXT:    s_setpc_b64 s[30:31]
;
; GFX6-LABEL: load_lds_v4i32_align16:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, 8, v0
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    ds_read_b64 v[2:3], v1
; GFX6-NEXT:    ds_read_b64 v[0:1], v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
  %load = load <4 x i32>, <4 x i32> addrspace(3)* %ptr, align 16
  ret <4 x i32> %load
}
