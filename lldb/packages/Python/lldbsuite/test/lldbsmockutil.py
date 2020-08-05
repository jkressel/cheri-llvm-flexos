"""
Utility functions for using the mock GDB server.
"""

import lldb
from lldbsuite.test import lldbtest


def connect(test, target, server):
    """Make a connection to the mock GDB server."""

    listener = lldb.SBListener("my.connect.listener")
    error = lldb.SBError()
    process = target.ConnectRemote(
        listener, 'connect://{}:{}'.format(server.server_address[0],
                                           server.server_address[1]),
        'gdb-remote', error)
    test.assertTrue(process.IsValid(), lldbtest.PROCESS_IS_VALID)
    test.assertEqual(process.GetState(), lldb.eStateUnloaded)

    # Get the 'state changed to stopped' event that was generated by the
    # connect command. Popping the event also changes the public state of
    # the process to the stopped state.
    event = lldb.SBEvent()
    success = listener.GetNextEvent(event)
    test.assertTrue(success)
    test.assertEqual(process.GetStateFromEvent(event), lldb.eStateStopped)
    test.assertEqual(process.GetState(), lldb.eStateStopped)

    return process
