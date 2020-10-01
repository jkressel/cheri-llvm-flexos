// RUN: %cheri_cc1 %s -O1 -o - -emit-llvm | FileCheck %s --check-prefix=CAPS
// RUN: %clang %s -O1 -target aarch64-none-linux-gnu -march=morello -o - -emit-llvm -S -fPIC | FileCheck %s --check-prefix=CAPS-AARCH64
// RUN: %clang_cc1 %s -O1 -triple i386-unknown-freebsd -o - -emit-llvm | FileCheck %s --check-prefix=PTRS
// RUN: %clang %s -O1 -target aarch64-none-linux-gnu -o - -emit-llvm -fPIC -S | FileCheck %s --check-prefix=PTRS-AARCH64

// Remove the static from all of the function prototypes so that this really exists.
#define static
#define inline 
#include <cheri.h>

// PTRS: define i32 @cheri_length_get(i8* nocapture readnone
// PTRS: ret i32 -1
// PTRS: define i32 @cheri_base_get(i8* nocapture readnone
// PTRS: ret i32 -1
// PTRS: define i32 @cheri_offset_get(i8* nocapture readnone
// PTRS: ret i32 -1
// PTRS: define i8* @cheri_offset_set(i8* readnone returned{{( %.+)?}}, i32
// PTRS: ret i8*
// PTRS: define i32 @cheri_type_get(i8* nocapture readnone
// PTRS: ret i32 0
// PTRS: define zeroext i16 @cheri_perms_get(i8* nocapture readnone
// PTRS: ret i16 0
// PTRS: define i8* @cheri_perms_and(i8* readnone returned{{.*}}, i16
// PTRS: ret i8*
// PTRS: define zeroext i16 @cheri_flags_get(i8* nocapture readnone
// PTRS: ret i16 0
// PTRS: define i8* @cheri_flags_set(i8* readnone returned{{( %.+)?}}, i16 zeroext
// PTRS: ret i8*
// PTRS: define zeroext i1 @cheri_tag_get(i8* nocapture readnone
// PTRS: ret i1 false
// PTRS: define zeroext i1 @cheri_sealed_get(i8* nocapture readnone
// PTRS: ret i1 false
// PTRS: define i8* @cheri_offset_increment(i8* readnone{{( %.+)?}}, i32
// PTRS: %[[TEMP1:[0-9a-z.]+]] = getelementptr inbounds i8, i8*{{( %.+)?}}, i32
// PTRS: ret i8* %[[TEMP1]]
// PTRS: define i8* @cheri_tag_clear(i8* readnone returned
// PTRS: ret i8*
// PTRS: define i8* @cheri_seal(i8* readnone returned{{( %.+)?}}, i8* nocapture readnone
// PTRS: ret i8*
// PTRS: define i8* @cheri_unseal(i8* readnone returned{{( %.+)?}}, i8* nocapture readnone
// PTRS: ret i8*
// PTRS: define i8* @cheri_bounds_set(i8* readnone returned{{.*}}, i32
// PTRS: ret i8*
// PTRS: define i8* @cheri_cap_from_pointer(i8* nocapture readnone %{{.*}}, i8* readnone returned %{{.*}})
// PTRS: ret i8*
// PTRS: define i8* @cheri_cap_to_pointer(i8* nocapture readnone %{{.*}}, i8* readnone returned %{{.*}})
// PTRS: ret i8*
// PTRS: define void @cheri_perms_check(i8* nocapture{{.*}}, i16
// PTRS: ret void
// PTRS: define void @cheri_type_check(i8* nocapture{{( %.+)?}}, i8* nocapture
// PTRS: ret void
// PTRS: define noalias i8* @cheri_global_data_get()
// PTRS: ret i8* null
// PTRS: define noalias i8* @cheri_program_counter_get()
// PTRS: ret i8* null

// PTRS-AARCH64: define i64 @cheri_length_get(i8* nocapture readnone %__cap)
// PTRS-AARCH64: ret i64 -1
// PTRS-AARCH64: define i64 @cheri_base_get(i8* nocapture readnone %__cap)
// PTRS-AARCH64: ret i64 -1
// PTRS-AARCH64: define i64 @cheri_offset_get(i8* nocapture readnone %__cap)
// PTRS-AARCH64: ret i64 -1
// PTRS-AARCH64: define i8* @cheri_offset_set(i8* readnone returned %__cap, i64  %__val)
// PTRS-AARCH64: ret i8* %__cap
// PTRS-AARCH64: define i32 @cheri_type_get(i8* nocapture readnone %__cap)
// PTRS-AARCH64: ret i32 0
// PTRS-AARCH64: define i32 @cheri_perms_get(i8* nocapture readnone %__cap)
// PTRS-AARCH64: ret i32 0
// PTRS-AARCH64: define i8* @cheri_perms_and(i8* readnone returned %__cap, i32 %__val)
// PTRS-AARCH64: ret i8* %__cap
// PTRS-AARCH64: define i1 @cheri_tag_get(i8* nocapture readnone %__cap)
// PTRS-AARCH64: ret i1 false
// PTRS-AARCH64: define i1 @cheri_sealed_get(i8* nocapture readnone %__cap)
// PTRS-AARCH64: ret i1 false
// PTRS-AARCH64: define i8* @cheri_offset_increment(i8* readnone %__cap, i64 %__offset)
// PTRS-AARCH64: %add.ptr = getelementptr inbounds i8, i8* %__cap, i64 %__offset
// PTRS-AARCH64: ret i8* %add.ptr
// PTRS-AARCH64: define i8* @cheri_tag_clear(i8* readnone returned %__cap)
// PTRS-AARCH64: ret i8* %__cap
// PTRS-AARCH64: define i8* @cheri_seal(i8* readnone returned %__cap, i8* nocapture readnone %__type)
// PTRS-AARCH64: ret i8* %__cap
// PTRS-AARCH64: define i8* @cheri_unseal(i8* readnone returned %__cap, i8* nocapture readnone %__type)
// PTRS-AARCH64: ret i8* %__cap
// PTRS-AARCH64: define i8* @cheri_bounds_set(i8* readnone returned %__cap, i64 %__bounds)
// PTRS-AARCH64: ret i8* %__cap
// PTRS-AARCH64: define i8* @cheri_cap_from_pointer(i8* nocapture readnone %{{.*}}, i8* readnone returned %{{.*}})
// PTRS-AARCH64: ret i8*
// PTRS-AARCH64: define i8* @cheri_cap_to_pointer(i8* nocapture readnone %{{.*}}, i8* readnone returned %{{.*}})
// PTRS-AARCH64: ret i8*
// PTRS-AARCH64: define noalias i8* @cheri_global_data_get()
// PTRS-AARCH64: ret i8* null
// PTRS-AARCH64: define noalias i8* @cheri_program_counter_get()
// PTRS-AARCH64: ret i8* null

// CAPS: define i64 @cheri_length_get(i8 addrspace(200)* readnone
// CAPS: call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)*
// CAPS: define i64 @cheri_base_get(i8 addrspace(200)* readnone
// CAPS: call i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)*
// CAPS: define i64 @cheri_offset_get(i8 addrspace(200)* readnone
// CAPS: call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)*
// CAPS: define i8 addrspace(200)* @cheri_offset_set(i8 addrspace(200)* readnone{{( %.+)?}}, i64 zeroext{{( %.+)?}}
// CAPS: call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)*{{( %.+)?}}, i64{{( %.+)?}})
// CAPS: define signext i32 @cheri_type_get(i8 addrspace(200)*
// CAPS: call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)*
// CAPS: define zeroext i16 @cheri_perms_get(i8 addrspace(200)*
// CAPS: call i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)*
// CAPS: define i8 addrspace(200)* @cheri_perms_and(i8 addrspace(200)* readnone{{( %.+)?}}, i16 zeroext
// CAPS: call i8 addrspace(200)* @llvm.cheri.cap.perms.and.i64(i8 addrspace(200)*{{( %.+)?}}, i64
// CAPS: define zeroext i16 @cheri_flags_get(i8 addrspace(200)*
// CAPS: call i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)*
// CAPS: define i8 addrspace(200)* @cheri_flags_set(i8 addrspace(200)* readnone{{( %.+)?}}, i16 zeroext
// CAPS: call i8 addrspace(200)* @llvm.cheri.cap.flags.set.i64(i8 addrspace(200)*{{( %.+)?}}, i64
// CAPS: define zeroext i1 @cheri_tag_get(i8 addrspace(200)* readnone
// CAPS: call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)*
// CAPS: define zeroext i1 @cheri_sealed_get(i8 addrspace(200)* readnone
// CAPS: call i1 @llvm.cheri.cap.sealed.get(i8 addrspace(200)*
// CAPS: define i8 addrspace(200)* @cheri_offset_increment(i8 addrspace(200)* readnone{{( %.+)?}}, i64 signext
// CAPS: %__builtin_cheri_offset_increment = getelementptr i8, i8 addrspace(200)* %__cap, i64 %__offset
// CAPS: ret i8 addrspace(200)* %__builtin_cheri_offset_increment
// CAPS: define i8 addrspace(200)* @cheri_tag_clear(i8 addrspace(200)* readnone
// CAPS: call i8 addrspace(200)* @llvm.cheri.cap.tag.clear(i8 addrspace(200)*
// CAPS: define i8 addrspace(200)* @cheri_seal(i8 addrspace(200)* readnone{{( %.+)?}}, i8 addrspace(200)* readnone
// CAPS: call i8 addrspace(200)* @llvm.cheri.cap.seal(i8 addrspace(200)*{{( %.+)?}}, i8 addrspace(200)*
// CAPS: define i8 addrspace(200)* @cheri_unseal(i8 addrspace(200)* readnone{{( %.+)?}}, i8 addrspace(200)* readnone
// CAPS: call i8 addrspace(200)* @llvm.cheri.cap.unseal(i8 addrspace(200)*{{( %.+)?}}, i8 addrspace(200)*
// CAPS: define i8 addrspace(200)* @cheri_cap_from_pointer(i8 addrspace(200)* readnone{{( %.+)?}}, i8* {{(%.+)?}})
// CAPS: call i8 addrspace(200)* @llvm.cheri.cap.from.pointer.i64(i8 addrspace(200)*{{( %.+)?}}, i64
// CAPS: define i8* @cheri_cap_to_pointer(i8 addrspace(200)* {{(%.+)?}}, i8 addrspace(200)* {{(%.+)?}})
// CAPS: call i64 @llvm.cheri.cap.to.pointer.i64(i8 addrspace(200)*{{( %.+)?}}, i8 addrspace(200)*
// CAPS: define void @cheri_perms_check(i8 addrspace(200)*{{( %.+)?}}, i16 zeroext
// CAPS: call void @llvm.cheri.cap.perms.check.i64(i8 addrspace(200)*{{( %.+)?}}, i64
// CAPS: define void @cheri_type_check(i8 addrspace(200)*{{( %.+)?}}, i8 addrspace(200)*
// CAPS: call void @llvm.cheri.cap.type.check(i8 addrspace(200)*{{( %.+)?}}, i8 addrspace(200)*
// CAPS: define i8 addrspace(200)* @cheri_global_data_get()
// CAPS: call i8 addrspace(200)* @llvm.cheri.ddc.get()
// CAPS: define i8 addrspace(200)* @cheri_program_counter_get()
// CAPS: call i8 addrspace(200)* @llvm.cheri.pcc.get()

// CAPS-AARCH64: define i64 @cheri_length_get(i8 addrspace(200)* readnone %__cap)
// CAPS-AARCH64: call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)* %__cap)
// CAPS-AARCH64: define i64 @cheri_base_get(i8 addrspace(200)* readnone %__cap)
// CAPS-AARCH64: call i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)* %__cap)
// CAPS-AARCH64: define i64 @cheri_offset_get(i8 addrspace(200)* readnone %__cap)
// CAPS-AARCH64: call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %__cap)
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_offset_set(i8 addrspace(200)* readnone %__cap, i64 %__val)
// CAPS-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %__cap, i64 %__val)
// CAPS-AARCH64: define i32 @cheri_type_get(i8 addrspace(200)* %__cap)
// CAPS-AARCH64: call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)* %__cap)
// CAPS-AARCH64: define i32 @cheri_perms_get(i8 addrspace(200)*  %__cap)
// CAPS-AARCH64: call i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)* %__cap)
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_perms_and(i8 addrspace(200)* readnone %__cap, i32 %__val)
// CAPS-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.perms.and.i64(i8 addrspace(200)* %__cap, i64
// CAPS-AARCH64: define i1 @cheri_tag_get(i8 addrspace(200)* readnone %__cap)
// CAPS-AARCH64: call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* %__cap)
// CAPS-AARCH64: define i1 @cheri_sealed_get(i8 addrspace(200)* readnone %__cap)
// CAPS-AARCH64: call i1 @llvm.cheri.cap.sealed.get(i8 addrspace(200)* %__cap)
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_offset_increment(i8 addrspace(200)* readnone %__cap, i64 %__offset)
// CAPS-AARCH64: getelementptr i8, i8 addrspace(200)* {{.*}}, i64
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_tag_clear(i8 addrspace(200)* readnone %__cap)
// CAPS-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.tag.clear(i8 addrspace(200)* %__cap)
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_seal(i8 addrspace(200)* readnone %__cap, i8 addrspace(200)* readnone %__type)
// CAPS-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.seal(i8 addrspace(200)* %__cap, i8 addrspace(200)* %__type)
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_unseal(i8 addrspace(200)* readnone %__cap, i8 addrspace(200)* readnone %__type)
// CAPS-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.unseal(i8 addrspace(200)* %__cap, i8 addrspace(200)* %__type)
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_bounds_set(i8 addrspace(200)* readnone %__cap, i64 %__bounds)
// CAPS-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.bounds.set.i64(i8 addrspace(200)* %__cap, i64 %__bounds)
// CAPS-AARCH64: define i64 @cheri_round_representable_length(i64 %__length)
// CAPS-AARCH64: call i64 @llvm.cheri.round.representable.length.i64(i64 %__length)
// CAPS-AARCH64: define i64 @cheri_round_representable_mask(i64 %__mask)
// CAPS-AARCH64: call i64 @llvm.cheri.representable.alignment.mask.i64(i64 %__mask)
// CAPS-AARCH64: define i64 @cheri_copy_from_high(i8 addrspace(200)* readnone %__cap)
// CAPS-AARCH64: call i64 @llvm.cheri.cap.copy.from.high.i64(i8 addrspace(200)* %__cap)
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_copy_to_high(i8 addrspace(200)* readnone %__cap, i64 %__high)
// CAPS-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.copy.to.high.i64(i8 addrspace(200)* %__cap, i64 %__high)
// CAPS-AARCH64: define i64 @cheri_equal_exact(i8 addrspace(200)* %__cap_a, i8 addrspace(200)* %__cap_b)
// CAPS-AARCH64: call i1 @llvm.cheri.cap.equal.exact(i8 addrspace(200)* %__cap_a, i8 addrspace(200)* %__cap_b)
// CAPS-AARCH64: define i64 @cheri_subset_test(i8 addrspace(200)* %__cap_a, i8 addrspace(200)* %__cap_b)
// CAPS-AARCH64: call i1 @llvm.cheri.cap.subset.test(i8 addrspace(200)* %__cap_a, i8 addrspace(200)* %__cap_b)
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_cap_from_pointer(i8 addrspace(200)* readnone %{{.*}}, i8* %{{.*}})
// CAPS-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.from.pointer.i64(i8 addrspace(200)* %{{.*}}, i64
// CAPS-AArch64: define i64 @cheri_cap_to_pointer(i8 addrspace(200)* readnone %{{.*}}, i8 addrspace(200)* readnone %{{.*}})
// CAPS-AARCH64: call i64 @llvm.cheri.cap.to.pointer.i64(i8 addrspace(200)*
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_global_data_get()
// CAPS-AARCH64: call i8 addrspace(200)* @llvm.cheri.ddc.get()
// CAPS-AARCH64: define i8 addrspace(200)* @cheri_program_counter_get()
// CAPS-AARCH64: call i8 addrspace(200)* @llvm.cheri.pcc.get()

