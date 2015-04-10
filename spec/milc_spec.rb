require 'spec_helper'

describe Milc do
  it 'has a version number' do
    expect(Milc::VERSION).not_to be nil
  end

  describe :verbose do
    it "default" do
      expect(Milc.verbose).to be_falsey
      expect(Milc.logger.level).to eq Logger::INFO
    end
    it "set true" do
      Milc.verbose = true
      expect(Milc.verbose).to be_truthy
      expect(Milc.logger.level).to eq Logger::DEBUG
    end
    it "set false" do
      Milc.verbose = false
      expect(Milc.verbose).to be_falsey
      expect(Milc.logger.level).to eq Logger::INFO
    end
  end

end
