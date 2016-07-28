FactoryGirl.define do
	factory :quote_benefit_group do
		title "My Benefit Group"
		default  true

		after(:create) do |q, evaluator|
			build(:quote_relationship_benefit, quote_benefit_group: q)
		end

	end
end
