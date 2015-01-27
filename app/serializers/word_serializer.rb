class WordSerializer < BaseSerializer
  attributes :id, :name
  has_many :entries, serializer: EntrySerializer
  has_many :proposals, serializer: MiniProposalSerializer

  #params :hi
end
