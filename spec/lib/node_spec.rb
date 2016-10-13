require 'spec_helper'
describe Node do
  before do
    @params = { bootstrap_version: '12.6.0',
                server_url: 'https://chef_url.com',
                role: 'api-search',
                environment: 'linode_alpha',
                image: '124',
                kernel: '138',
                datacenter: '7',
                flavor: '4',
                num_nodes: '1',
                linode_api_key: nil,
                chef_key: nil,
    }
    [
      %w(linode server delete),
      %w(node delete),
    ].each do |knife_cmd|
      allow(Chef::Knife).to receive(:run).with(
        array_including(knife_cmd),
        instance_of(Hash)
      ).and_return true
    end
  end
  before :each do
    @node = described_class.new
  end

  describe '.status' do
    it 'falsey by default' do
      expect(@node.status).to be_falsey
    end
    it 'truthy if nodeup passed' do
      expect(Chef::Knife).to receive(:run).with(
        array_including(%w(linode server create))
      ).and_return true
      expect(Chef::Knife).to receive(:run).with(
        array_including(%w(tag create maintain))
      ).and_return true
      expect { @node.create @params }.to_not output.to_stdout
      expect(@node.status).to be_truthy
      expect(@node.name_colorize).to eql @node.name.green
    end
    {
      SystemExit => 'SystemExitMsg',
      StandardError => 'StandardErrorMsg',
    }.each do |err, err_msg|
      it "falsey if nodeup failed with #{err_msg}" do
        expect(Chef::Knife).to receive(:run).with(
          array_including(%w(linode server create))
        ).and_raise(err, err_msg)
        expect { @node.create @params }.to output(/#{err_msg}/).to_stdout
        expect(@node.status).to be_falsey
      end
    end
  end
end
