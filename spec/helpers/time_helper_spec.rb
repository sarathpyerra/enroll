require "rails_helper"

RSpec.describe TimeHelper, :type => :helper do
  let(:person) { FactoryGirl.create(:person, :with_consumer_role) }
  let(:hbx_enrollment) { FactoryGirl.create(:hbx_enrollment) }

  describe "time remaining in words" do
    it "counts 90 days from user creating date" do
      expect(helper.time_remaining_in_words(person.created_at)).to eq("95 days")
    end
  end

  describe "earliest date for terminating enrollment" do
    it "counts -6 days from enrollment effective date"
      hbx_enrollment.effective_on = TimeKeeper.date_of_record - 7.days
      hbx_enrollment.save
      expect(set_date_min_to_effective_on(hbx_enrollment, TimeKeeper.date_of_record)).to eq("-6D")
    end
  end
