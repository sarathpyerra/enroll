Given(/^I am a consumer$/) do
  person_all = FactoryGirl.create(:person, :with_family, :with_consumer_role, :with_employee_role, :male)
  family_all = person_all.primary_family
  FactoryGirl.create(:hbx_profile, :no_open_enrollment_coverage_period, :ivl_2015_benefit_package)
  qle_all = FactoryGirl.create(:qualifying_life_event_kind, market_kind: "shop")
  FactoryGirl.create(:special_enrollment_period, family: family_all, effective_on_kind:"date_of_event", qualifying_life_event_kind_id: qle_all.id)
  all_er_profile = FactoryGirl.create(:employer_profile)
  all_census_ee = FactoryGirl.create(:census_employee, employer_profile: all_er_profile)
  person_all.employee_roles.first.census_employee = all_census_ee
  person_all.employee_roles.first.save!
  family_all = Family.find(family_all.id)
  Caches::PlanDetails.load_record_cache!
end

Given(/^I am already enrolled$/) do
  empty
end

Given(/^my gender is set to male$/) do
  empty
end

When(/^I visit the Families Home Page$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^then I click on the Manage Family link\.$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^male should be selected$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I click female$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I click Save$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^Person was successfully updated appears\.$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^I am an admin$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^the consumer is already enrolled$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^the consumer's gender is set to male$/) do
  pending # Write code here that turns the phrase above into concrete actions
end