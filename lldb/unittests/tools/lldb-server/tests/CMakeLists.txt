add_lldb_unittest(LLDBServerTests
  LLGSTest.cpp
  MessageObjects.cpp
  TestBase.cpp
  TestClient.cpp
  ThreadIdsInJstopinfoTest.cpp

  LINK_LIBS
    lldbHost
    lldbCore
    lldbInterpreter
    lldbTarget
    lldbPluginPlatformLinux
    lldbPluginProcessGDBRemote

    LLVMTestingSupport
  LINK_COMPONENTS
    RuntimeDyld
    Support
  )

add_dependencies(LLDBServerTests lldb-server ${ALL_LLDB_TEST_EXECUTABLES})
