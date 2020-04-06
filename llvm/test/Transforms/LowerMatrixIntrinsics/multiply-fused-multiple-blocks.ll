; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -lower-matrix-intrinsics -fuse-matrix-tile-size=2 -matrix-allow-contract -force-fuse-matrix -instcombine -verify-dom-info %s -S | FileCheck %s

; REQUIRES: aarch64-registered-target

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "aarch64-apple-ios"

define void @test(<6 x double> * %A, <6 x double> * %B, <9 x double>* %C, i1 %cond) {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[COL_CAST196:%.*]] = bitcast <6 x double>* [[A:%.*]] to <3 x double>*
; CHECK-NEXT:    [[COL_LOAD197:%.*]] = load <3 x double>, <3 x double>* [[COL_CAST196]], align 8
; CHECK-NEXT:    [[COL_GEP198:%.*]] = getelementptr <6 x double>, <6 x double>* [[A]], i64 0, i64 3
; CHECK-NEXT:    [[COL_CAST199:%.*]] = bitcast double* [[COL_GEP198]] to <3 x double>*
; CHECK-NEXT:    [[COL_LOAD200:%.*]] = load <3 x double>, <3 x double>* [[COL_CAST199]], align 8
; CHECK-NEXT:    [[COL_CAST201:%.*]] = bitcast <6 x double>* [[B:%.*]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD202:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST201]], align 8
; CHECK-NEXT:    [[COL_GEP203:%.*]] = getelementptr <6 x double>, <6 x double>* [[B]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST204:%.*]] = bitcast double* [[COL_GEP203]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD205:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST204]], align 8
; CHECK-NEXT:    [[COL_GEP206:%.*]] = getelementptr <6 x double>, <6 x double>* [[B]], i64 0, i64 4
; CHECK-NEXT:    [[COL_CAST207:%.*]] = bitcast double* [[COL_GEP206]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD208:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST207]], align 8
; CHECK-NEXT:    [[ST_B:%.*]] = ptrtoint <9 x double>* [[C:%.*]] to i64
; CHECK-NEXT:    [[ST_E:%.*]] = add nuw nsw i64 [[ST_B]], 72
; CHECK-NEXT:    [[LD_B:%.*]] = ptrtoint <6 x double>* [[A]] to i64
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ugt i64 [[ST_E]], [[LD_B]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[ALIAS_CONT:%.*]], label [[NO_ALIAS:%.*]]
; CHECK:       alias_cont:
; CHECK-NEXT:    [[LD_E:%.*]] = add nuw nsw i64 [[LD_B]], 48
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i64 [[LD_E]], [[ST_B]]
; CHECK-NEXT:    br i1 [[TMP1]], label [[COPY:%.*]], label [[NO_ALIAS]]
; CHECK:       copy:
; CHECK-NEXT:    [[TMP2:%.*]] = alloca <6 x double>, align 64
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast <6 x double>* [[TMP2]] to i8*
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast <6 x double>* [[A]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 64 dereferenceable(48) [[TMP3]], i8* nonnull align 16 dereferenceable(48) [[TMP4]], i64 48, i1 false)
; CHECK-NEXT:    br label [[NO_ALIAS]]
; CHECK:       no_alias:
; CHECK-NEXT:    [[TMP5:%.*]] = phi <6 x double>* [ [[A]], [[ENTRY:%.*]] ], [ [[A]], [[ALIAS_CONT]] ], [ [[TMP2]], [[COPY]] ]
; CHECK-NEXT:    [[ST_B1:%.*]] = ptrtoint <9 x double>* [[C]] to i64
; CHECK-NEXT:    [[ST_E2:%.*]] = add nuw nsw i64 [[ST_B1]], 72
; CHECK-NEXT:    [[LD_B6:%.*]] = ptrtoint <6 x double>* [[B]] to i64
; CHECK-NEXT:    [[TMP6:%.*]] = icmp ugt i64 [[ST_E2]], [[LD_B6]]
; CHECK-NEXT:    br i1 [[TMP6]], label [[ALIAS_CONT3:%.*]], label [[NO_ALIAS5:%.*]]
; CHECK:       alias_cont1:
; CHECK-NEXT:    [[LD_E7:%.*]] = add nuw nsw i64 [[LD_B6]], 48
; CHECK-NEXT:    [[TMP7:%.*]] = icmp ugt i64 [[LD_E7]], [[ST_B1]]
; CHECK-NEXT:    br i1 [[TMP7]], label [[COPY4:%.*]], label [[NO_ALIAS5]]
; CHECK:       copy2:
; CHECK-NEXT:    [[TMP8:%.*]] = alloca <6 x double>, align 64
; CHECK-NEXT:    [[TMP9:%.*]] = bitcast <6 x double>* [[TMP8]] to i8*
; CHECK-NEXT:    [[TMP10:%.*]] = bitcast <6 x double>* [[B]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 64 dereferenceable(48) [[TMP9]], i8* nonnull align 16 dereferenceable(48) [[TMP10]], i64 48, i1 false)
; CHECK-NEXT:    br label [[NO_ALIAS5]]
; CHECK:       no_alias3:
; CHECK-NEXT:    [[TMP11:%.*]] = phi <6 x double>* [ [[B]], [[NO_ALIAS]] ], [ [[B]], [[ALIAS_CONT3]] ], [ [[TMP8]], [[COPY4]] ]
; CHECK-NEXT:    [[COL_CAST8:%.*]] = bitcast <6 x double>* [[TMP5]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST8]], align 8
; CHECK-NEXT:    [[COL_GEP:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP5]], i64 0, i64 3
; CHECK-NEXT:    [[COL_CAST9:%.*]] = bitcast double* [[COL_GEP]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD10:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST9]], align 8
; CHECK-NEXT:    [[COL_CAST12:%.*]] = bitcast <6 x double>* [[TMP11]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD13:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST12]], align 8
; CHECK-NEXT:    [[COL_GEP14:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP11]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST15:%.*]] = bitcast double* [[COL_GEP14]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD16:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST15]], align 8
; CHECK-NEXT:    [[SPLAT_SPLAT:%.*]] = shufflevector <2 x double> [[COL_LOAD13]], <2 x double> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP12:%.*]] = fmul <2 x double> [[COL_LOAD]], [[SPLAT_SPLAT]]
; CHECK-NEXT:    [[SPLAT_SPLAT19:%.*]] = shufflevector <2 x double> [[COL_LOAD13]], <2 x double> undef, <2 x i32> <i32 1, i32 1>
; CHECK-NEXT:    [[TMP13:%.*]] = call <2 x double> @llvm.fmuladd.v2f64(<2 x double> [[COL_LOAD10]], <2 x double> [[SPLAT_SPLAT19]], <2 x double> [[TMP12]])
; CHECK-NEXT:    [[SPLAT_SPLAT22:%.*]] = shufflevector <2 x double> [[COL_LOAD16]], <2 x double> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP14:%.*]] = fmul <2 x double> [[COL_LOAD]], [[SPLAT_SPLAT22]]
; CHECK-NEXT:    [[SPLAT_SPLAT25:%.*]] = shufflevector <2 x double> [[COL_LOAD16]], <2 x double> undef, <2 x i32> <i32 1, i32 1>
; CHECK-NEXT:    [[TMP15:%.*]] = call <2 x double> @llvm.fmuladd.v2f64(<2 x double> [[COL_LOAD10]], <2 x double> [[SPLAT_SPLAT25]], <2 x double> [[TMP14]])
; CHECK-NEXT:    [[COL_CAST27:%.*]] = bitcast <9 x double>* [[C]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP13]], <2 x double>* [[COL_CAST27]], align 8
; CHECK-NEXT:    [[COL_GEP28:%.*]] = getelementptr <9 x double>, <9 x double>* [[C]], i64 0, i64 3
; CHECK-NEXT:    [[COL_CAST29:%.*]] = bitcast double* [[COL_GEP28]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP15]], <2 x double>* [[COL_CAST29]], align 8
; CHECK-NEXT:    [[TMP16:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP5]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST31:%.*]] = bitcast double* [[TMP16]] to <1 x double>*
; CHECK-NEXT:    [[COL_LOAD32:%.*]] = load <1 x double>, <1 x double>* [[COL_CAST31]], align 8
; CHECK-NEXT:    [[COL_GEP33:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP5]], i64 0, i64 5
; CHECK-NEXT:    [[COL_CAST34:%.*]] = bitcast double* [[COL_GEP33]] to <1 x double>*
; CHECK-NEXT:    [[COL_LOAD35:%.*]] = load <1 x double>, <1 x double>* [[COL_CAST34]], align 8
; CHECK-NEXT:    [[COL_CAST37:%.*]] = bitcast <6 x double>* [[TMP11]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD38:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST37]], align 8
; CHECK-NEXT:    [[COL_GEP39:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP11]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST40:%.*]] = bitcast double* [[COL_GEP39]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD41:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST40]], align 8
; CHECK-NEXT:    [[SPLAT_SPLATINSERT43:%.*]] = shufflevector <2 x double> [[COL_LOAD38]], <2 x double> undef, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP17:%.*]] = fmul <1 x double> [[COL_LOAD32]], [[SPLAT_SPLATINSERT43]]
; CHECK-NEXT:    [[SPLAT_SPLATINSERT46:%.*]] = shufflevector <2 x double> [[COL_LOAD38]], <2 x double> undef, <1 x i32> <i32 1>
; CHECK-NEXT:    [[TMP18:%.*]] = call <1 x double> @llvm.fmuladd.v1f64(<1 x double> [[COL_LOAD35]], <1 x double> [[SPLAT_SPLATINSERT46]], <1 x double> [[TMP17]])
; CHECK-NEXT:    [[SPLAT_SPLATINSERT49:%.*]] = shufflevector <2 x double> [[COL_LOAD41]], <2 x double> undef, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP19:%.*]] = fmul <1 x double> [[COL_LOAD32]], [[SPLAT_SPLATINSERT49]]
; CHECK-NEXT:    [[SPLAT_SPLATINSERT52:%.*]] = shufflevector <2 x double> [[COL_LOAD41]], <2 x double> undef, <1 x i32> <i32 1>
; CHECK-NEXT:    [[TMP20:%.*]] = call <1 x double> @llvm.fmuladd.v1f64(<1 x double> [[COL_LOAD35]], <1 x double> [[SPLAT_SPLATINSERT52]], <1 x double> [[TMP19]])
; CHECK-NEXT:    [[TMP21:%.*]] = getelementptr <9 x double>, <9 x double>* [[C]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST55:%.*]] = bitcast double* [[TMP21]] to <1 x double>*
; CHECK-NEXT:    store <1 x double> [[TMP18]], <1 x double>* [[COL_CAST55]], align 8
; CHECK-NEXT:    [[COL_GEP56:%.*]] = getelementptr <9 x double>, <9 x double>* [[C]], i64 0, i64 5
; CHECK-NEXT:    [[COL_CAST57:%.*]] = bitcast double* [[COL_GEP56]] to <1 x double>*
; CHECK-NEXT:    store <1 x double> [[TMP20]], <1 x double>* [[COL_CAST57]], align 8
; CHECK-NEXT:    [[COL_CAST59:%.*]] = bitcast <6 x double>* [[TMP5]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD60:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST59]], align 8
; CHECK-NEXT:    [[COL_GEP61:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP5]], i64 0, i64 3
; CHECK-NEXT:    [[COL_CAST62:%.*]] = bitcast double* [[COL_GEP61]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD63:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST62]], align 8
; CHECK-NEXT:    [[TMP22:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP11]], i64 0, i64 4
; CHECK-NEXT:    [[COL_CAST65:%.*]] = bitcast double* [[TMP22]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD66:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST65]], align 8
; CHECK-NEXT:    [[SPLAT_SPLAT69:%.*]] = shufflevector <2 x double> [[COL_LOAD66]], <2 x double> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP23:%.*]] = fmul <2 x double> [[COL_LOAD60]], [[SPLAT_SPLAT69]]
; CHECK-NEXT:    [[SPLAT_SPLAT72:%.*]] = shufflevector <2 x double> [[COL_LOAD66]], <2 x double> undef, <2 x i32> <i32 1, i32 1>
; CHECK-NEXT:    [[TMP24:%.*]] = call <2 x double> @llvm.fmuladd.v2f64(<2 x double> [[COL_LOAD63]], <2 x double> [[SPLAT_SPLAT72]], <2 x double> [[TMP23]])
; CHECK-NEXT:    [[TMP25:%.*]] = getelementptr <9 x double>, <9 x double>* [[C]], i64 0, i64 6
; CHECK-NEXT:    [[COL_CAST74:%.*]] = bitcast double* [[TMP25]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP24]], <2 x double>* [[COL_CAST74]], align 8
; CHECK-NEXT:    [[TMP26:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP5]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST76:%.*]] = bitcast double* [[TMP26]] to <1 x double>*
; CHECK-NEXT:    [[COL_LOAD77:%.*]] = load <1 x double>, <1 x double>* [[COL_CAST76]], align 8
; CHECK-NEXT:    [[COL_GEP78:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP5]], i64 0, i64 5
; CHECK-NEXT:    [[COL_CAST79:%.*]] = bitcast double* [[COL_GEP78]] to <1 x double>*
; CHECK-NEXT:    [[COL_LOAD80:%.*]] = load <1 x double>, <1 x double>* [[COL_CAST79]], align 8
; CHECK-NEXT:    [[TMP27:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP11]], i64 0, i64 4
; CHECK-NEXT:    [[COL_CAST82:%.*]] = bitcast double* [[TMP27]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD83:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST82]], align 8
; CHECK-NEXT:    [[SPLAT_SPLATINSERT85:%.*]] = shufflevector <2 x double> [[COL_LOAD83]], <2 x double> undef, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP28:%.*]] = fmul <1 x double> [[COL_LOAD77]], [[SPLAT_SPLATINSERT85]]
; CHECK-NEXT:    [[SPLAT_SPLATINSERT88:%.*]] = shufflevector <2 x double> [[COL_LOAD83]], <2 x double> undef, <1 x i32> <i32 1>
; CHECK-NEXT:    [[TMP29:%.*]] = call <1 x double> @llvm.fmuladd.v1f64(<1 x double> [[COL_LOAD80]], <1 x double> [[SPLAT_SPLATINSERT88]], <1 x double> [[TMP28]])
; CHECK-NEXT:    [[TMP30:%.*]] = getelementptr <9 x double>, <9 x double>* [[C]], i64 0, i64 8
; CHECK-NEXT:    [[COL_CAST91:%.*]] = bitcast double* [[TMP30]] to <1 x double>*
; CHECK-NEXT:    store <1 x double> [[TMP29]], <1 x double>* [[COL_CAST91]], align 8
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[TRUE:%.*]], label [[FALSE:%.*]]
; CHECK:       true:
; CHECK-NEXT:    [[TMP31:%.*]] = fadd <3 x double> [[COL_LOAD197]], [[COL_LOAD197]]
; CHECK-NEXT:    [[TMP32:%.*]] = fadd <3 x double> [[COL_LOAD200]], [[COL_LOAD200]]
; CHECK-NEXT:    [[COL_CAST214:%.*]] = bitcast <6 x double>* [[A]] to <3 x double>*
; CHECK-NEXT:    store <3 x double> [[TMP31]], <3 x double>* [[COL_CAST214]], align 8
; CHECK-NEXT:    [[COL_GEP215:%.*]] = getelementptr <6 x double>, <6 x double>* [[A]], i64 0, i64 3
; CHECK-NEXT:    [[COL_CAST216:%.*]] = bitcast double* [[COL_GEP215]] to <3 x double>*
; CHECK-NEXT:    store <3 x double> [[TMP32]], <3 x double>* [[COL_CAST216]], align 8
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       false:
; CHECK-NEXT:    [[TMP33:%.*]] = fadd <2 x double> [[COL_LOAD202]], [[COL_LOAD202]]
; CHECK-NEXT:    [[TMP34:%.*]] = fadd <2 x double> [[COL_LOAD205]], [[COL_LOAD205]]
; CHECK-NEXT:    [[TMP35:%.*]] = fadd <2 x double> [[COL_LOAD208]], [[COL_LOAD208]]
; CHECK-NEXT:    [[COL_CAST209:%.*]] = bitcast <6 x double>* [[B]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP33]], <2 x double>* [[COL_CAST209]], align 8
; CHECK-NEXT:    [[COL_GEP210:%.*]] = getelementptr <6 x double>, <6 x double>* [[B]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST211:%.*]] = bitcast double* [[COL_GEP210]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP34]], <2 x double>* [[COL_CAST211]], align 8
; CHECK-NEXT:    [[COL_GEP212:%.*]] = getelementptr <6 x double>, <6 x double>* [[B]], i64 0, i64 4
; CHECK-NEXT:    [[COL_CAST213:%.*]] = bitcast double* [[COL_GEP212]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP35]], <2 x double>* [[COL_CAST213]], align 8
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[ST_B92:%.*]] = ptrtoint <9 x double>* [[C]] to i64
; CHECK-NEXT:    [[ST_E93:%.*]] = add nuw nsw i64 [[ST_B92]], 72
; CHECK-NEXT:    [[LD_B97:%.*]] = ptrtoint <6 x double>* [[A]] to i64
; CHECK-NEXT:    [[TMP36:%.*]] = icmp ugt i64 [[ST_E93]], [[LD_B97]]
; CHECK-NEXT:    br i1 [[TMP36]], label [[ALIAS_CONT94:%.*]], label [[NO_ALIAS96:%.*]]
; CHECK:       alias_cont91:
; CHECK-NEXT:    [[LD_E98:%.*]] = add nuw nsw i64 [[LD_B97]], 48
; CHECK-NEXT:    [[TMP37:%.*]] = icmp ugt i64 [[LD_E98]], [[ST_B92]]
; CHECK-NEXT:    br i1 [[TMP37]], label [[COPY95:%.*]], label [[NO_ALIAS96]]
; CHECK:       copy92:
; CHECK-NEXT:    [[TMP38:%.*]] = alloca <6 x double>, align 64
; CHECK-NEXT:    [[TMP39:%.*]] = bitcast <6 x double>* [[TMP38]] to i8*
; CHECK-NEXT:    [[TMP40:%.*]] = bitcast <6 x double>* [[A]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 64 dereferenceable(48) [[TMP39]], i8* nonnull align 16 dereferenceable(48) [[TMP40]], i64 48, i1 false)
; CHECK-NEXT:    br label [[NO_ALIAS96]]
; CHECK:       no_alias93:
; CHECK-NEXT:    [[TMP41:%.*]] = phi <6 x double>* [ [[A]], [[END]] ], [ [[A]], [[ALIAS_CONT94]] ], [ [[TMP38]], [[COPY95]] ]
; CHECK-NEXT:    [[ST_B99:%.*]] = ptrtoint <9 x double>* [[C]] to i64
; CHECK-NEXT:    [[ST_E100:%.*]] = add nuw nsw i64 [[ST_B99]], 72
; CHECK-NEXT:    [[LD_B104:%.*]] = ptrtoint <6 x double>* [[B]] to i64
; CHECK-NEXT:    [[TMP42:%.*]] = icmp ugt i64 [[ST_E100]], [[LD_B104]]
; CHECK-NEXT:    br i1 [[TMP42]], label [[ALIAS_CONT101:%.*]], label [[NO_ALIAS103:%.*]]
; CHECK:       alias_cont98:
; CHECK-NEXT:    [[LD_E105:%.*]] = add nuw nsw i64 [[LD_B104]], 48
; CHECK-NEXT:    [[TMP43:%.*]] = icmp ugt i64 [[LD_E105]], [[ST_B99]]
; CHECK-NEXT:    br i1 [[TMP43]], label [[COPY102:%.*]], label [[NO_ALIAS103]]
; CHECK:       copy99:
; CHECK-NEXT:    [[TMP44:%.*]] = alloca <6 x double>, align 64
; CHECK-NEXT:    [[TMP45:%.*]] = bitcast <6 x double>* [[TMP44]] to i8*
; CHECK-NEXT:    [[TMP46:%.*]] = bitcast <6 x double>* [[B]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 64 dereferenceable(48) [[TMP45]], i8* nonnull align 16 dereferenceable(48) [[TMP46]], i64 48, i1 false)
; CHECK-NEXT:    br label [[NO_ALIAS103]]
; CHECK:       no_alias100:
; CHECK-NEXT:    [[TMP47:%.*]] = phi <6 x double>* [ [[B]], [[NO_ALIAS96]] ], [ [[B]], [[ALIAS_CONT101]] ], [ [[TMP44]], [[COPY102]] ]
; CHECK-NEXT:    [[COL_CAST107:%.*]] = bitcast <6 x double>* [[TMP41]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD108:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST107]], align 8
; CHECK-NEXT:    [[COL_GEP109:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP41]], i64 0, i64 3
; CHECK-NEXT:    [[COL_CAST110:%.*]] = bitcast double* [[COL_GEP109]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD111:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST110]], align 8
; CHECK-NEXT:    [[COL_CAST113:%.*]] = bitcast <6 x double>* [[TMP47]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD114:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST113]], align 8
; CHECK-NEXT:    [[COL_GEP115:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP47]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST116:%.*]] = bitcast double* [[COL_GEP115]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD117:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST116]], align 8
; CHECK-NEXT:    [[SPLAT_SPLAT120:%.*]] = shufflevector <2 x double> [[COL_LOAD114]], <2 x double> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP48:%.*]] = fmul <2 x double> [[COL_LOAD108]], [[SPLAT_SPLAT120]]
; CHECK-NEXT:    [[SPLAT_SPLAT123:%.*]] = shufflevector <2 x double> [[COL_LOAD114]], <2 x double> undef, <2 x i32> <i32 1, i32 1>
; CHECK-NEXT:    [[TMP49:%.*]] = call <2 x double> @llvm.fmuladd.v2f64(<2 x double> [[COL_LOAD111]], <2 x double> [[SPLAT_SPLAT123]], <2 x double> [[TMP48]])
; CHECK-NEXT:    [[SPLAT_SPLAT126:%.*]] = shufflevector <2 x double> [[COL_LOAD117]], <2 x double> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP50:%.*]] = fmul <2 x double> [[COL_LOAD108]], [[SPLAT_SPLAT126]]
; CHECK-NEXT:    [[SPLAT_SPLAT129:%.*]] = shufflevector <2 x double> [[COL_LOAD117]], <2 x double> undef, <2 x i32> <i32 1, i32 1>
; CHECK-NEXT:    [[TMP51:%.*]] = call <2 x double> @llvm.fmuladd.v2f64(<2 x double> [[COL_LOAD111]], <2 x double> [[SPLAT_SPLAT129]], <2 x double> [[TMP50]])
; CHECK-NEXT:    [[COL_CAST131:%.*]] = bitcast <9 x double>* [[C]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP49]], <2 x double>* [[COL_CAST131]], align 8
; CHECK-NEXT:    [[COL_GEP132:%.*]] = getelementptr <9 x double>, <9 x double>* [[C]], i64 0, i64 3
; CHECK-NEXT:    [[COL_CAST133:%.*]] = bitcast double* [[COL_GEP132]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP51]], <2 x double>* [[COL_CAST133]], align 8
; CHECK-NEXT:    [[TMP52:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP41]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST135:%.*]] = bitcast double* [[TMP52]] to <1 x double>*
; CHECK-NEXT:    [[COL_LOAD136:%.*]] = load <1 x double>, <1 x double>* [[COL_CAST135]], align 8
; CHECK-NEXT:    [[COL_GEP137:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP41]], i64 0, i64 5
; CHECK-NEXT:    [[COL_CAST138:%.*]] = bitcast double* [[COL_GEP137]] to <1 x double>*
; CHECK-NEXT:    [[COL_LOAD139:%.*]] = load <1 x double>, <1 x double>* [[COL_CAST138]], align 8
; CHECK-NEXT:    [[COL_CAST141:%.*]] = bitcast <6 x double>* [[TMP47]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD142:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST141]], align 8
; CHECK-NEXT:    [[COL_GEP143:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP47]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST144:%.*]] = bitcast double* [[COL_GEP143]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD145:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST144]], align 8
; CHECK-NEXT:    [[SPLAT_SPLATINSERT147:%.*]] = shufflevector <2 x double> [[COL_LOAD142]], <2 x double> undef, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP53:%.*]] = fmul <1 x double> [[COL_LOAD136]], [[SPLAT_SPLATINSERT147]]
; CHECK-NEXT:    [[SPLAT_SPLATINSERT150:%.*]] = shufflevector <2 x double> [[COL_LOAD142]], <2 x double> undef, <1 x i32> <i32 1>
; CHECK-NEXT:    [[TMP54:%.*]] = call <1 x double> @llvm.fmuladd.v1f64(<1 x double> [[COL_LOAD139]], <1 x double> [[SPLAT_SPLATINSERT150]], <1 x double> [[TMP53]])
; CHECK-NEXT:    [[SPLAT_SPLATINSERT153:%.*]] = shufflevector <2 x double> [[COL_LOAD145]], <2 x double> undef, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP55:%.*]] = fmul <1 x double> [[COL_LOAD136]], [[SPLAT_SPLATINSERT153]]
; CHECK-NEXT:    [[SPLAT_SPLATINSERT156:%.*]] = shufflevector <2 x double> [[COL_LOAD145]], <2 x double> undef, <1 x i32> <i32 1>
; CHECK-NEXT:    [[TMP56:%.*]] = call <1 x double> @llvm.fmuladd.v1f64(<1 x double> [[COL_LOAD139]], <1 x double> [[SPLAT_SPLATINSERT156]], <1 x double> [[TMP55]])
; CHECK-NEXT:    [[TMP57:%.*]] = getelementptr <9 x double>, <9 x double>* [[C]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST159:%.*]] = bitcast double* [[TMP57]] to <1 x double>*
; CHECK-NEXT:    store <1 x double> [[TMP54]], <1 x double>* [[COL_CAST159]], align 8
; CHECK-NEXT:    [[COL_GEP160:%.*]] = getelementptr <9 x double>, <9 x double>* [[C]], i64 0, i64 5
; CHECK-NEXT:    [[COL_CAST161:%.*]] = bitcast double* [[COL_GEP160]] to <1 x double>*
; CHECK-NEXT:    store <1 x double> [[TMP56]], <1 x double>* [[COL_CAST161]], align 8
; CHECK-NEXT:    [[COL_CAST163:%.*]] = bitcast <6 x double>* [[TMP41]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD164:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST163]], align 8
; CHECK-NEXT:    [[COL_GEP165:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP41]], i64 0, i64 3
; CHECK-NEXT:    [[COL_CAST166:%.*]] = bitcast double* [[COL_GEP165]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD167:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST166]], align 8
; CHECK-NEXT:    [[TMP58:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP47]], i64 0, i64 4
; CHECK-NEXT:    [[COL_CAST169:%.*]] = bitcast double* [[TMP58]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD170:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST169]], align 8
; CHECK-NEXT:    [[SPLAT_SPLAT173:%.*]] = shufflevector <2 x double> [[COL_LOAD170]], <2 x double> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP59:%.*]] = fmul <2 x double> [[COL_LOAD164]], [[SPLAT_SPLAT173]]
; CHECK-NEXT:    [[SPLAT_SPLAT176:%.*]] = shufflevector <2 x double> [[COL_LOAD170]], <2 x double> undef, <2 x i32> <i32 1, i32 1>
; CHECK-NEXT:    [[TMP60:%.*]] = call <2 x double> @llvm.fmuladd.v2f64(<2 x double> [[COL_LOAD167]], <2 x double> [[SPLAT_SPLAT176]], <2 x double> [[TMP59]])
; CHECK-NEXT:    [[TMP61:%.*]] = getelementptr <9 x double>, <9 x double>* [[C]], i64 0, i64 6
; CHECK-NEXT:    [[COL_CAST178:%.*]] = bitcast double* [[TMP61]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP60]], <2 x double>* [[COL_CAST178]], align 8
; CHECK-NEXT:    [[TMP62:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP41]], i64 0, i64 2
; CHECK-NEXT:    [[COL_CAST180:%.*]] = bitcast double* [[TMP62]] to <1 x double>*
; CHECK-NEXT:    [[COL_LOAD181:%.*]] = load <1 x double>, <1 x double>* [[COL_CAST180]], align 8
; CHECK-NEXT:    [[COL_GEP182:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP41]], i64 0, i64 5
; CHECK-NEXT:    [[COL_CAST183:%.*]] = bitcast double* [[COL_GEP182]] to <1 x double>*
; CHECK-NEXT:    [[COL_LOAD184:%.*]] = load <1 x double>, <1 x double>* [[COL_CAST183]], align 8
; CHECK-NEXT:    [[TMP63:%.*]] = getelementptr <6 x double>, <6 x double>* [[TMP47]], i64 0, i64 4
; CHECK-NEXT:    [[COL_CAST186:%.*]] = bitcast double* [[TMP63]] to <2 x double>*
; CHECK-NEXT:    [[COL_LOAD187:%.*]] = load <2 x double>, <2 x double>* [[COL_CAST186]], align 8
; CHECK-NEXT:    [[SPLAT_SPLATINSERT189:%.*]] = shufflevector <2 x double> [[COL_LOAD187]], <2 x double> undef, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP64:%.*]] = fmul <1 x double> [[COL_LOAD181]], [[SPLAT_SPLATINSERT189]]
; CHECK-NEXT:    [[SPLAT_SPLATINSERT192:%.*]] = shufflevector <2 x double> [[COL_LOAD187]], <2 x double> undef, <1 x i32> <i32 1>
; CHECK-NEXT:    [[TMP65:%.*]] = call <1 x double> @llvm.fmuladd.v1f64(<1 x double> [[COL_LOAD184]], <1 x double> [[SPLAT_SPLATINSERT192]], <1 x double> [[TMP64]])
; CHECK-NEXT:    [[TMP66:%.*]] = getelementptr <9 x double>, <9 x double>* [[C]], i64 0, i64 8
; CHECK-NEXT:    [[COL_CAST195:%.*]] = bitcast double* [[TMP66]] to <1 x double>*
; CHECK-NEXT:    store <1 x double> [[TMP65]], <1 x double>* [[COL_CAST195]], align 8
; CHECK-NEXT:    ret void
;
entry:
  %a = load <6 x double>, <6 x double>* %A, align 16
  %b = load <6 x double>, <6 x double>* %B, align 16
  %c = call <9 x double> @llvm.matrix.multiply(<6 x double> %a, <6 x double> %b, i32 3, i32 2, i32 3)
  store <9 x double> %c, <9 x double>* %C, align 16

  br i1 %cond, label %true, label %false

true:
  %a.add = fadd <6 x double> %a, %a
  store <6 x double> %a.add, <6 x double>* %A
  br label %end

false:
  %b.add = fadd <6 x double> %b, %b
  store <6 x double> %b.add, <6 x double>* %B
  br label %end

end:
  %a.2 = load <6 x double>, <6 x double>* %A, align 16
  %b.2 = load <6 x double>, <6 x double>* %B, align 16
  %c.2 = call <9 x double> @llvm.matrix.multiply(<6 x double> %a.2, <6 x double> %b.2, i32 3, i32 2, i32 3)
  store <9 x double> %c.2, <9 x double>* %C, align 16
  ret void
}

declare <9 x double> @llvm.matrix.multiply(<6 x double>, <6 x double>, i32, i32, i32)
