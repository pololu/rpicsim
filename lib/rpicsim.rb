require_relative 'rpicsim/version'
require_relative 'rpicsim/sim'
require_relative 'rpicsim/call_stack_info'
require_relative 'rpicsim/xc8_sym_file'

# TODO: deprecate or remove ProgramFile#labels, prolly replaced with Sim#labels
# TODO: allow stack traces to use labels that didn't come from the ProgramFile
# TODO: probably deprecate ProgramFile.address_description and do that somewhere else
#  because the ProgramFile no longer has a complete idea of all the symbols
