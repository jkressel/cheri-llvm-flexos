//===-- NativeRegisterContextLinux_arm64.h ---------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#if defined(__arm64__) || defined(__aarch64__)

#ifndef lldb_NativeRegisterContextLinux_arm64_h
#define lldb_NativeRegisterContextLinux_arm64_h

#include "Plugins/Process/Linux/NativeRegisterContextLinux.h"
#include "Plugins/Process/Utility/lldb-arm64-register-enums.h"

namespace lldb_private {
namespace process_linux {

class NativeProcessLinux;

class NativeRegisterContextLinux_arm64 : public NativeRegisterContextLinux {
public:
  NativeRegisterContextLinux_arm64(const ArchSpec &target_arch,
                                   NativeThreadProtocol &native_thread);

  uint32_t GetRegisterSetCount() const override;

  uint32_t GetUserRegisterCount() const override;

  const RegisterSet *GetRegisterSet(uint32_t set_index) const override;

  Status ReadRegister(const RegisterInfo *reg_info,
                      RegisterValue &reg_value) override;

  Status WriteRegister(const RegisterInfo *reg_info,
                       const RegisterValue &reg_value) override;

  Status ReadAllRegisterValues(lldb::DataBufferSP &data_sp) override;

  Status WriteAllRegisterValues(const lldb::DataBufferSP &data_sp) override;

  void InvalidateAllRegisters() override;

  // Hardware breakpoints/watchpoint management functions

  uint32_t NumSupportedHardwareBreakpoints() override;

  uint32_t SetHardwareBreakpoint(lldb::addr_t addr, size_t size) override;

  bool ClearHardwareBreakpoint(uint32_t hw_idx) override;

  Status ClearAllHardwareBreakpoints() override;

  Status GetHardwareBreakHitIndex(uint32_t &bp_index,
                                  lldb::addr_t trap_addr) override;

  uint32_t NumSupportedHardwareWatchpoints() override;

  uint32_t SetHardwareWatchpoint(lldb::addr_t addr, size_t size,
                                 uint32_t watch_flags) override;

  bool ClearHardwareWatchpoint(uint32_t hw_index) override;

  Status ClearAllHardwareWatchpoints() override;

  Status GetWatchpointHitIndex(uint32_t &wp_index,
                               lldb::addr_t trap_addr) override;

  lldb::addr_t GetWatchpointHitAddress(uint32_t wp_index) override;

  lldb::addr_t GetWatchpointAddress(uint32_t wp_index) override;

  uint32_t GetWatchpointSize(uint32_t wp_index);

  bool WatchpointIsEnabled(uint32_t wp_index);

  // Debug register type select
  enum DREGType { eDREGTypeWATCH = 0, eDREGTypeBREAK };

protected:

  Status ReadGPR() override;

  Status WriteGPR() override;

  Status ReadFPR() override;

  Status WriteFPR() override;

  void *GetGPRBuffer() override { return &m_gpr_arm64; }

  void *GetFPRBuffer() override { return &m_fpr; }

  size_t GetFPRSize() override { return sizeof(m_fpr); }

private:
  struct RegInfo {
    uint32_t num_registers;
    uint32_t num_gpr_registers;
    uint32_t num_fpr_registers;
    uint32_t num_cap_registers;
    uint32_t num_state_registers;
    uint32_t num_thread_registers;

    uint32_t last_gpr;
    uint32_t first_fpr;
    uint32_t last_fpr;

    uint32_t first_fpr_v;
    uint32_t last_fpr_v;

    uint32_t first_cap;
    uint32_t last_cap;

    uint32_t first_state;
    uint32_t last_state;

    uint32_t first_thread;
    uint32_t last_thread;

    uint32_t gpr_flags;
  };

  // based on RegisterContextDarwin_arm64.h
  struct VReg {
    uint8_t bytes[16];
  };

  // based on RegisterContextDarwin_arm64.h
  struct FPU {
    VReg v[32];
    uint32_t fpsr;
    uint32_t fpcr;
  };

  struct GPR {
    uint64_t x[31];
    uint64_t sp;
    uint64_t pc;
    uint64_t pstate;
  };

  bool m_gpr_is_valid;
  bool m_fpu_is_valid;

  GPR m_gpr_arm64; // 64-bit general purpose registers.
  RegInfo m_reg_info;
  FPU m_fpr; // floating-point registers including extended register sets.

  // Debug register info for hardware breakpoints and watchpoints management.
  struct DREG {
    lldb::addr_t address;  // Breakpoint/watchpoint address value.
    lldb::addr_t hit_addr; // Address at which last watchpoint trigger exception
                           // occurred.
    lldb::addr_t real_addr; // Address value that should cause target to stop.
    uint32_t control;       // Breakpoint/watchpoint control value.
    uint32_t refcount;      // Serves as enable/disable and reference counter.
  };

  struct DREG m_hbr_regs[16]; // Arm native linux hardware breakpoints
  struct DREG m_hwp_regs[16]; // Arm native linux hardware watchpoints

  uint32_t m_max_hwp_supported;
  uint32_t m_max_hbp_supported;
  bool m_refresh_hwdebug_info;

  bool IsGPR(unsigned reg) const;

  bool IsFPR(unsigned reg) const;

  bool IsCapR(unsigned reg) const;

  bool IsStateR(unsigned reg) const;

  bool IsThreadR(unsigned reg) const;

  Status ReadHardwareDebugInfo();

  Status WriteHardwareDebugRegs(int hwbType);

  Status GetRegSetFromKernel(int regset, void *reg_state, size_t len);

  void SetCapabilityRegisterValue(uint8_t *value, uint64_t tag,
                                  RegisterValue &reg_value);

  Status ReadCapabilityRegister(uint32_t regnum, RegisterValue &reg_value);

  Status ReadStateRegister(uint32_t regnum, RegisterValue &reg_value);

  Status ReadThreadRegister(uint32_t regnum, RegisterValue &reg_value);

  uint32_t CalculateFprOffset(const RegisterInfo *reg_info) const;
};

} // namespace process_linux
} // namespace lldb_private

#endif // #ifndef lldb_NativeRegisterContextLinux_arm64_h

#endif // defined (__arm64__) || defined (__aarch64__)
