require_relative '../spec_helper'

describe 'rcs03a program structure' do
  subject(:call_stack_info) do
    RPicSim::CallStackInfo.hash_from_program_file(
      Firmware::NestedSubroutines.program_file,
      [0, 4]
    )
  end

  it 'can double check itself' do
    call_stack_info[0].double_check!
    call_stack_info[4].double_check!
  end

  it 'can report the reachable instructions' do
    expect(call_stack_info[0].reachable_instructions.map(&:address).sort).to eq \
      [0, 32, 33, 34, 35, 36, 37, 64, 65, 66, 96, 97, 128, 129, 256, 257, 258]
  end

  it 'reports the max stack depth for mainline code is 5' do
    expect(call_stack_info[0].max_depth).to eq 5
  end

  it 'reports the max stack depths for the ISR is 1' do
    expect(call_stack_info[4].max_depth).to eq 1
  end

  it 'reports back traces containing each instruction in the path' do
    addrs = call_stack_info[4].worst_case_code_paths.map(&:addresses)
    expect(addrs).to eq [[4, 0x100], [4, 0x100, 0x101], [4, 0x100, 0x101, 0x102]]

    addrs = call_stack_info[0].worst_case_code_paths.map(&:addresses)
    expect(addrs).to eq [
      [0, 32, 33, 36,     64, 65, 96, 128, 256],
      [0, 32, 34, 35, 36, 64, 65, 96, 128, 256],
      [0, 32, 33, 36,     64, 65, 96, 128, 256],
      [0, 32, 34, 35, 36, 64, 65, 96, 128, 256],
      [0, 32, 33, 36,     64, 65, 96, 128, 256, 257],
      [0, 32, 34, 35, 36, 64, 65, 96, 128, 256, 257],
      [0, 32, 33, 36,     64, 65, 96, 128, 256, 257],
      [0, 32, 34, 35, 36, 64, 65, 96, 128, 256, 257],
      [0, 32, 33, 36,     64, 65, 96, 128, 256, 257, 258],
      [0, 32, 34, 35, 36, 64, 65, 96, 128, 256, 257, 258],
      [0, 32, 33, 36,     64, 65, 96, 128, 256, 257, 258],
      [0, 32, 34, 35, 36, 64, 65, 96, 128, 256, 257, 258],
    ]
  end

  it 'can report filtered code paths' do
    addrs = call_stack_info[0].worst_case_code_paths_filtered.map(&:interesting_addresses)
    expect(addrs).to eq [
      [0, 36, 64, 65, 96, 128, 256],
    ]
  end

  it 'can report filtered code paths as a string with #worst_case_code_paths_filtered_report' do
    report = call_stack_info[0].worst_case_code_paths_filtered_report
    expect(report).to eq <<END
CodePath:
Instruction(0x0000, GOTO 0x20)
Instruction(0x0024 = start2, CALL 0x40)
Instruction(0x0040 = foo, CALL 0x41)
Instruction(0x0041 = goo, CALL 0x60)
Instruction(0x0060 = hoo, CALL 0x80)
Instruction(0x0080 = ioo, CALL 0x100)
Instruction(0x0100 = joo, CLRF 0x7)


END
  end

  it 'does not have a gigantic #inspect' do
    expect(call_stack_info[0].inspect).to eq '#<RPicSim::CallStackInfo:root=#<RPicSim::Instruction:0x0000, GOTO 0x20>>'
  end

end
