require 'spec_helper'

describe Milc::Gcloud::Resource do

  let(:project){ "dummy-ghost-333" }

  describe :lookup do

    it "by strings" do
      r = Milc::Gcloud::Resource.lookup(project, "compute", "instances")
      expect(r).to be_a Milc::Gcloud::Resource
    end

    it "by symbols" do
      r = Milc::Gcloud::Resource.lookup(project, :compute, :instances)
      expect(r).to be_a Milc::Gcloud::Resource
    end

    it "invalid service name" do
      expect{
        Milc::Gcloud::Resource.lookup(project, :cloud, :instances)
      }.to raise_error(/cloud.+not found/)
    end

    it "invalid resource name" do
      expect{
        Milc::Gcloud::Resource.lookup(project, :cloud, :vm)
      }.to raise_error(/cloud.+not found/)
    end
  end
end
