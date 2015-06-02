class Quiz
  include Mongoid::Document
  include AASM
  include BelongsToLang

  field :slug, type: String
  field :title, type: String
  field :instructions, type: String

  validates :title, presence: true
  validates :slug,  presence: true

  embeds_many :quiz_questions, cascade_callbacks: true
  embeds_many :quiz_results, cascade_callbacks: true

  mount_uploader :image, ImageUploader
  field :image_link, type: String
  field :image_citation, type: String


  accepts_nested_attributes_for :quiz_questions, allow_destroy: true
  accepts_nested_attributes_for :quiz_results, allow_destroy: true

  field :state, type: String

  index({state: 1})
  index({state: 1, slug: 1})

  aasm :column => :state do
    state :draft, initial: true
    state :rejected
    state :published

    event :publish do
      transitions from: :draft, to: :published
    end

    event :reject do
      transitions from: :draft, to: :published
    end
  end

end
