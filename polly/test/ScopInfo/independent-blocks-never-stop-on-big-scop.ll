; RUN: opt %loadPolly -polly-detect-unprofitable -polly-independent < %s
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @main() nounwind uwtable readnone {
  %arr = alloca [100 x i32], align 16
  br label %1

; <label>:1                                       ; preds = %1, %0
  %indvars.iv3 = phi i64 [ 0, %0 ], [ %indvars.iv.next4, %1 ]
  %2 = getelementptr inbounds [100 x i32], [100 x i32]* %arr, i64 0, i64 %indvars.iv3
  %3 = trunc i64 %indvars.iv3 to i32
  store i32 %3, i32* %2, align 4, !tbaa !0
  %indvars.iv.next4 = add i64 %indvars.iv3, 1
  %lftr.wideiv5 = trunc i64 %indvars.iv.next4 to i32
  %exitcond6 = icmp eq i32 %lftr.wideiv5, 100
  br i1 %exitcond6, label %.preheader, label %1

.preheader:                                       ; preds = %.preheader, %1
  %indvars.iv = phi i64 [ %indvars.iv.next, %.preheader ], [ 0, %1 ]
  %4 = getelementptr inbounds [100 x i32], [100 x i32]* %arr, i64 0, i64 %indvars.iv
  %5 = load i32, i32* %4, align 4, !tbaa !0
  %6 = xor i32 %5, -1
  %7 = shl i32 %5, 15
  %8 = add nsw i32 %7, %6
  %9 = ashr i32 %8, 12
  %10 = xor i32 %9, %8
  %11 = mul i32 %10, 9
  %12 = ashr i32 %11, 4
  %13 = xor i32 %12, %11
  %14 = mul nsw i32 %13, 20571
  %15 = ashr i32 %14, 16
  %16 = xor i32 %15, %14
  %17 = xor i32 %16, -1
  %18 = shl i32 %16, 15
  %19 = add nsw i32 %18, %17
  %20 = ashr i32 %19, 12
  %21 = xor i32 %20, %19
  %22 = mul i32 %21, 5
  %23 = ashr i32 %22, 4
  %24 = xor i32 %23, %22
  %25 = mul nsw i32 %24, 20576
  %26 = ashr i32 %25, 16
  %27 = xor i32 %26, %25
  %28 = xor i32 %27, -1
  %29 = shl i32 %27, 15
  %30 = add nsw i32 %29, %28
  %31 = ashr i32 %30, 12
  %32 = xor i32 %31, %30
  %33 = mul i32 %32, 5
  %34 = ashr i32 %33, 4
  %35 = xor i32 %34, %33
  %36 = mul nsw i32 %35, 2057
  %37 = ashr i32 %36, 16
  %38 = xor i32 %37, %36
  %39 = xor i32 %38, -1
  %40 = shl i32 %38, 15
  %41 = add nsw i32 %40, %39
  %42 = ashr i32 %41, 12
  %43 = xor i32 %42, %41
  %44 = mul i32 %43, 5
  %45 = ashr i32 %44, 4
  %46 = xor i32 %45, %44
  %47 = mul nsw i32 %46, 20572
  %48 = ashr i32 %47, 16
  %49 = xor i32 %48, %47
  %50 = xor i32 %49, -1
  %51 = shl i32 %49, 15
  %52 = add nsw i32 %51, %50
  %53 = ashr i32 %52, 12
  %54 = xor i32 %53, %52
  %55 = mul i32 %54, 5
  %56 = ashr i32 %55, 4
  %57 = xor i32 %56, %55
  %58 = mul nsw i32 %57, 2051
  %59 = ashr i32 %58, 16
  %60 = xor i32 %59, %58
  %61 = xor i32 %60, -1
  %62 = shl i32 %60, 15
  %63 = add nsw i32 %62, %61
  %64 = ashr i32 %63, 12
  %65 = xor i32 %64, %63
  %66 = mul i32 %65, 5
  %67 = ashr i32 %66, 4
  %68 = xor i32 %67, %66
  %69 = mul nsw i32 %68, 2057
  %70 = ashr i32 %69, 16
  %71 = xor i32 %70, %69
  %72 = xor i32 %71, -1
  %73 = shl i32 %71, 15
  %74 = add nsw i32 %73, %72
  %75 = ashr i32 %74, 12
  %76 = xor i32 %75, %74
  %77 = mul i32 %76, 5
  %78 = ashr i32 %77, 4
  %79 = xor i32 %78, %77
  %80 = mul nsw i32 %79, 205
  %81 = ashr i32 %80, 17
  %82 = xor i32 %81, %80
  %83 = xor i32 %82, -1
  %84 = shl i32 %82, 15
  %85 = add nsw i32 %84, %83
  %86 = ashr i32 %85, 12
  %87 = xor i32 %86, %85
  %88 = mul i32 %87, 5
  %89 = ashr i32 %88, 4
  %90 = xor i32 %89, %88
  %91 = mul nsw i32 %90, 2057
  %92 = ashr i32 %91, 16
  %93 = xor i32 %92, %91
  %94 = xor i32 %93, -1
  %95 = shl i32 %93, 15
  %96 = add nsw i32 %95, %94
  %97 = ashr i32 %96, 12
  %98 = xor i32 %97, %96
  %99 = mul i32 %98, 5
  %100 = ashr i32 %99, 3
  %101 = xor i32 %100, %99
  %102 = mul nsw i32 %101, 20571
  %103 = ashr i32 %102, 16
  %104 = xor i32 %103, %102
  %105 = xor i32 %104, -1
  %106 = shl i32 %104, 15
  %107 = add nsw i32 %106, %105
  %108 = ashr i32 %107, 12
  %109 = xor i32 %108, %107
  %110 = mul i32 %109, 5
  %111 = ashr i32 %110, 4
  %112 = xor i32 %111, %110
  %113 = mul nsw i32 %112, 2057
  %114 = ashr i32 %113, 16
  %115 = xor i32 %114, %113
  %116 = xor i32 %115, -1
  %117 = shl i32 %115, 15
  %118 = add nsw i32 %117, %116
  %119 = ashr i32 %118, 12
  %120 = xor i32 %119, %118
  %121 = mul i32 %120, 5
  %122 = ashr i32 %121, 4
  %123 = xor i32 %122, %121
  %124 = mul nsw i32 %123, 20572
  %125 = ashr i32 %124, 16
  %126 = xor i32 %125, %124
  %127 = xor i32 %126, -1
  %128 = shl i32 %126, 15
  %129 = add nsw i32 %128, %127
  %130 = ashr i32 %129, 12
  %131 = xor i32 %130, %129
  %132 = mul i32 %131, 5
  %133 = ashr i32 %132, 4
  %134 = xor i32 %133, %132
  %135 = mul nsw i32 %134, 2057
  %136 = ashr i32 %135, 16
  %137 = xor i32 %136, %135
  %138 = xor i32 %137, -1
  %139 = shl i32 %137, 15
  %140 = add nsw i32 %139, %138
  %141 = ashr i32 %140, 12
  %142 = xor i32 %141, %140
  %143 = mul i32 %142, 5
  %144 = ashr i32 %143, 4
  %145 = xor i32 %144, %143
  %146 = mul nsw i32 %145, 2057
  %147 = ashr i32 %146, 16
  %148 = xor i32 %147, %146
  %149 = xor i32 %148, -1
  %150 = shl i32 %148, 15
  %151 = add nsw i32 %150, %149
  %152 = ashr i32 %151, 12
  %153 = xor i32 %152, %151
  %154 = mul i32 %153, 5
  %155 = ashr i32 %154, 4
  %156 = xor i32 %155, %154
  %157 = mul nsw i32 %156, 2057
  %158 = ashr i32 %157, 16
  %159 = xor i32 %158, %157
  %160 = xor i32 %159, -1
  %161 = shl i32 %159, 15
  %162 = add nsw i32 %161, %160
  %163 = ashr i32 %162, 12
  %164 = xor i32 %163, %162
  %165 = mul i32 %164, 5
  %166 = ashr i32 %165, 4
  %167 = xor i32 %166, %165
  %168 = mul nsw i32 %167, 2057
  %169 = ashr i32 %168, 16
  %170 = xor i32 %169, %168
  store i32 %170, i32* %4, align 4, !tbaa !0
  %indvars.iv.next = add i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, 100
  br i1 %exitcond, label %171, label %.preheader

; <label>:171                                     ; preds = %.preheader
  ret i32 0
}

!0 = !{!"int", !1}
!1 = !{!"omnipotent char", !2}
!2 = !{!"Simple C/C++ TBAA", null}
