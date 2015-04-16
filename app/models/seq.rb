class Seq
  include Mongoid::Document
  include Mongoid::Timestamps
  include AnagramHelpers

  belongs_to :lang
  belongs_to :wordset
  field :text, as: "t"

  validates :text, :format => { with: /\A[a-zA-Z][a-zA-Z\d\/\-' .]*\z/ } #'
  validates :lang, presence: true
  validate :seq_uniqueness, on: :create

  field :word_length, type: Integer, as: "l"
  index({text: 1, lang_id: 1}, {unique: true})
  index({word_length: 1})

  before_save do |d|
    d.word_length = d.text.length
  end

  def self.lookup(key)
    lang_code, *text = key.split("-")
    lang = Lang.where(code: lang_code).first
    Seq.where(lang: lang, text: text.join("-"), :wordset_id.ne => nil).first
  end

  def seq_uniqueness
    if Seq.where(:lang => lang, text: self.text).any?
      errors.add(:text, "is not unique")
    end
  end

  def key
    "#{lang.code}-#{text}"
  end
end
