Capybara.ignore_hidden_elements = false

module BrokerWorld
  def broker(*traits)
    attributes = traits.extract_options!
    @broker ||= FactoryGirl.create :user, *traits, attributes
  end

  def broker_agency(*traits)
    attributes = traits.extract_options!
    @broker_agency ||= FactoryGirl.create :broker , *traits, attributes
  end

end

World(BrokerWorld)

Given (/^that a broker exists$/) do
  broker_agency
  broker :with_family, :broker_with_person, organization: broker_agency
end

And(/^the broker is signed in$/) do
  login_as broker, scope: :user
end

When(/^he visits the Roster Quoting tool$/) do
  visit my_quotes_broker_agencies_quotes_path
end

When(/^click on the New Quote button$/) do
  click_link 'New Quote'
end


When(/^click on the Upload Employee Roster button$/) do
  click_link "Upload Employee Roster"
end

When(/^the broker clicks on the Select File to Upload button$/) do
  within '.upload_csv' do
    attach_file('employee_roster_file', "#{Rails.root}/spec/test_data/employee_roster_import/Employee_Roster_sample.csv")
    find('html div#modal-wrapper div.employee-upload form.upload_csv label.select.btn.btn-primary.btn-br').trigger("click")
  end
end

Then(/^the broker should see the data in the table$/) do
  #expect(page).to have_selector("input#quote_quote_households_attributes_0_family_id[value=\"1\"]")
  #expect(page).to have_selector("input#quote_quote_households_attributes_1_family_id[value=\"2\"]")
  #expect(page).to have_selector('div.panel.panel-default div input.uidatepicker', count: 4)
  #expect(page).to have_selector("#quote_quote_households_attributes_0_quote_members_attributes_0_dob[value=\"03/14/2016\"]")
end

When(/^broker enters valid information$/) do
  fill_in 'quote[quote_name]', with: 'Test Quote'
  fill_in 'quote[quote_households_attributes][0][quote_members_attributes][0][dob]', with: "11/11/1991"
  select "Employee", :from => "quote_quote_households_attributes_0_quote_members_attributes_0_employee_relationship"
  fill_in 'quote[quote_households_attributes][0][quote_members_attributes][0][first_name]', with: "John"
  fill_in 'quote[quote_households_attributes][0][quote_members_attributes][0][last_name]', with: "Bandari"
end

When(/^the broker clicks on the Save Changes button$/) do
  find('.interaction-click-control-save-changes').trigger 'click'
end

Then(/^the broker should see a successful message$/) do
  expect(page).to have_content('Successfully updated the employee roster')
end

Then(/^the broker clicks on Back to Quotes button$/) do
  find('.interaction-click-control-back-to-quotes').trigger 'click'
end

Then(/^the broker clicks delete button$/) do
  find('#close_button').trigger 'click'
end

Then(/^the quote should be deleted$/) do
  page.should have_no_content('Test Quote')
end