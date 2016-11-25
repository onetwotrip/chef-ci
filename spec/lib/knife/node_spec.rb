require 'spec_helper'

describe Node do
  describe '.new' do
    before :each do
      allow_any_instance_of(Node).to receive(:run_with_out).with(
        include('knife node show')
      ).and_return '{}'
    end
    it 'Raise ArgumentError wit wrong args' do
      expect { described_class.new                      }.to raise_error(ArgumentError) # No args
      expect { described_class.new(autogen: 'gen_name') }.to raise_error(ArgumentError) # autogen without symbol *
      expect { described_class.new(name: '*')           }.to raise_error(ArgumentError) # name with dangerous symbol *
      expect { described_class.new(name: 'test')        }.to raise_error(ArgumentError) # name with short name
      described_class.new(name: 'test-name')
    end
    it 'with :name arg' do
      node = described_class.new(name: 'test_node')
      expect(node.name).to eq 'test-node'
    end
    it 'with :role arg' do
      node = described_class.new(autogen: 'gen_name-*')
      expect(node.name).to match(/gen-name-(\w{6})/)
    end
  end

  describe '.status' do
    it 'falsey by default' do
      allow_any_instance_of(Node).to receive(:run_with_out).with(
        include('knife node show')
      ).and_return '{}'
      node = described_class.new(name: 'test_name')
      expect(node.status).to be_falsey
    end
    it 'truthy if nodeup passed' do
      node = described_class.new(autogen: 'gen_name-*')
      allow_any_instance_of(Kernel).to receive(:system).with(include('knife linode server create'), any_args).and_return true
      node.create(flavor: 2, template: 'bootstrap_tmp')
      expect(node.status).to be_truthy
    end
    {
      SystemExit => 'ExitMsg',
      StandardError => 'ErrorMsg',
    }.each do |err, err_msg|
      it "falsey if nodeup failed with #{err_msg}" do
        node = described_class.new(autogen: 'gen_name-*')
        allow_any_instance_of(Node).to receive(:run_with_log).with(
          include('linode server create')
        ).and_raise(err, err_msg)
        cmd = proc { node.create(flavor: 3, template: 'bootstrap_tmp') }
        expect(cmd).to output(/#{err_msg}/).to_stdout
        expect(cmd).to output(/#{err.to_s}/).to_stdout
        expect(node.status).to be_falsey
      end
    end
  end

  describe '.delete' do
    node = described_class.new(autogen: 'gen_name-*')
    it 'truthy on delete' do
      [
        %w(linode server delete),
        %w(node delete),
        %w(client delete),
      ].each do |knife_cmd|
        allow(Chef::Knife).to receive(:run).with(
          array_including(knife_cmd),
          instance_of(Hash)
        ).and_return true
      end
      expect(node.delete).to be_truthy
    end
  end
end
