require "spec_helper"

describe ActiveRecord::Turntable::Base do
  context "When installed to ActiveRecord::Base" do
    it "ActiveRecord::Base respond_to 'turntable'" do
      expect(ActiveRecord::Base).to respond_to(:turntable)
    end
  end

  context "When enable turntable on STI models" do
    subject { klass.new }

    context "With a STI parent class" do
      let(:klass) { UserEventHistory }

      its(:connection) { expect { subject }.not_to raise_error }
    end

    context "With a STI subclass" do
      let(:klass) { SpecialUserEventHistory }

      its(:connection) { expect { subject }.not_to raise_error }
    end
  end

  context ".with_shard" do
    subject { klass.with_shard(shard, &block) }

    let(:klass) { User }
    let(:block) {
      -> {}
    }
    let(:shard) { klass.turntable_cluster.shards.first }

    context "call with Shard object"
    it { expect { subject }.not_to raise_error }
  end
end
