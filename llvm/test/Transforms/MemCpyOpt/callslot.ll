; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -memcpyopt < %s | FileCheck %s

define i8 @read_dest_between_call_and_memcpy() {
; CHECK-LABEL: @read_dest_between_call_and_memcpy(
; CHECK-NEXT:    [[DEST:%.*]] = alloca [16 x i8], align 1
; CHECK-NEXT:    [[SRC:%.*]] = alloca [16 x i8], align 1
; CHECK-NEXT:    [[DEST_I8:%.*]] = bitcast [16 x i8]* [[DEST]] to i8*
; CHECK-NEXT:    [[SRC_I8:%.*]] = bitcast [16 x i8]* [[SRC]] to i8*
; CHECK-NEXT:    store i8 1, i8* [[DEST_I8]], align 1
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* [[SRC_I8]], i8 0, i64 16, i1 false)
; CHECK-NEXT:    [[X:%.*]] = load i8, i8* [[DEST_I8]], align 1
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* [[DEST_I8]], i8 0, i64 16, i1 false)
; CHECK-NEXT:    ret i8 [[X]]
;
  %dest = alloca [16 x i8]
  %src = alloca [16 x i8]
  %dest.i8 = bitcast [16 x i8]* %dest to i8*
  %src.i8 = bitcast [16 x i8]* %src to i8*
  store i8 1, i8* %dest.i8
  call void @llvm.memset.p0i8.i64(i8* %src.i8, i8 0, i64 16, i1 false)
  %x = load i8, i8* %dest.i8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest.i8, i8* %src.i8, i64 16, i1 false)
  ret i8 %x
}

define i8 @read_src_between_call_and_memcpy() {
; CHECK-LABEL: @read_src_between_call_and_memcpy(
; CHECK-NEXT:    [[DEST:%.*]] = alloca [16 x i8], align 1
; CHECK-NEXT:    [[SRC:%.*]] = alloca [16 x i8], align 1
; CHECK-NEXT:    [[DEST_I8:%.*]] = bitcast [16 x i8]* [[DEST]] to i8*
; CHECK-NEXT:    [[SRC_I8:%.*]] = bitcast [16 x i8]* [[SRC]] to i8*
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* [[SRC_I8]], i8 0, i64 16, i1 false)
; CHECK-NEXT:    [[X:%.*]] = load i8, i8* [[SRC_I8]], align 1
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* [[DEST_I8]], i8* [[SRC_I8]], i64 16, i1 false)
; CHECK-NEXT:    ret i8 [[X]]
;
  %dest = alloca [16 x i8]
  %src = alloca [16 x i8]
  %dest.i8 = bitcast [16 x i8]* %dest to i8*
  %src.i8 = bitcast [16 x i8]* %src to i8*
  call void @llvm.memset.p0i8.i64(i8* %src.i8, i8 0, i64 16, i1 false)
  %x = load i8, i8* %src.i8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest.i8, i8* %src.i8, i64 16, i1 false)
  ret i8 %x
}

define void @write_dest_between_call_and_memcpy() {
; CHECK-LABEL: @write_dest_between_call_and_memcpy(
; CHECK-NEXT:    [[DEST:%.*]] = alloca [16 x i8], align 1
; CHECK-NEXT:    [[SRC:%.*]] = alloca [16 x i8], align 1
; CHECK-NEXT:    [[DEST_I8:%.*]] = bitcast [16 x i8]* [[DEST]] to i8*
; CHECK-NEXT:    [[SRC_I8:%.*]] = bitcast [16 x i8]* [[SRC]] to i8*
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* [[SRC_I8]], i8 0, i64 16, i1 false)
; CHECK-NEXT:    store i8 1, i8* [[DEST_I8]], align 1
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* [[DEST_I8]], i8 0, i64 16, i1 false)
; CHECK-NEXT:    ret void
;
  %dest = alloca [16 x i8]
  %src = alloca [16 x i8]
  %dest.i8 = bitcast [16 x i8]* %dest to i8*
  %src.i8 = bitcast [16 x i8]* %src to i8*
  call void @llvm.memset.p0i8.i64(i8* %src.i8, i8 0, i64 16, i1 false)
  store i8 1, i8* %dest.i8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest.i8, i8* %src.i8, i64 16, i1 false)
  ret void
}

define void @write_src_between_call_and_memcpy() {
; CHECK-LABEL: @write_src_between_call_and_memcpy(
; CHECK-NEXT:    [[DEST:%.*]] = alloca [16 x i8], align 1
; CHECK-NEXT:    [[SRC:%.*]] = alloca [16 x i8], align 1
; CHECK-NEXT:    [[DEST_I8:%.*]] = bitcast [16 x i8]* [[DEST]] to i8*
; CHECK-NEXT:    [[SRC_I8:%.*]] = bitcast [16 x i8]* [[SRC]] to i8*
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* [[SRC_I8]], i8 0, i64 16, i1 false)
; CHECK-NEXT:    store i8 1, i8* [[SRC_I8]], align 1
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* [[DEST_I8]], i8* [[SRC_I8]], i64 16, i1 false)
; CHECK-NEXT:    ret void
;
  %dest = alloca [16 x i8]
  %src = alloca [16 x i8]
  %dest.i8 = bitcast [16 x i8]* %dest to i8*
  %src.i8 = bitcast [16 x i8]* %src to i8*
  call void @llvm.memset.p0i8.i64(i8* %src.i8, i8 0, i64 16, i1 false)
  store i8 1, i8* %src.i8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest.i8, i8* %src.i8, i64 16, i1 false)
  ret void
}

; TODO: This is a miscompile.
define void @throw_between_call_and_mempy(i8* dereferenceable(16) %dest.i8) {
; CHECK-LABEL: @throw_between_call_and_mempy(
; CHECK-NEXT:    [[SRC:%.*]] = alloca [16 x i8], align 1
; CHECK-NEXT:    [[SRC_I8:%.*]] = bitcast [16 x i8]* [[SRC]] to i8*
; CHECK-NEXT:    [[DEST_I81:%.*]] = bitcast i8* [[DEST_I8:%.*]] to [16 x i8]*
; CHECK-NEXT:    [[DEST_I812:%.*]] = bitcast [16 x i8]* [[DEST_I81]] to i8*
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* [[DEST_I812]], i8 0, i64 16, i1 false)
; CHECK-NEXT:    call void @may_throw() [[ATTR2:#.*]]
; CHECK-NEXT:    ret void
;
  %src = alloca [16 x i8]
  %src.i8 = bitcast [16 x i8]* %src to i8*
  call void @llvm.memset.p0i8.i64(i8* %src.i8, i8 0, i64 16, i1 false)
  call void @may_throw() readnone
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest.i8, i8* %src.i8, i64 16, i1 false)
  ret void
}

declare void @may_throw()
declare void @llvm.memcpy.p0i8.p0i8.i64(i8*, i8*, i64, i1)
declare void @llvm.memset.p0i8.i64(i8*, i8, i64, i1)
