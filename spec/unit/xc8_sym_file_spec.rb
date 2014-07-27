require 'spec_helper'

describe RPicSim::Xc8SymFile do
  let (:filename) { 'spec/firmware/xc8/ExampleSym.sym' }

  subject(:sym_file) do
    described_class.new(filename,
      custom_ram_sections: %w{MYRAM},
      custom_code_sections: %w{MYCODE},
      custom_eeprom_sections: %w{MYEEPROM},
    )
  end

  it 'gets the addresses right' do
    expect(sym_file.symbols[:_varAt67]).to eq 0x67
    expect(sym_file.symbols_in_ram[:_varAt67]).to eq 0x67
  end

  def test_ram_var(varname, expected_address = nil)
    expect(sym_file.symbols[varname]).to be
    expect(sym_file.symbols_in_ram[varname]).to be
    expect(sym_file.symbols_in_eeprom[varname]).to eq nil
    expect(sym_file.symbols_in_program_memory[varname]).to eq nil
  end

  def test_code_var(varname, expected_address = nil)
    expect(sym_file.symbols[varname]).to be
    expect(sym_file.symbols_in_ram[varname]).to eq nil
    expect(sym_file.symbols_in_eeprom[varname]).to eq nil
    expect(sym_file.symbols_in_program_memory[varname]).to be
  end

  def test_eeprom_var(varname)
    expect(sym_file.symbols[varname]).to be
    expect(sym_file.symbols_in_ram[varname]).to eq nil
    expect(sym_file.symbols_in_eeprom[varname]).to be
    expect(sym_file.symbols_in_program_memory[varname]).to eq nil
  end

  ram_sections = %w{ABS COMRAM BIGRAM RAM SFR FARRAM MYRAM}
  ram_sections += 8.times.map { |n| "BANK#{n}" }
  ram_sections.each do |section|
    it "reports variables in #{section} as RAM" do
      test_ram_var("_varIn#{section}".to_sym)
    end
  end

  code_sections = %w{CODE CONST IDLOC SMALLCONST MEDIUMCONST MYCODE}
  code_sections.each do |section|
    it "reports variables in #{section} as code" do
      test_code_var("_varIn#{section}".to_sym)
    end
  end

  eeprom_sections = %w{EEDATA MYEEPROM}
  eeprom_sections.each do |section|
    it "reports variables in #{section} as EEPROM" do
      test_eeprom_var("_varIn#{section}".to_sym)
    end
  end

  it 'can process a SYM file that actually came from XC8' do
    filename = Firmware::Xc8DistDir + 'TestXC8.sym'
    expect { described_class.new(filename) }.to_not raise_error
  end
end
