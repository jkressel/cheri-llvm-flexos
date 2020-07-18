#!/usr/bin/env python
#===----------------------------------------------------------------------===##
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
#===----------------------------------------------------------------------===##

"""
Runs an executable on a remote host.

This is meant to be used as an executor when running the C++ Standard Library
conformance test suite.
"""

import argparse
import os
import posixpath
import shlex
import subprocess
import sys
import tarfile
import tempfile

def ssh(args, command):
    cmd = ['ssh', '-oBatchMode=yes']
    if args.extra_ssh_args is not None:
        cmd.extend(shlex.split(args.extra_ssh_args))
    return cmd + [args.host, command]


def scp(args, src, dst):
    cmd = ['scp', '-q', '-oBatchMode=yes']
    if args.extra_scp_args is not None:
        cmd.extend(shlex.split(args.extra_scp_args))
    return cmd + [src, '{}:{}'.format(args.host, dst)]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', type=str, required=True)
    parser.add_argument('--execdir', type=str, required=True)
    parser.add_argument('--extra-ssh-args', type=str, required=False)
    parser.add_argument('--extra-scp-args', type=str, required=False)
    parser.add_argument('--codesign_identity', type=str, required=False, default=None)
    parser.add_argument('--env', type=str, nargs='*', required=False, default=dict())
    parser.add_argument("command", nargs=argparse.ONE_OR_MORE)
    args = parser.parse_args()

    commandLine = args.command  # argparse will strip the initial '--'
    if len(commandLine) < 1:
        sys.stderr.write('Missing actual commands to run')
        return 1

    # Create a temporary directory where the test will be run.
    # That is effectively the value of %T on the remote host.
    tmp = subprocess.check_output(ssh(args, 'mktemp -d /tmp/libcxx.XXXXXXXXXX'), universal_newlines=True).strip()

    # HACK:
    # If an argument is a file that ends in `.tmp.exe`, assume it is the name
    # of an executable generated by a test file. We call these test-executables
    # below. This allows us to do custom processing like codesigning test-executables
    # and changing their path when running on the remote host. It's also possible
    # for there to be no such executable, for example in the case of a .sh.cpp
    # test.
    isTestExe = lambda exe: exe.endswith('.tmp.exe') and os.path.exists(exe)
    pathOnRemote = lambda file: posixpath.join(tmp, os.path.basename(file))

    try:
        # Do any necessary codesigning of test-executables found in the command line.
        if args.codesign_identity:
            for exe in filter(isTestExe, commandLine):
                subprocess.check_call(['xcrun', 'codesign', '-f', '-s', args.codesign_identity, exe], env={})

        # tar up the execution directory (which contains everything that's needed
        # to run the test), and copy the tarball over to the remote host.
        try:
            tmpTar = tempfile.NamedTemporaryFile(suffix='.tar', delete=False)
            with tarfile.open(fileobj=tmpTar, mode='w') as tarball:
                tarball.add(args.execdir, arcname=os.path.basename(args.execdir))

            # Make sure we close the file before we scp it, because accessing
            # the temporary file while still open doesn't work on Windows.
            tmpTar.close()
            remoteTarball = pathOnRemote(tmpTar.name)
            subprocess.check_call(scp(args, tmpTar.name, remoteTarball))
        finally:
            # Make sure we close the file in case an exception happens before
            # we've closed it above -- otherwise close() is idempotent.
            tmpTar.close()
            os.remove(tmpTar.name)

        # Untar the dependencies in the temporary directory and remove the tarball.
        remoteCommands = [
            'tar -xf {} -C {} --strip-components 1'.format(remoteTarball, tmp),
            'rm {}'.format(remoteTarball)
        ]

        # Make sure all test-executables in the remote command line have 'execute'
        # permissions on the remote host. The host that compiled the test-executable
        # might not have a notion of 'executable' permissions.
        for exe in map(pathOnRemote, filter(isTestExe, commandLine)):
            remoteCommands.append('chmod +x {}'.format(exe))

        # Execute the command through SSH in the temporary directory, with the
        # correct environment. We tweak the command line to run it on the remote
        # host by transforming the path of test-executables to their path in the
        # temporary directory on the remote host.
        commandLine = (pathOnRemote(x) if isTestExe(x) else x for x in commandLine)
        remoteCommands.append('cd {}'.format(tmp))
        if args.env:
            remoteCommands.append('export {}'.format(' '.join(args.env)))
        remoteCommands.append(subprocess.list2cmdline(commandLine))

        # Finally, SSH to the remote host and execute all the commands.
        rc = subprocess.call(ssh(args, ' && '.join(remoteCommands)))
        return rc

    finally:
        # Make sure the temporary directory is removed when we're done.
        subprocess.check_call(ssh(args, 'rm -r {}'.format(tmp)))


if __name__ == '__main__':
    exit(main())
