; REQUIRES: object-emission

; RUN: llc -mtriple=x86_64-linux -O0 -filetype=obj < %s \
; RUN:     | llvm-dwarfdump -debug-dump=info - | FileCheck --check-prefix=CHECK --check-prefix=CHECK-V4 %s
; RUN: llc -mtriple=x86_64-linux -dwarf-version=3 -O0 -filetype=obj < %s \
; RUN:     | llvm-dwarfdump -debug-dump=info - | FileCheck --check-prefix=CHECK --check-prefix=CHECK-V3 %s

; Check that we emit DW_TAG_lexical_block and that it has the right encoding
; depending on the dwarf version.

; CHECK: DW_TAG_lexical_block
; CHECK-NOT: DW_TAG
; CHECK: DW_AT_low_pc [DW_FORM_addr]
; CHECK-NOT: DW_TAG
; CHECK-V4: DW_AT_high_pc [DW_FORM_data4]
; CHECK-V3: DW_AT_high_pc [DW_FORM_addr]

; Test case produced from:
; void b() {
;   if (int i = 3)
;     return;
; }

; Function Attrs: nounwind uwtable
define void @_Z1bv() #0 {
entry:
  %i = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %i, metadata !11, metadata !MDExpression()), !dbg !14
  store i32 3, i32* %i, align 4, !dbg !14
  %0 = load i32, i32* %i, align 4, !dbg !14
  %tobool = icmp ne i32 %0, 0, !dbg !14
  br i1 %tobool, label %if.then, label %if.end, !dbg !14

if.then:                                          ; preds = %entry
  br label %if.end, !dbg !15

if.end:                                           ; preds = %if.then, %entry
  ret void, !dbg !16
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = !MDCompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.5.0 ", isOptimized: false, emissionKind: 1, file: !1, enums: !2, retainedTypes: !2, subprograms: !3, globals: !2, imports: !2)
!1 = !MDFile(filename: "lexical_block.cpp", directory: "/tmp/dbginfo")
!2 = !{}
!3 = !{!4}
!4 = !MDSubprogram(name: "b", linkageName: "_Z1bv", line: 1, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 1, file: !1, scope: !5, type: !6, function: void ()* @_Z1bv, variables: !2)
!5 = !MDFile(filename: "lexical_block.cpp", directory: "/tmp/dbginfo")
!6 = !MDSubroutineType(types: !7)
!7 = !{null}
!8 = !{i32 2, !"Dwarf Version", i32 4}
!9 = !{i32 1, !"Debug Info Version", i32 3}
!10 = !{!"clang version 3.5.0 "}
!11 = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "i", line: 2, scope: !12, file: !5, type: !13)
!12 = distinct !MDLexicalBlock(line: 2, column: 0, file: !1, scope: !4)
!13 = !MDBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!14 = !MDLocation(line: 2, scope: !12)
!15 = !MDLocation(line: 3, scope: !12)
!16 = !MDLocation(line: 4, scope: !4)
