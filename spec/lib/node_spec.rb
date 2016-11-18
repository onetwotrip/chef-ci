require 'spec_helper'

describe Node do
  before do
    @params = SimpleConfig.deploy
    @params.save = true
  end

  describe '.new' do
    it 'Raise ArgumentError without args' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
    it 'with :name arg' do
      node = described_class.new(name: 'test_node')
      expect(node.name).to eq 'test-node'
    end
    it 'with :role arg' do
      node = described_class.new(autogen: 'gen_name')
      expect(node.name).to match(/gen-name-(\w{6})/)
    end
  end

  describe '.status' do
    node = described_class.new(name: 'test_name')
    it 'falsey by default' do
      expect(node.status).to be_falsey
    end
    it 'truthy if nodeup passed' do
      node = described_class.new(autogen: 'gen_name')
      allow_any_instance_of(Node).to receive(:system_call).with(
        include('linode server create')
      ).and_return 'System_call output'
      expect(Chef::Knife).to receive(:run).with(
        array_including(%w(tag create maintain))
      ).and_return true
      node.create @params
      expect(node.output).to eq 'System_call output'
      expect(node.status).to be_truthy
    end
    {
      SystemExit => 'ExitMsg',
      StandardError => 'ErrorMsg',
    }.each do |err, err_msg|
      it "falsey if nodeup failed with #{err_msg}" do
        allow_any_instance_of(Node).to receive(:system_call).with(
          include('linode server create')
        ).and_raise(err, err_msg)
        node.create @params
        expect(node.output).to include err_msg
        expect(node.output).to include err.to_s
        expect(node.status).to be_falsey
      end
    end
  end

  describe '.delete' do
    node = described_class.new(autogen: 'gen_name')
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

  describe '.system_call' do
    node = described_class.new(autogen: 'gen_name')
    it 'return true with stdout' do
      expect(node).to receive(:system_call).with(any_args).and_return 'stdout'
      node.send(:system_call, 'echo stdout; true')
    end
    it 'return true with stderr' do
      expect(node).to receive(:system_call).with(any_args).and_return 'stderr'
      node.send(:system_call, '>&2 echo stderr; true')
    end
    it 'return false with stdout' do
      expect { node.send(:system_call, 'echo stdout; false') }.to raise_error(RuntimeError, /stdout/)
    end
    it 'return false with stderr' do
      expect { node.send(:system_call, '>&2 echo stderr; false') }.to raise_error(RuntimeError, /stderr/)
    end
  end
end
