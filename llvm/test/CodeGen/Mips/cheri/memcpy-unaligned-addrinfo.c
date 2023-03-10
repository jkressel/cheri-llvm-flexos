// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %cheri128_purecap_cc1 %s -emit-llvm -O0 -o - | FileCheck %s -check-prefix OPTNONE
// RUN: %cheri128_purecap_cc1 %s -emit-llvm -O2 -o - -debug-info-kind=standalone | FileCheck %s
// RUN: %cheri128_purecap_cc1 %s -S -O2 -o - -verify -debug-info-kind=standalone | FileCheck %s -check-prefix ASM
// REQUIRES: clang
// FIXME
// This test is checking a load of detail in the debug info and I can't tell
// what it actually wants to be testing, so I've disabled the middle test.
// It's also a horrible layering violation having a test that depends on clang
// in the LLVM back end.

struct addrinfo {
  char *b;
};

// OPTNONE-LABEL: define {{[^@]+}}@c
// OPTNONE-SAME: (i8 addrspace(200)* [[A:%.*]]) addrspace(200) #0
// OPTNONE-NEXT:  entry:
// OPTNONE-NEXT:    [[RETVAL:%.*]] = alloca [[STRUCT_ADDRINFO:%.*]], align 16, addrspace(200)
// OPTNONE-NEXT:    [[A_ADDR:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
// OPTNONE-NEXT:    store i8 addrspace(200)* [[A]], i8 addrspace(200)* addrspace(200)* [[A_ADDR]], align 16
// OPTNONE-NEXT:    [[TMP0:%.*]] = bitcast [[STRUCT_ADDRINFO]] addrspace(200)* [[RETVAL]] to i8 addrspace(200)*
// OPTNONE-NEXT:    [[TMP1:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* [[A_ADDR]], align 16
// OPTNONE-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 16 [[TMP0]], i8 addrspace(200)* align 1 [[TMP1]], i64 16, i1 false)
// OPTNONE-NEXT:    [[COERCE_DIVE:%.*]] = getelementptr inbounds [[STRUCT_ADDRINFO]], [[STRUCT_ADDRINFO]] addrspace(200)* [[RETVAL]], i32 0, i32 0
// OPTNONE-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(200)* addrspace(200)* [[COERCE_DIVE]] to { i8 addrspace(200)* } addrspace(200)*
// OPTNONE-NEXT:    [[TMP3:%.*]] = load { i8 addrspace(200)* }, { i8 addrspace(200)* } addrspace(200)* [[TMP2]], align 16
// OPTNONE-NEXT:    ret { i8 addrspace(200)* } [[TMP3]]
//
// CHECK-LABEL: define {{[^@]+}}@c
// CHECK-SAME: (i8 addrspace(200)* nocapture readonly [[A:%.*]]) local_unnamed_addr addrspace(200) #0 !dbg !14
// CHECK-NEXT:  entry:
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i8 addrspace(200)* [[A]], metadata !21, metadata !DIExpression()), !dbg !23
// CHECK-NEXT:    [[RETVAL_SROA_0_0_A_ADDR_0__SROA_CAST:%.*]] = bitcast i8 addrspace(200)* [[A]] to i8 addrspace(200)* addrspace(200)*, !dbg !24
// CHECK-NEXT:    [[RETVAL_SROA_0_0_COPYLOAD:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* [[RETVAL_SROA_0_0_A_ADDR_0__SROA_CAST]], align 1, !dbg !24
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i8 addrspace(200)* [[RETVAL_SROA_0_0_COPYLOAD]], metadata !22, metadata !DIExpression()), !dbg !23
// CHECK-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue { i8 addrspace(200)* } undef, i8 addrspace(200)* [[RETVAL_SROA_0_0_COPYLOAD]], 0, !dbg !25
// CHECK-NEXT:    ret { i8 addrspace(200)* } [[DOTFCA_0_INSERT]], !dbg !25
//
struct addrinfo c(char *a) {
  struct addrinfo d;
  __builtin_memcpy(&d, a, sizeof(struct addrinfo));
  // expected-warning@-1{{found underaligned load of capability type (aligned to 1 bytes instead of 16). Will use memcpy() instead of capability load to preserve tags if it is aligned correctly at runtime}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast}}
  return d;

  // ASM:      .Ltmp1:
  // ASM-NEXT: .loc 1 42 3 prologue_end
  // ASM-NEXT: csetbounds $c4, $c3, 16
  // ASM-NEXT: clcbi	$c12, %capcall20(memcpy)($c1)
  // ASM-NEXT: csetbounds	$c3, $c11, 16
  // ASM-NEXT: .Ltmp2:
  // ASM-NEXT: #DEBUG_VALUE: c:a <- [DW_OP_LLVM_entry_value 1] $c3
  // ASM-NEXT: cjalr	$c12, $c17
  // ASM-NEXT: daddiu	$4, $zero, 16
}

struct group {
  char *b;
};
void do_stuff(struct group *g);
// OPTNONE-LABEL: define {{[^@]+}}@copy_group
// OPTNONE-SAME: (i8 addrspace(200)* [[A:%.*]]) addrspace(200) #0
// OPTNONE-NEXT:  entry:
// OPTNONE-NEXT:    [[A_ADDR:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
// OPTNONE-NEXT:    [[BUFFER:%.*]] = alloca [16 x i8], align 1, addrspace(200)
// OPTNONE-NEXT:    [[G:%.*]] = alloca [[STRUCT_GROUP:%.*]] addrspace(200)*, align 16, addrspace(200)
// OPTNONE-NEXT:    store i8 addrspace(200)* [[A]], i8 addrspace(200)* addrspace(200)* [[A_ADDR]], align 16
// OPTNONE-NEXT:    [[ARRAYDECAY:%.*]] = getelementptr inbounds [16 x i8], [16 x i8] addrspace(200)* [[BUFFER]], i64 0, i64 0
// OPTNONE-NEXT:    [[TMP0:%.*]] = bitcast i8 addrspace(200)* addrspace(200)* [[A_ADDR]] to i8 addrspace(200)*
// OPTNONE-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 1 [[ARRAYDECAY]], i8 addrspace(200)* align 16 [[TMP0]], i64 16, i1 false) #3
// OPTNONE-NEXT:    [[ARRAYDECAY1:%.*]] = getelementptr inbounds [16 x i8], [16 x i8] addrspace(200)* [[BUFFER]], i64 0, i64 0
// OPTNONE-NEXT:    [[TMP1:%.*]] = bitcast i8 addrspace(200)* [[ARRAYDECAY1]] to [[STRUCT_GROUP]] addrspace(200)*
// OPTNONE-NEXT:    store [[STRUCT_GROUP]] addrspace(200)* [[TMP1]], [[STRUCT_GROUP]] addrspace(200)* addrspace(200)* [[G]], align 16
// OPTNONE-NEXT:    [[TMP2:%.*]] = load [[STRUCT_GROUP]] addrspace(200)*, [[STRUCT_GROUP]] addrspace(200)* addrspace(200)* [[G]], align 16
// OPTNONE-NEXT:    call void @do_stuff(%struct.group addrspace(200)* [[TMP2]])
// OPTNONE-NEXT:    ret void
//
// CHECK-LABEL: define {{[^@]+}}@copy_group
// CHECK-SAME: (i8 addrspace(200)* [[A:%.*]]) local_unnamed_addr addrspace(200) #2 !dbg !26
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[BUFFER:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i8 addrspace(200)* [[A]], metadata !32, metadata !DIExpression()), !dbg !38
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast i8 addrspace(200)* addrspace(200)* [[BUFFER]] to i8 addrspace(200)*, !dbg !39
// CHECK-NEXT:    call void @llvm.lifetime.start.p200i8(i64 16, i8 addrspace(200)* nonnull [[TMP0]]) #5, !dbg !39
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i8 addrspace(200)* [[A]], metadata !33, metadata !DIExpression()), !dbg !38
// CHECK-NEXT:    store i8 addrspace(200)* [[A]], i8 addrspace(200)* addrspace(200)* [[BUFFER]], align 16, !dbg !40
// CHECK-NEXT:    [[TMP1:%.*]] = bitcast i8 addrspace(200)* addrspace(200)* [[BUFFER]] to [[STRUCT_GROUP:%.*]] addrspace(200)*, !dbg !41
// CHECK-NEXT:    call void @llvm.dbg.value(metadata [[STRUCT_GROUP]] addrspace(200)* [[TMP1]], metadata !37, metadata !DIExpression()), !dbg !38
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i8 addrspace(200)* addrspace(200)* [[BUFFER]], metadata !33, metadata !DIExpression(DW_OP_deref)), !dbg !38
// CHECK-NEXT:    call void @do_stuff(%struct.group addrspace(200)* nonnull [[TMP1]]) #5, !dbg !42
// CHECK-NEXT:    call void @llvm.lifetime.end.p200i8(i64 16, i8 addrspace(200)* nonnull [[TMP0]]) #5, !dbg !43
// CHECK-NEXT:    ret void, !dbg !43
//
void copy_group(const char *a) {
  // derived from the unaligned memcpy used in getgrent
  // NOTE: this buffer will be aligned sensibly at -O2 so that we can use a csc/clc
  char buffer[sizeof(struct group)];
  __builtin_memcpy(buffer, &a, sizeof(char *));
  struct group *g = (struct group *)buffer;
  do_stuff(g);
}

// OPTNONE-LABEL: define {{[^@]+}}@copy_group2
// OPTNONE-SAME: (i8 addrspace(200)* [[A:%.*]], i8 addrspace(200)* [[BUFFER:%.*]]) addrspace(200) #0
// OPTNONE-NEXT:  entry:
// OPTNONE-NEXT:    [[A_ADDR:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
// OPTNONE-NEXT:    [[BUFFER_ADDR:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
// OPTNONE-NEXT:    [[G:%.*]] = alloca [[STRUCT_GROUP:%.*]] addrspace(200)*, align 16, addrspace(200)
// OPTNONE-NEXT:    store i8 addrspace(200)* [[A]], i8 addrspace(200)* addrspace(200)* [[A_ADDR]], align 16
// OPTNONE-NEXT:    store i8 addrspace(200)* [[BUFFER]], i8 addrspace(200)* addrspace(200)* [[BUFFER_ADDR]], align 16
// OPTNONE-NEXT:    [[TMP0:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* [[BUFFER_ADDR]], align 16
// OPTNONE-NEXT:    [[TMP1:%.*]] = bitcast i8 addrspace(200)* addrspace(200)* [[A_ADDR]] to i8 addrspace(200)*
// OPTNONE-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 1 [[TMP0]], i8 addrspace(200)* align 16 [[TMP1]], i64 16, i1 false) #3
// OPTNONE-NEXT:    [[TMP2:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* [[BUFFER_ADDR]], align 16
// OPTNONE-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(200)* [[TMP2]] to [[STRUCT_GROUP]] addrspace(200)*
// OPTNONE-NEXT:    store [[STRUCT_GROUP]] addrspace(200)* [[TMP3]], [[STRUCT_GROUP]] addrspace(200)* addrspace(200)* [[G]], align 16
// OPTNONE-NEXT:    [[TMP4:%.*]] = load [[STRUCT_GROUP]] addrspace(200)*, [[STRUCT_GROUP]] addrspace(200)* addrspace(200)* [[G]], align 16
// OPTNONE-NEXT:    call void @do_stuff(%struct.group addrspace(200)* [[TMP4]])
// OPTNONE-NEXT:    ret void
//
// CHECK-LABEL: define {{[^@]+}}@copy_group2
// CHECK-SAME: (i8 addrspace(200)* [[A:%.*]], i8 addrspace(200)* [[BUFFER:%.*]]) local_unnamed_addr addrspace(200) #2 !dbg !44
// CHECK-NEXT:  entry:
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i8 addrspace(200)* [[A]], metadata !48, metadata !DIExpression()), !dbg !51
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i8 addrspace(200)* [[BUFFER]], metadata !49, metadata !DIExpression()), !dbg !51
// CHECK-NEXT:    [[A_ADDR_0_BUFFER_ADDR_0__SROA_CAST:%.*]] = bitcast i8 addrspace(200)* [[BUFFER]] to i8 addrspace(200)* addrspace(200)*, !dbg !52
// CHECK-NEXT:    store i8 addrspace(200)* [[A]], i8 addrspace(200)* addrspace(200)* [[A_ADDR_0_BUFFER_ADDR_0__SROA_CAST]], align 1, !dbg !52
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast i8 addrspace(200)* [[BUFFER]] to [[STRUCT_GROUP:%.*]] addrspace(200)*, !dbg !53
// CHECK-NEXT:    call void @llvm.dbg.value(metadata [[STRUCT_GROUP]] addrspace(200)* [[TMP0]], metadata !50, metadata !DIExpression()), !dbg !51
// CHECK-NEXT:    tail call void @do_stuff(%struct.group addrspace(200)* [[TMP0]]) #5, !dbg !54
// CHECK-NEXT:    ret void, !dbg !55
//
void copy_group2(const char *a, char *buffer) {

  // derived from the unaligned memcpy used in getgrent
  // Note: this will result in an unaligned memcpy
  __builtin_memcpy(buffer, &a, sizeof(char *));
  // expected-warning@-1{{found underaligned store of capability type (aligned to 1 bytes instead of 16). Will use memcpy() instead of capability load to preserve tags if it is aligned correctly at runtime}}
  // expected-note@-2{{use __builtin_assume_aligned()}}
  struct group *g = (struct group *)buffer;
  do_stuff(g);
}

// OPTNONE-LABEL: define {{[^@]+}}@copy_group3
// OPTNONE-SAME: (i8 addrspace(200)* [[BUFFER:%.*]], i8 addrspace(200)* inreg [[A_COERCE:%.*]], i64 signext [[SIZE:%.*]]) addrspace(200) #0
// OPTNONE-NEXT:  entry:
// OPTNONE-NEXT:    [[A:%.*]] = alloca [[STRUCT_GROUP:%.*]], align 16, addrspace(200)
// OPTNONE-NEXT:    [[BUFFER_ADDR:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
// OPTNONE-NEXT:    [[SIZE_ADDR:%.*]] = alloca i64, align 8, addrspace(200)
// OPTNONE-NEXT:    [[G:%.*]] = alloca [[STRUCT_GROUP]] addrspace(200)*, align 16, addrspace(200)
// OPTNONE-NEXT:    [[COERCE_DIVE:%.*]] = getelementptr inbounds [[STRUCT_GROUP]], [[STRUCT_GROUP]] addrspace(200)* [[A]], i32 0, i32 0
// OPTNONE-NEXT:    store i8 addrspace(200)* [[A_COERCE]], i8 addrspace(200)* addrspace(200)* [[COERCE_DIVE]], align 16
// OPTNONE-NEXT:    store i8 addrspace(200)* [[BUFFER]], i8 addrspace(200)* addrspace(200)* [[BUFFER_ADDR]], align 16
// OPTNONE-NEXT:    store i64 [[SIZE]], i64 addrspace(200)* [[SIZE_ADDR]], align 8
// OPTNONE-NEXT:    [[TMP0:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* [[BUFFER_ADDR]], align 16
// OPTNONE-NEXT:    [[TMP1:%.*]] = bitcast [[STRUCT_GROUP]] addrspace(200)* [[A]] to i8 addrspace(200)*
// OPTNONE-NEXT:    [[TMP2:%.*]] = load i64, i64 addrspace(200)* [[SIZE_ADDR]], align 8
// OPTNONE-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 1 [[TMP0]], i8 addrspace(200)* align 16 [[TMP1]], i64 [[TMP2]], i1 false) #4
// OPTNONE-NEXT:    [[TMP3:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* [[BUFFER_ADDR]], align 16
// OPTNONE-NEXT:    [[TMP4:%.*]] = bitcast i8 addrspace(200)* [[TMP3]] to [[STRUCT_GROUP]] addrspace(200)*
// OPTNONE-NEXT:    store [[STRUCT_GROUP]] addrspace(200)* [[TMP4]], [[STRUCT_GROUP]] addrspace(200)* addrspace(200)* [[G]], align 16
// OPTNONE-NEXT:    [[TMP5:%.*]] = load [[STRUCT_GROUP]] addrspace(200)*, [[STRUCT_GROUP]] addrspace(200)* addrspace(200)* [[G]], align 16
// OPTNONE-NEXT:    call void @do_stuff(%struct.group addrspace(200)* [[TMP5]])
// OPTNONE-NEXT:    ret void
//
// CHECK-LABEL: define {{[^@]+}}@copy_group3
// CHECK-SAME: (i8 addrspace(200)* [[BUFFER:%.*]], i8 addrspace(200)* inreg [[A_COERCE:%.*]], i64 signext [[SIZE:%.*]]) local_unnamed_addr addrspace(200) #2 !dbg !56
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[A_SROA_0:%.*]] = alloca i8 addrspace(200)*, align 16, addrspace(200)
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i8 addrspace(200)* [[A_COERCE]], metadata !62, metadata !DIExpression()), !dbg !65
// CHECK-NEXT:    store i8 addrspace(200)* [[A_COERCE]], i8 addrspace(200)* addrspace(200)* [[A_SROA_0]], align 16
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i8 addrspace(200)* [[BUFFER]], metadata !61, metadata !DIExpression()), !dbg !65
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i64 [[SIZE]], metadata !63, metadata !DIExpression()), !dbg !65
// CHECK-NEXT:    call void @llvm.dbg.value(metadata i8 addrspace(200)* addrspace(200)* [[A_SROA_0]], metadata !62, metadata !DIExpression(DW_OP_deref)), !dbg !65
// CHECK-NEXT:    [[A_SROA_0_0__SROA_CAST:%.*]] = bitcast i8 addrspace(200)* addrspace(200)* [[A_SROA_0]] to i8 addrspace(200)*, !dbg !66
// CHECK-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 1 [[BUFFER]], i8 addrspace(200)* nonnull align 16 [[A_SROA_0_0__SROA_CAST]], i64 [[SIZE]], i1 false) #6, !dbg !66
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast i8 addrspace(200)* [[BUFFER]] to [[STRUCT_GROUP:%.*]] addrspace(200)*, !dbg !67
// CHECK-NEXT:    call void @llvm.dbg.value(metadata [[STRUCT_GROUP]] addrspace(200)* [[TMP0]], metadata !64, metadata !DIExpression()), !dbg !65
// CHECK-NEXT:    tail call void @do_stuff(%struct.group addrspace(200)* [[TMP0]]) #5, !dbg !68
// CHECK-NEXT:    ret void, !dbg !69
//
void copy_group3(char *buffer, struct group a, long size) {
  // derived from the unaligned memcpy used in getgrent
  __builtin_memcpy(buffer, &a, size);
  struct group *g = (struct group *)buffer;
  do_stuff(g);
}
