; RUN: %llc_dwarf -filetype=obj < %s \
; RUN:   | llvm-dwarfdump -debug-info -debug-loclists - | FileCheck %s
; RUN: llc -mtriple x86_64-pc-linux -split-dwarf-file=foo.dwo -filetype=obj < %s \
; RUN:   | llvm-dwarfdump -debug-info -debug-loclists - | FileCheck %s

; CHECK: 0x{{0*}}[[TYPE:.*]]: DW_TAG_base_type
; CHECK-NEXT:                   DW_AT_name ("DW_ATE_unsigned_32")

; CHECK: DW_LLE_offset_pair ({{.*}}): DW_OP_consts +7, DW_OP_convert 0x[[TYPE]], DW_OP_stack_value

; Function Attrs: uwtable
define dso_local void @_Z2f2v() local_unnamed_addr #0 !dbg !11 {
entry:
  tail call void @_Z2f1v(), !dbg !15
  call void @llvm.dbg.value(metadata i32 7, metadata !13, metadata !DIExpression(DW_OP_LLVM_convert, 32, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !16
  tail call void @_Z2f1v(), !dbg !17
  ret void, !dbg !18
}

declare !dbg !4 dso_local void @_Z2f1v() local_unnamed_addr #1

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!7, !8, !9}
!llvm.ident = !{!10}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 11.0.0 (git@github.com:llvm/llvm-project.git edc3f4f02e54c2ae1067f60f6a0ed6caf5b92ef6)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "loc.cpp", directory: "/usr/local/google/home/blaikie/dev/scratch")
!2 = !{}
!3 = !{!4}
!4 = !DISubprogram(name: "f1", linkageName: "_Z2f1v", scope: !1, file: !1, line: 1, type: !5, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !2)
!5 = !DISubroutineType(types: !6)
!6 = !{null}
!7 = !{i32 7, !"Dwarf Version", i32 5}
!8 = !{i32 2, !"Debug Info Version", i32 3}
!9 = !{i32 1, !"wchar_size", i32 4}
!10 = !{!"clang version 11.0.0 (git@github.com:llvm/llvm-project.git edc3f4f02e54c2ae1067f60f6a0ed6caf5b92ef6)"}
!11 = distinct !DISubprogram(name: "f2", linkageName: "_Z2f2v", scope: !1, file: !1, line: 2, type: !5, scopeLine: 2, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !12)
!12 = !{!13}
!13 = !DILocalVariable(name: "x", scope: !11, file: !1, line: 3, type: !14)
!14 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!15 = !DILocation(line: 4, column: 3, scope: !11)
!16 = !DILocation(line: 0, scope: !11)
!17 = !DILocation(line: 6, column: 3, scope: !11)
!18 = !DILocation(line: 7, column: 1, scope: !11)
