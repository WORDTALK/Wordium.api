require 'rails_helper'

describe ProposeMeaningChange do

  before do
    @user = create(:user)
    @meaning = create(:meaning)
    @lang = create(:lang)
    @label = create(:label)
  end

  describe "Valid New Meaning Proposal" do
    before :each do
      @def = "To be secretly submissive"
      @p = ProposeMeaningChange.new(user: @user,
                                    meaning: @meaning,
                                    def: @def,
                                    lang: @lang,
                                    example: "I thought the boss was a little subbery")
    end

    it "should be valid" do
      expect(@p).to be_valid
    end

    it "should edit the meaning" do
      @p.save
      original = @meaning.def
      expect(Meaning.where(def: original).count).to eq(1)
      @p.approve!
      expect(Meaning.where(def: original).count).to eq(0)
      expect(Meaning.where(def: @def).count).to eq(1)
      meaning = Meaning.where(def: @def).first
      expect(meaning.accepted_proposal.id).to eq(@p.id)
      expect(meaning.open_proposal).to eq(nil)
    end

    it "shouldn't commit if invalid" do
      count = Meaning.count
      @p.def = ""
      @p.approve!
      expect(Meaning.count).to eq(count)
    end

    it "should clear open_proposal_id if rejected" do
      @p.save
      @p.reject!
      @meaning.reload
      expect(@meaning.open_proposal).to be_nil
    end

    it "should clear open_proposal if accepted" do
      @p.save
      @p.approve!
      @meaning.reload
      expect(@meaning.open_proposal).to be_nil
    end

    it "should clear open_proposal if flagged" do
      @p.save
      @p.flag!
      @meaning.reload
      expect(@meaning.open_proposal).to be_nil
    end

    it "should apply new labels if accepted" do
      expect(@meaning.labels.count).to eq(0)
      @p.labels << @label
      @p.save
      @p.approve!
      @meaning.reload
      expect(@meaning.labels.count).to eq(1)
      expect(@meaning.labels.first.id).to eq(@label.id)
    end

    it "should remove label if the label is proposed to be removed" do
      @two_labels = [@label, create(:label)]
      @meaning.labels << @two_labels
      expect(@meaning.labels.count).to eq(2)
      @p.labels << @label
      @p.save
      @p.approve!
      @meaning.reload
      expect(@meaning.labels.count).to eq(1)
    end

  end

end
