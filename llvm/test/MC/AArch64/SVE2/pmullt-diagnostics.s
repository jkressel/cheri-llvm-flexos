// RUN: not llvm-mc -triple=aarch64 -show-encoding -mattr=+sve2  2>&1 < %s| FileCheck %s


// ------------------------------------------------------------------------- //
// Invalid element width

pmullt z0.b, z0.b, z0.b
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: pmullt z0.b, z0.b, z0.b
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

pmullt z0.h, z0.h, z0.h
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: pmullt z0.h, z0.h, z0.h
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

pmullt z0.s, z0.s, z0.s
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: pmullt z0.s, z0.s, z0.s
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

pmullt z0.d, z0.d, z0.d
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: pmullt z0.d, z0.d, z0.d
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

pmullt z0.q, z0.q, z0.q
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: pmullt z0.q, z0.q, z0.q
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

// --------------------------------------------------------------------------//
// Negative tests for instructions that are incompatible with movprfx

movprfx z31.d, p0/z, z6.d
pmullt z0.d, z1.s, z2.s
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: instruction is unpredictable when following a movprfx, suggest replacing movprfx with mov
// CHECK-NEXT: pmullt z0.d, z1.s, z2.s
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

movprfx z31, z6
pmullt z0.d, z1.s, z2.s
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: instruction is unpredictable when following a movprfx, suggest replacing movprfx with mov
// CHECK-NEXT: pmullt z0.d, z1.s, z2.s
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:
