*** Settings ***
Resource         ../../Resources/setuplogin.robot
Resource         AdvancedSearchKeywords.robot
Resource         ../../Resources/Variables.robot
Resource        ../FlexUI - Create/CreateMenuKeywords.robot
Resource        ../FlexUI - Vehicle/VehicleUIKeywords.robot
Test Setup       Login on the new Flex Portal
Suite Setup      Open Flex Portal
Suite Teardown   Close Flex Portal
Test Teardown    Logout Flex
Force Tags       AdvancedSearch

*** Test Cases ***
FLXPRM-241
    [Tags]    FLXPRM-241
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-241
    ...    Given the current search criteria is only boolean field
    ...    When the search is attempted
    ...    Then it shows the error message "Please add search criteria other than True/False values." and search is halted
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Address
    Select a boolean condition field from Conditions box
    Click on Search button
    Validate the displayed message        Please add search criteria other than True


FLXPRM-242
    [Tags]    FLXPRM-242
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-242
    ...    Given the current search criteria having more than one boolean fields conditions.
    ...    When the search is attempted
    ...    Then it shows the error message "Please add search criteria other than True/False values." and search is halted
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Address
    Select a boolean condition field from Conditions box
    Click Add Condition button
    Select a second boolean condition field from Conditions box
    Click on Search button
    Validate the displayed message        Please add search criteria other than True


FLXPRM-243
    [Tags]    FLXPRM-243
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-243
    ...    Given the current search criteria is boolean + non boolean condition fields
    ...    When the search is attempted
    ...    Then it not showing the error message "Please add search criteria other than True/False values." and search is halted
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Address
    Select a boolean condition field from Conditions box
    Click Add Condition button
    Select a no boolean condition field from Conditions box
    Click on Search button
    Wait until search ends
    Validate the search result


FLXPRM-244
    [Tags]    FLXPRM-244
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-244
    ...    Given the current search criteria is some boolean + non boolean condition fields
    ...    When the search is attempted
    ...    Then it not showing the error message "Please add search criteria other than True/False values." and search is halted
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Address
    Select a boolean condition field from Conditions box
    Click Add Condition button
    Select a no boolean condition field from Conditions box
    Click Add Condition button
    Select a third boolean condition field from Conditions box
    Click on Search button
    Wait until search ends
    Validate the search result


FLXPRM-311
    [Tags]    FLXPRM-311
        [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-311
    ...    Given the user is in the Advanced Search Feature of Flex.
    ...    And the user chooses a search type
    ...    When the user clicks on a search field that is of type lookup table
    ...    Then The search values displayed in the dropdown are sorted in alphabetical order.
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Contract
    Select the Field from Conditions box       Contract Revenue GL           1
    Select the Operator from Conditions box    Equals                        1
    Select the look up value
    Validate that the search values displayed are sorted in alphabetical order
    Close the list


FLXPRM-337
    [Tags]    FLXPRM-337
        [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-337
    ...    Given the user is in the Advanced Search Feature of Flex.
    ...    And the user chooses a search type and a search condition with included columns containing a lookup table column 
    ...    And the search results are displayed 
    ...    When the user clicks on the arrow icon to sort the lookup table column in the search results grid
    ...    Then The search results are sorted by the description of the lookup table values 
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Contract
    Select the Field from Conditions box       Contract Revenue GL      1
    Select the Operator from Conditions box    Not Equals               1
    Select the Field from Conditions box       Contract                 2
    Click on Search button
    Wait until search ends
    Click on the column Header
    Wait until search ends
    Validate that column is ordered in alphabetical order     Contract Revenue GL


FLXPRM-341
    [Tags]    FLXPRM-341
        [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-341
    ...    Given the user is in the Advanced Search Feature of Flex.
    ...    And the user chooses a valid search type and a valid search condition 
    ...    And the search results are displayed
    ...    When the user first clicks on a column header arrow icon to sort the column in the search results grid
    ...    Then The search results are sorted in the ascending order
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Address
    Select the Field from Conditions box       City           1
    Select the Operator from Conditions box    Begins With    1
    Input the value on the field               C
    Click on Search button
    Wait until search ends
    Click on the column Header
    Wait until search ends
    Validate that column is ordered in alphabetical order     City


FLXPRM-342
    [Tags]    FLXPRM-342
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-342
    ...    Given the user is in the Advanced Search Feature of Flex.
    ...    And the user chooses a valid search type and a valid search condition 
    ...    And the search results are displayed 
    ...    When the user clicks on the column header arrow icon the second time to sort the column in the search results grid
    ...    Then The search results are sorted in the descending order and the down arrow as well indicates to the user the sort option
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name     Address
    Select the Field from Conditions box       City            1
    Select the Operator from Conditions box    Is Not Blank    1
    Click on Search button
    Wait until search ends
    Click on the column Header
    Wait until search ends
    Click on the column Header
    Wait until search ends
    Validate that column is ordered in descending order        City 


FLXPRM-347
    [Tags]    FLXPRM-347
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-347
    ...    Given the user is in the Advanced Search Feature of Flex.
    ...    And the user chooses a valid search type and *multiple* search conditions 
    ...    And the search results are displayed 
    ...    Then The search results are sorted by the first search condition column in ascending order 
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Address
    Select the Field from Conditions box       City           1
    Select the Operator from Conditions box    Begins With    1
    Input the value on the field               C
    Click Add Condition button
    Select the Field from Conditions box       Country        2
    Select the Operator from Conditions box    Is Not Blank   2
    Click on Search button
    Wait until search ends
    Validate that column is ordered in pre-defined alphabetical order    City


FLXPRM-375
    [Tags]    FLXPRM-375
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-375
    ...    Given I have selected a Search Type in the Advanced Search feature of New Flex 
    ...    And a valid search criteria and search conditions are selected and searched upon
    ...    And the search Results  have currency values 
    ...    Then the Search Results that have currency values are displayed in the Currency Format ($X.XX )
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name     Contract
    Select the Field from Conditions box       Contract Fee    1
    Select the Operator from Conditions box    Greater Than    1
    Input the value on the field                               14
    Click on Search button
    Wait until search ends
    Validate that the currency has the correct formatting


FLXPRM-697
    [Tags]    FLXPRM-697
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-697
    ...    Given the record exists in the database
    ...    When a change is made to the drivers license number field without updating any value 
    ...    Then the record in the database is updated and the drivers license number field encrypted and updated 
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Customer
    Select the Field from Conditions box       Drivers License           1
    Select the Operator from Conditions box    Is Not Blank              1
    Click on Search button
    Wait until search ends
    click on the first element found for the search    Drivers License
    Wait until search ends                     
    Click on Edit button
    Fill in field info                         DriversLicense            size=0
    Click Save button


FLXPRM-882
    [Tags]    FLXPRM-882
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-882
    ...    Given there are no matching records based on the search criteria.
    ...    When I hit search
    ...    Then display “No records to display.”
    Click on Advanced Search from the left menu
    Read file and validate information for an invalid sheet         Invalid_Boolean


FLXPRM-900
    [Tags]    FLXPRM-900
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-900
    ...    Given there are no matching records based on the search criteria.
    ...    When I hit search
    ...    Then display “You must have at least one condition and column defined.”
    Click on Advanced Search from the left menu
    Read file and validate information for an invalid sheet         Invalid_String


FLXPRM-886
    [Tags]    FLXPRM-886
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-886
    ...    Given there are no matching records based on the search criteria.
    ...    When I hit search
    ...    Then display “You must have at least one condition and column defined.”
    Click on Advanced Search from the left menu
    Read file and validate information for an invalid sheet         Invalid_Number


FLXPRM-888
    [Tags]    FLXPRM-888
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-888
    ...    Given there are no matching records based on the search criteria.
    ...    When I hit search
    ...    Then display “You must have at least one condition and column defined.”
    Click on Advanced Search from the left menu
    Read file and validate information for an invalid sheet         Invalid_Date


FLXPRM-899
    [Tags]    FLXPRM-899
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-899
    ...    Given I have a valid search criteria in at least one of the fields displayed
    ...    When I hit search
    ...    Then display the results in table format using the selected columns
    Click on Advanced Search from the left menu
    Read file and validate information for a valid sheet        Valid_String


FLXPRM-885
    [Tags]    FLXPRM-885
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-885
    ...    Given I have a valid search criteria in at least one of the fields displayed
    ...    When I hit search
    ...    Then display the results in table format using the selected columns
    Click on Advanced Search from the left menu
    Read file and validate information for a valid sheet        Valid_Number


FLXPRM-887
    [Tags]    FLXPRM-887
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-887
    ...    Given I have a valid search criteria in at least one of the fields displayed
    ...    When I hit search
    ...    Then display the results in table format using the selected columns
    Click on Advanced Search from the left menu
    Read file and validate information for a valid sheet        Valid_Date


FLXPRM-889
    [Tags]    FLXPRM-889
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-889
    ...    Given I have a valid search criteria in at least one of the fields displayed
    ...    When I hit search
    ...    Then display the results in table format using the selected columns
    Click on Advanced Search from the left menu
    Read file and validate information for a valid boolean sheet        Valid_Boolean


FLXPRM-813
    [Tags]    FLXPRM-813
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-813
    ...    Given I have selected the Search Type as “Email Address” in the Advanced Search feature of New Flex
    ...    And a valid search criteria in at least one of the fields is selected with the Operator and the Value field 
    ...    And combined with Or condition with another field selected with the Operator and the Value fields 
    ...    And the selected fields are selected by default in the Included Columns 
    ...    When I hit search
    ...    Then the results are displayed in table format using the selected columns and the results reflect the Or condition of the search fields
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Address
    Select the Field from Conditions box       Customer UID   1
    Select the Operator from Conditions box    Is Not Blank   1
    Click Add Condition button
    Choose the OR condition
    Select the Field from Conditions box       Address UID    2
    Select the Operator from Conditions box    Is Not Blank   2
    Click on Search button
    Wait until search ends
    Validate the search result


FLXPRM-816
    [Tags]    FLXPRM-816
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-816
    ...    Given there are no matching records based on the Search criteria chosen in the Email Address advanced search
    ...    When I hit search 
    ...    Then the message "No records to display" is displayed to the use 
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Contract
    Select the Field from Conditions box       Contract UID   1
    Select the Operator from Conditions box    Is Blank   1
    Click on Search button
    Wait until search ends
    Validate the displayed message             No records to display.


FLXPRM-789
    [Tags]    FLXPRM-789
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-789
    ...    Given I have selected the Search Type as “Email Address” in the Advanced Search feature of New Flex 
    ...    And a valid search criteria in at least one of the fields is selected with the Operator and the Value fields 
    ...    And the selected fields are selected by default in the Included Columns 
    ...    When I hit search
    ...    Then the results are displayed in table format as per the search criteria using the selected columns
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Email Address
    Select the Field from Conditions box       Customer UID   1
    Select the Operator from Conditions box    Equals         1
    Get a valid Uid from table cor_email
    Input the value on the field               ${getUid[0][0]}
    Include column to the search               Email Address
    Include column to the search               Email Address UID
    Include column to the search               Is Active
    Include column to the search               Priority
    Click on Search button
    Wait until search ends
    Compare the values of the results


FLXPRM-1313
    [Tags]    FLXPRM-1313
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1313
    ...    Account Balance Content Manager - Colapse Button
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Customer
    Select the Field from Conditions box       Account Balance           1
    Select the Operator from Conditions box    Greater Than              1
    Input the value on the field               1
    Click on Search button
    Wait until search ends
    click on the first element found for the search    Account Balance
    Wait until search ends   
    Validate that the section has data                 Remaining
    Click the arrow to collapse the section            Account Balance
    Validate that the section was collapsed            Account Balance


FLXPRM-1543
    [Tags]    FLXPRM-1543    TODO    # It's not possible yet to create a Boot/Tow by the new Flex
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1543
    ...    Boot/Tows Content Manager - Colapse Button
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Vehicle
    Select the Field from Conditions box       Vehicle UID           1
    Select the Operator from Conditions box    Is Not Blank          1
    Click on Search button
    Wait until search ends
    click on the first element found for the search    Vehicle UID
    Wait until search ends   
    # Validate that the section has data                 Remaining
    Click the arrow to collapse the section            Boot/Tow
    Validate that the section was collapsed            Boot/Tow


FLXPRM-1577
    [Tags]    FLXPRM-1577    TODO    # It's not possible yet to create a Notes by the new Flex
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1577
    ...    Notes Content Manager - Colapse Button
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Vehicle
    Select the Field from Conditions box       Vehicle UID           1
    Select the Operator from Conditions box    Is Not Blank          1
    Click on Search button
    Wait until search ends
    click on the first element found for the search    Vehicle UID
    Wait until search ends   
    # Validate that the section has data                 Remaining
    Click the arrow to collapse the section            Notes
    Validate that the section was collapsed            Notes


FLXPRM-1574
    [Tags]    FLXPRM-1574    TODO    # It's not possible yet to create a Customers by the new Flex
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1574
    ...    Customers Content Manager - Colapse Button
    Click on Advanced Search from the left menu
    Click on the Search Type dropdown and select the table with a single name    Vehicle
    Select the Field from Conditions box       Vehicle UID           1
    Select the Operator from Conditions box    Is Not Blank          1
    Click on Search button
    Wait until search ends
    click on the first element found for the search    Vehicle UID
    Wait until search ends   
    # Validate that the section has data                 Remaining
    Click the arrow to collapse the section            Customers
    Validate that the section was collapsed            Customers
