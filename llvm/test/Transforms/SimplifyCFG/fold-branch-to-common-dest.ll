; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -S -simplifycfg -bonus-inst-threshold=10 | FileCheck %s

declare void @sideeffect0()
declare void @sideeffect1()
declare void @sideeffect2()
declare void @use8(i8)

; Basic cases, blocks have nothing other than the comparison itself.

define void @one_pred(i8 %v0, i8 %v1) {
; CHECK-LABEL: @one_pred(
; CHECK-NEXT:  pred:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C0]], [[C1]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
pred:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %dispatch, label %final_right
dispatch:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

define void @two_preds(i8 %v0, i8 %v1, i8 %v2, i8 %v3) {
; CHECK-LABEL: @two_preds(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    br i1 [[C0]], label [[PRED0:%.*]], label [[PRED1:%.*]]
; CHECK:       pred0:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    [[C3_OLD:%.*]] = icmp eq i8 [[V3:%.*]], 0
; CHECK-NEXT:    [[OR_COND1:%.*]] = or i1 [[C1]], [[C3_OLD]]
; CHECK-NEXT:    br i1 [[OR_COND1]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       pred1:
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i8 [[V2:%.*]], 0
; CHECK-NEXT:    [[C3:%.*]] = icmp eq i8 [[V3]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C2]], [[C3]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT]], label [[FINAL_RIGHT]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
entry:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %pred0, label %pred1
pred0:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %dispatch
pred1:
  %c2 = icmp eq i8 %v2, 0
  br i1 %c2, label %dispatch, label %final_right
dispatch:
  %c3 = icmp eq i8 %v3, 0
  br i1 %c3, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

; More complex case, there's an extra op that is safe to execute unconditionally.

define void @one_pred_with_extra_op(i8 %v0, i8 %v1) {
; CHECK-LABEL: @one_pred_with_extra_op(
; CHECK-NEXT:  pred:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    [[V1_ADJ:%.*]] = add i8 [[V0]], [[V1:%.*]]
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1_ADJ]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C0]], [[C1]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
pred:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %dispatch, label %final_right
dispatch:
  %v1_adj = add i8 %v0, %v1
  %c1 = icmp eq i8 %v1_adj, 0
  br i1 %c1, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

define void @two_preds_with_extra_op(i8 %v0, i8 %v1, i8 %v2, i8 %v3) {
; CHECK-LABEL: @two_preds_with_extra_op(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    br i1 [[C0]], label [[PRED0:%.*]], label [[PRED1:%.*]]
; CHECK:       pred0:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    [[DOTOLD:%.*]] = add i8 [[V1]], [[V2:%.*]]
; CHECK-NEXT:    [[C3_OLD:%.*]] = icmp eq i8 [[DOTOLD]], 0
; CHECK-NEXT:    [[OR_COND2:%.*]] = or i1 [[C1]], [[C3_OLD]]
; CHECK-NEXT:    br i1 [[OR_COND2]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       pred1:
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i8 [[V2]], 0
; CHECK-NEXT:    [[V3_ADJ:%.*]] = add i8 [[V1]], [[V2]]
; CHECK-NEXT:    [[C3:%.*]] = icmp eq i8 [[V3_ADJ]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C2]], [[C3]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT]], label [[FINAL_RIGHT]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
entry:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %pred0, label %pred1
pred0:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %dispatch
pred1:
  %c2 = icmp eq i8 %v2, 0
  br i1 %c2, label %dispatch, label %final_right
dispatch:
  %v3_adj = add i8 %v1, %v2
  %c3 = icmp eq i8 %v3_adj, 0
  br i1 %c3, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

; More complex case, there's an extra op that is safe to execute unconditionally, and it has multiple uses.

define void @one_pred_with_extra_op_multiuse(i8 %v0, i8 %v1) {
; CHECK-LABEL: @one_pred_with_extra_op_multiuse(
; CHECK-NEXT:  pred:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    [[V1_ADJ:%.*]] = add i8 [[V0]], [[V1:%.*]]
; CHECK-NEXT:    [[V1_ADJ_ADJ:%.*]] = add i8 [[V1_ADJ]], [[V1_ADJ]]
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1_ADJ_ADJ]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C0]], [[C1]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
pred:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %dispatch, label %final_right
dispatch:
  %v1_adj = add i8 %v0, %v1
  %v1_adj_adj = add i8 %v1_adj, %v1_adj
  %c1 = icmp eq i8 %v1_adj_adj, 0
  br i1 %c1, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

define void @two_preds_with_extra_op_multiuse(i8 %v0, i8 %v1, i8 %v2, i8 %v3) {
; CHECK-LABEL: @two_preds_with_extra_op_multiuse(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    br i1 [[C0]], label [[PRED0:%.*]], label [[PRED1:%.*]]
; CHECK:       pred0:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    [[DOTOLD:%.*]] = add i8 [[V1]], [[V2:%.*]]
; CHECK-NEXT:    [[DOTOLD1:%.*]] = add i8 [[DOTOLD]], [[DOTOLD]]
; CHECK-NEXT:    [[C3_OLD:%.*]] = icmp eq i8 [[DOTOLD1]], 0
; CHECK-NEXT:    [[OR_COND4:%.*]] = or i1 [[C1]], [[C3_OLD]]
; CHECK-NEXT:    br i1 [[OR_COND4]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       pred1:
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i8 [[V2]], 0
; CHECK-NEXT:    [[V3_ADJ:%.*]] = add i8 [[V1]], [[V2]]
; CHECK-NEXT:    [[V3_ADJ_ADJ:%.*]] = add i8 [[V3_ADJ]], [[V3_ADJ]]
; CHECK-NEXT:    [[C3:%.*]] = icmp eq i8 [[V3_ADJ_ADJ]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C2]], [[C3]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT]], label [[FINAL_RIGHT]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
entry:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %pred0, label %pred1
pred0:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %dispatch
pred1:
  %c2 = icmp eq i8 %v2, 0
  br i1 %c2, label %dispatch, label %final_right
dispatch:
  %v3_adj = add i8 %v1, %v2
  %v3_adj_adj = add i8 %v3_adj, %v3_adj
  %c3 = icmp eq i8 %v3_adj_adj, 0
  br i1 %c3, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

; More complex case, there's an op that is safe to execute unconditionally,
; and said op is live-out.

define void @one_pred_with_extra_op_liveout(i8 %v0, i8 %v1) {
; CHECK-LABEL: @one_pred_with_extra_op_liveout(
; CHECK-NEXT:  pred:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    [[V1_ADJ:%.*]] = add i8 [[V0]], [[V1:%.*]]
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1_ADJ]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C0]], [[C1]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    call void @use8(i8 [[V1_ADJ]])
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
pred:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %dispatch, label %final_right
dispatch:
  %v1_adj = add i8 %v0, %v1
  %c1 = icmp eq i8 %v1_adj, 0
  br i1 %c1, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  call void @use8(i8 %v1_adj)
  ret void
final_right:
  call void @sideeffect1()
  ret void
}
define void @one_pred_with_extra_op_liveout_multiuse(i8 %v0, i8 %v1) {
; CHECK-LABEL: @one_pred_with_extra_op_liveout_multiuse(
; CHECK-NEXT:  pred:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    [[V1_ADJ:%.*]] = add i8 [[V0]], [[V1:%.*]]
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1_ADJ]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C0]], [[C1]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    call void @use8(i8 [[V1_ADJ]])
; CHECK-NEXT:    call void @use8(i8 [[V1_ADJ]])
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
pred:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %dispatch, label %final_right
dispatch:
  %v1_adj = add i8 %v0, %v1
  %c1 = icmp eq i8 %v1_adj, 0
  br i1 %c1, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  call void @use8(i8 %v1_adj)
  call void @use8(i8 %v1_adj)
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

define void @one_pred_with_extra_op_liveout_distant_phi(i8 %v0, i8 %v1) {
; CHECK-LABEL: @one_pred_with_extra_op_liveout_distant_phi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    br i1 [[C0]], label [[PRED:%.*]], label [[LEFT_END:%.*]]
; CHECK:       pred:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    [[V2_ADJ:%.*]] = add i8 [[V0]], [[V1]]
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i8 [[V2_ADJ]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C1]], [[C2]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    call void @use8(i8 [[V2_ADJ]])
; CHECK-NEXT:    br label [[LEFT_END]]
; CHECK:       left_end:
; CHECK-NEXT:    [[MERGE_LEFT:%.*]] = phi i8 [ [[V2_ADJ]], [[FINAL_LEFT]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    call void @use8(i8 [[MERGE_LEFT]])
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect2()
; CHECK-NEXT:    ret void
;
entry:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %pred, label %left_end
pred:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %dispatch, label %final_right
dispatch:
  %v2_adj = add i8 %v0, %v1
  %c2 = icmp eq i8 %v2_adj, 0
  br i1 %c2, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  call void @use8(i8 %v2_adj)
  br label %left_end
left_end:
  %merge_left = phi i8 [ %v2_adj, %final_left ], [ 0, %entry ]
  call void @sideeffect1()
  call void @use8(i8 %merge_left)
  ret void
final_right:
  call void @sideeffect2()
  ret void
}

define void @two_preds_with_extra_op_liveout(i8 %v0, i8 %v1, i8 %v2, i8 %v3) {
; CHECK-LABEL: @two_preds_with_extra_op_liveout(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    br i1 [[C0]], label [[PRED0:%.*]], label [[PRED1:%.*]]
; CHECK:       pred0:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    br i1 [[C1]], label [[FINAL_LEFT:%.*]], label [[DISPATCH:%.*]]
; CHECK:       pred1:
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i8 [[V2:%.*]], 0
; CHECK-NEXT:    [[V3_ADJ:%.*]] = add i8 [[V1]], [[V2]]
; CHECK-NEXT:    [[C3:%.*]] = icmp eq i8 [[V3_ADJ]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C2]], [[C3]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT]], label [[FINAL_RIGHT:%.*]]
; CHECK:       dispatch:
; CHECK-NEXT:    [[DOTOLD:%.*]] = add i8 [[V1]], [[V2]]
; CHECK-NEXT:    [[C3_OLD:%.*]] = icmp eq i8 [[DOTOLD]], 0
; CHECK-NEXT:    br i1 [[C3_OLD]], label [[FINAL_LEFT]], label [[FINAL_RIGHT]]
; CHECK:       final_left:
; CHECK-NEXT:    [[MERGE_LEFT:%.*]] = phi i8 [ [[DOTOLD]], [[DISPATCH]] ], [ 0, [[PRED0]] ], [ [[V3_ADJ]], [[PRED1]] ]
; CHECK-NEXT:    call void @use8(i8 [[MERGE_LEFT]])
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
entry:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %pred0, label %pred1
pred0:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %dispatch
pred1:
  %c2 = icmp eq i8 %v2, 0
  br i1 %c2, label %dispatch, label %final_right
dispatch:
  %v3_adj = add i8 %v1, %v2
  %c3 = icmp eq i8 %v3_adj, 0
  br i1 %c3, label %final_left, label %final_right
final_left:
  %merge_left = phi i8 [ %v3_adj, %dispatch ], [ 0, %pred0 ]
  call void @use8(i8 %merge_left)
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

define void @two_preds_with_extra_op_liveout_multiuse(i8 %v0, i8 %v1, i8 %v2, i8 %v3) {
; CHECK-LABEL: @two_preds_with_extra_op_liveout_multiuse(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    br i1 [[C0]], label [[PRED0:%.*]], label [[PRED1:%.*]]
; CHECK:       pred0:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    br i1 [[C1]], label [[FINAL_LEFT:%.*]], label [[DISPATCH:%.*]]
; CHECK:       pred1:
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i8 [[V2:%.*]], 0
; CHECK-NEXT:    [[V3_ADJ:%.*]] = add i8 [[V1]], [[V2]]
; CHECK-NEXT:    [[C3:%.*]] = icmp eq i8 [[V3_ADJ]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C2]], [[C3]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT]], label [[FINAL_RIGHT:%.*]]
; CHECK:       dispatch:
; CHECK-NEXT:    [[DOTOLD:%.*]] = add i8 [[V1]], [[V2]]
; CHECK-NEXT:    [[C3_OLD:%.*]] = icmp eq i8 [[DOTOLD]], 0
; CHECK-NEXT:    br i1 [[C3_OLD]], label [[FINAL_LEFT]], label [[FINAL_RIGHT]]
; CHECK:       final_left:
; CHECK-NEXT:    [[MERGE_LEFT:%.*]] = phi i8 [ [[DOTOLD]], [[DISPATCH]] ], [ 0, [[PRED0]] ], [ [[V3_ADJ]], [[PRED1]] ]
; CHECK-NEXT:    [[MERGE_LEFT_2:%.*]] = phi i8 [ [[DOTOLD]], [[DISPATCH]] ], [ 42, [[PRED0]] ], [ [[V3_ADJ]], [[PRED1]] ]
; CHECK-NEXT:    call void @use8(i8 [[MERGE_LEFT]])
; CHECK-NEXT:    call void @use8(i8 [[MERGE_LEFT_2]])
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
entry:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %pred0, label %pred1
pred0:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %dispatch
pred1:
  %c2 = icmp eq i8 %v2, 0
  br i1 %c2, label %dispatch, label %final_right
dispatch:
  %v3_adj = add i8 %v1, %v2
  %c3 = icmp eq i8 %v3_adj, 0
  br i1 %c3, label %final_left, label %final_right
final_left:
  %merge_left = phi i8 [ %v3_adj, %dispatch ], [ 0, %pred0 ]
  %merge_left_2 = phi i8 [ %v3_adj, %dispatch ], [ 42, %pred0 ]
  call void @use8(i8 %merge_left)
  call void @use8(i8 %merge_left_2)
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

; More complex case, there's an op that is safe to execute unconditionally,
; and said op is live-out, and it is only used externally.

define void @one_pred_with_extra_op_eexternally_used_only(i8 %v0, i8 %v1) {
; CHECK-LABEL: @one_pred_with_extra_op_eexternally_used_only(
; CHECK-NEXT:  pred:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    [[V1_ADJ:%.*]] = add i8 [[V0]], [[V1:%.*]]
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C0]], [[C1]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    call void @use8(i8 [[V1_ADJ]])
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
pred:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %dispatch, label %final_right
dispatch:
  %v1_adj = add i8 %v0, %v1
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  call void @use8(i8 %v1_adj)
  ret void
final_right:
  call void @sideeffect1()
  ret void
}
define void @one_pred_with_extra_op_externally_used_only_multiuse(i8 %v0, i8 %v1) {
; CHECK-LABEL: @one_pred_with_extra_op_externally_used_only_multiuse(
; CHECK-NEXT:  pred:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    [[V1_ADJ:%.*]] = add i8 [[V0]], [[V1:%.*]]
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C0]], [[C1]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    call void @use8(i8 [[V1_ADJ]])
; CHECK-NEXT:    call void @use8(i8 [[V1_ADJ]])
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
pred:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %dispatch, label %final_right
dispatch:
  %v1_adj = add i8 %v0, %v1
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  call void @use8(i8 %v1_adj)
  call void @use8(i8 %v1_adj)
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

define void @two_preds_with_extra_op_externally_used_only(i8 %v0, i8 %v1, i8 %v2, i8 %v3) {
; CHECK-LABEL: @two_preds_with_extra_op_externally_used_only(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    br i1 [[C0]], label [[PRED0:%.*]], label [[PRED1:%.*]]
; CHECK:       pred0:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    br i1 [[C1]], label [[FINAL_LEFT:%.*]], label [[DISPATCH:%.*]]
; CHECK:       pred1:
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i8 [[V2:%.*]], 0
; CHECK-NEXT:    [[V3_ADJ:%.*]] = add i8 [[V1]], [[V2]]
; CHECK-NEXT:    [[C3:%.*]] = icmp eq i8 [[V3:%.*]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C2]], [[C3]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT]], label [[FINAL_RIGHT:%.*]]
; CHECK:       dispatch:
; CHECK-NEXT:    [[DOTOLD:%.*]] = add i8 [[V1]], [[V2]]
; CHECK-NEXT:    [[C3_OLD:%.*]] = icmp eq i8 [[V3]], 0
; CHECK-NEXT:    br i1 [[C3_OLD]], label [[FINAL_LEFT]], label [[FINAL_RIGHT]]
; CHECK:       final_left:
; CHECK-NEXT:    [[MERGE_LEFT:%.*]] = phi i8 [ [[DOTOLD]], [[DISPATCH]] ], [ 0, [[PRED0]] ], [ [[V3_ADJ]], [[PRED1]] ]
; CHECK-NEXT:    call void @use8(i8 [[MERGE_LEFT]])
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
entry:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %pred0, label %pred1
pred0:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %dispatch
pred1:
  %c2 = icmp eq i8 %v2, 0
  br i1 %c2, label %dispatch, label %final_right
dispatch:
  %v3_adj = add i8 %v1, %v2
  %c3 = icmp eq i8 %v3, 0
  br i1 %c3, label %final_left, label %final_right
final_left:
  %merge_left = phi i8 [ %v3_adj, %dispatch ], [ 0, %pred0 ]
  call void @use8(i8 %merge_left)
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

define void @two_preds_with_extra_op_externally_used_only_multiuse(i8 %v0, i8 %v1, i8 %v2, i8 %v3) {
; CHECK-LABEL: @two_preds_with_extra_op_externally_used_only_multiuse(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    br i1 [[C0]], label [[PRED0:%.*]], label [[PRED1:%.*]]
; CHECK:       pred0:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    br i1 [[C1]], label [[FINAL_LEFT:%.*]], label [[DISPATCH:%.*]]
; CHECK:       pred1:
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i8 [[V2:%.*]], 0
; CHECK-NEXT:    [[V3_ADJ:%.*]] = add i8 [[V1]], [[V2]]
; CHECK-NEXT:    [[C3:%.*]] = icmp eq i8 [[V3:%.*]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[C2]], [[C3]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FINAL_LEFT]], label [[FINAL_RIGHT:%.*]]
; CHECK:       dispatch:
; CHECK-NEXT:    [[DOTOLD:%.*]] = add i8 [[V1]], [[V2]]
; CHECK-NEXT:    [[C3_OLD:%.*]] = icmp eq i8 [[V3]], 0
; CHECK-NEXT:    br i1 [[C3_OLD]], label [[FINAL_LEFT]], label [[FINAL_RIGHT]]
; CHECK:       final_left:
; CHECK-NEXT:    [[MERGE_LEFT:%.*]] = phi i8 [ [[DOTOLD]], [[DISPATCH]] ], [ 0, [[PRED0]] ], [ [[V3_ADJ]], [[PRED1]] ]
; CHECK-NEXT:    [[MERGE_LEFT_2:%.*]] = phi i8 [ [[DOTOLD]], [[DISPATCH]] ], [ 42, [[PRED0]] ], [ [[V3_ADJ]], [[PRED1]] ]
; CHECK-NEXT:    call void @use8(i8 [[MERGE_LEFT]])
; CHECK-NEXT:    call void @use8(i8 [[MERGE_LEFT_2]])
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
entry:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %pred0, label %pred1
pred0:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %dispatch
pred1:
  %c2 = icmp eq i8 %v2, 0
  br i1 %c2, label %dispatch, label %final_right
dispatch:
  %v3_adj = add i8 %v1, %v2
  %c3 = icmp eq i8 %v3, 0
  br i1 %c3, label %final_left, label %final_right
final_left:
  %merge_left = phi i8 [ %v3_adj, %dispatch ], [ 0, %pred0 ]
  %merge_left_2 = phi i8 [ %v3_adj, %dispatch ], [ 42, %pred0 ]
  call void @use8(i8 %merge_left)
  call void @use8(i8 %merge_left_2)
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}

; The liveout instruction can be located after the branch condition.
define void @one_pred_with_extra_op_externally_used_only_after_cond_distant_phi(i8 %v0, i8 %v1, i8 %v3, i8 %v4, i8 %v5) {
; CHECK-LABEL: @one_pred_with_extra_op_externally_used_only_after_cond_distant_phi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    br i1 [[C0]], label [[PRED:%.*]], label [[LEFT_END:%.*]]
; CHECK:       pred:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    br i1 [[C1]], label [[DISPATCH:%.*]], label [[FINAL_RIGHT:%.*]]
; CHECK:       dispatch:
; CHECK-NEXT:    [[C3:%.*]] = icmp eq i8 [[V3:%.*]], 0
; CHECK-NEXT:    [[V2_ADJ:%.*]] = add i8 [[V4:%.*]], [[V5:%.*]]
; CHECK-NEXT:    br i1 [[C3]], label [[FINAL_LEFT:%.*]], label [[FINAL_RIGHT]]
; CHECK:       final_left:
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    call void @use8(i8 [[V2_ADJ]])
; CHECK-NEXT:    br label [[LEFT_END]]
; CHECK:       left_end:
; CHECK-NEXT:    [[MERGE_LEFT:%.*]] = phi i8 [ [[V2_ADJ]], [[FINAL_LEFT]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    call void @use8(i8 [[MERGE_LEFT]])
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect2()
; CHECK-NEXT:    ret void
;
entry:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %pred, label %left_end
pred:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %dispatch, label %final_right
dispatch:
  %c3 = icmp eq i8 %v3, 0
  %v2_adj = add i8 %v4, %v5
  br i1 %c3, label %final_left, label %final_right
final_left:
  call void @sideeffect0()
  call void @use8(i8 %v2_adj)
  br label %left_end
left_end:
  %merge_left = phi i8 [ %v2_adj, %final_left ], [ 0, %entry ]
  call void @sideeffect1()
  call void @use8(i8 %merge_left)
  ret void
final_right:
  call void @sideeffect2()
  ret void
}
define void @two_preds_with_extra_op_externally_used_only_after_cond(i8 %v0, i8 %v1, i8 %v2, i8 %v3, i8 %v4, i8 %v5) {
; CHECK-LABEL: @two_preds_with_extra_op_externally_used_only_after_cond(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp eq i8 [[V0:%.*]], 0
; CHECK-NEXT:    br i1 [[C0]], label [[PRED0:%.*]], label [[PRED1:%.*]]
; CHECK:       pred0:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[V1:%.*]], 0
; CHECK-NEXT:    br i1 [[C1]], label [[FINAL_LEFT:%.*]], label [[DISPATCH:%.*]]
; CHECK:       pred1:
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i8 [[V2:%.*]], 0
; CHECK-NEXT:    br i1 [[C2]], label [[DISPATCH]], label [[FINAL_RIGHT:%.*]]
; CHECK:       dispatch:
; CHECK-NEXT:    [[C3:%.*]] = icmp eq i8 [[V3:%.*]], 0
; CHECK-NEXT:    [[V3_ADJ:%.*]] = add i8 [[V4:%.*]], [[V5:%.*]]
; CHECK-NEXT:    br i1 [[C3]], label [[FINAL_LEFT]], label [[FINAL_RIGHT]]
; CHECK:       final_left:
; CHECK-NEXT:    [[MERGE_LEFT:%.*]] = phi i8 [ [[V3_ADJ]], [[DISPATCH]] ], [ 0, [[PRED0]] ]
; CHECK-NEXT:    call void @use8(i8 [[MERGE_LEFT]])
; CHECK-NEXT:    call void @sideeffect0()
; CHECK-NEXT:    ret void
; CHECK:       final_right:
; CHECK-NEXT:    call void @sideeffect1()
; CHECK-NEXT:    ret void
;
entry:
  %c0 = icmp eq i8 %v0, 0
  br i1 %c0, label %pred0, label %pred1
pred0:
  %c1 = icmp eq i8 %v1, 0
  br i1 %c1, label %final_left, label %dispatch
pred1:
  %c2 = icmp eq i8 %v2, 0
  br i1 %c2, label %dispatch, label %final_right
dispatch:
  %c3 = icmp eq i8 %v3, 0
  %v3_adj = add i8 %v4, %v5
  br i1 %c3, label %final_left, label %final_right
final_left:
  %merge_left = phi i8 [ %v3_adj, %dispatch ], [ 0, %pred0 ]
  call void @use8(i8 %merge_left)
  call void @sideeffect0()
  ret void
final_right:
  call void @sideeffect1()
  ret void
}
