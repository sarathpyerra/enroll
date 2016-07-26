FactoryGirl.define do
  factory :quote do
    claim_code Faker::Lorem.characters(8)
  end
  # trait :with_household_and_members do 
  # 	quote_household {[FactoryGirl.build(:quote_household)]}
  # end
end
