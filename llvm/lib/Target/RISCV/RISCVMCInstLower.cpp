//===-- RISCVMCInstLower.cpp - Convert RISCV MachineInstr to an MCInst ------=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains code to lower RISCV MachineInstrs to their corresponding
// MCInst records.
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "RISCVSubtarget.h"
#include "MCTargetDesc/RISCVMCExpr.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

static MCOperand lowerSymbolOperand(const MachineOperand &MO, MCSymbol *Sym,
                                    const AsmPrinter &AP) {
  MCContext &Ctx = AP.OutContext;
  RISCVMCExpr::VariantKind Kind;

  switch (MO.getTargetFlags()) {
  default:
    llvm_unreachable("Unknown target flag on GV operand");
  case RISCVII::MO_None:
    Kind = RISCVMCExpr::VK_RISCV_None;
    break;
  case RISCVII::MO_CALL:
    Kind = RISCVMCExpr::VK_RISCV_CALL;
    break;
  case RISCVII::MO_PLT:
    Kind = RISCVMCExpr::VK_RISCV_CALL_PLT;
    break;
  case RISCVII::MO_LO:
    Kind = RISCVMCExpr::VK_RISCV_LO;
    break;
  case RISCVII::MO_HI:
    Kind = RISCVMCExpr::VK_RISCV_HI;
    break;
  case RISCVII::MO_PCREL_LO:
    Kind = RISCVMCExpr::VK_RISCV_PCREL_LO;
    break;
  case RISCVII::MO_PCREL_HI:
    Kind = RISCVMCExpr::VK_RISCV_PCREL_HI;
    break;
  case RISCVII::MO_GOT_HI:
    Kind = RISCVMCExpr::VK_RISCV_GOT_HI;
    break;
  case RISCVII::MO_TPREL_LO:
    Kind = RISCVMCExpr::VK_RISCV_TPREL_LO;
    break;
  case RISCVII::MO_TPREL_HI:
    Kind = RISCVMCExpr::VK_RISCV_TPREL_HI;
    break;
  case RISCVII::MO_TPREL_ADD:
    Kind = RISCVMCExpr::VK_RISCV_TPREL_ADD;
    break;
  case RISCVII::MO_TLS_GOT_HI:
    Kind = RISCVMCExpr::VK_RISCV_TLS_GOT_HI;
    break;
  case RISCVII::MO_TLS_GD_HI:
    Kind = RISCVMCExpr::VK_RISCV_TLS_GD_HI;
    break;
  case RISCVII::MO_CAPTAB_PCREL_HI:
    Kind = RISCVMCExpr::VK_RISCV_CAPTAB_PCREL_HI;
    break;
  case RISCVII::MO_TPREL_CINCOFFSET:
    Kind = RISCVMCExpr::VK_RISCV_TPREL_CINCOFFSET;
    break;
  case RISCVII::MO_TLS_IE_CAPTAB_PCREL_HI:
    Kind = RISCVMCExpr::VK_RISCV_TLS_IE_CAPTAB_PCREL_HI;
    break;
  case RISCVII::MO_TLS_GD_CAPTAB_PCREL_HI:
    Kind = RISCVMCExpr::VK_RISCV_TLS_GD_CAPTAB_PCREL_HI;
    break;
  }

  const MCExpr *ME =
      MCSymbolRefExpr::create(Sym, MCSymbolRefExpr::VK_None, Ctx);

  if (!MO.isJTI() && !MO.isMBB() && MO.getOffset())
    ME = MCBinaryExpr::createAdd(
        ME, MCConstantExpr::create(MO.getOffset(), Ctx), Ctx);

  if (Kind != RISCVMCExpr::VK_RISCV_None)
    ME = RISCVMCExpr::create(ME, Kind, Ctx);
  return MCOperand::createExpr(ME);
}

bool llvm::LowerRISCVMachineOperandToMCOperand(const MachineOperand &MO,
                                               MCOperand &MCOp,
                                               const AsmPrinter &AP) {
  switch (MO.getType()) {
  default:
    report_fatal_error("LowerRISCVMachineInstrToMCInst: unknown operand type");
  case MachineOperand::MO_Register:
    // Ignore all implicit register operands.
    if (MO.isImplicit())
      return false;
    MCOp = MCOperand::createReg(MO.getReg());
    break;
  case MachineOperand::MO_RegisterMask:
    // Regmasks are like implicit defs.
    return false;
  case MachineOperand::MO_Immediate:
    MCOp = MCOperand::createImm(MO.getImm());
    break;
  case MachineOperand::MO_MachineBasicBlock:
    MCOp = lowerSymbolOperand(MO, MO.getMBB()->getSymbol(), AP);
    break;
  case MachineOperand::MO_GlobalAddress:
    MCOp = lowerSymbolOperand(MO, AP.getSymbol(MO.getGlobal()), AP);
    break;
  case MachineOperand::MO_BlockAddress:
    MCOp = lowerSymbolOperand(
        MO, AP.GetBlockAddressSymbol(MO.getBlockAddress()), AP);
    break;
  case MachineOperand::MO_ExternalSymbol:
    MCOp = lowerSymbolOperand(
        MO, AP.GetExternalSymbolSymbol(MO.getSymbolName()), AP);
    break;
  case MachineOperand::MO_ConstantPoolIndex:
    MCOp = lowerSymbolOperand(MO, AP.GetCPISymbol(MO.getIndex()), AP);
    break;
  }
  return true;
}

static bool lowerRISCVVMachineInstrToMCInst(const MachineInstr *MI,
                                            MCInst &OutMI) {
  const RISCVVPseudosTable::PseudoInfo *RVV =
      RISCVVPseudosTable::getPseudoInfo(MI->getOpcode());
  if (!RVV)
    return false;

  OutMI.setOpcode(RVV->BaseInstr);

  const MachineBasicBlock *MBB = MI->getParent();
  assert(MBB && "MI expected to be in a basic block");
  const MachineFunction *MF = MBB->getParent();
  assert(MF && "MBB expected to be in a machine function");

  const TargetRegisterInfo *TRI =
      MF->getSubtarget<RISCVSubtarget>().getRegisterInfo();
  assert(TRI && "TargetRegisterInfo expected");

  for (const MachineOperand &MO : MI->explicit_operands()) {
    int OpNo = (int)MI->getOperandNo(&MO);
    assert(OpNo >= 0 && "Operand number doesn't fit in an 'int' type");

    // Skip VL, SEW and MergeOp operands
    if (OpNo == RVV->getVLIndex() || OpNo == RVV->getSEWIndex() ||
        OpNo == RVV->getMergeOpIndex())
      continue;

    MCOperand MCOp;
    switch (MO.getType()) {
    default:
      llvm_unreachable("Unknown operand type");
    case MachineOperand::MO_Register: {
      unsigned Reg = MO.getReg();

      // Nothing to do on NoRegister operands (used as vector mask operand on
      // unmasked instructions)
      if (Reg == RISCV::NoRegister) {
        MCOp = MCOperand::createReg(Reg);
        break;
      }

      const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);
      if (RC->hasSuperClassEq(&RISCV::VRM2RegClass) ||
          RC->hasSuperClassEq(&RISCV::VRM4RegClass) ||
          RC->hasSuperClassEq(&RISCV::VRM8RegClass)) {
        Reg = TRI->getSubReg(Reg, RISCV::sub_vrm2);
        assert(Reg && "Subregister does not exist");
      }

      MCOp = MCOperand::createReg(Reg);
      break;
    }
    case MachineOperand::MO_Immediate:
      MCOp = MCOperand::createImm(MO.getImm());
      break;
    }
    OutMI.addOperand(MCOp);
  }
  return true;
}

void llvm::LowerRISCVMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                          const AsmPrinter &AP) {
  if (lowerRISCVVMachineInstrToMCInst(MI, OutMI))
    return;

  OutMI.setOpcode(MI->getOpcode());

  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if (LowerRISCVMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }
}
