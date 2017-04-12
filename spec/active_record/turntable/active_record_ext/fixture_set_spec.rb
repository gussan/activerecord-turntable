require "spec_helper"

require "active_record"
require "active_record/turntable/active_record_ext/fixtures"

describe ActiveRecord::FixtureSet do
  let(:fixtures_root) { File.join(File.dirname(__FILE__), "../../../fixtures") }
  let(:fixture_file) { File.join(fixtures_root, "cards.yml") }
  let(:cards) { YAML.load(ERB.new(IO.read(fixture_file)).result) }

  before do
    ActiveRecord::FixtureSet.reset_cache
  end

  describe ".create_fixtures" do
    subject { ActiveRecord::FixtureSet.create_fixtures(fixtures_root, "cards") }

    it { is_expected.to be_instance_of(Array) }
    it "creates card records" do
      expect { subject }.to change { Card.count }.from(0).to(cards.size)
    end
  end
end
