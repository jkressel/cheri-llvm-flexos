add_lldb_library(lldbPluginABIX86 PLUGIN
  ABIX86.cpp
  ABIMacOSX_i386.cpp
  ABISysV_i386.cpp
  ABISysV_x86_64.cpp
  ABIWindows_x86_64.cpp

  LINK_LIBS
    lldbCore
    lldbSymbol
    lldbTarget
    lldbPluginABIUtility
  LINK_COMPONENTS
    Support
  )
