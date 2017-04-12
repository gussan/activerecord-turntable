require "spec_helper"

describe ActiveRecord::Turntable::ConnectionProxy do
  context "When initialized" do
    subject { ActiveRecord::Turntable::ConnectionProxy.new(User, cluster) }

    let(:cluster) { ActiveRecord::Turntable::Cluster.new(ActiveRecord::Base.turntable_config[:clusters][:user_cluster]) }

    its(:master_connection) { is_expected.to eql(ActiveRecord::Base.connection) }
  end

  context "User insert with id" do
    it "is saved to user_shard_1 with id = 1" do
      user = User.new
      user.id = 1
      expect {
        user.save!
      }.not_to raise_error
    end

    it "is saved to user_shard_2 with id = 30000" do
      user = User.new
      user.id = 30000
      expect {
        user.save!
      }.not_to raise_error
    end

    it "is saved to user_shard_2 with id = 30000 with SQL injection attack" do
      user = User.new
      user.id = 30000
      user.nickname = "hogehgoge'00"
      expect {
        user.save!
      }.not_to raise_error
      user.reload
    end

    it "is saved the same string when includes escaped string" do
      user = User.new
      user.id = 30000
      user.nickname = "hoge@\n@\\@@\\nhoge\\\nhoge\\n"
      user.save!
      user.reload
      expect(user.nickname).to eq("hoge@\n@\\@@\\nhoge\\\nhoge\\n")
    end
  end

  context "When have no users" do
    it "User.#count should be zero" do
      expect(User.count).to be_zero
    end

    it "User.all should have no item" do
      expect(User.all.to_a).to have(0).items
    end
  end

  context "When have 2 Users in different shards" do
    before do
      @user1 = User.new
      @user1.id = 1
      @user1.save!
      @user2 = User.new
      @user2.id = 30000
      @user2.save!
    end

    it "is saved to user_shard_1 with id = 1" do
      @user1.nickname = "foobar"
      expect {
        @user1.save!
      }.not_to raise_error
    end

    it "is saved to user_shard_2 with id = 30000" do
      @user2.nickname = "hogehoge"
      expect {
        @user2.save!
      }.not_to raise_error
    end

    it "User.where('id IN (1, 30000)') returns 2 record" do
      expect(User.where(id: [1, 30000]).all.size).to eq(2)
    end

    it "User.count is 2" do
      expect(User.count).to eq(2)
    end

    it "User.all returns 2 User object" do
      expect(User.all.size).to eq(2)
    end
  end

  context "When calling with_all" do
    before do
      @user1 = User.new
      @user1.id = 1
      @user1.nickname = "user1"
      @user1.save!
      @user2 = User.new
      @user2.id = 30000
      @user2.nickname = "user2"
      @user2.save!
    end

    context "do; User.count; end" do
      subject {
        User.connection.with_all do
          User.count
        end
      }

      it { is_expected.to have(3).items }

      it "returns User.count of each shards" do
        expect(subject[0]).to eq(1)
        expect(subject[1]).to eq(1)
        expect(subject[2]).to eq(0)
      end
    end

    context "call with true" do
      context "block raises error" do
        subject {
          User.connection.with_all(true) do
            raise "Unko Error"
          end
        }

        it { expect { subject }.not_to raise_error }
        it { is_expected.to have(3).items }
        it "collection " do
          expect(subject).to all(be_instance_of(RuntimeError))
        end
      end
    end
  end

  context "When calling exists? with shard_key" do
    before do
      @user1 = User.new
      @user1.id = 1
      @user1.nickname = "user1"
      @user1.save!
      @user2 = User.new
      @user2.id = 30000
      @user2.nickname = "user2"
      @user2.save!
    end

    subject { User.exists?(id: 1) }

    it { is_expected.to be_truthy }
  end

  context "When calling exists? with non-existed shard_key" do
    before do
      @user1 = User.new
      @user1.id = 1
      @user1.nickname = "user1"
      @user1.save!
      @user2 = User.new
      @user2.id = 30000
      @user2.nickname = "user2"
      @user2.save!
    end

    subject { User.exists?(id: 3) }

    it { is_expected.to be_falsey }
  end

  context "When calling exists? with non shard_key" do
    before do
      @user1 = User.new
      @user1.id = 1
      @user1.nickname = "user1"
      @user1.save!
      @user2 = User.new
      @user2.id = 30000
      @user2.nickname = "user2"
      @user2.save!
    end

    subject { User.exists?(nickname: "user2") }

    it { is_expected.to be_truthy }
  end

  context "When calling exists? with non-existed non shard_key" do
    before do
      @user1 = User.new
      @user1.id = 1
      @user1.nickname = "user1"
      @user1.save!
      @user2 = User.new
      @user2.id = 30000
      @user2.nickname = "user2"
      @user2.save!
    end

    subject { User.exists?(nickname: "user999") }

    it { is_expected.to be_falsey }
  end

  context "#data_source_exists?" do
    before do
      @user1 = User.new
      @user1.id = 1
      @user1.nickname = "user1"
      @user1.save!
      @user2 = User.new
      @user2.id = 30000
      @user2.nickname = "user2"
      @user2.save!
    end

    subject { User.connection.data_source_exists?(:users) }

    it { is_expected.to be_truthy }
  end
end
