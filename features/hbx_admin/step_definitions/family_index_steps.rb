Given(/^I click the Families link from the hbx_profiles page$/) do
  visit "/"
  click_link 'HBX Portal'
  click_link 'Families'
end

Then(/^I should see the Family Index page$/) do
  sleep 3
  expect(page).to have_content('Families')
end

Then(/^it should have a column with the heading "([^"]*)"$/) do |arg1|
  expect(page).to have_content(arg1)
end
