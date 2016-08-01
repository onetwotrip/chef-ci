require 'spec_helper'
describe Node do
  before do
    allow(Chef::Knife).to receive(:run).with(
      array_including(%w(linode server delete)),
      instance_of(Hash)
    ).and_return true
  end
  before :each do
    @name = 'node'
    @node = described_class.new bootstrap_version: '12.6.0',
                                server_url: 'https://chef_url.com',
                                role: 'api-search',
                                environment: 'linode_alpha',
                                image: '124',
                                kernel: '138',
                                datacenter: '7',
                                flavor: '4',
                                num_nodes: '1',
                                linode_api_key: nil,
                                chef_key: nil
  end

  describe '.status' do
    it 'falsey by default' do
      expect(@node.status).to be_falsey
    end
    it 'truthy if nodeup passed' do
      expect(Chef::Knife).to receive(:run).with(
        array_including(%w(linode server create))
      ).and_return true
      expect { @node.deploy }.to_not output.to_stdout
      expect(@node.status).to be_truthy
      expect(@node.name_colorize).to eql @node.name.green
      expect(@node.fail?).to be_falsey
    end
    it 'falsey if nodeup failed' do
      expect(Chef::Knife).to receive(:run).with(
        array_including(%w(linode server create))
      ).and_raise('STUB Raise')
      expect { @node.deploy }.to output(/STUB Raise/).to_stdout
      expect(@node.name_colorize).to eql @node.name.red
      expect(@node.status).to be_falsey
      expect(@node.fail?).to be_truthy
    end
    it 'falsey if nodeup failed with SystemExit' do
      expect(Chef::Knife).to receive(:run).with(
        array_including(%w(linode server create))
      ).and_raise(SystemExit, 'SystemExit')
      expect { @node.deploy }.to output(/SystemExit/).to_stdout
      expect(@node.status).to be_falsey
    end
    it 'falsey if nodeup failed with StandartError' do
      expect(Chef::Knife).to receive(:run).with(
        array_including(%w(linode server create))
      ).and_raise(StandardError, 'StandardError')
      expect { @node.deploy }.to output(/StandardError/).to_stdout
      expect(@node.status).to be_falsey
    end
  end
end
