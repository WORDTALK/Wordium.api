class Activity
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  index({user_id: 1})
  field :username, type: String
  belongs_to :word
  index({word_id: 1})
  field :word_name, type: String
  belongs_to :proposal
  index({proposal_id: 1})
  index({type: 1})

  index({created_at: -1})

  field :comment, type: String

  before_create :set_cached_fields

  def set_cached_fields
    if word
      self.word_name = word.name
    elsif proposal
      self.word_name = proposal.word_name
    end
    if user
      self.username = user.username
    end
    true
  end
end