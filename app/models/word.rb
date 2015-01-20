class Word
  include Mongoid::Document
  include Mongoid::Timestamps
  include Suggestable
  field :name
  field :word_length, type: Integer, as: "l"
  has_many :entries, autosave: true


  before_save do |d|
    d.word_length = d.name.length
  end

  def self.suggestable_fields
    %w(name)
  end

  def self.suggestable_children
    %w(entries)
  end
  suggestable_validations

  index({:name => 1}, {:unique => true, drop_dups: true})
end
