ActiveRecord::Turntable.configure do
  cluster :user_cluster do
    algorithm :range_bsearch

    sequence to: :user_seq

    shard   0...100, to: :user_shard_1
    shard 100...200, to: :user_shard_2
    shard 200...300, to: :user_shard_3
  end
end
