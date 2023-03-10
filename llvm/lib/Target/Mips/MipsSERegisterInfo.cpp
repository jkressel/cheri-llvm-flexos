//===-- MipsSERegisterInfo.cpp - MIPS32/64 Register Information -== -------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the MIPS32/64 implementation of the TargetRegisterInfo
// class.
//
//===----------------------------------------------------------------------===//

#include "MipsSERegisterInfo.h"
#include "Mips.h"
#include "MipsMachineFunction.h"
#include "MipsSEInstrInfo.h"
#include "MipsSubtarget.h"
#include "MipsTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

#define DEBUG_TYPE "mips-reg-info"

MipsSERegisterInfo::MipsSERegisterInfo(const MipsSubtarget &STI) :
  MipsRegisterInfo(STI) {}

bool MipsSERegisterInfo::
requiresRegisterScavenging(const MachineFunction &MF) const {
  return true;
}

bool MipsSERegisterInfo::
requiresFrameIndexScavenging(const MachineFunction &MF) const {
  return true;
}

const TargetRegisterClass *
MipsSERegisterInfo::intRegClass(unsigned Size) const {
  if (Size == 4)
    return &Mips::GPR32RegClass;

  assert(Size == 8);
  return &Mips::GPR64RegClass;
}

/// Get the size of the offset supported by the given load/store/inline asm.
/// The result includes the effects of any scale factors applied to the
/// instruction immediate.
static inline unsigned getLoadStoreOffsetSizeInBits(const unsigned Opcode,
                                                    MachineOperand MO) {
  switch (Opcode) {
  case Mips::CAPSTORE8:
  case Mips::CAPSTORE832:
  case Mips::CAPLOAD8:
  case Mips::CAPLOAD832:
  case Mips::CAPLOADU8:
  case Mips::CAPLOADU832:
    return 8;
  case Mips::CAPSTORE16:
  case Mips::CAPSTORE1632:
  case Mips::CAPLOAD16:
  case Mips::CAPLOAD1632:
  case Mips::CAPLOADU16:
  case Mips::CAPLOADU1632:
    return 8 + 1 /* scale factor */;
  case Mips::CAPSTORE32:
  case Mips::CAPSTORE3264:
  case Mips::CAPLOAD32:
  case Mips::CAPLOAD3264:
  case Mips::CAPLOADU32:
    return 8 + 2 /* scale factor */;
  case Mips::CAPSTORE64:
  case Mips::CAPLOAD64:
    return 8 + 3 /* scale factor */;
  case Mips::LOADCAP:
  case Mips::STORECAP:
    return 11 + 4 /* scale factor */;
  case Mips::LOADCAP_BigImm:
  case Mips::STORECAP_BigImm:
    return 16 + 4 /* scale factor */;
  case Mips::CIncOffsetImm:
    return 11;
  case Mips::CheriBoundedStackPseudoImm:
  case Mips::CheriBoundedStackPseudoReg:
    return 1;  // only 0 is valid, otherwise we need a CIncOffset
  case Mips::LD_B:
  case Mips::ST_B:
    return 10;
  case Mips::LD_H:
  case Mips::ST_H:
    return 10 + 1 /* scale factor */;
  case Mips::LD_W:
  case Mips::ST_W:
    return 10 + 2 /* scale factor */;
  case Mips::LD_D:
  case Mips::ST_D:
    return 10 + 3 /* scale factor */;
  case Mips::LL:
  case Mips::LL64:
  case Mips::LLD:
  case Mips::LLE:
  case Mips::SC:
  case Mips::SC64:
  case Mips::SCD:
  case Mips::SCE:
    return 16;
  case Mips::LLE_MM:
  case Mips::LL_MM:
  case Mips::SCE_MM:
  case Mips::SC_MM:
    return 12;
  case Mips::LL64_R6:
  case Mips::LL_R6:
  case Mips::LLD_R6:
  case Mips::SC64_R6:
  case Mips::SCD_R6:
  case Mips::SC_R6:
  case Mips::LL_MMR6:
  case Mips::SC_MMR6:
    return 9;
  case Mips::INLINEASM: {
    unsigned ConstraintID = InlineAsm::getMemoryConstraintID(MO.getImm());
    switch (ConstraintID) {
    case InlineAsm::Constraint_ZC: {
      const MipsSubtarget &Subtarget = MO.getParent()
                                           ->getParent()
                                           ->getParent()
                                           ->getSubtarget<MipsSubtarget>();
      if (Subtarget.inMicroMipsMode())
        return 12;

      if (Subtarget.hasMips32r6())
        return 9;

      return 16;
    }
    default:
      return 16;
    }
  }
  default:
    return 16;
  }
}

/// Get the scale factor applied to the immediate in the given load/store.
static inline unsigned getLoadStoreOffsetAlign(const unsigned Opcode) {
  switch (Opcode) {
  case Mips::CheriBoundedStackPseudoImm:
  case Mips::CheriBoundedStackPseudoReg:
    return 64; // Ensure that only 0 is valid (since max width is 1)
  case Mips::CAPSTORE16:
  case Mips::CAPLOAD16:
  case Mips::CAPLOAD1632:
  case Mips::CAPLOADU1632:
  case Mips::CAPLOADU16:
    return 2;
  case Mips::CAPSTORE32:
  case Mips::CAPLOAD32:
  case Mips::CAPLOADU32:
    return 4;
  case Mips::CAPSTORE64:
  case Mips::CAPLOAD64:
    return 8;
  case Mips::LOADCAP:
  case Mips::LOADCAP_BigImm:
  case Mips::STORECAP:
  case Mips::STORECAP_BigImm:
    return 16;
  case Mips::LD_H:
  case Mips::ST_H:
    return 2;
  case Mips::LD_W:
  case Mips::ST_W:
    return 4;
  case Mips::LD_D:
  case Mips::ST_D:
    return 8;
  default:
    return 1;
  }
}

void MipsSERegisterInfo::eliminateFI(MachineBasicBlock::iterator II,
                                     unsigned OpNo, int FrameIndex,
                                     uint64_t StackSize,
                                     int64_t SPOffset,
                                     RegScavenger *RS) const {
  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  MipsFunctionInfo *MipsFI = MF.getInfo<MipsFunctionInfo>();

  auto &TM = static_cast<const MipsTargetMachine &>(MF.getTarget());
  MipsABIInfo ABI = TM.getABI();
  const MipsRegisterInfo *RegInfo =
    static_cast<const MipsRegisterInfo *>(MF.getSubtarget().getRegisterInfo());

  const std::vector<CalleeSavedInfo> &CSI = MFI.getCalleeSavedInfo();
  int MinCSFI = 0;
  int MaxCSFI = -1;

  if (CSI.size()) {
    MinCSFI = CSI[0].getFrameIdx();
    MaxCSFI = CSI[CSI.size() - 1].getFrameIdx();
  }

  bool EhDataRegFI = MipsFI->isEhDataRegFI(FrameIndex);
  bool IsISRRegFI = MipsFI->isISRRegFI(FrameIndex);
  // The following stack frame objects are always referenced relative to $sp:
  //  1. Outgoing arguments.
  //  2. Pointer to dynamically allocated stack space.
  //  3. Locations for callee-saved registers.
  //  4. Locations for eh data registers.
  //  5. Locations for ISR saved Coprocessor 0 registers 12 & 14.
  // Everything else is referenced relative to whatever register
  // getFrameRegister() returns.
  unsigned FrameReg;

  if ((FrameIndex >= MinCSFI && FrameIndex <= MaxCSFI) || EhDataRegFI ||
      IsISRRegFI)
    FrameReg = ABI.GetStackPtr();
  else if (RegInfo->hasStackRealignment(MF)) {
    if (MFI.hasVarSizedObjects() && !MFI.isFixedObjectIndex(FrameIndex))
      FrameReg = ABI.GetBasePtr();
    else if (MFI.isFixedObjectIndex(FrameIndex))
      FrameReg = getFrameRegister(MF);
    else
      FrameReg = ABI.GetStackPtr();
  } else
    FrameReg = getFrameRegister(MF);

  // Calculate final offset.
  // - There is no need to change the offset if the frame object is one of the
  //   following: an outgoing argument, pointer to a dynamically allocated
  //   stack space or a $gp restore location,
  // - If the frame object is any of the following, its offset must be adjusted
  //   by adding the size of the stack:
  //   incoming argument, callee-saved register location or local variable.
  bool IsKill = false;
  int64_t Offset;
  int RegOpNo = OpNo;
  int ImmOpNo = OpNo + 1;
  if (ABI.IsCheriPureCap()) {
    RegOpNo = OpNo;
    switch (MI.getOpcode()) {
    case Mips::CAPSTORE64:
    case Mips::CAPSTORE32:
    case Mips::CAPSTORE3264:
    case Mips::CAPSTORE16:
    case Mips::CAPSTORE1632:
    case Mips::CAPSTORE8:
    case Mips::CAPSTORE832:
    case Mips::STORECAP:
    case Mips::LOADCAP:
    case Mips::CAPLOAD64:
    case Mips::CAPLOAD32:
    case Mips::CAPLOAD3264:
    case Mips::CAPLOADU32:
    case Mips::CAPLOAD16:
    case Mips::CAPLOAD1632:
    case Mips::CAPLOADU16:
    case Mips::CAPLOADU1632:
    case Mips::CAPLOAD8:
    case Mips::CAPLOAD832:
    case Mips::CAPLOADU8:
    case Mips::CAPLOADU832:
      ImmOpNo = 2;
      RegOpNo = 3;
      break;
    case Mips::CIncOffsetImm:
      ImmOpNo = 2;
      RegOpNo = 1;
      break;
    case Mips::CheriBoundedStackPseudoImm:
    case Mips::CheriBoundedStackPseudoReg:
      ImmOpNo = 2;
      RegOpNo = 1;
      break;
    case Mips::CIncOffset:
      break;
    case Mips::INLINEASM:
      break;
    default:
#if !defined(NDEBUG) || defined(LLVM_ENABLE_DUMP)
      MI.dump();
#endif
      llvm_unreachable("Unsupported instruction in eliminateFI!");
    }
  }


  Offset = SPOffset + (int64_t)StackSize;
  if (MI.getOperand(ImmOpNo).isImm())
    Offset += MI.getOperand(ImmOpNo).getImm();

  // For CHERI spills, we store the offset as an immediate operand from the
  // FrameIndex where the register operand should go and then replace it with
  // the real register here.
  if (MI.getOperand(RegOpNo).isImm())
    Offset += MI.getOperand(RegOpNo).getImm();

  LLVM_DEBUG(errs() << "Offset     : " << Offset << "\n"
                    << "<--------->\n");

  if (!MI.isDebugValue()) {
    // Make sure Offset fits within the field available.
    // For MSA instructions, this is a 10-bit signed immediate (scaled by
    // element size), otherwise it is a 16-bit signed immediate.
    unsigned OffsetBitSize =
        getLoadStoreOffsetSizeInBits(MI.getOpcode(), MI.getOperand(OpNo - 1));
    const Align OffsetAlign(getLoadStoreOffsetAlign(MI.getOpcode()));
    auto *STI = TM.getSubtargetImpl(MF.getFunction());
    const MipsSEInstrInfo &TII = *static_cast<const MipsSEInstrInfo *>(
          STI->getInstrInfo());
    DebugLoc DL = II->getDebugLoc();

    // Convert CIncOffset <-> CIncOffsetImm depending on offset value
    if (MI.getOpcode() == Mips::CIncOffset || MI.getOpcode() == Mips::CIncOffsetImm) {
      MI.getOperand(1).ChangeToRegister(FrameReg, false);
      // If this is an 11-bit offset, then replace the CIncOffset that takes a
      // register with one that takes an immediate.
      if (isInt<11>(Offset)) {
        if (MI.getOpcode() == Mips::CIncOffset)
          MI.setDesc(TII.get(Mips::CIncOffsetImm));
        MI.getOperand(2).ChangeToImmediate(Offset);
      } else {
        if (MI.getOpcode() == Mips::CIncOffsetImm)
          MI.setDesc(TII.get(Mips::CIncOffset));
        MachineBasicBlock &MBB = *MI.getParent();
        unsigned Reg = TII.loadImmediate(Offset, MBB, II, DL, nullptr);
        MI.getOperand(2).ChangeToRegister(Reg, false, false, true);
      }
      return;
    }

    if (ABI.IsCheriPureCap()) {
      if (!isIntN(OffsetBitSize, Offset) || !isAligned(OffsetAlign, Offset)) {
        MachineBasicBlock &MBB = *MI.getParent();
        // If we have an offset that needs to fit into a signed n-bit immediate
        // (where n < 16) and doesn't, but does fit into 16-bits then use an ADDiu
        bool isFrameRegLoad = MI.getOperand(0).getReg() == FrameReg && MI.getOpcode() != Mips::STORECAP;
        // bounded stack caps always need inc-offset (except for offset 0)
        bool needsIncOffset = MI.isPseudo() || MI.getOperand(1).getReg() != Mips::ZERO_64;
        MachineRegisterInfo &RegInfo = MBB.getParent()->getRegInfo();
#if 0
        // This was the original code which avoids allocating a new capreg.
        const TargetRegisterClass *PtrRC =
            ABI.ArePtrs64bit() ? &Mips::GPR64RegClass : &Mips::GPR32RegClass;
        MachineRegisterInfo &RegInfo = MBB.getParent()->getRegInfo();
        unsigned Reg = TII.loadImmediate(Offset, MBB, II, DL, nullptr);
        // TODO: use CIncOffsetImmediate here!
        if (needsIncOffset) {
          BuildMI(MBB, II, DL, TII.get(Mips::CIncOffset), FrameReg)
              .addReg(FrameReg)
              .addReg(Reg, isFrameReg ? RegState::Kill : 0);
          if (!isFrameReg) {
            unsigned NegReg = RegInfo.createVirtualRegister(PtrRC);
            BuildMI(MBB, (++II), DL, TII.get(Mips::DSUBu), NegReg)
              .addReg(Mips::ZERO_64)
              .addReg(Reg, RegState::Kill);
            BuildMI(MBB, II, DL, TII.get(Mips::CIncOffset), FrameReg)
              .addReg(FrameReg)
              .addReg(NegReg, RegState::Kill);
          }
#endif
        unsigned TmpCap = -1;
        if (isFrameRegLoad ||
            MI.getOpcode() == Mips::CheriBoundedStackPseudoReg ||
            MI.getOpcode() == Mips::CheriBoundedStackPseudoImm) {
          assert(MI.getOpcode() == Mips::LOADCAP || MI.isPseudo());
          TmpCap = MI.getOperand(0).getReg();
        } else {
          TmpCap = RegInfo.createVirtualRegister(&Mips::CheriGPRRegClass);
        }
        // TODO: use CIncOffsetImmediate here!
        if (needsIncOffset) {
          if (isInt<11>(Offset)) {
            BuildMI(MBB, II, DL, TII.get(Mips::CIncOffsetImm), TmpCap)
                .addReg(FrameReg, isFrameRegLoad ? RegState::Kill : 0)
                .addImm(Offset);
          } else {
            unsigned Reg = TII.loadImmediate(Offset, MBB, II, DL, nullptr);
            BuildMI(MBB, II, DL, TII.get(Mips::CIncOffset), TmpCap)
                .addReg(FrameReg, isFrameRegLoad ? RegState::Kill : 0)
                .addReg(Reg, RegState::Kill);
          }
          FrameReg = TmpCap;
          IsKill = true;
        } else {
          unsigned Reg = TII.loadImmediate(Offset, MBB, II, DL, nullptr);
          MI.getOperand(1).ChangeToRegister(Reg, false, false, true);
        }
        Offset = 0;
      }
    } else if (OffsetBitSize < 16 && isInt<16>(Offset) &&
        (!isIntN(OffsetBitSize, Offset) || !isAligned(OffsetAlign, Offset))) {
      // If we have an offset that needs to fit into a signed n-bit immediate
      // (where n < 16) and doesn't, but does fit into 16-bits then use an ADDiu
      MachineBasicBlock &MBB = *MI.getParent();
      const TargetRegisterClass *PtrRC =
          ABI.ArePtrs64bit() ? &Mips::GPR64RegClass : &Mips::GPR32RegClass;
      MachineRegisterInfo &RegInfo = MBB.getParent()->getRegInfo();
      Register Reg = RegInfo.createVirtualRegister(PtrRC);
      BuildMI(MBB, II, DL, TII.get(ABI.GetPtrAddiuOp()), Reg)
          .addReg(FrameReg)
          .addImm(Offset);

      FrameReg = Reg;
      Offset = 0;
      IsKill = true;
    } else if (!isInt<16>(Offset)) {
      // Otherwise split the offset into 16-bit pieces and add it in multiple
      // instructions.
      MachineBasicBlock &MBB = *MI.getParent();
      DebugLoc DL = II->getDebugLoc();
      unsigned NewImm = 0;
      unsigned Reg = TII.loadImmediate(Offset, MBB, II, DL,
                                       OffsetBitSize == 16 ? &NewImm : nullptr);
      BuildMI(MBB, II, DL, TII.get(ABI.GetPtrAdduOp()), Reg).addReg(FrameReg)
        .addReg(Reg, RegState::Kill);

      FrameReg = Reg;
      Offset = SignExtend64<16>(NewImm);
      IsKill = true;
    }
  }

  MI.getOperand(RegOpNo).ChangeToRegister(FrameReg, false, false, IsKill);
  MI.getOperand(ImmOpNo).ChangeToImmediate(Offset);
}
