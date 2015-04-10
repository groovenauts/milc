# coding: utf-8
require 'spec_helper'

describe Milc::Base do
  let(:query_options){ {returns: :stdout, logging: :stderr} }
  let(:ope_options){ {returns: :none, logging: :both} }

  CONFIG_PATH = File.expand_path("../sample.yml", __FILE__)
  CONFIG      = YAML.load_file(CONFIG_PATH)
  PROJECT     = CONFIG["PROJECT"]

  NETWORK = "network-sandbox99"


  class MgcloudSample # 冪等サポートあり
    include Milc::Base
    def process
      mgcloud "compute networks create #{NETWORK}", range: "\"10.0.0.0/8\""
    end
  end

  class GcloudSample # 冪等サポートなし
    include Milc::Base
    def process
      gcloud "compute networks create #{NETWORK} --range \"10.0.0.0/8\""
    end
  end

  class JsonGcloudSample # 冪等サポートなしJSON形式
    include Milc::Base
    def process
      json_gcloud "compute networks create #{NETWORK} --range \"10.0.0.0/8\""
    end
  end

  class AnsibleSample
    include Milc::Base
    def process
      ansible_playbook "-i inventory_filename config.yml"
    end
  end

  let(:project){ PROJECT }
  let(:network1_name){ NETWORK }
  let(:network1_res) do
    {
      "kind" => "compute#network",
     "selfLink" => "https://www.googleapis.com/compute/v1/projects/#{project}/global/networks/#{network1_name}",
     "id" => "14337132035283116762",
     "creationTimestamp" => "2015-03-24T18:43:34.777-07:00",
     "name" => network1_name,
     "IPv4Range" => "10.0.0.0/8",
     "gatewayIPv4" => "10.0.0.1"
    }
  end

  describe :help do
    subject{ MgcloudSample.new }
    it do
      expect($stderr).to receive(:puts).with("Usage: #{File.basename($0)} -c CONF_FILE")
      expect(subject).to receive(:exit).with(1).and_raise("exit 1")
      expect{
        subject.run([])
      }.to raise_error("exit 1")
    end
  end

  describe :dry_run do
    subject{ MgcloudSample.new }
    around do |example|
      Milc.dry_run = false
      begin
        example.call
      ensure
        Milc.dry_run = false
      end
    end

    it :false do
      Milc.dry_run = false
      expect(subject.dry_run).to eq false
    end

    it :true do
      Milc.dry_run = true
      expect(subject.dry_run).to eq true
    end
  end

  describe :mgcloud do
    let(:find_arg_ptn) { %r!gcloud compute networks list #{network1_name}\s+--format json\s+--project #{project}! }
    subject{ MgcloudSample.new }
    let(:create_arg_ptn){ %r!gcloud compute networks create #{network1_name}\s+--range \"10.0.0.0\/8\"\s+--format json\s+--project #{project}! }
    it "when not created yet" do
      expect(LoggerPipe).to receive(:run).with(Milc.logger, find_arg_ptn  , query_options.merge(dry_run: be_falsey)).and_return([].to_json)
      expect(LoggerPipe).to receive(:run).with(Milc.logger, create_arg_ptn,   ope_options.merge(dry_run: be_falsey)).and_return([].to_json)
      subject.run(["-c", CONFIG_PATH])
    end
    it "when already created" do
      expect(LoggerPipe).to     receive(:run).with(Milc.logger, find_arg_ptn, query_options.merge(dry_run: be_falsey)).and_return([network1_res].to_json)
      expect(LoggerPipe).to_not receive(:run).with(Milc.logger, /gcloud compute networks create/, ope_options.merge(dry_run: be_falsey))
      subject.run(["-c", CONFIG_PATH])
    end
  end

  describe :gcloud do
    subject{ GcloudSample.new }
    let(:create_arg_ptn){ %r!gcloud compute networks create #{network1_name}\s+--range \"10.0.0.0\/8\"\s+--project #{project}! }
    it do
      expect(LoggerPipe).to receive(:run).with(Milc.logger, create_arg_ptn, ope_options.merge(dry_run: be_falsey))
      subject.run(["-c", CONFIG_PATH])
    end
  end

  describe :json_gcloud do
    subject{ JsonGcloudSample.new }
    let(:create_arg_ptn){ %r!gcloud compute networks create #{network1_name}\s+--range \"10.0.0.0\/8\"\s+--format json\s+--project #{project}! }
    it do
      expect(LoggerPipe).to receive(:run).with(Milc.logger, create_arg_ptn, query_options.merge(dry_run: be_falsey))
      subject.run(["-c", CONFIG_PATH])
    end
  end

  describe :ansible_playbook do
    subject{ AnsibleSample.new }
    it do
      expect(LoggerPipe).to receive(:run).with(Milc.logger, /ansible-playbook -i inventory_filename config.yml/, ope_options.merge(dry_run: be_falsey))
      subject.run(["-c", CONFIG_PATH])
    end
  end

end
