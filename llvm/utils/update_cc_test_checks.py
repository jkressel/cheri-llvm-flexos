#!/usr/bin/env python3
'''A utility to update LLVM IR CHECK lines in C/C++ FileCheck test files.

Example RUN lines in .c/.cc test files:

// RUN: %clang -emit-llvm -S %s -o - -O2 | FileCheck %s
// RUN: %clangxx -emit-llvm -S %s -o - -O2 | FileCheck -check-prefix=CHECK-A %s

Usage:

% utils/update_cc_test_checks.py --llvm-bin=release/bin test/a.cc
% utils/update_cc_test_checks.py --clang=release/bin/clang /tmp/c/a.cc
'''

import argparse
import collections
import distutils.spawn
import json
import os
import shlex
import string
import subprocess
import sys
import re
import tempfile

from UpdateTestChecks import asm, common

ADVERT = '// NOTE: Assertions have been autogenerated by '

CHECK_RE = re.compile(r'^\s*//\s*([^:]+?)(?:-NEXT|-NOT|-DAG|-LABEL)?:')

SUBST = {
    '%clang': [],
    '%clang_cc1': ['-cc1'],
    '%clangxx': ['--driver-mode=g++'],
    '%cheri_cc1': ['-cc1', "-triple=cheri-unknown-freebsd"],
    '%cheri_clang': ['-target', 'cheri-unknown-freebsd'],
    '%cheri128_cc1': ['-cc1', "-triple=cheri-unknown-freebsd", "-target-cpu", "cheri128", "-cheri-size", "128"],
    '%cheri256_cc1': ['-cc1', "-triple=cheri-unknown-freebsd", "-target-cpu", "cheri256", "-cheri-size", "256"],
    '%cheri_purecap_clang': ['-target', 'cheri-unknown-freebsd', '-mabi=purecap'],
    '%cheri_purecap_cc1': ['-cc1', "-triple=cheri-unknown-freebsd", "-target-abi", "purecap"],
    '%cheri128_purecap_cc1': ['-cc1', "-triple=cheri-unknown-freebsd", "-target-abi", "purecap", "-target-cpu", "cheri128", "-cheri-size", "128"],
    '%cheri256_purecap_cc1': ['-cc1', "-triple=cheri-unknown-freebsd", "-target-abi", "purecap", "-target-cpu", "cheri256", "-cheri-size", "256"],
}

def get_line2spell_and_mangled(args, clang_args):
  ret = {}
  # Use clang's JSON AST dump to get the mangled name
  json_dump_args = [args.clang, *clang_args, '-fsyntax-only', '-o', '-']
  if '-cc1' not in json_dump_args:
    # For tests that invoke %clang instead if %clang_cc1 we have to use
    # -Xclang -ast-dump=json instead:
    json_dump_args.append('-Xclang')
  json_dump_args.append('-ast-dump=json')
  common.debug('Running', ' '.join(json_dump_args))
  status = subprocess.run(json_dump_args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  if status.returncode != 0:
    sys.stderr.write('Failed to run ' + ' '.join(json_dump_args) + '\n')
    sys.stderr.write(status.stderr.decode())
    sys.stderr.write(status.stdout.decode())
    sys.exit(2)

  # Parse the clang JSON and add all children of type FunctionDecl.
  # TODO: Should we add checks for global variables being emitted?
  def parse_clang_ast_json(node):
    node_kind = node['kind']
    # Recurse for the following nodes that can contain nested function decls:
    if node_kind in ('NamespaceDecl', 'LinkageSpecDecl', 'TranslationUnitDecl'):
      for inner in node['inner']:
        parse_clang_ast_json(inner)
    # Otherwise we ignore everything except functions:
    if node['kind'] != 'FunctionDecl':
      return
    if node.get('isImplicit') is True and node.get('storageClass') == 'extern':
      common.debug('Skipping builtin function:', node['name'], '@', node['loc'])
      return
    common.debug('Found function:', node['kind'], node['name'], '@', node['loc'])
    line = node['loc'].get('line')
    # If there is no line it is probably a builtin function -> skip
    if line is None:
      common.debug('Skipping function without line number:', node['name'], '@', node['loc'])
      return
    spell = node['name']
    mangled = node.get('mangledName', spell)
    ret[int(line)-1] = (spell, mangled)

  ast = json.loads(status.stdout.decode())
  if ast['kind'] != 'TranslationUnitDecl':
    common.error('Clang AST dump JSON format changed?')
    sys.exit(2)
  parse_clang_ast_json(ast)

  for line, func_name in sorted(ret.items()):
    common.debug('line {}: found function {}'.format(line+1, func_name), file=sys.stderr)
  if not ret:
    common.warn('Did not find any functions using', ' '.join(json_dump_args))
  return ret


def config():
  parser = argparse.ArgumentParser(
      description=__doc__,
      formatter_class=argparse.RawTextHelpFormatter)
  parser.add_argument('--llvm-bin', help='llvm $prefix/bin path')
  parser.add_argument('--clang',
                      help='"clang" executable, defaults to $llvm_bin/clang')
  parser.add_argument('--clang-args',
                      help='Space-separated extra args to clang, e.g. --clang-args=-v')
  parser.add_argument('--opt',
                      help='"opt" executable, defaults to $llvm_bin/opt')
  parser.add_argument(
      '--functions', nargs='+', help='A list of function name regexes. '
      'If specified, update CHECK lines for functions matching at least one regex')
  parser.add_argument(
      '--x86_extra_scrub', action='store_true',
      help='Use more regex for x86 matching to reduce diffs between various subtargets')
  parser.add_argument('--function-signature', action='store_true',
                      help='Keep function signature information around for the check line')
  parser.add_argument('tests', nargs='+')
  args = common.parse_commandline_args(parser)
  args.clang_args = shlex.split(args.clang_args or '')

  if args.clang is None:
    if args.llvm_bin is None:
      args.clang = 'clang'
    else:
      args.clang = os.path.join(args.llvm_bin, 'clang')
  if not distutils.spawn.find_executable(args.clang):
    print('Please specify --llvm-bin or --clang', file=sys.stderr)
    sys.exit(1)

  # Determine the builtin includes directory so that we can update tests that
  # depend on the builtin headers. See get_clang_builtin_include_dir() and
  # use_clang() in llvm/utils/lit/lit/llvm/config.py.
  try:
    builtin_include_dir = subprocess.check_output(
      [args.clang, '-print-file-name=include']).decode().strip()
    SUBST['%clang_cc1'] = ['-cc1', '-internal-isystem', builtin_include_dir,
                           '-nostdsysteminc']
  except subprocess.CalledProcessError:
    common.warn('Could not determine clang builtins directory, some tests '
                'might not update correctly.')

  if args.opt is None:
    if args.llvm_bin is None:
      args.opt = 'opt'
    else:
      args.opt = os.path.join(args.llvm_bin, 'opt')
  if not distutils.spawn.find_executable(args.opt):
    # Many uses of this tool will not need an opt binary, because it's only
    # needed for updating a test that runs clang | opt | FileCheck. So we
    # defer this error message until we find that opt is actually needed.
    args.opt = None

  return args


def get_function_body(args, filename, clang_args, extra_commands, prefixes, triple_in_cmd, func_dict):
  # TODO Clean up duplication of asm/common build_function_body_dictionary
  # Invoke external tool and extract function bodies.
  raw_tool_output = common.invoke_tool(args.clang, clang_args, filename)
  for extra_command in extra_commands:
    extra_args = shlex.split(extra_command)
    with tempfile.NamedTemporaryFile() as f:
      f.write(raw_tool_output.encode())
      f.flush()
      if extra_args[0] == 'opt':
        if args.opt is None:
          print(filename, 'needs to run opt. '
                'Please specify --llvm-bin or --opt', file=sys.stderr)
          sys.exit(1)
        extra_args[0] = args.opt
      raw_tool_output = common.invoke_tool(extra_args[0],
                                           extra_args[1:], f.name)
  if '-emit-llvm' in clang_args:
    common.build_function_body_dictionary(
            common.OPT_FUNCTION_RE, common.scrub_body, [],
            raw_tool_output, prefixes, func_dict, args.verbose, args.function_signature)
  else:
    print('The clang command line should include -emit-llvm as asm tests '
          'are discouraged in Clang testsuite.', file=sys.stderr)
    sys.exit(1)


def main():
  args = config()
  script_name = os.path.basename(__file__)
  autogenerated_note = (ADVERT + 'utils/' + script_name)

  for filename in args.tests:
    with open(filename) as f:
      input_lines = [l.rstrip() for l in f]

    first_line = input_lines[0] if input_lines else ""
    if 'autogenerated' in first_line and script_name not in first_line:
      common.warn("Skipping test which wasn't autogenerated by " + script_name, filename)
      continue

    if args.update_only:
      if not first_line or 'autogenerated' not in first_line:
        common.warn("Skipping test which isn't autogenerated: " + filename)
        continue

    # Extract RUN lines.
    run_lines = common.find_run_lines(filename, input_lines)

    # Build a list of clang command lines and check prefixes from RUN lines.
    run_list = []
    line2spell_and_mangled_list = collections.defaultdict(list)
    for l in run_lines:
      commands = [cmd.strip() for cmd in l.split('|')]

      triple_in_cmd = None
      m = common.TRIPLE_ARG_RE.search(commands[0])
      if m:
        triple_in_cmd = m.groups()[0]

      # Apply %clang substitution rule, replace %s by `filename`, and append args.clang_args
      clang_args = shlex.split(commands[0])
      if clang_args[0] not in SUBST:
        print('WARNING: Skipping non-clang RUN line: ' + l, file=sys.stderr)
        continue
      clang_args[0:1] = SUBST[clang_args[0]]
      clang_args = [filename if i == '%s' else i for i in clang_args] + args.clang_args

      # Permit piping the output through opt
      if not (len(commands) == 2 or
              (len(commands) == 3 and commands[1].startswith('opt'))):
        print('WARNING: Skipping non-clang RUN line: ' + l, file=sys.stderr)

      # Extract -check-prefix in FileCheck args
      filecheck_cmd = commands[-1]
      common.verify_filecheck_prefixes(filecheck_cmd)
      if not filecheck_cmd.startswith('FileCheck ') and not filecheck_cmd.startswith('%cheri_FileCheck '):
        print('WARNING: Skipping non-FileChecked RUN line: ' + l, file=sys.stderr)
        continue
      check_prefixes = [item for m in common.CHECK_PREFIX_RE.finditer(filecheck_cmd)
                               for item in m.group(1).split(',')]
      if not check_prefixes:
        check_prefixes = ['CHECK']
      run_list.append((check_prefixes, clang_args, commands[1:-1], triple_in_cmd))

    # Strip CHECK lines which are in `prefix_set`, update test file.
    prefix_set = set([prefix for p in run_list for prefix in p[0]])
    input_lines = []
    with open(filename, 'r+') as f:
      for line in f:
        m = CHECK_RE.match(line)
        if not (m and m.group(1) in prefix_set) and line != '//\n':
          input_lines.append(line)
      f.seek(0)
      f.writelines(input_lines)
      f.truncate()

    # Execute clang, generate LLVM IR, and extract functions.
    func_dict = {}
    for p in run_list:
      prefixes = p[0]
      for prefix in prefixes:
        func_dict.update({prefix: dict()})
    for prefixes, clang_args, extra_commands, triple_in_cmd in run_list:
      common.debug('Extracted clang cmd: clang {}'.format(clang_args))
      common.debug('Extracted FileCheck prefixes: {}'.format(prefixes))

      get_function_body(args, filename, clang_args, extra_commands, prefixes, triple_in_cmd, func_dict)

      # Invoke clang -Xclang -ast-dump=json to get mapping from start lines to
      # mangled names. Forward all clang args for now.
      for k, v in get_line2spell_and_mangled(args, clang_args).items():
        line2spell_and_mangled_list[k].append(v)

    output_lines = [autogenerated_note]
    for idx, line in enumerate(input_lines):
      # Discard any previous script advertising.
      if line.startswith(ADVERT):
        continue
      if idx in line2spell_and_mangled_list:
        added = set()
        for spell, mangled in line2spell_and_mangled_list[idx]:
          # One line may contain multiple function declarations.
          # Skip if the mangled name has been added before.
          # The line number may come from an included file,
          # we simply require the spelling name to appear on the line
          # to exclude functions from other files.
          if mangled in added or spell not in line:
            continue
          if args.functions is None or any(re.search(regex, spell) for regex in args.functions):
            if added:
              output_lines.append('//')
            added.add(mangled)
            common.add_ir_checks(output_lines, '//', run_list, func_dict, mangled,
                                 False, args.function_signature)
      output_lines.append(line.rstrip('\n'))

    # Update the test file.
    with open(filename, 'w') as f:
      for line in output_lines:
        f.write(line + '\n')

  return 0


if __name__ == '__main__':
  sys.exit(main())
