; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %cheri128_purecap_llc %s -o - -O1 | FileCheck %s

@va_copy = common addrspace(200) global i8 addrspace(200)* null, align 32

; Check that locally creating a va_list and then storing it to a global works
; (Yes, this is an odd thing to do.  See libxo for a real-world example)
define void @copy_to_global(i8 addrspace(200)* nocapture readnone %y, i32 signext %x, ...) nounwind {
; CHECK-LABEL: copy_to_global:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cincoffset $c11, $c11, -64
; CHECK-NEXT:    csc $c24, $zero, 48($c11) # 16-byte Folded Spill
; CHECK-NEXT:    csc $c17, $zero, 32($c11) # 16-byte Folded Spill
; CHECK-NEXT:    cincoffset $c24, $c11, $zero
; CHECK-NEXT:    cgetaddr $1, $c11
; CHECK-NEXT:    daddiu $2, $zero, -32
; CHECK-NEXT:    and $1, $1, $2
; CHECK-NEXT:    csetaddr $c11, $c11, $1
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    clcbi $c1, %captab20(va_copy)($c1)
; CHECK-NEXT:    csetbounds $c2, $c11, 16
; CHECK-NEXT:    csc $c13, $zero, 0($c2)
; CHECK-NEXT:    csc $c13, $zero, 0($c1)
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    cincoffset $c11, $c24, $zero
; CHECK-NEXT:    clc $c17, $zero, 32($c11) # 16-byte Folded Reload
; CHECK-NEXT:    clc $c24, $zero, 48($c11) # 16-byte Folded Reload
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    cincoffset $c11, $c11, 64
  %1 = alloca i8 addrspace(200)*, align 32, addrspace(200)
  %2 = bitcast i8 addrspace(200)* addrspace(200)* %1 to i8 addrspace(200)*
  %3 = addrspacecast i8 addrspace(200)* %2 to i8*
  call void @llvm.va_start.p200i8(i8 addrspace(200)* %2)
  call void @llvm.va_copy.p200i8.p200i8(i8 addrspace(200)* bitcast (i8 addrspace(200)* addrspace(200)* @va_copy to i8 addrspace(200)*), i8 addrspace(200)* %2)
  call void @llvm.va_end.p200i8(i8 addrspace(200)* %2)
  ret void
}

declare void @llvm.va_start.p200i8(i8 addrspace(200)*)
declare void @llvm.va_copy.p200i8.p200i8(i8 addrspace(200)*, i8 addrspace(200)*)
declare void @llvm.va_end.p200i8(i8 addrspace(200)*)

; Check that va_copy can copy from a global to a register.
; TODO: there is no need to set the bounds on the va_copy() destination since
; it is just a single capability store.
define i8 addrspace(200)* @copy_from_global() nounwind {
; CHECK-LABEL: copy_from_global:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cincoffset $c11, $c11, -64
; CHECK-NEXT:    csc $c24, $zero, 48($c11) # 16-byte Folded Spill
; CHECK-NEXT:    csc $c17, $zero, 32($c11) # 16-byte Folded Spill
; CHECK-NEXT:    cincoffset $c24, $c11, $zero
; CHECK-NEXT:    cgetaddr $1, $c11
; CHECK-NEXT:    daddiu $2, $zero, -32
; CHECK-NEXT:    and $1, $1, $2
; CHECK-NEXT:    csetaddr $c11, $c11, $1
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    clcbi $c1, %captab20(va_copy)($c1)
; CHECK-NEXT:    clc $c1, $zero, 0($c1)
; CHECK-NEXT:    csetbounds $c2, $c11, 16
; CHECK-NEXT:    csc $c1, $zero, 0($c2)
; CHECK-NEXT:    clc $c3, $zero, 0($c11)
; CHECK-NEXT:    cincoffset $c11, $c24, $zero
; CHECK-NEXT:    clc $c17, $zero, 32($c11) # 16-byte Folded Reload
; CHECK-NEXT:    clc $c24, $zero, 48($c11) # 16-byte Folded Reload
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    cincoffset $c11, $c11, 64
  %1 = alloca i8 addrspace(200)*, align 32, addrspace(200)
  %2 = bitcast i8 addrspace(200)* addrspace(200)* %1 to i8 addrspace(200)*
  call void @llvm.va_copy.p200i8.p200i8(i8 addrspace(200)* %2, i8 addrspace(200)* bitcast (i8 addrspace(200)* addrspace(200)* @va_copy to i8 addrspace(200)*))
  %3 = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* %1, align 32
  ret i8 addrspace(200)* %3
}

; When calling from a variadic function to one that takes a va_list, we should
; simply move the va capability from $c13 to the relevant argument register,
; but also make sure to clear $c13.
; TODO: this could be a simple cmove!
define void @pass_va_list(i8 addrspace(200)* nocapture readnone %y, i32 signext %x, ...) nounwind {
; CHECK-LABEL: pass_va_list:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cincoffset $c11, $c11, -64
; CHECK-NEXT:    csc $c24, $zero, 48($c11) # 16-byte Folded Spill
; CHECK-NEXT:    csc $c17, $zero, 32($c11) # 16-byte Folded Spill
; CHECK-NEXT:    cincoffset $c24, $c11, $zero
; CHECK-NEXT:    cgetaddr $1, $c11
; CHECK-NEXT:    daddiu $2, $zero, -32
; CHECK-NEXT:    and $1, $1, $2
; CHECK-NEXT:    csetaddr $c11, $c11, $1
; CHECK-NEXT:    csetbounds $c1, $c11, 16
; CHECK-NEXT:    csc $c13, $zero, 0($c1)
; CHECK-NEXT:    clc $c3, $zero, 0($c11)
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    clcbi $c12, %capcall20(f)($c1)
; CHECK-NEXT:    daddiu $4, $zero, 1
; CHECK-NEXT:    daddiu $5, $zero, 2
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    cincoffset $c11, $c24, $zero
; CHECK-NEXT:    clc $c17, $zero, 32($c11) # 16-byte Folded Reload
; CHECK-NEXT:    clc $c24, $zero, 48($c11) # 16-byte Folded Reload
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    cincoffset $c11, $c11, 64
  %1 = alloca i8 addrspace(200)*, align 32, addrspace(200)
  %2 = bitcast i8 addrspace(200)* addrspace(200)* %1 to i8 addrspace(200)*
  call void @llvm.va_start.p200i8(i8 addrspace(200)* %2)
  %3 = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* %1, align 32
  %4 = call i32 @f(i32 signext 1, i32 signext 2, i8 addrspace(200)* %3)
  call void @llvm.va_end.p200i8(i8 addrspace(200)* %2)
  ret void
}

declare i32 @f(i32 signext, i32 signext, i8 addrspace(200)*)

; When calling a variadic function, we should set $c13 to the size of the
; arguments.
define void @check_bounded(i32 addrspace(200)* %x, i32 addrspace(200)* %y) nounwind {
; CHECK-LABEL: check_bounded:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cincoffset $c11, $c11, -128
; CHECK-NEXT:    csc $c24, $zero, 112($c11) # 16-byte Folded Spill
; CHECK-NEXT:    csc $c17, $zero, 96($c11) # 16-byte Folded Spill
; CHECK-NEXT:    cincoffset $c24, $c11, $zero
; CHECK-NEXT:    cgetaddr $1, $c11
; CHECK-NEXT:    daddiu $2, $zero, -32
; CHECK-NEXT:    and $1, $1, $2
; CHECK-NEXT:    csetaddr $c11, $c11, $1
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    csc $c3, $zero, 64($c11)
; CHECK-NEXT:    csc $c4, $zero, 32($c11)
; CHECK-NEXT:    cincoffset $c2, $c11, 32
; CHECK-NEXT:    csetbounds $c2, $c2, 16
; CHECK-NEXT:    csc $c2, $zero, 0($c11)
; CHECK-NEXT:    csetbounds $c2, $c11, 16
; CHECK-NEXT:    ori $1, $zero, 65495
; CHECK-NEXT:    clcbi $c12, %capcall20(g)($c1)
; CHECK-NEXT:    candperm $c13, $c2, $1
; CHECK-NEXT:    cincoffset $c3, $c11, 64
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    csetbounds $c3, $c3, 16
; CHECK-NEXT:    cincoffset $c11, $c24, $zero
; CHECK-NEXT:    clc $c17, $zero, 96($c11) # 16-byte Folded Reload
; CHECK-NEXT:    clc $c24, $zero, 112($c11) # 16-byte Folded Reload
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    cincoffset $c11, $c11, 128
  %x.addr = alloca i32 addrspace(200)*, align 32, addrspace(200)
  %y.addr = alloca i32 addrspace(200)*, align 32, addrspace(200)
  store i32 addrspace(200)* %x, i32 addrspace(200)* addrspace(200)* %x.addr, align 32
  store i32 addrspace(200)* %y, i32 addrspace(200)* addrspace(200)* %y.addr, align 32
  %x.addr.cast = bitcast i32 addrspace(200)* addrspace(200)* %x.addr to i8 addrspace(200)*
  call void (i8 addrspace(200)*, ...) @g(i8 addrspace(200)* %x.addr.cast, i32 addrspace(200)* addrspace(200)* nonnull %y.addr)
  ret void
}

; When calling a variadic function without any arguments, we should set it to
; null rather than leave it uninitialised due to having no on-stack arguments.
; FIXME: This is currently not done.
define void @check_empty(i8 addrspace(200)* %x) nounwind {
; CHECK-LABEL: check_empty:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cincoffset $c11, $c11, -16
; CHECK-NEXT:    csc $c17, $zero, 0($c11) # 16-byte Folded Spill
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    clcbi $c12, %capcall20(g)($c1)
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    clc $c17, $zero, 0($c11) # 16-byte Folded Reload
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    cincoffset $c11, $c11, 16
  call void (i8 addrspace(200)*, ...) @g(i8 addrspace(200)* %x)
  ret void
}

declare void @g(i8 addrspace(200)*, ...)
