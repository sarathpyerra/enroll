Feature: Families Index View
	As an HBX admin, any functionality that I need to do for a family enrollment
  should be done from the families index view.

	Scenario: View Families Data Table
		Given I have logged in as an HBX-Admin
    And I click the Families link from the hbx_profiles page
    Then I should see the Family Index page
    And it should have a column with the heading "Name"
    And it should have a column with the heading "SSN"
    And it should have a column with the heading "DOB"
    And it should have a column with the heading "HBX ID"
    #And it should have a column with the heading "Family Count"
    And it should have a column with the heading "Registered?"
    And it should have a column with the heading "Consumer?"
    And it should have a column with the heading "Employee?"
