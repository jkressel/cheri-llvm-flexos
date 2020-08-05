// RUN: %cheri_cc1 -o - -O0 -emit-llvm %s | FileCheck %s -check-prefix=CHECK-CHERI -check-prefix=CHECK-ALL
// RUN: %clang %s -target aarch64-none-linux-gnu -march=morello -S -o - -O0 -emit-llvm | FileCheck -check-prefix=CHECK-AARCH64 -check-prefix=CHECK-ALL %s

// RUN: %cheri128_cc1 -o - -O0 -emit-llvm %s | FileCheck %s --check-prefixes=CHECK,CHECK128
// RUN: %cheri256_cc1 -o - -O0 -emit-llvm %s | FileCheck %s --check-prefixes=CHECK,CHECK256
// FIXME: we shouldn't really be testing ASM output in clang
// RXUN: %cheri128_cc1 -o - -O0 -S %s | FileCheck %s -check-prefixes=ASM,ASM128
// RXUN: %cheri256_cc1 -o - -O0 -S %s | FileCheck %s -check-prefixes=ASM,ASM256
void * __capability results[12];

#ifndef __aarch64__
long long testDeprecated(void * __capability foo)
{
	// CHECK-LABEL: @testDeprecated(
	long long x;
	// CHECK-CHERI-LABEL @testDeprecated(
	// CHECK-CHERI: call i64 @llvm.cheri.cap.length.get.i64
	// CHECK-CHERI: call i64 @llvm.cheri.cap.perms.get.i64
	// CHECK-CHERI: call i64 @llvm.cheri.cap.type.get.i64
	// CHECK-CHERI: call i1 @llvm.cheri.cap.tag.get
	// CHECK-CHERI: call i1 @llvm.cheri.cap.sealed.get
	// CHECK-CHERI: call i8 addrspace(200)* @llvm.cheri.cap.perms.and.i64
	// CHECK-CHERI: call i8 addrspace(200)* @llvm.cheri.cap.seal
	// CHECK-CHERI: call i8 addrspace(200)* @llvm.cheri.cap.unseal
	// CHECK-CHERI: call void @llvm.mips.cap.cause.set(i64 42)
	// CHECK-CHERI: call void @llvm.cheri.cap.perms.check.i64
	// CHECK-CHERI: call void @llvm.cheri.cap.type.check
	// CHECK-CHERI: call i64 @llvm.mips.cap.cause.get()
	x &= __builtin_mips_cheri_get_cap_length(foo);
	x &= __builtin_mips_cheri_get_cap_perms(foo);
	x &= __builtin_mips_cheri_get_cap_type(foo);
	x &= __builtin_mips_cheri_get_cap_tag(foo);
	x &= __builtin_mips_cheri_get_cap_sealed(foo);
	results[1] = __builtin_mips_cheri_and_cap_perms(foo, 12);
	results[4] = __builtin_mips_cheri_seal_cap(foo, foo);
	results[5] = __builtin_mips_cheri_unseal_cap(foo, foo);
	__builtin_mips_cheri_set_cause(42);
	__builtin_mips_cheri_check_perms(foo, 12);
	__builtin_mips_cheri_check_type(foo, results[0]);
	return x & __builtin_mips_cheri_get_cause();
}
#endif

long long test(void* __capability foo)
{
  // CHECK-LABEL: @test(
  // ASM-LABEL: test:
  long long x;
  x &= __builtin_cheri_length_get(foo);
  // CHECK-ALL: call i64 @llvm.cheri.cap.length.get.i64
  // ASM: cgetlen ${{[0-9]+}}, $c{{[0-9]+}}
  x &= __builtin_cheri_perms_get(foo);
  // CHECK-ALL: call i64 @llvm.cheri.cap.perms.get.i64
  // ASM: cgetperm ${{[0-9]+}}, $c{{[0-9]+}}
  x &= __builtin_cheri_type_get(foo);
  // CHECK-ALL: call i64 @llvm.cheri.cap.type.get.i64
  // ASM: cgettype ${{[0-9]+}}, $c{{[0-9]+}}
  x &= __builtin_cheri_tag_get(foo);
  // CHECK-ALL: call i1 @llvm.cheri.cap.tag.get
  // ASM: cgettag ${{[0-9]+}}, $c{{[0-9]+}}
  x &= __builtin_cheri_offset_get(foo);
  // CHECK-ALL: call i64 @llvm.cheri.cap.offset.get.i64
  // ASM: cgetoffset ${{[0-9]+}}, $c{{[0-9]+}}
  x &= __builtin_cheri_base_get(foo);
  // CHECK-ALL: call i64 @llvm.cheri.cap.base.get.i64
  // ASM: cgetbase ${{[0-9]+}}, $c{{[0-9]+}}
  x &= __builtin_cheri_sealed_get(foo);
  // CHECK-ALL: call i1 @llvm.cheri.cap.sealed.get
  // ASM: cgetsealed ${{[0-9]+}}, $c{{[0-9]+}}
  void * bar = __builtin_cheri_cap_to_pointer(foo, foo);
  // CHECK-ALL: call i64 @llvm.cheri.cap.to.pointer.i64
  // ASM: ctoptr ${{[0-9]+}}, $c{{[0-9]+}}, $c{{[0-9]+}}
  results[0] = __builtin_cheri_cap_from_pointer(foo, bar);
  // CHECK-ALL: call i8 addrspace(200)* @llvm.cheri.cap.from.pointer.i64
  // ASM: cfromptr $c{{[0-9]+}}, $c{{[0-9]+}}, ${{[0-9]+}}
  results[1] = __builtin_cheri_perms_and(foo, 12);
  // CHECK-ALL: call i8 addrspace(200)* @llvm.cheri.cap.perms.and.i64
  // ASM: candperm $c{{[0-9]+}}, $c{{[0-9]+}}, ${{[0-9]+}}
  results[4] = __builtin_cheri_seal(foo, foo);
  // CHECK-ALL: call i8 addrspace(200)* @llvm.cheri.cap.seal
  // ASM: cseal $c{{[0-9]+}}, $c{{[0-9]+}}, $c{{[0-9]+}}
  results[5] = __builtin_cheri_unseal(foo, foo);
  // CHECK-ALL: call i8 addrspace(200)* @llvm.cheri.cap.unseal
  // ASM: cunseal $c{{[0-9]+}}, $c{{[0-9]+}}, $c{{[0-9]+}}
  results[6] = __builtin_cheri_bounds_set(foo, 42);
  // CHECK-ALL: call i8 addrspace(200)* @llvm.cheri.cap.bounds.set.i64(i8 addrspace(200)* {{.+}}, i64 42)
  // ASM: csetbounds $c{{[0-9]+}}, $c{{[0-9]+}}, 42
  results[6] = __builtin_cheri_bounds_set(foo, 16384); // too big for immediate csetbounds
  // CHECK-ALL: call i8 addrspace(200)* @llvm.cheri.cap.bounds.set.i64(i8 addrspace(200)* {{.+}}, i64 16384)
  // ASM: daddiu [[INEXACT_SIZE:\$[0-9]+]], $zero, 16384
  // ASM: csetbounds $c{{[0-9]+}}, $c{{[0-9]+}}, [[INEXACT_SIZE]]
  results[7] = __builtin_cheri_bounds_set_exact(foo, 43);
  // CHECK-ALL: call i8 addrspace(200)* @llvm.cheri.cap.bounds.set.exact.i64(i8 addrspace(200)* {{.+}}, i64 43)
  // ASM: daddiu [[EXACT_SIZE:\$[0-9]+]], $zero, 43
  // ASM: csetboundsexact $c{{[0-9]+}}, $c{{[0-9]+}}, [[EXACT_SIZE]]
  results[8] = __builtin_cheri_seal_entry(foo);
  // CHECK: call i8 addrspace(200)* @llvm.cheri.cap.seal.entry(i8 addrspace(200)* {{.+}})
  // ASM: csealentry $c{{[0-9]+}}, $c{{[0-9]+}}

#ifndef __aarch64__
  __builtin_mips_cheri_cause_set(42);
#endif

  // CHECK-CHERI: call void @llvm.mips.cap.cause.set(i64 42)
  // ASM: csetcause ${{[0-9]+}}
#ifndef __aarch64__
  __builtin_cheri_perms_check(foo, 12);
  __builtin_cheri_type_check(foo, results[0]);
#endif
  // CHECK-CHERI: call void @llvm.cheri.cap.perms.check.i64
  // ASM: ccheckperm $c{{[0-9]+}}, ${{[0-9]+}}
  // CHECK-CHERI: call void @llvm.cheri.cap.type.check
  // ASM: cchecktype $c{{[0-9]+}}, $c{{[0-9]+}}
#ifndef __aarch64__
  return x & __builtin_mips_cheri_get_cause();
#endif
  // CHECK-CHERI: call i64 @llvm.mips.cap.cause.get()
  // ASM: cgetcause ${{[0-9]+}}
}

// FIXME: convert this to an IR test.
void buildcap(void * __capability auth, __intcap_t bits) {
  // CHECK-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.build
  // CHECK-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.type.copy
  // CHECK-AARCH64: call i8 addrspace(200)* @llvm.cheri.cap.conditional.seal
  // ASM-LABEL: buildcap:
  void * __capability tagged = __builtin_cheri_cap_build(auth, (void * __capability)bits);
  // ASM: cbuildcap $c{{[0-9]+}}, $c{{[0-9]+}}, $c{{[0-9]+}}
  void * __capability sealed = __builtin_cheri_cap_type_copy(auth, tagged);
  // ASM: ccopytype $c{{[0-9]+}}, $c{{[0-9]+}}, $c{{[0-9]+}}
  void * __capability condseal = __builtin_cheri_conditional_seal(auth, tagged);
  // ASM: ccseal $c{{[0-9]+}}, $c{{[0-9]+}}, $c{{[0-9]+}}
}


int crap_cram(int len) {
  // CHECK-LABEL: @crap_cram(
  // ASM-LABEL: crap_cram:
  return __builtin_cheri_round_representable_length(len) & __builtin_cheri_representable_alignment_mask(len);
  // CHECK: call i64 @llvm.cheri.round.representable.length.i64(
  // CHECK: call i64 @llvm.cheri.representable.alignment.mask.i64(
  // ASM128: croundrepresentablelength	${{[0-9]+}}, ${{[0-9]+}}
  // ASM128: crepresentablealignmentmask	${{[0-9]+}}, ${{[0-9]+}}
  // These are no-ops for 256 and should not be emitted:
  // ASM256-NOT: croundrepresentablelength
  // ASM256-NOT: crepresentablealignmentmask
}
