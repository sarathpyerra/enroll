Feature: Broker Assigns a General Agency to an Employer

  Scenario: A Broker Assigns a General Agency to an Employer
    Given a general agency, approved, confirmed, exists
    And a broker exists
    And an employer exists for ga

    When the employer login in
    Then the employer should see the home of employer
    When the employer click the link of brokers
    Then the employer should see no active broker
    When the employer click on Browse Brokers button
    Then the employer should see broker agencies index view
    Then the employer should see the broker agency
    When the employer clicks select broker button
    Then the employer should see confirm modal dialog box
    When the employer confirms broker selection
    Then the employer should see broker selected successful message
    When the employer clicks on the Brokers tab
    Then the employer should see broker active for the employer
    Then the employer logs out

    When the broker login in
    Then the broker should see the home of broker
    When the broker visits their Employers page
    And selects the general agency from dropdown for the employer
    Then the broker should see assign successful message
    When the broker visits their Employers page
    Then the employer will be assigned that general agency

    When the broker click the link of clear assign
    When the broker visits their Employers page
    Then the employer will not be assigned that general agency

    When the broker visits their general agencies page
    Then the broker should see the list of general agencies
    And the broker set default ga
    When the broker visits their Employers page
    Then the employer will be assigned that general agency
    Then the broker logs out

    When the ga login in
    Then the ga should see the home of ga
    When the ga visits their Employers page
    Then the ga should see the employer

    When the ga click the name of employer
    Then the ga should see the home of employer
    When the ga clicks on the Brokers tab
    Then the ga should see the broker

    When the ga click the back link
    Then the ga should see the home of ga

  Scenario: A Broker have the ability to assign default GA for any future employers that come on board
    Given a general agency, approved, confirmed, exists
    And a broker exists
    And an employer exists for ga

    When the broker login in
    Then the broker should see the home of broker
    When the broker visits their general agencies page
    Then the broker should see the list of general agencies
    And the broker set default ga
    Then the broker logs out

    When the employer login in
    Then the employer should see the home of employer
    When the employer click the link of brokers
    Then the employer should see no active broker
    When the employer click on Browse Brokers button
    Then the employer should see broker agencies index view
    Then the employer should see the broker agency
    When the employer clicks select broker button
    Then the employer should see confirm modal dialog box
    When the employer confirms broker selection
    Then the employer should see broker selected successful message
    When the employer clicks on the Brokers tab
    Then the employer should see broker active for the employer
    Then the employer logs out

    When the ga login in
    Then the ga should see the home of ga
    When the ga visits their Employers page
    Then the ga should see the employer

  Scenario: A Broker have the ability to assign default GA for any old employers
    Given a general agency, approved, confirmed, exists
    Given another general agency-ga2, approved, confirmed, exists
    And a broker exists
    And an employer exists for ga

    When the employer login in
    Then the employer should see the home of employer
    When the employer click the link of brokers
    Then the employer should see no active broker
    When the employer click on Browse Brokers button
    Then the employer should see broker agencies index view
    Then the employer should see the broker agency
    When the employer clicks select broker button
    Then the employer should see confirm modal dialog box
    When the employer confirms broker selection
    Then the employer should see broker selected successful message
    When the employer clicks on the Brokers tab
    Then the employer should see broker active for the employer
    Then the employer logs out

    When the broker login in
    Then the broker should see the home of broker
    When the broker visits their Employers page
    Then the employer will not be assigned that general agency

    # assign to ga2
    And selects the GA2 from dropdown for the employer
    Then the broker should see assign successful message
    When the broker visits their Employers page
    Then the employer has assigned to GA2

    # set default ga(ga1)
    When the broker visits their general agencies page
    Then the broker should see the list of general agencies
    And the broker set default ga
    When the broker visits their Employers page
    Then the employer will be assigned that general agency
    Then the broker logs out

    When the ga2 login in
    Then the ga2 should see the home of ga
    When the ga2 visits their Employers page
    Then the ga2 should not see the employer

  Scenario: If broker already assigned some ERs, while the Broker remove his default GA, that particular GA should automatically loss the permission to those ERs
    Given a general agency, approved, confirmed, exists
    And a broker exists
    And an employer exists for ga

    When the employer login in
    Then the employer should see the home of employer
    When the employer click the link of brokers
    Then the employer should see no active broker
    When the employer click on Browse Brokers button
    Then the employer should see broker agencies index view
    Then the employer should see the broker agency
    When the employer clicks select broker button
    Then the employer should see confirm modal dialog box
    When the employer confirms broker selection
    Then the employer should see broker selected successful message
    When the employer clicks on the Brokers tab
    Then the employer should see broker active for the employer
    Then the employer logs out

    When the broker login in
    Then the broker should see the home of broker
    When the broker visits their Employers page
    And selects the general agency from dropdown for the employer
    Then the broker should see assign successful message
    When the broker visits their Employers page
    Then the employer will be assigned that general agency

    When the broker visits their general agencies page
    Then the broker should see the list of general agencies
    When the broker click the link of clear default ga
    When the broker visits their Employers page
    Then the employer will not be assigned that general agency
