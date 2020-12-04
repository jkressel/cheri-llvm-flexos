; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-- | FileCheck %s
; Don't accidentally add the offset twice for trailing bytes.

	%struct.S63 = type { [63 x i8] }
@g1s63 = external dso_local global %struct.S63		; <%struct.S63*> [#uses=1]

declare void @test63(%struct.S63* byval(%struct.S63) align 4 ) nounwind

define void @testit63_entry_2E_ce() nounwind  {
; CHECK-LABEL: testit63_entry_2E_ce:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushl %edi
; CHECK-NEXT:    pushl %esi
; CHECK-NEXT:    subl $64, %esp
; CHECK-NEXT:    movl $15, %ecx
; CHECK-NEXT:    movl %esp, %edi
; CHECK-NEXT:    movl $g1s63, %esi
; CHECK-NEXT:    rep;movsl (%esi), %es:(%edi)
; CHECK-NEXT:    movb g1s63+62, %al
; CHECK-NEXT:    movb %al, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movzwl g1s63+60, %eax
; CHECK-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; CHECK-NEXT:    calll test63
; CHECK-NEXT:    addl $64, %esp
; CHECK-NEXT:    popl %esi
; CHECK-NEXT:    popl %edi
; CHECK-NEXT:    retl
	tail call void @test63(%struct.S63* byval(%struct.S63) align 4  @g1s63) nounwind
	ret void
}
