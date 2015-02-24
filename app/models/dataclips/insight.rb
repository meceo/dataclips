module Dataclips
  class Insight < ActiveRecord::Base
    validates :clip_id, presence: true

    def to_param
      hash_id
    end

    def self.find_by_hash_id(hash_id)
      find_by(id: Dataclips.hashids.decode(hash_id))
    end

    def hash_id
      return unless persisted?
      Dataclips.hashids.encode(id)
    end
  end
end