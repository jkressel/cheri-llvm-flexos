// RUN: %cheri_purecap_cc1 -emit-llvm -o - %s -mllvm -cheri-cap-table-abi=plt | FileCheck %s
// RUN: %clang_cc1 -triple cheri-unknown-freebsd -target-abi purecap -emit-llvm -o - %s -mllvm -cheri-cap-table-abi=plt | FileCheck %s

// type_info type for 'typeid' to work.
namespace std { class type_info; }

// CHECK: [[TI_TYPE:%"[a-zA-Z_:.]+"]] = type opaque
// CHECK: [[TI_GLOBAL:@_ZTI[a-zA-Z]+]] = external addrspace(200) constant i8 addrspace(200)*  

void f() {
  // CHECK: store [[TI_TYPE]] addrspace(200)* bitcast (i8 addrspace(200)* addrspace(200)* [[TI_GLOBAL]] to [[TI_TYPE]] addrspace(200)*), [[TI_TYPE]] addrspace(200)* addrspace(200)*
  const std::type_info& t = typeid(bool);
}
