require 'spec_helper'

describe "compute instances" do

  let(:project){ "dummy-ghost-333" }
  let(:env_name) { "sandbox99" }
  let(:network1_name) { "network-#{env_name}" }
  let(:vm1_internal_ip){ "10.79.62.91" }
  let(:vm1_external_ip){ "104.199.133.228" }
  let(:vm1_name) { "#{env_name}-trdb01" }
  let(:vm1_res) do
    {
      "kind" => "compute#instance",
      "id" => "2412312837024968987",
      "creationTimestamp" => "2015-03-24T20:00:38.623-07:00",
      "zone" => "https://www.googleapis.com/compute/v1/projects/#{project}/zones/asia-east1-c",
      "status" => "RUNNING",
      "name" => vm1_name,
      "tags" => {
        "items" => [
          "trdb",
          env_name
        ],
        "fingerprint" => "lomVJaZHa7M="
      },
      "machineType" => "https://www.googleapis.com/compute/v1/projects/#{project}/zones/asia-east1-c/machineTypes/n1-standard-4",
      "canIpForward" => false,
      "networkInterfaces" => [
        {
          "network" => "https://www.googleapis.com/compute/v1/projects/#{project}/global/networks/#{network1_name}",
          "networkIP" => vm1_internal_ip,
          "name" => "nic0",
          "accessConfigs" => [
            {
              "kind" => "compute#accessConfig",
              "type" => "ONE_TO_ONE_NAT",
              "name" => "external-nat",
              "natIP" => vm1_external_ip,
            }
          ]
        }
      ],
      "disks" => [
        {
          "kind" => "compute#attachedDisk",
          "index" => 0,
          "type" => "PERSISTENT",
          "mode" => "READ_WRITE",
          "source" => "https://www.googleapis.com/compute/v1/projects/#{project}/zones/asia-east1-c/disks/#{vm1_name}",
          "deviceName" => vm1_name,
          "boot" => true,
          "interface" => "SCSI"
        },
        {
          "kind" => "compute#attachedDisk",
          "index" => 1,
          "type" => "PERSISTENT",
          "mode" => "READ_WRITE",
          "source" => "https://www.googleapis.com/compute/v1/projects/#{project}/zones/asia-east1-c/disks/data-#{vm1_name}",
          "deviceName" => "data-#{vm1_name}",
          "interface" => "SCSI"
        }
      ],
      "metadata" => {
        "kind" => "compute#metadata",
        "fingerprint" => "MEddF-5gsPY="
      },
      "serviceAccounts" => [
        {
          "email" => "826897881949-compute@developer.gserviceaccount.com",
          "scopes" => [
            "https://www.googleapis.com/auth/bigquery"
          ]
        }
      ],
      "selfLink" => "https://www.googleapis.com/compute/v1/projects/#{project}/zones/asia-east1-c/instances/#{vm1_name}",
      "scheduling" => {
        "onHostMaintenance" => "MIGRATE",
        "automaticRestart" => true
      },
      "cpuPlatform" => "Intel Ivy Bridge"
    }
  end

  context "instance methods" do
    let(:find_arg_ptn) { %r!gcloud compute instances list #{vm1_name}\s+--format json\s+--project #{project}! }

    subject{ Milc::Gcloud::Resource.lookup(project, :compute, :instances) }
    describe :find do
      it "found" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([vm1_res].to_json)
        r = subject.find(vm1_name)
        expect(r).to eq vm1_res
      end

      it "not found" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([].to_json)
        r = subject.find(vm1_name)
        expect(r).to be_nil
      end
    end

    let(:vm_args) do
      {
        disks: [
          {name: "#{env_name}-trdb01"     , device_name: "#{env_name}-trdb01"     , mode: "rw", boot: "yes"},
          {name: "data-#{env_name}-trdb01", device_name: "data-#{env_name}-trdb01", mode: "rw", boot: "no" },
        ],
        zone: "asia-east1-c", machine_type: "n1-standard-4", scopes: "bigquery",
        network: "network-#{env_name}", tags: "trdb #{env_name}"
      }
    end

    describe :create do
      # gcloud compute instances create #{env_name}-trdb01 --disk name=#{env_name}-trdb01 device-name=#{env_name}-trdb01 mode=rw boot=yes --disk name=data-#{env_name}-trdb01 device-name=data-#{env_name}-trdb01 mode=rw boot=no --zone asia-east1-c --machine-type n1-standard-4 --scopes bigquery --network network-#{env_name} --tags trdb #{env_name}  --format json --project #{project}
      let(:create_arg_ptn){ %r!gcloud compute instances create #{vm1_name}\s+--disk name=#{env_name}-trdb01 device-name=#{env_name}-trdb01 mode=rw boot=yes --disk name=data-#{env_name}-trdb01 device-name=data-#{env_name}-trdb01 mode=rw boot=no --zone asia-east1-c --machine-type n1-standard-4 --scopes bigquery --network network-#{env_name} --tags trdb #{env_name}\s+--format json\s+--project #{project}! }
      it "when not created yet" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([].to_json)
        expect(Milc::Gcloud.backend).to receive(:execute).with(create_arg_ptn).and_return([].to_json)
        subject.create(vm1_name, vm_args)
      end
      it "when already created" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([vm1_res].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute instances create/)
        subject.create(vm1_name, vm_args)
      end
    end

    describe :update do
      it "when not created yet" do
        expect{
          subject.update(vm1_name, vm_args)
        }.to raise_error(NotImplementedError)
      end
    end

    describe :delete do
      let(:delete_arg_ptn){ %r!gcloud compute instances delete #{vm1_name}\s+--format json\s+--project #{project}! }
      it "when not created yet" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([].to_json)
        expect(Milc::Gcloud.backend).to_not receive(:execute).with(/gcloud compute instances delete/)
        subject.delete(vm1_name)
      end
      it "when already created" do
        expect(Milc::Gcloud.backend).to receive(:execute).with(find_arg_ptn).and_return([vm1_res].to_json)
        expect(Milc::Gcloud.backend).to receive(:execute).with(delete_arg_ptn).and_return([].to_json)
        subject.delete(vm1_name)
      end
    end

  end

  context :module_function do
    describe :first_internal_ip do
      it do
        expect(Milc::Gcloud::Compute::Instances.first_internal_ip(vm1_res["networkInterfaces"])).to eq vm1_internal_ip
      end
    end
    describe :first_external_ip do
      it do
        expect(Milc::Gcloud::Compute::Instances.first_external_ip(vm1_res["networkInterfaces"])).to eq vm1_external_ip
      end
    end
    
  end
end
