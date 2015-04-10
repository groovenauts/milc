require 'spec_helper'

describe Milc::Gcloud::Compute::TargetPools do

  let(:project){ "dummy-ghost-333" }
  let(:network1_name) { "network-sandbox99" }
  let(:target_pool1_name) { "lb-pool-sandbox99-rp" }
  let(:target_pool1_res) do
    {
      "kind" => "compute#targetPool",
      "id" => "10846463316428170495",
      "creationTimestamp" => "2015-03-24T19:57:02.297-07:00",
      "name" => target_pool1_name,
      "region" => "https://www.googleapis.com/compute/v1/projects/#{project}/regions/asia-east1",
      "healthChecks" => [
        "https://www.googleapis.com/compute/v1/projects/#{project}/global/httpHealthChecks/#{target_pool1_name.sub(/pool/, 'check')}"
      ],
      "instances" => [
        "https://www.googleapis.com/compute/v1/projects/#{project}/zones/asia-east1-c/instances/rp01",
        "https://www.googleapis.com/compute/v1/projects/#{project}/zones/asia-east1-c/instances/rp02"
      ],
      "selfLink" => "https://www.googleapis.com/compute/v1/projects/#{project}/regions/asia-east1/targetPools/#{target_pool1_name}"
    }
  end

  context "instance methods" do
    let(:find_arg_ptn) { %r!gcloud compute target-pools list #{network1_name}\s+--format json\s+--project #{project}! }

    subject{ Milc::Gcloud::Resource.lookup(project, :compute, "target-pools") }
    describe :find do
      it "found" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([target_pool1_res].to_json)
        r = subject.find(network1_name)
        expect(r).to eq target_pool1_res
      end

      it "not found" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([].to_json)
        r = subject.find(network1_name)
        expect(r).to be_nil
      end

      it "using logger_pipe" do
        expect(LoggerPipe).to receive(:run).with(Milc.logger, find_arg_ptn, dry_run: be_falsey).and_return([target_pool1_res].to_json)
        r = subject.find(network1_name)
        expect(r).to eq target_pool1_res
      end
    end

    describe :create do
      let(:create_arg_ptn){ %r!gcloud compute target-pools create #{network1_name}\s+--range \"10.0.0.0\/8\"\s+--format json\s+--project #{project}! }
      it "when not created yet" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([].to_json)
        expect(Milc::Gcloud.backend).to receive(:execute).with(create_arg_ptn).and_return([].to_json)
        subject.create(network1_name, range: "\"10.0.0.0/8\"")
      end
      it "when already created" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([target_pool1_res].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute target-pools create/)
        subject.create(network1_name, range: "\"10.0.0.0/8\"")
      end
    end

    describe :update do
      it "when not created yet" do
        expect{
          subject.update(network1_name, range: "\"0.0.0.0/0\"")
        }.to raise_error(NotImplementedError)
      end
    end

    describe :delete do
      let(:delete_arg_ptn){ %r!gcloud compute target-pools delete #{network1_name}\s+--format json\s+--project #{project}! }
      it "when not created yet" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute target-pools delete/)
        subject.delete(network1_name, range: "\"10.0.0.0/8\"")
      end
      it "when already created" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([target_pool1_res].to_json)
        expect(Milc::Gcloud.backend).to receive(:execute).with(delete_arg_ptn).and_return([].to_json)
        subject.delete(network1_name)
      end
    end

    describe :add_instances do
      let(:delete_arg_ptn){  }
      it "when already created" do
        ptn = /gcloud compute target-pools add-instances #{target_pool1_name} --instances rp01 --zone asia-east1-c\s+--format json\s+--project #{project}/ 
        expect(Milc::Gcloud.backend).to receive(:execute).with(ptn)
       subject.add_instances(target_pool1_name, instances: "rp01", zone: "asia-east1-c")
      end
    end

  end
end
