require 'spec_helper'

describe KnifeFabric do
  before :each do
    @knife_fabric = described_class.new
  end
  describe 'run_with_log' do
    it 'return true with stdout' do
      expect(@knife_fabric.send(:run_with_log, 'printf stdout; true')).to be_truthy
      expect(File.read(@knife_fabric.logfile)).to eq 'stdout'
    end
    it 'return true with stderr' do
      expect(@knife_fabric.send(:run_with_log, '>&2 printf stderr; true')).to be_truthy
      expect(File.read(@knife_fabric.logfile)).to eq 'stderr'
    end
    it 'return false with stdout' do
      expect(@knife_fabric.send(:run_with_log, 'printf stdout; false')).to be_falsey
      expect(File.read(@knife_fabric.logfile)).to eq 'stdout'
    end
    it 'return false with stderr' do
      expect(@knife_fabric.send(:run_with_log, '>&2 printf stderr; false')).to be_falsey
      expect(File.read(@knife_fabric.logfile)).to eq 'stderr'
    end
  end
  describe 'run_with_out' do
    it 'return true with stdout' do
      expect(@knife_fabric.send(:run_with_out, 'printf stdout; true')).to eq 'stdout'
    end
    it 'return true with stderr' do
      expect(@knife_fabric.send(:run_with_out, '>&2 printf stderr; true')).to eq 'stderr'
    end
    it 'return false with stdout' do
      expect(@knife_fabric.send(:run_with_out, 'printf stdout; false')).to eq 'stdout'
    end
    it 'return false with stderr' do
      expect(@knife_fabric.send(:run_with_out, '>&2 printf stderr; false')).to eq 'stderr'
    end
  end

  describe 'rescue_knife' do
    it 'status true' do
      expect(@knife_fabric.status).to be_truthy
    end
    it 'check fail status' do
      block = proc { raise RuntimeError }
      @knife_fabric.send(:rescue_knife, &block)
      expect(@knife_fabric.status).to be_falsey
    end
  end
end
