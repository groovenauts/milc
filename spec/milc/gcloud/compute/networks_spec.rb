require 'spec_helper'

describe "compute networks" do
  let(:query_options){ {returns: :stdout, logging: :stderr} }
  let(:ope_options){ {returns: :none, logging: :both} }

  let(:project){ "dummy-ghost-333" }
  let(:network1_name) { "network-sandbox99" }
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

  context "instance methods" do
    let(:find_arg_ptn) { %r!gcloud compute networks list #{network1_name}\s+--format json\s+--project #{project}! }

    subject{ Milc::Gcloud::Resource.lookup(project, :compute, :networks) }
    describe :find do
      it "found" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn, query_options).and_return([network1_res].to_json)
        r = subject.find(network1_name)
        expect(r).to eq network1_res
      end

      it "not found" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn, query_options).and_return([].to_json)
        r = subject.find(network1_name)
        expect(r).to be_nil
      end

      it "using logger_pipe" do
        expect(LoggerPipe).to receive(:run).with(Milc.logger, find_arg_ptn, query_options.merge(dry_run: be_falsey)).and_return([network1_res].to_json)
        r = subject.find(network1_name)
        expect(r).to eq network1_res
      end
    end

    describe :create do
      let(:create_arg_ptn){ %r!gcloud compute networks create #{network1_name}\s+--range \"10.0.0.0\/8\"\s+--format json\s+--project #{project}! }
      it "when not created yet" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn, query_options).and_return([].to_json)
        expect(Milc::Gcloud.backend).to receive(:execute).with(create_arg_ptn, ope_options).and_return([].to_json)
        subject.create(network1_name, range: "\"10.0.0.0/8\"")
      end
      it "when already created" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn, query_options).and_return([network1_res].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute networks create/, ope_options)
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
      let(:delete_arg_ptn){ %r!gcloud compute networks delete #{network1_name}\s+--format json\s+--project #{project}! }
      it "when not created yet" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn, query_options).and_return([].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute networks delete/, ope_options)
        subject.delete(network1_name, range: "\"10.0.0.0/8\"")
      end
      it "when already created" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn, query_options).and_return([network1_res].to_json)
        expect(Milc::Gcloud.backend).to receive(:execute).with(delete_arg_ptn, ope_options).and_return([].to_json)
        subject.delete(network1_name)
      end
    end

  end
end
