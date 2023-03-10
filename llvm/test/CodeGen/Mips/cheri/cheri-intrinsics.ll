; RUN: %cheri_llc %s -o - | FileCheck %s
; ModuleID = 'cheriintrinsic.c'
target datalayout = "E-p:64:64:64-i1:8:8-i8:8:32-i16:16:32-i32:32:32-i64:64:64-f32:32:32-f64:64:64-f128:128:128-v64:64:64-n32"
target triple = "cheri-unknown-freebsd"

; CHECK: cmalloc
define i8 addrspace(200)* @cmalloc(i64 %s) nounwind {
entry:
  %call = tail call i8* @malloc(i64 %s) nounwind
  %cap = addrspacecast i8* %call to i8 addrspace(200)*
  ; CHECK: csetbounds
  %bounded = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set.i64(i8 addrspace(200)* %cap, i64 %s)
  ; CHECK: .end cmalloc
  ret i8 addrspace(200)* %bounded
}

declare noalias i8* @malloc(i64) nounwind

; CHECK-LABEL: addBase
define i8 addrspace(200)* @addBase(i8 addrspace(200)* %p) nounwind readnone {
entry:
  ; CHECK: cincoffset
  ; CHECK: .end addBase
  %incdec.ptr = getelementptr inbounds i8, i8 addrspace(200)* %p, i64 1
  ret i8 addrspace(200)* %incdec.ptr
}

; CHECK-LABEL: getLength
define i64 @getLength(i8 addrspace(200)* %c) nounwind readnone {
entry:
  ; CHECK: cgetlen $2, $c3
  %0 = tail call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)* %c)
  ret i64 %0
}

declare i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)*) nounwind readnone

; CHECK-LABEL: getAddress
define i64 @getAddress(i8 addrspace(200)* %c) nounwind readnone {
entry:
  ; CHECK: cgetaddr $2, $c3
  ; CHECK: .end getAddress
  %0 = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %c)
  ret i64 %0
}

declare i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)*) nounwind readnone

; CHECK-LABEL: setAddress
define i8 addrspace(200)* @setAddress(i8 addrspace(200)* %c) nounwind readnone {
entry:
  ; CHECK:  daddiu  $1, $zero, 1234
  ; CHECK:  csetaddr $c3, $c3, $1
  ; CHECK: .end setAddress
  %0 = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %c, i64 1234)
  ret i8 addrspace(200)* %0
}

declare i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)*, i64) nounwind readnone

; CHECK-LABEL: getPerms
define signext i64 @getPerms(i8 addrspace(200)* %c) nounwind readnone {
entry:
  ; CHECK: cgetperm        $2, $c3
  ; CHECK: .end getPerms
  %0 = tail call i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)* %c)
  ret i64 %0
}

declare i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)*) nounwind readnone

; CHECK-LABEL: andPerms
define i8 addrspace(200)* @andPerms(i8 addrspace(200)* %c, i16 signext %perms) nounwind readnone {
entry:
  ; CHECK: candperm        $c3, $c3, $1
  ; CHECK: .end andPerms
  %0 = zext i16 %perms to i64
  %1 = tail call i8 addrspace(200)* @llvm.cheri.cap.perms.and.i64(i8 addrspace(200)* %c, i64 %0)
  ret i8 addrspace(200)* %1
}

declare i8 addrspace(200)* @llvm.cheri.cap.perms.and.i64(i8 addrspace(200)*, i64) nounwind readnone

; CHECK-LABEL: getFlags
define signext i64 @getFlags(i8 addrspace(200)* %c) nounwind readnone {
entry:
  ; CHECK: cgetflags       $2, $c3
  ; CHECK: .end getFlags
  %0 = tail call i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)* %c)
  ret i64 %0
}

declare i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)*) nounwind readnone

; CHECK-LABEL: setFlags
define i8 addrspace(200)* @setFlags(i8 addrspace(200)* %c, i16 signext %flags) nounwind readnone {
entry:
  ; CHECK: csetflags       $c3, $c3, $1
  ; CHECK: .end setFlags
  %0 = zext i16 %flags to i64
  %1 = tail call i8 addrspace(200)* @llvm.cheri.cap.flags.set.i64(i8 addrspace(200)* %c, i64 %0)
  ret i8 addrspace(200)* %1
}

declare i8 addrspace(200)* @llvm.cheri.cap.flags.set.i64(i8 addrspace(200)*, i64) nounwind readnone

; CHECK-LABEL: gettype
define i64 @gettype(i8 addrspace(200)* %c) nounwind readnone {
entry:
  ; CHECK: cgettype        $2, $c3
  ; CHECK: .end gettype
  %0 = tail call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)* %c)
  ret i64 %0
}

declare i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)*) nounwind readnone

; CHECK-LABEL: setBounds
define i8 addrspace(200)* @setBounds(i8 addrspace(200)* %c, i64 %bounds) nounwind readnone {
entry:
  ; CHECK: csetbounds      $c3, $c3, $4
  ; CHECK: .end setBounds
  %0 = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set.i64(i8 addrspace(200)* %c, i64 %bounds)
  ret i8 addrspace(200)* %0
}

declare i8 addrspace(200)* @llvm.cheri.cap.bounds.set.i64(i8 addrspace(200)*, i64) nounwind readnone
