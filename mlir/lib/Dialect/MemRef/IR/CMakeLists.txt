add_mlir_dialect_library(MLIRMemRef
  MemRefDialect.cpp
  MemRefOps.cpp

  ADDITIONAL_HEADER_DIRS
  ${PROJECT_SOURCE_DIR}/inlude/mlir/Dialect/MemRefDialect

  DEPENDS
  MLIRStandardOpsIncGen
  MLIRMemRefOpsIncGen

  LINK_COMPONENTS
  Core

  LINK_LIBS PUBLIC
  MLIRDialect
  MLIRInferTypeOpInterface
  MLIRIR
  MLIRStandard
  MLIRTensor
  MLIRViewLikeInterface
)
