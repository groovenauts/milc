require 'spec_helper'

describe Milc::Gcloud::Compute::FirewallRules do

  let(:project){ "dummy-ghost-333" }
  let(:network1_name) { "network-sandbox99" }
  let(:fw1_name) { "#{network1_name}-allow-rabbitmq" }
  let(:fw1_res) do
    {
      "kind" => "compute#firewall",
      "selfLink" => "https://www.googleapis.com/compute/v1/projects/#{project}/global/firewalls/#{fw1_name}",
      "id" => "13439680969600378738",
      "creationTimestamp" => "2015-03-24T18:44:38.294-07:00",
      "name" => fw1_name,
      "description" => "",
      "network" => "https://www.googleapis.com/compute/v1/projects/#{project}/global/networks/#{network1_name}",
      "sourceRanges" => [
        "0.0.0.0"
      ],
      "targetTags" => [
        "trmq"
      ],
      "allowed" => [
        {
          "IPProtocol" => "tcp",
          "ports" => [
            "5672"
          ]
        }
      ]
    }
  end

  context "instance methods" do
    let(:find_arg_ptn) { %r!gcloud compute firewall-rules list #{fw1_name}\s+--format json\s+--project #{project}! }

    subject{ Milc::Gcloud::Resource.lookup(project, :compute, :"firewall-rules") }
    describe :find do
      it "found" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([fw1_res].to_json)
        r = subject.find(fw1_name)
        expect(r).to eq fw1_res
      end

      it "not found" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([].to_json)
        r = subject.find(fw1_name)
        expect(r).to be_nil
      end
    end

    describe :create do
      let(:create_arg_ptn){ %r!gcloud compute firewall-rules create #{fw1_name}\s+--allow tcp:5672 --source-ranges 0.0.0.0 --target-tags trmq\s+--format json\s+--project #{project}! }
      it "when not created yet" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([].to_json)
        expect(Milc::Gcloud.backend).to receive(:execute).with(create_arg_ptn).and_return([].to_json)
        subject.create(fw1_name, allow: "tcp:5672", source_ranges: "0.0.0.0", target_tags: "trmq")
      end
      it "when already created" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([fw1_res].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute firewall-rules create/)
        subject.create(fw1_name, allow: "tcp:5672", source_ranges: "0.0.0.0", target_tags: "trmq")
      end
      it "when already created but updated" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).
                                         and_return([fw1_res.merge("sourceRanges" => "10.0.0.0/8")].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute firewall-rules create/)
        update_arg_ptn = %r!gcloud compute firewall-rules update #{fw1_name}\s+--allow tcp:5672 --source-ranges 0.0.0.0 --target-tags trmq\s+--format json\s+--project #{project}!
        expect(Milc::Gcloud.backend).to receive(:execute).with(update_arg_ptn)
        subject.create(fw1_name, allow: "tcp:5672", source_ranges: "0.0.0.0", target_tags: "trmq")
      end

      it "when already created but updated with icmp" do
        allowed = [{"IPProtocol" => "icmp"}]
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).
                                         and_return([fw1_res.merge("sourceRanges" => "10.0.0.0/8", "allowed" => allowed)].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute firewall-rules create/)
        update_arg_ptn = %r!gcloud compute firewall-rules update #{fw1_name}\s+--allow icmp --source-ranges 0.0.0.0 --target-tags trmq\s+--format json\s+--project #{project}!
        expect(Milc::Gcloud.backend).to receive(:execute).with(update_arg_ptn)
        subject.create(fw1_name, allow: "icmp", source_ranges: "0.0.0.0", target_tags: "trmq")
      end
    end

    describe :update do
      let(:create_arg_ptn){ %r!gcloud compute firewall-rules create #{fw1_name}\s+--allow tcp:5672 --source-ranges 0.0.0.0 --target-tags trmq\s+--format json\s+--project #{project}! }
      it "when not created yet" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute firewall-rules create/)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute firewall-rules update/)
        expect{
          subject.update(fw1_name, allow: "tcp:5672", source_ranges: "0.0.0.0", target_tags: "trmq")
        }.to raise_error(/not found.+#{fw1_name}/)
      end
      it "when already created and not updated" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([fw1_res].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute firewall-rules update/)
        subject.update(fw1_name, allow: "tcp:5672", source_ranges: "0.0.0.0", target_tags: "trmq")
      end
      let(:update_arg_ptn){ %r!gcloud compute firewall-rules update #{fw1_name}\s+--allow tcp:5672 --source-ranges 0.0.0.0 --target-tags trmq\s+--format json\s+--project #{project}! }
      it "when already created but updated" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).
                                         and_return([fw1_res.merge("sourceRanges" => "10.0.0.0/8")].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute firewall-rules create/)
        expect(Milc::Gcloud.backend).to receive(:execute).with(update_arg_ptn)
        subject.update(fw1_name, allow: "tcp:5672", source_ranges: "0.0.0.0", target_tags: "trmq")
      end
    end

    describe :delete do
      let(:delete_arg_ptn){ %r!gcloud compute firewall-rules delete #{fw1_name}\s+--format json\s+--project #{project}! }
      it "when not created yet" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute firewall-rules delete/)
        subject.delete(fw1_name)
      end
      it "when already created" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([fw1_res].to_json)
        expect(Milc::Gcloud.backend).to receive(:execute).with(delete_arg_ptn).and_return([].to_json)
        subject.delete(fw1_name)
      end
    end

  end
end
