//===-- MipsTargetStreamer.cpp - Mips Target Streamer Methods -------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides Mips specific target streamer methods.
//
//===----------------------------------------------------------------------===//

#include "MipsTargetStreamer.h"
#include "MipsInstPrinter.h"
#include "MCTargetDesc/MipsABIInfo.h"
#include "MipsELFStreamer.h"
#include "MipsMCExpr.h"
#include "MipsMCTargetDesc.h"
#include "MipsTargetObjectFile.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCSectionELF.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"

#include "../cheri-compressed-cap/cheri_compressed_cap.h"

using namespace llvm;

namespace {
static cl::opt<bool> RoundSectionSizes(
    "mips-round-section-sizes", cl::init(false),
    cl::desc("Round section sizes up to the section alignment"), cl::Hidden);
} // end anonymous namespace

llvm::Optional<unsigned> llvm::getCheriCapabilitySize(FeatureBitset Features) {
  if (Features[Mips::FeatureMipsCheri256]) {
    assert(Features[Mips::FeatureMipsCheri]);
    return 32;
  }
  if (Features[Mips::FeatureMipsCheri128]) {
    assert(Features[Mips::FeatureMipsCheri]);
    return 16;
  }
  if (Features[Mips::FeatureMipsCheri64]) {
    assert(Features[Mips::FeatureMipsCheri]);
    return 8;
  }
  assert(!Features[Mips::FeatureMipsCheri]);
  return None;
}

static bool isMicroMips(const MCSubtargetInfo *STI) {
  return STI->getFeatureBits()[Mips::FeatureMicroMips];
}

MipsTargetStreamer::MipsTargetStreamer(MCStreamer &S,
                                       llvm::Optional<unsigned> CheriCapSize)
    : MCTargetStreamer(S), CheriCapSize(CheriCapSize), GPReg(Mips::GP),
      ModuleDirectiveAllowed(true) {
  GPRInfoSet = FPRInfoSet = FrameInfoSet = false;
}
void MipsTargetStreamer::emitDirectiveSetMicroMips() {}
void MipsTargetStreamer::emitDirectiveSetNoMicroMips() {}
void MipsTargetStreamer::setUsesMicroMips() {}
void MipsTargetStreamer::emitDirectiveSetMips16() {}
void MipsTargetStreamer::emitDirectiveSetNoMips16() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetReorder() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetNoReorder() {}
void MipsTargetStreamer::emitDirectiveSetMacro() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetNoMacro() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMsa() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetNoMsa() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMt() {}
void MipsTargetStreamer::emitDirectiveSetNoMt() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetCRC() {}
void MipsTargetStreamer::emitDirectiveSetNoCRC() {}
void MipsTargetStreamer::emitDirectiveSetVirt() {}
void MipsTargetStreamer::emitDirectiveSetNoVirt() {}
void MipsTargetStreamer::emitDirectiveSetGINV() {}
void MipsTargetStreamer::emitDirectiveSetNoGINV() {}
void MipsTargetStreamer::emitDirectiveSetAt() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetAtWithArg(unsigned RegNo) {
  forbidModuleDirective();
}
void MipsTargetStreamer::emitDirectiveSetNoAt() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveEnd(StringRef Name) {}
void MipsTargetStreamer::emitDirectiveEnt(const MCSymbol &Symbol) {}
void MipsTargetStreamer::emitDirectiveAbiCalls() {}
void MipsTargetStreamer::emitDirectiveNaN2008() {}
void MipsTargetStreamer::emitDirectiveNaNLegacy() {}
void MipsTargetStreamer::emitDirectiveOptionPic0() {}
void MipsTargetStreamer::emitDirectiveOptionPic2() {}
void MipsTargetStreamer::emitDirectiveInsn() { forbidModuleDirective(); }
void MipsTargetStreamer::emitFrame(unsigned StackReg, unsigned StackSize,
                                   unsigned ReturnReg) {}
void MipsTargetStreamer::emitMask(unsigned CPUBitmask, int CPUTopSavedRegOff) {}
void MipsTargetStreamer::emitFMask(unsigned FPUBitmask, int FPUTopSavedRegOff) {
}
void MipsTargetStreamer::emitDirectiveSetArch(StringRef Arch) {
  forbidModuleDirective();
}
void MipsTargetStreamer::emitDirectiveSetMips0() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips1() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips2() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips3() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips4() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips5() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips32() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips32R2() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips32R3() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips32R5() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips32R6() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips64() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips64R2() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips64R3() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips64R5() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetMips64R6() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetPop() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetPush() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetSoftFloat() {
  forbidModuleDirective();
}
void MipsTargetStreamer::emitDirectiveSetHardFloat() {
  forbidModuleDirective();
}
void MipsTargetStreamer::emitDirectiveSetDsp() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetDspr2() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetNoDsp() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveCpLoad(unsigned RegNo) {}
void MipsTargetStreamer::emitDirectiveCpLocal(unsigned RegNo) {
  // .cplocal $reg
  // This directive forces to use the alternate register for context pointer.
  // For example
  //   .cplocal $4
  //   jal foo
  // expands to
  //   ld    $25, %call16(foo)($4)
  //   jalr  $25

  if (!getABI().IsN32() && !getABI().IsN64())
    return;

  GPReg = RegNo;

  forbidModuleDirective();
}
bool MipsTargetStreamer::emitDirectiveCpRestore(
    int Offset, function_ref<unsigned()> GetATReg, SMLoc IDLoc,
    const MCSubtargetInfo *STI) {
  forbidModuleDirective();
  return true;
}
void MipsTargetStreamer::emitDirectiveCpsetup(unsigned RegNo, int RegOrOffset,
                                              const MCSymbol &Sym, bool IsReg) {
}
void MipsTargetStreamer::emitDirectiveCpreturn(unsigned SaveLocation,
                                               bool SaveLocationIsRegister) {}

void MipsTargetStreamer::emitDirectiveModuleFP() {}

void MipsTargetStreamer::emitDirectiveModuleOddSPReg() {
  if (!ABIFlagsSection.OddSPReg && !ABIFlagsSection.Is32BitABI)
    report_fatal_error("+nooddspreg is only valid for O32");
}
void MipsTargetStreamer::emitDirectiveModuleSoftFloat() {}
void MipsTargetStreamer::emitDirectiveModuleHardFloat() {}
void MipsTargetStreamer::emitDirectiveModuleMT() {}
void MipsTargetStreamer::emitDirectiveModuleCRC() {}
void MipsTargetStreamer::emitDirectiveModuleNoCRC() {}
void MipsTargetStreamer::emitDirectiveModuleVirt() {}
void MipsTargetStreamer::emitDirectiveModuleNoVirt() {}
void MipsTargetStreamer::emitDirectiveModuleGINV() {}
void MipsTargetStreamer::emitDirectiveModuleNoGINV() {}
void MipsTargetStreamer::emitDirectiveSetFp(
    MipsABIFlagsSection::FpABIKind Value) {
  forbidModuleDirective();
}
void MipsTargetStreamer::emitDirectiveSetOddSPReg() { forbidModuleDirective(); }
void MipsTargetStreamer::emitDirectiveSetNoOddSPReg() {
  forbidModuleDirective();
}

void MipsTargetStreamer::emitR(unsigned Opcode, unsigned Reg0, SMLoc IDLoc,
                               const MCSubtargetInfo *STI) {
  MCInst TmpInst;
  TmpInst.setOpcode(Opcode);
  TmpInst.addOperand(MCOperand::createReg(Reg0));
  TmpInst.setLoc(IDLoc);
  getStreamer().emitInstruction(TmpInst, *STI);
}

void MipsTargetStreamer::emitRX(unsigned Opcode, unsigned Reg0, MCOperand Op1,
                                SMLoc IDLoc, const MCSubtargetInfo *STI) {
  MCInst TmpInst;
  TmpInst.setOpcode(Opcode);
  TmpInst.addOperand(MCOperand::createReg(Reg0));
  TmpInst.addOperand(Op1);
  TmpInst.setLoc(IDLoc);
  getStreamer().emitInstruction(TmpInst, *STI);
}

void MipsTargetStreamer::emitRI(unsigned Opcode, unsigned Reg0, int32_t Imm,
                                SMLoc IDLoc, const MCSubtargetInfo *STI) {
  emitRX(Opcode, Reg0, MCOperand::createImm(Imm), IDLoc, STI);
}

void MipsTargetStreamer::emitRR(unsigned Opcode, unsigned Reg0, unsigned Reg1,
                                SMLoc IDLoc, const MCSubtargetInfo *STI) {
  emitRX(Opcode, Reg0, MCOperand::createReg(Reg1), IDLoc, STI);
}

void MipsTargetStreamer::emitII(unsigned Opcode, int16_t Imm1, int16_t Imm2,
                                SMLoc IDLoc, const MCSubtargetInfo *STI) {
  MCInst TmpInst;
  TmpInst.setOpcode(Opcode);
  TmpInst.addOperand(MCOperand::createImm(Imm1));
  TmpInst.addOperand(MCOperand::createImm(Imm2));
  TmpInst.setLoc(IDLoc);
  getStreamer().emitInstruction(TmpInst, *STI);
}

void MipsTargetStreamer::emitRRX(unsigned Opcode, unsigned Reg0, unsigned Reg1,
                                 MCOperand Op2, SMLoc IDLoc,
                                 const MCSubtargetInfo *STI) {
  MCInst TmpInst;
  TmpInst.setOpcode(Opcode);
  TmpInst.addOperand(MCOperand::createReg(Reg0));
  TmpInst.addOperand(MCOperand::createReg(Reg1));
  TmpInst.addOperand(Op2);
  TmpInst.setLoc(IDLoc);
  getStreamer().emitInstruction(TmpInst, *STI);
}

void MipsTargetStreamer::emitRRR(unsigned Opcode, unsigned Reg0, unsigned Reg1,
                                 unsigned Reg2, SMLoc IDLoc,
                                 const MCSubtargetInfo *STI) {
  emitRRX(Opcode, Reg0, Reg1, MCOperand::createReg(Reg2), IDLoc, STI);
}

void MipsTargetStreamer::emitRRRX(unsigned Opcode, unsigned Reg0, unsigned Reg1,
                                  unsigned Reg2, MCOperand Op3, SMLoc IDLoc,
                                  const MCSubtargetInfo *STI) {
  MCInst TmpInst;
  TmpInst.setOpcode(Opcode);
  TmpInst.addOperand(MCOperand::createReg(Reg0));
  TmpInst.addOperand(MCOperand::createReg(Reg1));
  TmpInst.addOperand(MCOperand::createReg(Reg2));
  TmpInst.addOperand(Op3);
  TmpInst.setLoc(IDLoc);
  getStreamer().emitInstruction(TmpInst, *STI);
}

void MipsTargetStreamer::emitRRI(unsigned Opcode, unsigned Reg0, unsigned Reg1,
                                 int16_t Imm, SMLoc IDLoc,
                                 const MCSubtargetInfo *STI) {
  emitRRX(Opcode, Reg0, Reg1, MCOperand::createImm(Imm), IDLoc, STI);
}

void MipsTargetStreamer::emitRRIII(unsigned Opcode, unsigned Reg0,
                                   unsigned Reg1, int16_t Imm0, int16_t Imm1,
                                   int16_t Imm2, SMLoc IDLoc,
                                   const MCSubtargetInfo *STI) {
  MCInst TmpInst;
  TmpInst.setOpcode(Opcode);
  TmpInst.addOperand(MCOperand::createReg(Reg0));
  TmpInst.addOperand(MCOperand::createReg(Reg1));
  TmpInst.addOperand(MCOperand::createImm(Imm0));
  TmpInst.addOperand(MCOperand::createImm(Imm1));
  TmpInst.addOperand(MCOperand::createImm(Imm2));
  TmpInst.setLoc(IDLoc);
  getStreamer().emitInstruction(TmpInst, *STI);
}

void MipsTargetStreamer::emitAddu(unsigned DstReg, unsigned SrcReg,
                                  unsigned TrgReg, bool Is64Bit,
                                  const MCSubtargetInfo *STI) {
  emitRRR(Is64Bit ? Mips::DADDu : Mips::ADDu, DstReg, SrcReg, TrgReg, SMLoc(),
          STI);
}

void MipsTargetStreamer::emitDSLL(unsigned DstReg, unsigned SrcReg,
                                  int16_t ShiftAmount, SMLoc IDLoc,
                                  const MCSubtargetInfo *STI) {
  if (ShiftAmount >= 32) {
    emitRRI(Mips::DSLL32, DstReg, SrcReg, ShiftAmount - 32, IDLoc, STI);
    return;
  }

  emitRRI(Mips::DSLL, DstReg, SrcReg, ShiftAmount, IDLoc, STI);
}

void MipsTargetStreamer::emitEmptyDelaySlot(bool hasShortDelaySlot, SMLoc IDLoc,
                                            const MCSubtargetInfo *STI) {
  if (hasShortDelaySlot)
    emitRR(Mips::MOVE16_MM, Mips::ZERO, Mips::ZERO, IDLoc, STI);
  else
    emitRRI(Mips::SLL, Mips::ZERO, Mips::ZERO, 0, IDLoc, STI);
}

void MipsTargetStreamer::emitNop(SMLoc IDLoc, const MCSubtargetInfo *STI) {
  if (isMicroMips(STI))
    emitRR(Mips::MOVE16_MM, Mips::ZERO, Mips::ZERO, IDLoc, STI);
  else
    emitRRI(Mips::SLL, Mips::ZERO, Mips::ZERO, 0, IDLoc, STI);
}

/// Emit the $gp restore operation for .cprestore.
void MipsTargetStreamer::emitGPRestore(int Offset, SMLoc IDLoc,
                                       const MCSubtargetInfo *STI) {
  emitLoadWithImmOffset(Mips::LW, GPReg, Mips::SP, Offset, GPReg, IDLoc, STI);
}

/// Emit a store instruction with an immediate offset.
void MipsTargetStreamer::emitStoreWithImmOffset(
    unsigned Opcode, unsigned SrcReg, unsigned BaseReg, int64_t Offset,
    function_ref<unsigned()> GetATReg, SMLoc IDLoc,
    const MCSubtargetInfo *STI) {
  if (isInt<16>(Offset)) {
    emitRRI(Opcode, SrcReg, BaseReg, Offset, IDLoc, STI);
    return;
  }

  // sw $8, offset($8) => lui $at, %hi(offset)
  //                      add $at, $at, $8
  //                      sw $8, %lo(offset)($at)

  unsigned ATReg = GetATReg();
  if (!ATReg)
    return;

  unsigned LoOffset = Offset & 0x0000ffff;
  unsigned HiOffset = (Offset & 0xffff0000) >> 16;

  // If msb of LoOffset is 1(negative number) we must increment HiOffset
  // to account for the sign-extension of the low part.
  if (LoOffset & 0x8000)
    HiOffset++;

  // Generate the base address in ATReg.
  emitRI(Mips::LUi, ATReg, HiOffset, IDLoc, STI);
  if (BaseReg != Mips::ZERO)
    emitRRR(Mips::ADDu, ATReg, ATReg, BaseReg, IDLoc, STI);
  // Emit the store with the adjusted base and offset.
  emitRRI(Opcode, SrcReg, ATReg, LoOffset, IDLoc, STI);
}

/// Emit a load instruction with an immediate offset. DstReg and TmpReg are
/// permitted to be the same register iff DstReg is distinct from BaseReg and
/// DstReg is a GPR. It is the callers responsibility to identify such cases
/// and pass the appropriate register in TmpReg.
void MipsTargetStreamer::emitLoadWithImmOffset(unsigned Opcode, unsigned DstReg,
                                               unsigned BaseReg, int64_t Offset,
                                               unsigned TmpReg, SMLoc IDLoc,
                                               const MCSubtargetInfo *STI) {
  if (isInt<16>(Offset)) {
    emitRRI(Opcode, DstReg, BaseReg, Offset, IDLoc, STI);
    return;
  }

  // 1) lw $8, offset($9) => lui $8, %hi(offset)
  //                         add $8, $8, $9
  //                         lw $8, %lo(offset)($9)
  // 2) lw $8, offset($8) => lui $at, %hi(offset)
  //                         add $at, $at, $8
  //                         lw $8, %lo(offset)($at)

  unsigned LoOffset = Offset & 0x0000ffff;
  unsigned HiOffset = (Offset & 0xffff0000) >> 16;

  // If msb of LoOffset is 1(negative number) we must increment HiOffset
  // to account for the sign-extension of the low part.
  if (LoOffset & 0x8000)
    HiOffset++;

  // Generate the base address in TmpReg.
  emitRI(Mips::LUi, TmpReg, HiOffset, IDLoc, STI);
  if (BaseReg != Mips::ZERO)
    emitRRR(Mips::ADDu, TmpReg, TmpReg, BaseReg, IDLoc, STI);
  // Emit the load with the adjusted base and offset.
  emitRRI(Opcode, DstReg, TmpReg, LoOffset, IDLoc, STI);
}

MipsTargetAsmStreamer::MipsTargetAsmStreamer(
    MCStreamer &S, llvm::Optional<unsigned> CheriCapSize,
    formatted_raw_ostream &OS)
    : MipsTargetStreamer(S, CheriCapSize), OS(OS) {}

void MipsTargetAsmStreamer::emitDirectiveSetMicroMips() {
  OS << "\t.set\tmicromips\n";
  forbidModuleDirective();
}

void MipsTargetAsmStreamer::emitDirectiveSetNoMicroMips() {
  OS << "\t.set\tnomicromips\n";
  forbidModuleDirective();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips16() {
  OS << "\t.set\tmips16\n";
  forbidModuleDirective();
}

void MipsTargetAsmStreamer::emitDirectiveSetNoMips16() {
  OS << "\t.set\tnomips16\n";
  MipsTargetStreamer::emitDirectiveSetNoMips16();
}

void MipsTargetAsmStreamer::emitDirectiveSetReorder() {
  OS << "\t.set\treorder\n";
  MipsTargetStreamer::emitDirectiveSetReorder();
}

void MipsTargetAsmStreamer::emitDirectiveSetNoReorder() {
  OS << "\t.set\tnoreorder\n";
  forbidModuleDirective();
}

void MipsTargetAsmStreamer::emitDirectiveSetMacro() {
  OS << "\t.set\tmacro\n";
  MipsTargetStreamer::emitDirectiveSetMacro();
}

void MipsTargetAsmStreamer::emitDirectiveSetNoMacro() {
  OS << "\t.set\tnomacro\n";
  MipsTargetStreamer::emitDirectiveSetNoMacro();
}

void MipsTargetAsmStreamer::emitDirectiveSetMsa() {
  OS << "\t.set\tmsa\n";
  MipsTargetStreamer::emitDirectiveSetMsa();
}

void MipsTargetAsmStreamer::emitDirectiveSetNoMsa() {
  OS << "\t.set\tnomsa\n";
  MipsTargetStreamer::emitDirectiveSetNoMsa();
}

void MipsTargetAsmStreamer::emitDirectiveSetMt() {
  OS << "\t.set\tmt\n";
  MipsTargetStreamer::emitDirectiveSetMt();
}

void MipsTargetAsmStreamer::emitDirectiveSetNoMt() {
  OS << "\t.set\tnomt\n";
  MipsTargetStreamer::emitDirectiveSetNoMt();
}

void MipsTargetAsmStreamer::emitDirectiveSetCRC() {
  OS << "\t.set\tcrc\n";
  MipsTargetStreamer::emitDirectiveSetCRC();
}

void MipsTargetAsmStreamer::emitDirectiveSetNoCRC() {
  OS << "\t.set\tnocrc\n";
  MipsTargetStreamer::emitDirectiveSetNoCRC();
}

void MipsTargetAsmStreamer::emitDirectiveSetVirt() {
  OS << "\t.set\tvirt\n";
  MipsTargetStreamer::emitDirectiveSetVirt();
}

void MipsTargetAsmStreamer::emitDirectiveSetNoVirt() {
  OS << "\t.set\tnovirt\n";
  MipsTargetStreamer::emitDirectiveSetNoVirt();
}

void MipsTargetAsmStreamer::emitDirectiveSetGINV() {
  OS << "\t.set\tginv\n";
  MipsTargetStreamer::emitDirectiveSetGINV();
}

void MipsTargetAsmStreamer::emitDirectiveSetNoGINV() {
  OS << "\t.set\tnoginv\n";
  MipsTargetStreamer::emitDirectiveSetNoGINV();
}

void MipsTargetAsmStreamer::emitDirectiveSetAt() {
  OS << "\t.set\tat\n";
  MipsTargetStreamer::emitDirectiveSetAt();
}

void MipsTargetAsmStreamer::emitDirectiveSetAtWithArg(unsigned RegNo) {
  OS << "\t.set\tat=$" << Twine(RegNo) << "\n";
  MipsTargetStreamer::emitDirectiveSetAtWithArg(RegNo);
}

void MipsTargetAsmStreamer::emitDirectiveSetNoAt() {
  OS << "\t.set\tnoat\n";
  MipsTargetStreamer::emitDirectiveSetNoAt();
}

void MipsTargetAsmStreamer::emitDirectiveEnd(StringRef Name) {
  OS << "\t.end\t" << Name << '\n';
}

void MipsTargetAsmStreamer::emitDirectiveEnt(const MCSymbol &Symbol) {
  OS << "\t.ent\t" << Symbol.getName() << '\n';
}

void MipsTargetAsmStreamer::emitDirectiveAbiCalls() { OS << "\t.abicalls\n"; }

void MipsTargetAsmStreamer::emitDirectiveNaN2008() { OS << "\t.nan\t2008\n"; }

void MipsTargetAsmStreamer::emitDirectiveNaNLegacy() {
  OS << "\t.nan\tlegacy\n";
}

void MipsTargetAsmStreamer::emitDirectiveOptionPic0() {
  OS << "\t.option\tpic0\n";
}

void MipsTargetAsmStreamer::emitDirectiveOptionPic2() {
  OS << "\t.option\tpic2\n";
}

void MipsTargetAsmStreamer::emitDirectiveInsn() {
  MipsTargetStreamer::emitDirectiveInsn();
  OS << "\t.insn\n";
}

void MipsTargetAsmStreamer::emitFrame(unsigned StackReg, unsigned StackSize,
                                      unsigned ReturnReg) {
  OS << "\t.frame\t$"
     << StringRef(MipsInstPrinter::getRegisterName(StackReg)).lower() << ","
     << StackSize << ",$"
     << StringRef(MipsInstPrinter::getRegisterName(ReturnReg)).lower() << '\n';
}

void MipsTargetAsmStreamer::emitDirectiveSetArch(StringRef Arch) {
  OS << "\t.set arch=" << Arch << "\n";
  MipsTargetStreamer::emitDirectiveSetArch(Arch);
}

void MipsTargetAsmStreamer::emitDirectiveSetMips0() {
  OS << "\t.set\tmips0\n";
  MipsTargetStreamer::emitDirectiveSetMips0();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips1() {
  OS << "\t.set\tmips1\n";
  MipsTargetStreamer::emitDirectiveSetMips1();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips2() {
  OS << "\t.set\tmips2\n";
  MipsTargetStreamer::emitDirectiveSetMips2();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips3() {
  OS << "\t.set\tmips3\n";
  MipsTargetStreamer::emitDirectiveSetMips3();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips4() {
  OS << "\t.set\tmips4\n";
  MipsTargetStreamer::emitDirectiveSetMips4();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips5() {
  OS << "\t.set\tmips5\n";
  MipsTargetStreamer::emitDirectiveSetMips5();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips32() {
  OS << "\t.set\tmips32\n";
  MipsTargetStreamer::emitDirectiveSetMips32();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips32R2() {
  OS << "\t.set\tmips32r2\n";
  MipsTargetStreamer::emitDirectiveSetMips32R2();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips32R3() {
  OS << "\t.set\tmips32r3\n";
  MipsTargetStreamer::emitDirectiveSetMips32R3();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips32R5() {
  OS << "\t.set\tmips32r5\n";
  MipsTargetStreamer::emitDirectiveSetMips32R5();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips32R6() {
  OS << "\t.set\tmips32r6\n";
  MipsTargetStreamer::emitDirectiveSetMips32R6();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips64() {
  OS << "\t.set\tmips64\n";
  MipsTargetStreamer::emitDirectiveSetMips64();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips64R2() {
  OS << "\t.set\tmips64r2\n";
  MipsTargetStreamer::emitDirectiveSetMips64R2();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips64R3() {
  OS << "\t.set\tmips64r3\n";
  MipsTargetStreamer::emitDirectiveSetMips64R3();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips64R5() {
  OS << "\t.set\tmips64r5\n";
  MipsTargetStreamer::emitDirectiveSetMips64R5();
}

void MipsTargetAsmStreamer::emitDirectiveSetMips64R6() {
  OS << "\t.set\tmips64r6\n";
  MipsTargetStreamer::emitDirectiveSetMips64R6();
}

void MipsTargetAsmStreamer::emitDirectiveSetDsp() {
  OS << "\t.set\tdsp\n";
  MipsTargetStreamer::emitDirectiveSetDsp();
}

void MipsTargetAsmStreamer::emitDirectiveSetDspr2() {
  OS << "\t.set\tdspr2\n";
  MipsTargetStreamer::emitDirectiveSetDspr2();
}

void MipsTargetAsmStreamer::emitDirectiveSetNoDsp() {
  OS << "\t.set\tnodsp\n";
  MipsTargetStreamer::emitDirectiveSetNoDsp();
}

void MipsTargetAsmStreamer::emitDirectiveSetPop() {
  OS << "\t.set\tpop\n";
  MipsTargetStreamer::emitDirectiveSetPop();
}

void MipsTargetAsmStreamer::emitDirectiveSetPush() {
 OS << "\t.set\tpush\n";
 MipsTargetStreamer::emitDirectiveSetPush();
}

void MipsTargetAsmStreamer::emitDirectiveSetSoftFloat() {
  OS << "\t.set\tsoftfloat\n";
  MipsTargetStreamer::emitDirectiveSetSoftFloat();
}

void MipsTargetAsmStreamer::emitDirectiveSetHardFloat() {
  OS << "\t.set\thardfloat\n";
  MipsTargetStreamer::emitDirectiveSetHardFloat();
}

// Print a 32 bit hex number with all numbers.
static void printHex32(unsigned Value, raw_ostream &OS) {
  OS << "0x";
  for (int i = 7; i >= 0; i--)
    OS.write_hex((Value & (0xF << (i * 4))) >> (i * 4));
}

void MipsTargetAsmStreamer::emitMask(unsigned CPUBitmask,
                                     int CPUTopSavedRegOff) {
  OS << "\t.mask \t";
  printHex32(CPUBitmask, OS);
  OS << ',' << CPUTopSavedRegOff << '\n';
}

void MipsTargetAsmStreamer::emitFMask(unsigned FPUBitmask,
                                      int FPUTopSavedRegOff) {
  OS << "\t.fmask\t";
  printHex32(FPUBitmask, OS);
  OS << "," << FPUTopSavedRegOff << '\n';
}

void MipsTargetAsmStreamer::emitDirectiveCpLoad(unsigned RegNo) {
  OS << "\t.cpload\t$"
     << StringRef(MipsInstPrinter::getRegisterName(RegNo)).lower() << "\n";
  forbidModuleDirective();
}

void MipsTargetAsmStreamer::emitDirectiveCpLocal(unsigned RegNo) {
  OS << "\t.cplocal\t$"
     << StringRef(MipsInstPrinter::getRegisterName(RegNo)).lower() << "\n";
  MipsTargetStreamer::emitDirectiveCpLocal(RegNo);
}

bool MipsTargetAsmStreamer::emitDirectiveCpRestore(
    int Offset, function_ref<unsigned()> GetATReg, SMLoc IDLoc,
    const MCSubtargetInfo *STI) {
  MipsTargetStreamer::emitDirectiveCpRestore(Offset, GetATReg, IDLoc, STI);
  OS << "\t.cprestore\t" << Offset << "\n";
  return true;
}

void MipsTargetAsmStreamer::emitDirectiveCpsetup(unsigned RegNo,
                                                 int RegOrOffset,
                                                 const MCSymbol &Sym,
                                                 bool IsReg) {
  OS << "\t.cpsetup\t$"
     << StringRef(MipsInstPrinter::getRegisterName(RegNo)).lower() << ", ";

  if (IsReg)
    OS << "$"
       << StringRef(MipsInstPrinter::getRegisterName(RegOrOffset)).lower();
  else
    OS << RegOrOffset;

  OS << ", ";

  OS << Sym.getName();
  forbidModuleDirective();
}

void MipsTargetAsmStreamer::emitDirectiveCpreturn(unsigned SaveLocation,
                                                  bool SaveLocationIsRegister) {
  OS << "\t.cpreturn";
  forbidModuleDirective();
}

void MipsTargetAsmStreamer::emitDirectiveModuleFP() {
  MipsABIFlagsSection::FpABIKind FpABI = ABIFlagsSection.getFpABI();
  if (FpABI == MipsABIFlagsSection::FpABIKind::SOFT)
    OS << "\t.module\tsoftfloat\n";
  else
    OS << "\t.module\tfp=" << ABIFlagsSection.getFpABIString(FpABI) << "\n";
}

void MipsTargetAsmStreamer::emitDirectiveSetFp(
    MipsABIFlagsSection::FpABIKind Value) {
  MipsTargetStreamer::emitDirectiveSetFp(Value);

  OS << "\t.set\tfp=";
  OS << ABIFlagsSection.getFpABIString(Value) << "\n";
}

void MipsTargetAsmStreamer::emitDirectiveModuleOddSPReg() {
  MipsTargetStreamer::emitDirectiveModuleOddSPReg();

  OS << "\t.module\t" << (ABIFlagsSection.OddSPReg ? "" : "no") << "oddspreg\n";
}

void MipsTargetAsmStreamer::emitDirectiveSetOddSPReg() {
  MipsTargetStreamer::emitDirectiveSetOddSPReg();
  OS << "\t.set\toddspreg\n";
}

void MipsTargetAsmStreamer::emitDirectiveSetNoOddSPReg() {
  MipsTargetStreamer::emitDirectiveSetNoOddSPReg();
  OS << "\t.set\tnooddspreg\n";
}

void MipsTargetAsmStreamer::emitDirectiveModuleSoftFloat() {
  OS << "\t.module\tsoftfloat\n";
}

void MipsTargetAsmStreamer::emitDirectiveModuleHardFloat() {
  OS << "\t.module\thardfloat\n";
}

void MipsTargetAsmStreamer::emitDirectiveModuleMT() {
  OS << "\t.module\tmt\n";
}

void MipsTargetAsmStreamer::emitDirectiveModuleCRC() {
  OS << "\t.module\tcrc\n";
}

void MipsTargetAsmStreamer::emitDirectiveModuleNoCRC() {
  OS << "\t.module\tnocrc\n";
}

void MipsTargetAsmStreamer::emitDirectiveModuleVirt() {
  OS << "\t.module\tvirt\n";
}

void MipsTargetAsmStreamer::emitDirectiveModuleNoVirt() {
  OS << "\t.module\tnovirt\n";
}

void MipsTargetAsmStreamer::emitDirectiveModuleGINV() {
  OS << "\t.module\tginv\n";
}

void MipsTargetAsmStreamer::emitDirectiveModuleNoGINV() {
  OS << "\t.module\tnoginv\n";
}

// This part is for ELF object output.
MipsTargetELFStreamer::MipsTargetELFStreamer(MCStreamer &S,
                                             const MCSubtargetInfo &STI)
    : MipsTargetStreamer(S, getCheriCapabilitySize(STI.getFeatureBits())),
      MicroMipsEnabled(false), STI(STI) {
  MCAssembler &MCA = getStreamer().getAssembler();

  // It's possible that MCObjectFileInfo isn't fully initialized at this point
  // due to an initialization order problem where LLVMTargetMachine creates the
  // target streamer before TargetLoweringObjectFile calls
  // InitializeMCObjectFileInfo. There doesn't seem to be a single place that
  // covers all cases so this statement covers most cases and direct object
  // emission must call setPic() once MCObjectFileInfo has been initialized. The
  // cases we don't handle here are covered by MipsAsmPrinter.
  Pic = MCA.getContext().getObjectFileInfo()->isPositionIndependent();

  const FeatureBitset &Features = STI.getFeatureBits();

  // Set the header flags that we can in the constructor.
  // FIXME: This is a fairly terrible hack. We set the rest
  // of these in the destructor. The problem here is two-fold:
  //
  // a: Some of the eflags can be set/reset by directives.
  // b: There aren't any usage paths that initialize the ABI
  //    pointer until after we initialize either an assembler
  //    or the target machine.
  // We can fix this by making the target streamer construct
  // the ABI, but this is fraught with wide ranging dependency
  // issues as well.
  unsigned EFlags = MCA.getELFHeaderEFlags();

  // FIXME: Fix a dependency issue by instantiating the ABI object to some
  // default based off the triple. The triple doesn't describe the target
  // fully, but any external user of the API that uses the MCTargetStreamer
  // would otherwise crash on assertion failure.

  ABI = MipsABIInfo(
      STI.getTargetTriple().getArch() == Triple::ArchType::mipsel ||
              STI.getTargetTriple().getArch() == Triple::ArchType::mips
          ? MipsABIInfo::O32()
          : MipsABIInfo::N64());

  // Architecture
  if (Features[Mips::FeatureMips64r6])
    EFlags |= ELF::EF_MIPS_ARCH_64R6;
  else if (Features[Mips::FeatureMips64r2] ||
           Features[Mips::FeatureMips64r3] ||
           Features[Mips::FeatureMips64r5])
    EFlags |= ELF::EF_MIPS_ARCH_64R2;
  else if (Features[Mips::FeatureMips64])
    EFlags |= ELF::EF_MIPS_ARCH_64;
  else if (Features[Mips::FeatureMips5])
    EFlags |= ELF::EF_MIPS_ARCH_5;
  else if (Features[Mips::FeatureMips4])
    EFlags |= ELF::EF_MIPS_ARCH_4;
  else if (Features[Mips::FeatureMips3])
    EFlags |= ELF::EF_MIPS_ARCH_3;
  else if (Features[Mips::FeatureMips32r6])
    EFlags |= ELF::EF_MIPS_ARCH_32R6;
  else if (Features[Mips::FeatureMips32r2] ||
           Features[Mips::FeatureMips32r3] ||
           Features[Mips::FeatureMips32r5])
    EFlags |= ELF::EF_MIPS_ARCH_32R2;
  else if (Features[Mips::FeatureMips32])
    EFlags |= ELF::EF_MIPS_ARCH_32;
  else if (Features[Mips::FeatureMips2])
    EFlags |= ELF::EF_MIPS_ARCH_2;
  else
    EFlags |= ELF::EF_MIPS_ARCH_1;

  // Machine
  if (Features[Mips::FeatureCnMips])
    EFlags |= ELF::EF_MIPS_MACH_OCTEON;
  else if (Features[Mips::FeatureMipsCheri128])
    EFlags |= ELF::EF_MIPS_MACH_CHERI128;
  else if (Features[Mips::FeatureMipsCheri])
    EFlags |= ELF::EF_MIPS_MACH_CHERI256;
  else if (Features[Mips::FeatureMipsBeri])
    EFlags |= ELF::EF_MIPS_MACH_BERI;

  // Other options.
  if (Features[Mips::FeatureNaN2008])
    EFlags |= ELF::EF_MIPS_NAN2008;

  MCA.setELFHeaderEFlags(EFlags);
}

void MipsTargetELFStreamer::emitLabel(MCSymbol *S) {
  auto *Symbol = cast<MCSymbolELF>(S);
  getStreamer().getAssembler().registerSymbol(*Symbol);
  uint8_t Type = Symbol->getType();
  if (Type != ELF::STT_FUNC)
    return;

  if (isMicroMipsEnabled())
    Symbol->setOther(ELF::STO_MIPS_MICROMIPS);
}

void MipsTargetELFStreamer::finish() {
  MCAssembler &MCA = getStreamer().getAssembler();
  const MCObjectFileInfo &OFI = *MCA.getContext().getObjectFileInfo();

  // .bss, .text and .data are always at least 16-byte aligned.
  MCSection &TextSection = *OFI.getTextSection();
  MCA.registerSection(TextSection);
  MCSection &DataSection = *OFI.getDataSection();
  MCA.registerSection(DataSection);
  MCSection &BSSSection = *OFI.getBSSSection();
  MCA.registerSection(BSSSection);

  TextSection.setAlignment(Align(std::max(16u, TextSection.getAlignment())));
  DataSection.setAlignment(Align(std::max(16u, DataSection.getAlignment())));
  BSSSection.setAlignment(Align(std::max(16u, BSSSection.getAlignment())));

  if (RoundSectionSizes) {
    // Make sections sizes a multiple of the alignment. This is useful for
    // verifying the output of IAS against the output of other assemblers but
    // it's not necessary to produce a correct object and increases section
    // size.
    MCStreamer &OS = getStreamer();
    for (MCSection &S : MCA) {
      MCSectionELF &Section = static_cast<MCSectionELF &>(S);

      unsigned Alignment = Section.getAlignment();
      if (Alignment) {
        OS.SwitchSection(&Section);
        if (Section.UseCodeAlign())
          OS.EmitCodeAlignment(Alignment, Alignment);
        else
          OS.EmitValueToAlignment(Alignment, 0, 1, Alignment);
      }
    }
  }

  const FeatureBitset &Features = STI.getFeatureBits();

  // Update e_header flags. See the FIXME and comment above in
  // the constructor for a full rundown on this.
  unsigned EFlags = MCA.getELFHeaderEFlags();

  // ABI
  // N64 does not require any ABI bits.
  if (getABI().IsO32())
    EFlags |= ELF::EF_MIPS_ABI_O32;
  else if (getABI().IsN32())
    EFlags |= ELF::EF_MIPS_ABI2;

  if (Features[Mips::FeatureGP64Bit]) {
    if (getABI().IsO32())
      EFlags |= ELF::EF_MIPS_32BITMODE; /* Compatibility Mode */
  } else if (Features[Mips::FeatureMips64r2] || Features[Mips::FeatureMips64])
    EFlags |= ELF::EF_MIPS_32BITMODE;

  // -mplt is not implemented but we should act as if it was
  // given.
  if (!Features[Mips::FeatureNoABICalls])
    EFlags |= ELF::EF_MIPS_CPIC;

  if (Pic)
    EFlags |= ELF::EF_MIPS_PIC | ELF::EF_MIPS_CPIC;

  if (getABI().IsCheriPureCap())
    EFlags |= ELF::EF_MIPS_ABI_CHERIABI;

  MCA.setELFHeaderEFlags(EFlags);

  // Emit all the option records.
  // At the moment we are only emitting .Mips.options (ODK_REGINFO) and
  // .reginfo.
  MipsELFStreamer &MEF = static_cast<MipsELFStreamer &>(Streamer);
  MEF.EmitMipsOptionRecords();

  emitMipsAbiFlags();
}

void MipsTargetELFStreamer::emitAssignment(MCSymbol *S, const MCExpr *Value) {
  auto *Symbol = cast<MCSymbolELF>(S);
  // If on rhs is micromips symbol then mark Symbol as microMips.
  if (Value->getKind() != MCExpr::SymbolRef)
    return;
  const auto &RhsSym = cast<MCSymbolELF>(
      static_cast<const MCSymbolRefExpr *>(Value)->getSymbol());

  if (!(RhsSym.getOther() & ELF::STO_MIPS_MICROMIPS))
    return;

  Symbol->setOther(ELF::STO_MIPS_MICROMIPS);
}

MCELFStreamer &MipsTargetELFStreamer::getStreamer() {
  return static_cast<MCELFStreamer &>(Streamer);
}

void MipsTargetELFStreamer::emitDirectiveSetMicroMips() {
  MicroMipsEnabled = true;
  forbidModuleDirective();
}

void MipsTargetELFStreamer::emitDirectiveSetNoMicroMips() {
  MicroMipsEnabled = false;
  forbidModuleDirective();
}

void MipsTargetELFStreamer::setUsesMicroMips() {
  MCAssembler &MCA = getStreamer().getAssembler();
  unsigned Flags = MCA.getELFHeaderEFlags();
  Flags |= ELF::EF_MIPS_MICROMIPS;
  MCA.setELFHeaderEFlags(Flags);
}

void MipsTargetELFStreamer::emitDirectiveSetMips16() {
  MCAssembler &MCA = getStreamer().getAssembler();
  unsigned Flags = MCA.getELFHeaderEFlags();
  Flags |= ELF::EF_MIPS_ARCH_ASE_M16;
  MCA.setELFHeaderEFlags(Flags);
  forbidModuleDirective();
}

void MipsTargetELFStreamer::emitDirectiveSetNoReorder() {
  MCAssembler &MCA = getStreamer().getAssembler();
  unsigned Flags = MCA.getELFHeaderEFlags();
  Flags |= ELF::EF_MIPS_NOREORDER;
  MCA.setELFHeaderEFlags(Flags);
  forbidModuleDirective();
}

void MipsTargetELFStreamer::emitDirectiveEnd(StringRef Name) {
  MCAssembler &MCA = getStreamer().getAssembler();
  MCContext &Context = MCA.getContext();
  MCStreamer &OS = getStreamer();

  MCSectionELF *Sec = Context.getELFSection(".pdr", ELF::SHT_PROGBITS, 0);

  MCSymbol *Sym = Context.getOrCreateSymbol(Name);
  const MCSymbolRefExpr *ExprRef =
      MCSymbolRefExpr::create(Sym, MCSymbolRefExpr::VK_None, Context);

  MCA.registerSection(*Sec);
  Sec->setAlignment(Align(4));

  OS.PushSection();

  OS.SwitchSection(Sec);

  OS.EmitValueImpl(ExprRef, 4);

  OS.EmitIntValue(GPRInfoSet ? GPRBitMask : 0, 4); // reg_mask
  OS.EmitIntValue(GPRInfoSet ? GPROffset : 0, 4);  // reg_offset

  OS.EmitIntValue(FPRInfoSet ? FPRBitMask : 0, 4); // fpreg_mask
  OS.EmitIntValue(FPRInfoSet ? FPROffset : 0, 4);  // fpreg_offset

  OS.EmitIntValue(FrameInfoSet ? FrameOffset : 0, 4); // frame_offset
  OS.EmitIntValue(FrameInfoSet ? FrameReg : 0, 4);    // frame_reg
  OS.EmitIntValue(FrameInfoSet ? ReturnReg : 0, 4);   // return_reg

  // The .end directive marks the end of a procedure. Invalidate
  // the information gathered up until this point.
  GPRInfoSet = FPRInfoSet = FrameInfoSet = false;

  OS.PopSection();

  // .end also implicitly sets the size.
  MCSymbol *CurPCSym = Context.createTempSymbol();
  OS.EmitLabel(CurPCSym);
  const MCExpr *Size = MCBinaryExpr::createSub(
      MCSymbolRefExpr::create(CurPCSym, MCSymbolRefExpr::VK_None, Context),
      ExprRef, Context);

  // The ELFObjectWriter can determine the absolute size as it has access to
  // the layout information of the assembly file, so a size expression rather
  // than an absolute value is ok here.
  static_cast<MCSymbolELF *>(Sym)->setSize(Size);
}

void MipsTargetELFStreamer::emitDirectiveEnt(const MCSymbol &Symbol) {
  GPRInfoSet = FPRInfoSet = FrameInfoSet = false;

  // .ent also acts like an implicit '.type symbol, STT_FUNC'
  static_cast<const MCSymbolELF &>(Symbol).setType(ELF::STT_FUNC);
}

void MipsTargetELFStreamer::emitDirectiveAbiCalls() {
  MCAssembler &MCA = getStreamer().getAssembler();
  unsigned Flags = MCA.getELFHeaderEFlags();
  Flags |= ELF::EF_MIPS_CPIC | ELF::EF_MIPS_PIC;
  MCA.setELFHeaderEFlags(Flags);
}

void MipsTargetELFStreamer::emitDirectiveNaN2008() {
  MCAssembler &MCA = getStreamer().getAssembler();
  unsigned Flags = MCA.getELFHeaderEFlags();
  Flags |= ELF::EF_MIPS_NAN2008;
  MCA.setELFHeaderEFlags(Flags);
}

void MipsTargetELFStreamer::emitDirectiveNaNLegacy() {
  MCAssembler &MCA = getStreamer().getAssembler();
  unsigned Flags = MCA.getELFHeaderEFlags();
  Flags &= ~ELF::EF_MIPS_NAN2008;
  MCA.setELFHeaderEFlags(Flags);
}

void MipsTargetELFStreamer::emitDirectiveOptionPic0() {
  MCAssembler &MCA = getStreamer().getAssembler();
  unsigned Flags = MCA.getELFHeaderEFlags();
  // This option overrides other PIC options like -KPIC.
  Pic = false;
  Flags &= ~ELF::EF_MIPS_PIC;
  MCA.setELFHeaderEFlags(Flags);
}

void MipsTargetELFStreamer::emitDirectiveOptionPic2() {
  MCAssembler &MCA = getStreamer().getAssembler();
  unsigned Flags = MCA.getELFHeaderEFlags();
  Pic = true;
  // NOTE: We are following the GAS behaviour here which means the directive
  // 'pic2' also sets the CPIC bit in the ELF header. This is different from
  // what is stated in the SYSV ABI which consider the bits EF_MIPS_PIC and
  // EF_MIPS_CPIC to be mutually exclusive.
  Flags |= ELF::EF_MIPS_PIC | ELF::EF_MIPS_CPIC;
  MCA.setELFHeaderEFlags(Flags);
}

void MipsTargetELFStreamer::emitDirectiveInsn() {
  MipsTargetStreamer::emitDirectiveInsn();
  MipsELFStreamer &MEF = static_cast<MipsELFStreamer &>(Streamer);
  MEF.createPendingLabelRelocs();
}

void MipsTargetELFStreamer::emitFrame(unsigned StackReg, unsigned StackSize,
                                      unsigned ReturnReg_) {
  MCContext &Context = getStreamer().getAssembler().getContext();
  const MCRegisterInfo *RegInfo = Context.getRegisterInfo();

  FrameInfoSet = true;
  FrameReg = RegInfo->getEncodingValue(StackReg);
  FrameOffset = StackSize;
  ReturnReg = RegInfo->getEncodingValue(ReturnReg_);
}

void MipsTargetELFStreamer::emitMask(unsigned CPUBitmask,
                                     int CPUTopSavedRegOff) {
  GPRInfoSet = true;
  GPRBitMask = CPUBitmask;
  GPROffset = CPUTopSavedRegOff;
}

void MipsTargetELFStreamer::emitFMask(unsigned FPUBitmask,
                                      int FPUTopSavedRegOff) {
  FPRInfoSet = true;
  FPRBitMask = FPUBitmask;
  FPROffset = FPUTopSavedRegOff;
}

void MipsTargetELFStreamer::emitDirectiveCpLoad(unsigned RegNo) {
  // .cpload $reg
  // This directive expands to:
  // lui   $gp, %hi(_gp_disp)
  // addui $gp, $gp, %lo(_gp_disp)
  // addu  $gp, $gp, $reg
  // when support for position independent code is enabled.
  if (!Pic || (getABI().IsN32() || getABI().IsN64()))
    return;

  // There's a GNU extension controlled by -mno-shared that allows
  // locally-binding symbols to be accessed using absolute addresses.
  // This is currently not supported. When supported -mno-shared makes
  // .cpload expand to:
  //   lui     $gp, %hi(__gnu_local_gp)
  //   addiu   $gp, $gp, %lo(__gnu_local_gp)

  StringRef SymName("_gp_disp");
  MCAssembler &MCA = getStreamer().getAssembler();
  MCSymbol *GP_Disp = MCA.getContext().getOrCreateSymbol(SymName);
  MCA.registerSymbol(*GP_Disp);

  MCInst TmpInst;
  TmpInst.setOpcode(Mips::LUi);
  TmpInst.addOperand(MCOperand::createReg(GPReg));
  const MCExpr *HiSym = MipsMCExpr::create(
      MipsMCExpr::MEK_HI,
      MCSymbolRefExpr::create("_gp_disp", MCSymbolRefExpr::VK_None,
                              MCA.getContext()),
      MCA.getContext());
  TmpInst.addOperand(MCOperand::createExpr(HiSym));
  getStreamer().emitInstruction(TmpInst, STI);

  TmpInst.clear();

  TmpInst.setOpcode(Mips::ADDiu);
  TmpInst.addOperand(MCOperand::createReg(GPReg));
  TmpInst.addOperand(MCOperand::createReg(GPReg));
  const MCExpr *LoSym = MipsMCExpr::create(
      MipsMCExpr::MEK_LO,
      MCSymbolRefExpr::create("_gp_disp", MCSymbolRefExpr::VK_None,
                              MCA.getContext()),
      MCA.getContext());
  TmpInst.addOperand(MCOperand::createExpr(LoSym));
  getStreamer().emitInstruction(TmpInst, STI);

  TmpInst.clear();

  TmpInst.setOpcode(Mips::ADDu);
  TmpInst.addOperand(MCOperand::createReg(GPReg));
  TmpInst.addOperand(MCOperand::createReg(GPReg));
  TmpInst.addOperand(MCOperand::createReg(RegNo));
  getStreamer().emitInstruction(TmpInst, STI);

  forbidModuleDirective();
}

void MipsTargetELFStreamer::emitDirectiveCpLocal(unsigned RegNo) {
  if (Pic)
    MipsTargetStreamer::emitDirectiveCpLocal(RegNo);
}

bool MipsTargetELFStreamer::emitDirectiveCpRestore(
    int Offset, function_ref<unsigned()> GetATReg, SMLoc IDLoc,
    const MCSubtargetInfo *STI) {
  MipsTargetStreamer::emitDirectiveCpRestore(Offset, GetATReg, IDLoc, STI);
  // .cprestore offset
  // When PIC mode is enabled and the O32 ABI is used, this directive expands
  // to:
  //    sw $gp, offset($sp)
  // and adds a corresponding LW after every JAL.

  // Note that .cprestore is ignored if used with the N32 and N64 ABIs or if it
  // is used in non-PIC mode.
  if (!Pic || (getABI().IsN32() || getABI().IsN64()))
    return true;

  // Store the $gp on the stack.
  emitStoreWithImmOffset(Mips::SW, GPReg, Mips::SP, Offset, GetATReg, IDLoc,
                         STI);
  return true;
}

void MipsTargetELFStreamer::emitDirectiveCpsetup(unsigned RegNo,
                                                 int RegOrOffset,
                                                 const MCSymbol &Sym,
                                                 bool IsReg) {
  // Only N32 and N64 emit anything for .cpsetup iff PIC is set.
  if (!Pic || !(getABI().IsN32() || getABI().IsN64()))
    return;

  forbidModuleDirective();

  MCAssembler &MCA = getStreamer().getAssembler();
  MCInst Inst;

  // Either store the old $gp in a register or on the stack
  if (IsReg) {
    // move $save, $gpreg
    emitRRR(Mips::OR64, RegOrOffset, GPReg, Mips::ZERO, SMLoc(), &STI);
  } else {
    // sd $gpreg, offset($sp)
    emitRRI(Mips::SD, GPReg, Mips::SP, RegOrOffset, SMLoc(), &STI);
  }

  if (getABI().IsN32()) {
    MCSymbol *GPSym = MCA.getContext().getOrCreateSymbol("__gnu_local_gp");
    const MipsMCExpr *HiExpr = MipsMCExpr::create(
        MipsMCExpr::MEK_HI, MCSymbolRefExpr::create(GPSym, MCA.getContext()),
        MCA.getContext());
    const MipsMCExpr *LoExpr = MipsMCExpr::create(
        MipsMCExpr::MEK_LO, MCSymbolRefExpr::create(GPSym, MCA.getContext()),
        MCA.getContext());

    // lui $gp, %hi(__gnu_local_gp)
    emitRX(Mips::LUi, GPReg, MCOperand::createExpr(HiExpr), SMLoc(), &STI);

    // addiu  $gp, $gp, %lo(__gnu_local_gp)
    emitRRX(Mips::ADDiu, GPReg, GPReg, MCOperand::createExpr(LoExpr), SMLoc(),
            &STI);

    return;
  }

  const MipsMCExpr *HiExpr = MipsMCExpr::createGpOff(
      MipsMCExpr::MEK_HI, MCSymbolRefExpr::create(&Sym, MCA.getContext()),
      MCA.getContext());
  const MipsMCExpr *LoExpr = MipsMCExpr::createGpOff(
      MipsMCExpr::MEK_LO, MCSymbolRefExpr::create(&Sym, MCA.getContext()),
      MCA.getContext());

  // lui $gp, %hi(%neg(%gp_rel(funcSym)))
  emitRX(Mips::LUi, GPReg, MCOperand::createExpr(HiExpr), SMLoc(), &STI);

  // addiu  $gp, $gp, %lo(%neg(%gp_rel(funcSym)))
  emitRRX(Mips::ADDiu, GPReg, GPReg, MCOperand::createExpr(LoExpr), SMLoc(),
          &STI);

  // daddu  $gp, $gp, $funcreg
  emitRRR(Mips::DADDu, GPReg, GPReg, RegNo, SMLoc(), &STI);
}

void MipsTargetELFStreamer::emitDirectiveCpreturn(unsigned SaveLocation,
                                                  bool SaveLocationIsRegister) {
  // Only N32 and N64 emit anything for .cpreturn iff PIC is set.
  if (!Pic || !(getABI().IsN32() || getABI().IsN64()))
    return;

  MCInst Inst;
  // Either restore the old $gp from a register or on the stack
  if (SaveLocationIsRegister) {
    Inst.setOpcode(Mips::OR);
    Inst.addOperand(MCOperand::createReg(GPReg));
    Inst.addOperand(MCOperand::createReg(SaveLocation));
    Inst.addOperand(MCOperand::createReg(Mips::ZERO));
  } else {
    Inst.setOpcode(Mips::LD);
    Inst.addOperand(MCOperand::createReg(GPReg));
    Inst.addOperand(MCOperand::createReg(Mips::SP));
    Inst.addOperand(MCOperand::createImm(SaveLocation));
  }
  getStreamer().emitInstruction(Inst, STI);

  forbidModuleDirective();
}

void MipsTargetELFStreamer::emitMipsAbiFlags() {
  MCAssembler &MCA = getStreamer().getAssembler();
  MCContext &Context = MCA.getContext();
  MCStreamer &OS = getStreamer();
  MCSectionELF *Sec = Context.getELFSection(
      ".MIPS.abiflags", ELF::SHT_MIPS_ABIFLAGS, ELF::SHF_ALLOC, 24, "");
  MCA.registerSection(*Sec);
  Sec->setAlignment(Align(8));
  OS.SwitchSection(Sec);

  OS << ABIFlagsSection;
}
