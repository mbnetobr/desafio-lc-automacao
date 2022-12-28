*** Settings ***
Library         DatabaseLibrary
Library         RequestsLibrary
Library         Collections
Library         String

Resource    ../../Resources/API.robot
Resource    ../../Resources/Variables.robot

*** Test Cases ***
FLXPRM-5
    [Tags]    P1    FLXPRM-5
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-5
    ...    This test case is designed to validate the Synonym Data endpoint using a GET call via Postman.

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    # Send a query
    ${query}=    Query    SELECT * FROM synonym_text ORDER BY SYN_UID ASC
    Log Many    @{query}
    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/synonyms    status_code=200


FLXPRM-12
    [Tags]    P1    FLXPRM-12
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-12
    ...    This test case is designed to validate the Activity History Events related to an Object though Postman 

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    
    # Send a query to get the Object Uid
    ${getUid}    Query    SELECT * FROM activity_log where ROWNUM < 10 ORDER BY act_uid ASC
    Log Many     @{getUid}
    # Send a query to compare result endpoint with the result database
    ${query}=    Query    SELECT * FROM activity_log WHERE act_source_obj_uid = ${getUid[0][0]} and tab_uid_source_obj_type = 22 ORDER BY act_uid ASC
    Log Many    @{query}

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/activity?tableabbrev=USR&objectuid=${getUid[0][0]}   status_code=200

    # Compare Results
    ${index}    Set Variable  0
    FOR  ${synonym}    IN    @{response["response"]["content"]}
        # Compare UID's
        Should Be True  ${synonym["uid"]}==${query[${index}][0]}
        # Compare Names (Strings need to be in quotes)
        Should Be True  '${synonym["description"]}'=='${query[${index}][5]}'
        ${index}=    Evaluate    ${index} + 1
    END


FLXPRM-17
    [Tags]    P2    FLXPRM-17
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-17
    ...    This test case is designed to validate the Activity History Events related to a Customer Object though Postman 

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    
    # Send a query to get the Entity Uid
    ${entityUid}     Query    SELECT * FROM config_table ORDER BY tab_uid ASC
    Log Many         @{entityUid}

    # Send a query to get the table Uid
    ${objectUid}     Query    SELECT * FROM activity_log WHERE act_source_obj_uid > 1
    Log Many         @{objectUid}

    # Send a query to compare result endpoint with the result database
    ${query}=      Query    SELECT * FROM activity_log where act_source_obj_uid = ${objectUid[0][3]} AND tab_uid_source_obj_type = ${entityUid[0][0]} ORDER BY act_uid ASC
    Log Many       @{query}

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/activity?tableabbrev=${entityUid[0][1]}&objectuid=${objectUid[0][3]}   status_code=200

    # Compare Results
    ${index}    Set Variable  0
    FOR  ${synonym}    IN    @{response["response"]["content"]}
        # Compare UID's
        Should Be True  ${synonym["uid"]}==${query[${index}][0]}
        # Compare Names (Strings need to be in quotes)
        Should Be True  '${synonym["description"]}'=='${query[${index}][5]}'
        ${index}=    Evaluate    ${index} + 1
    END


FLXPRM-18
    [Tags]    P1    FLXPRM-18
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-18
    ...    This test case is designed to validate the Field Definition information returned for a Valid Table in the Flex database

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    # Send a query
    ${query}=    Query    SELECT * FROM data_dictionary WHERE tab_uid = 399 and dad_enabled = 1 ORDER BY dad_uid ASC
    Log Many    @{query}
    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/definitions?tableAbbrev=AST   status_code=200

    # Compare Results
    ${index}    Set Variable  0
    FOR  ${synonym}    IN    @{response["response"]}
        # Compare UID's
        Should Be True  ${synonym["uid"]}==${query[${index}][0]}
        Should Be True  ${synonym["tabUid"]}==${query[${index}][1]}
        # Compare Names (Strings need to be in quotes)
        Should Be True  '${synonym["dataType"]}'=='${query[${index}][4]}'
        Should Be True  '${synonym["fieldName"]}'=='${query[${index}][5]}'
        Should Be True  '${synonym["fieldLabel"]}'=='${query[${index}][6]}'
        ${index}=    Evaluate    ${index} + 1
    END


FLXPRM-19
    [Tags]    P1    FLXPRM-19
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-19
    ...    This test case is designed to validate the response received for the Field Definition endpoint for an Invalid Table in the Flex database

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/definitions?tableAbbrev=xpto   status_code=404
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Invalid Table Abbreviation: xpto


FLXPRM-25
    [Tags]    P1    FLXPRM-25
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-25
    ...    This test case is designed to validate the response received for the Lookup fields endpoint for an Invalid Table UID used in the Request

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/definitions/-5/lookupFields   status_code=404
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    ConfigurationTable with ID of -5 does not exist in the database.


FLXPRM-26
    [Tags]    P1    FLXPRM-26
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-26
    ...    This test case is designed to validate the response received for the Lookup fields endpoint for a non 
    ...    editable lookup Table UID used in the Request

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/definitions/1/lookupFields   status_code=404
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Invalid Table UID or Table UID is not a lookup.


FLXPRM-27
    [Tags]    P1    FLXPRM-27
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-27
    ...    This test case is designed to validate the Activity History Events related to an user log in, 
    ...    in order to generate the activity Type 92 - "User Insert"

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    # Send a query to get the USR_UID_USER
    ${getUid}    Query    SELECT DISTINCT usr_uid_user FROM activity_log WHERE atl_uid_activity_type = 92 order by usr_uid_user asc
    Log Many     @{getUid}
    # Convert the usr_uid_user
    ${getUid[1]}      Convert To String    ${getUid[1]}
    ${getUid[1]}      Remove String        ${getUid[1]}    (    )    ,

    # Send a quary to get the User Logout events
    ${query}     Query    SELECT * FROM activity_log WHERE usr_uid_user = ${getUid[1]} and atl_uid_activity_type = 92 order by act_uid asc
    Log Many     @{query}

    # Send a call to the History Events endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/activity/users?useruid=${getUid[1]}&activitytype=92   status_code=200

    # Compare Results
    ${index}    Set Variable  0
    FOR  ${synonym}    IN    @{response["response"]["content"]}
        # Compare UID's
        Should Be True  '${synonym["uid"]}'=='${query[${index}][0]}'
        Should Be True  ${synonym["activityTypeUid"]}==${query[${index}][4]}
        # # Compare Names (Strings need to be in quotes)
        Should Be True  '${synonym["description"]}'=='${query[${index}][5]}'
        ${index}=    Evaluate    ${index} + 1
    END


FLXPRM-28
    [Tags]    P1    FLXPRM-28
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-28
    ...    This test case is designed to validate the Activity History Events related to an user log in, 
    ...    in order to generate the activity Type 93 - "User Login"

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    # Send a query to get the USR_UID_USER
    ${getUid}    Query    SELECT DISTINCT usr_uid_user FROM activity_log WHERE atl_uid_activity_type = 93 order by usr_uid_user asc
    Log Many     @{getUid}
    # Convert the usr_uid_user
    ${getUid[1]}      Convert To String    ${getUid[1]}
    ${getUid[1]}      Remove String        ${getUid[1]}    (    )    ,

    # Send a quary to get the User Logout events
    ${query}     Query    SELECT * FROM activity_log WHERE usr_uid_user = ${getUid[1]} and atl_uid_activity_type = 93 order by act_uid asc
    Log Many     @{query}

    # Send a call to the History Events endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/activity/users?useruid=${getUid[1]}&activitytype=93   status_code=200

    # Compare Results
    ${index}    Set Variable  0
    FOR  ${synonym}    IN    @{response["response"]["content"]}
        # Compare UID's
        Should Be True  '${synonym["uid"]}'=='${query[${index}][0]}'
        Should Be True  ${synonym["activityTypeUid"]}==${query[${index}][4]}
        # # Compare Names (Strings need to be in quotes)
        Should Be True  '${synonym["description"]}'=='${query[${index}][5]}'
        ${index}=    Evaluate    ${index} + 1
    END


FLXPRM-29
    [Tags]    P1    FLXPRM-29
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-29
    ...    This test case is designed to validate the Activity History Events related to an user logout, 
    ...    in order to generate the activity Type 94 - "User Logout"

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    # Send a query to get the USR_UID_USER
    ${getUid}    Query    SELECT DISTINCT usr_uid_user FROM activity_log WHERE atl_uid_activity_type = 94 order by usr_uid_user asc
    Log Many     @{getUid}
    # Convert the usr_uid_user
    ${getUid[1]}      Convert To String    ${getUid[1]}
    ${getUid[1]}      Remove String        ${getUid[1]}    (    )    ,

    # Send a quary to get the User Logout events
    ${query}     Query    SELECT * FROM activity_log WHERE usr_uid_user = ${getUid[1]} and atl_uid_activity_type = 94 order by act_uid asc
    Log Many     @{query}

    # Send a call to the History Events endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/activity/users?useruid=${getUid[1]}&activitytype=94   status_code=200

    # Compare Results
    ${index}    Set Variable  0
    FOR  ${synonym}    IN    @{response["response"]["content"]}
        # Compare UID's
        Should Be True  '${synonym["uid"]}'=='${query[${index}][0]}'
        Should Be True  ${synonym["activityTypeUid"]}==${query[${index}][4]}
        # # Compare Names (Strings need to be in quotes)
        Should Be True  '${synonym["description"]}'=='${query[${index}][5]}'
        ${index}=    Evaluate    ${index} + 1
    END


FLXPRM-208
    [Tags]    P1    FLXPRM-208
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-208
    ...    This test case is designed to validate the response received for the Field Definitions 
    ...    endpoint for a Custom Lookup Table UID used in the Request
    # TODO: Create lookup table and entries during setup

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    # Send a query
    ${getUid}    Query    SELECT * FROM custom_lookup_data_mlkp
    Log Many     @{getUid}
    ${query}     Query    SELECT * FROM custom_lookup_data_mlkp WHERE cll_uid_custom_lookup = ${getUid[0][1]} and cld_is_active = 1
    Log Many     @{query}
    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/definitions/${query[0][1]}/lookupFields   status_code=200

    # Compare Results
    ${index}    Set Variable  0
    FOR  ${synonym}    IN    @{response["response"]}
        # Compare UID's
        Should Be True  ${synonym["uid"]}==${query[${index}][0]}
        Should Be True  ${synonym["rolBitfieldRoleMlkp"]}==${query[${index}][8]}
        # Compare Names (Strings need to be in quotes)
        Should Be True  '${synonym["description"]}'=='${query[${index}][2]}'
        Should Be True  '${synonym["code"]}'=='${query[${index}][3]}'
        ${index}=    Evaluate    ${index} + 1
    END


FLXPRM-238
    [Tags]    P1    FLXPRM-238
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-238
    ...    This test case is designed to validate the response received for the Field Definitions
    ...    endpoint for a valid lookup Table UID used in the Request

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    # Send a query
    ${query}=    Query    SELECT * FROM ENT_CLASSIFICATION_LKP WHERE ecl_is_active = 1 AND ecl_description <> ' ' ORDER BY ecl_description ASC
    Log Many    @{query}

    # Sort the dictionary same way as the Oracle
    ${sorted_list}   Sort List Custom    ${query}
    Log Many    @{sorted_list}

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/definitions/7/lookupFields   status_code=200

    # Compare Results
    ${index}    Set Variable  0
    FOR  ${synonym}    IN    @{response["response"]}
        # Compare UID's
        Should Be True  ${synonym["uid"]}==${sorted_list[${index}][0]}
        Should Be True  ${synonym["rolBitfieldRoleMlkp"]}==${sorted_list[${index}][7]}
        # Compare Names (Strings need to be in quotes)
        Should Be True  '${synonym["description"]}'=='${sorted_list[${index}][1]}'
        Should Be True  '${synonym["code"]}'=='${sorted_list[${index}][2]}'
        ${index}=    Evaluate    ${index} + 1
    END


FLXPRM-239
    [Tags]    P1    FLXPRM-239
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-239
    ...    This test case is designed to validate the response received for the Field Definitions
    ...    endpoint for a valid lookup Table UID used in the Request with onlyActive parameter set to true

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    # Send a query
    ${query}=    Query    SELECT * FROM VEH_MAKE_LKP WHERE vkl_is_active=1 ORDER BY VKL_UID ASC
    Log Many    @{query}

    # Sort the dictionary same way as the Oracle
    ${sorted_list}   Sort List Custom    ${query}
    Log Many    @{sorted_list}

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/definitions/5/lookupFields?onlyActive=true   status_code=200

    # Compare Results
    ${index}    Set Variable  1
    FOR  ${synonym}    IN    @{response["response"]}
        # Compare UID's
        Should Be True  ${synonym["uid"]}==${sorted_list[${index}][0]}
        Should Be True  ${synonym["rolBitfieldRoleMlkp"]}==${sorted_list[${index}][8]}
        # Compare Names (Strings need to be in quotes)
        Should Be True  '${synonym["description"]}'=='${sorted_list[${index}][1]}'
        Should Be True  '${synonym["code"]}'=='${sorted_list[${index}][2]}'
        ${index}=    Evaluate    ${index} + 1
    END


FLXPRM-240
    [Tags]    P1    FLXPRM-240
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-240
    ...    This test case is designed to validate the response received for the Field Definitions 
    ...    endpoint for a valid lookup Table UID used in the Request with onlyActive parameter set to false

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    # Send a query
    ${query}=    Query    SELECT * FROM VEH_MAKE_LKP ORDER BY VKL_UID ASC
    Log Many    @{query}

    # Sort the dictionary same way as the Oracle
    ${sorted_list}   Sort List Custom    ${query}
    Log Many    @{sorted_list}
    
    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/definitions/5/lookupFields?onlyActive=false   status_code=200

    # Compare Results
    ${index}    Set Variable  1
    FOR  ${synonym}    IN    @{response["response"]}
        # Compare UID's
        Should Be True  ${synonym["uid"]}==${sorted_list[${index}][0]}
        Should Be True  ${synonym["rolBitfieldRoleMlkp"]}==${sorted_list[${index}][8]}
        # Compare Names (Strings need to be in quotes)
        Should Be True  '${synonym["description"]}'=='${sorted_list[${index}][1]}'
        Should Be True  '${synonym["code"]}'=='${sorted_list[${index}][2]}'
        ${index}=    Evaluate    ${index} + 1
    END


FLXPRM-477
    [Tags]    P1    FLXPRM-477
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-477
    ...    Given the citation record exists in the database
    ...    When a specific citation UID is requested without Contravention View privilege
    ...    Then the service response gives a 403 response and the message: "User Account lacks the privileges to access this endpoint."

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/V1/contraventions/486252   status_code=403    keycloak_id=uinoview@t2systems.com    keycloak_pass=Auto@12345
    
    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    User Account lacks the privileges to access this endpoint.


FLXPRM-478
    [Tags]    P1    FLXPRM-478
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-478
    ...    Given the user enters a citation record that does not exists in the database
    ...    When the view citation service is executed
    ...    Then the service response gives a 404 response and the message: "Contravention with ID of "X" does not exist in the database."

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/V1/contraventions/1234   status_code=404
    
    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Contravention with ID of 1234 does not exist in the database.


FLXPRM-480
    [Tags]    P1    FLXPRM-480
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-480
    ...    Given a new Citation record is inserted from old Flex UI
    ...    When the specific Citation UID created is requested from service
    ...    Then the service shows the inserted Citation UID information
    
    # Generate a random ticketId
    ${ticketId}    Generate Random String    8

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a POST to insert a Citation
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "officer": 2002,
    ...    "zone": 2000,
    ...    "issueDate": "2022-08-29T11:00:00.000Z",
    ...    "violationCode": 2073,
    ...    "permissionNumber": "",
    ...    "location": 2022,
    ...    "blockNumber": "",
    ...    "meterNumber": "MTR22",
    ...    "ticketId": "${ticketId}",
    ...    "chalkDate": "2022-08-22T11:00:00.000Z",
    ...    "courtDate": "2022-09-23T11:00:00.000Z",
    ...    "openBlockDocket": 0,
    ...    "commentPublic": "public comment-post",
    ...    "commentPrivate": "private comment-post",
    ...    "commentLocation": "location comment-post",
    ...    "isSpecialStatus": true,
    ...    "isSourceManual": false,
    ...    "isWarning": false,
    ...    "modDigit": "1",
    ...    "snapVehicleModel": 1000,
    ...    "snapVehicleMake": 100,
    ...    "snapVehicleColor": 1,
    ...    "snapVehicleType": 1,
    ...    "snapVehicleState": 1,
    ...    "snapVehiclePlateType": 1,
    ...    "snapVehicleVin": "256265229298292",
    ...    "snapVehiclePlateLicense": "AWY4109"
    ...  }

    ${response}=    Send API Call    post    FlexAPI    ${base_URL}    /api/v1/contraventions/    status_code=201    data=${request_body}

    # Send a query to get the Object Uid
    ${getUid}=    Query    SELECT * FROM contravention WHERE con_snap_veh_plate_license LIKE 'AWY4109' ORDER BY con_uid DESC
    Log Many      @{getUid} 

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  get  synonyms  ${base_URL}  /api/v1/contraventions/${getUid[0][0]}   status_code=200

    # Compare Results
    Should Be Equal    ${response["response"]["commentPublic"]}                     ${getUid[0][14]}
    Should Be Equal    ${response["response"]["commentPrivate"]}                    ${getUid[0][15]}
    Should Be Equal    ${response["response"]["commentLocation"]}                   ${getUid[0][16]}
    Should Be Equal    ${response["response"]["vehicle"]["uid"]}                    ${getUid[0][2]}
    Should Be Equal    ${response["response"]["vehicle"]["plateLicense"]}           ${getUid[0][36]}
    Should Be Equal    ${response["response"]["violationCode"]["uid"]}              ${getUid[0][6]}
    Should Be Equal    ${response["response"]["location"]["uid"]}                   ${getUid[0][8]}
    Should Be Equal    ${response["response"]["ticketId"]}                          ${getUid[0][11]}


FLXPRM-692
    [Tags]    P3    FLXPRM-692
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-692
    ...    In Order To convert a citation to a warning in the Flex UI
    ...    As A Flex User
    ...    I Want to be able to reduce an existing citation to zero balance and flag it as a warning
    
    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Object Uid
    ${getUid}=    Query    SELECT * FROM contravention WHERE con_is_warning <> 1 AND con_amount_due_cac > 0 AND csl_uid_status_cac = 1 AND ROWNUM < 10
    Log Many      @{getUid} 

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${getUid[0][0]}/reducetowarning    status_code=200

    # Send a query to get the Object Uid
    ${query}=    Query    SELECT * FROM contravention WHERE con_uid = ${getUid[0][0]}
    Log Many     @{query} 

    # Compare Results
    ${warning}         Convert To String    ${query[0][20]}
    ${due}             Convert To String    ${query[0][47]}
    Should Be Equal    ${warning}           1
    Should Be Equal    ${due}               0.0


FLXPRM-693
    [Tags]    P1    FLXPRM-693
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-693
    ...    In Order To convert a citation to a warning in the Flex UI
    ...    As A Flex User
    ...    I Want to be able to reduce an existing citation to zero balance and flag it as a warning
    
    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Object Uid
    ${getUid}=    Query    SELECT * FROM contravention WHERE con_is_warning <> 1 AND con_amount_due_cac > 0 AND csl_uid_status_cac = 1 AND ROWNUM < 10
    Log Many      @{getUid} 

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${getUid[0][0]}/reducetowarning    status_code=200

    # Send a query to get the Object Uid
    ${query}=    Query    SELECT * FROM contravention WHERE con_uid = ${getUid[0][0]}
    Log Many     @{query} 

    # Compare Results
    ${warning}         Convert To String    ${query[0][49]}
    Should Be Equal    ${warning}           2


FLXPRM-694
    [Tags]    P1    FLXPRM-694
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-694
    ...    Given I want to reduce a citation to warning that has already been paid
    ...    When I complete the process
    ...    Then the citation is given a credit equal to the amount paid
    
    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Object Uid
    ${getUid}=    Query    SELECT * FROM contravention WHERE csl_uid_status_cac = 2 AND con_is_warning <> 1 AND con_is_historical = 0 AND con_is_uncollectable = 0 AND ROWNUM < 10
    Log Many      @{getUid}

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${getUid[0][0]}/reducetowarning    status_code=200

    # Send a query to get the value after the change
    ${query}=    Query    SELECT * FROM contravention WHERE con_uid = ${getUid[0][0]}
    Log Many     @{query} 

    # Compare Results
    Should Not Be Equal    ${query[0][47]}    ${getUid[0][47]}
    Log                    Value before the endpoint execution ${getUid[0][47]}
    Log                    Value after the endpoint execution ${query[0][47]}


FLXPRM-695
    [Tags]    P1    FLXPRM-695
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-695
    ...    Given I want to reduce a citation to warning that has been given an adjustment
    ...    When I complete the process
    ...    Then the adjustment amount is not applied to the citation as a credit
    
    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Object Uid
    ${getUid}=    Query    SELECT * FROM contravention WHERE csl_uid_status_cac = 4 AND con_is_warning <> 1 AND con_is_historical = 0 AND ROWNUM < 10
    Log Many      @{getUid}

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${getUid[0][0]}/reducetowarning    status_code=200

    # Send a query to get the value after the change
    ${query}=    Query    SELECT * FROM contravention WHERE con_uid = ${getUid[0][0]}
    Log Many     @{query} 

    # Compare Results
    Should Not Be Equal    ${query[0][47]}      ${getUid[0][47]}
    ${due}                 Convert To String    ${query[0][47]}
    Should Be Equal        ${due}               0.0


FLXPRM-695
    [Tags]    P2    FLXPRM-695    TODO
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-695
    ...    Given the citation record exists in the database
    ...    When a specific citation UID is requested without Contravention View privilege
    ...    Then the service response gives a 403 response and the message: "User Account lacks the privileges to access this endpoint."
    
    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Object Uid
    ${getUid}=    Query    SELECT * FROM contravention WHERE csl_uid_status_cac = 4 AND con_is_warning <> 1 AND con_is_historical = 0 AND ROWNUM < 10
    Log Many      @{getUid}

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/contraventions/${getUid[0][0]}    status_code=403    keycloak_id=uinoview@t2systems.com    keycloak_pass=Auto@12345

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}        User Account lacks the privileges to access this endpoint.


FLXPRM-790
    [Tags]    P2    FLXPRM-790    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-790
    ...    Given I have the correct permissions and a new Citation created
    ...    When I execute the service Write Off Citation
    ...    Then I am shown the message: "Citation (CIT12345) is not in the correct status to be written off.".
    
    # Generate a random ticketId
    ${ticketId}    Generate Random String    8    [LETTERS]
    ${ticketId}    Convert To Upper Case     ${ticketId}

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Citation where violation code is Zero Balance 
    ${getViolationCode}=    Query    SELECT * FROM con_violation_code_mlkp WHERE vic_base_amount = 0
    Log Many                @{getViolationCode}

    # Send a POST to insert a Citation
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "officer": 2002,
    ...    "zone": 2000,
    ...    "issueDate": "2022-08-29T11:00:00.000Z",
    ...    "violationCode": ${getViolationCode[0][0]},
    ...    "permissionNumber": "",
    ...    "location": 2022,
    ...    "blockNumber": "",
    ...    "meterNumber": "MTR22",
    ...    "ticketId": "${ticketId}",
    ...    "chalkDate": "2022-08-22T11:00:00.000Z",
    ...    "courtDate": "2022-09-23T11:00:00.000Z",
    ...    "openBlockDocket": 0,
    ...    "commentPublic": "public comment-post",
    ...    "commentPrivate": "private comment-post",
    ...    "commentLocation": "location comment-post",
    ...    "isSourceManual": false,
    ...    "isWarning": false,
    ...    "modDigit": "1",
    ...    "snapVehicleModel": 1000,
    ...    "snapVehicleMake": 100,
    ...    "snapVehicleColor": 1,
    ...    "snapVehicleType": 1,
    ...    "snapVehicleState": 1,
    ...    "snapVehiclePlateType": 1,
    ...    "snapVehicleVin": "256265229298292",
    ...    "snapVehiclePlateLicense": "AWY4109"
    ...  }

    ${response}=    Send API Call    post    FlexAPI    ${base_URL}    /api/v1/contraventions/    status_code=201    data=${request_body}

    # Send a query to get the Object Uid
    ${getUid}=    Query    SELECT * FROM contravention WHERE con_ticket_id LIKE '${ticketId}'
    Log Many      @{getUid} 
    
    # Send a endpoint to write off citation
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${getUid[0][0]}/writeoffcitation    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}       Citation (${ticketId}) is not in the correct status to be written off.


FLXPRM-791
    [Tags]    P2    FLXPRM-791
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-791
    ...    Given I have the correct permissions and a non existent citation
    ...    When I execute the service Write Off Citation
    ...    Then I am shown the message:  "Contravention with ID of 999999 does not exist in the database."
    
    # Generate a random ticketId
    ${ticketId}    Generate Random String    8    [NUMBERS]

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${ticketId}/writeoffcitation    status_code=404
    
    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}        Contravention with ID of ${ticketId} does not exist in the database.


FLXPRM-803
    [Tags]    P1    FLXPRM-803    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-803
    ...    Given I have the Edit Citation Privilege and am on a new created citation
    ...    When I execute the service
    ...    Then the response shows the message: "Citation (CITTEST12345) is not in the correct status to be transferred."
    
    # Generate a random ticketId
    ${ticketId}    Generate Random String    8    [LETTERS]
    ${ticketId}    Convert To Upper Case     ${ticketId}

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Citation where violation code is Zero Balance 
    ${getViolationCode}=    Query    SELECT * FROM con_violation_code_mlkp WHERE vic_base_amount = 0
    Log Many                @{getViolationCode}

    # Send a POST to insert a Citation
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "officer": 2002,
    ...    "zone": 2000,
    ...    "issueDate": "2022-08-29T11:00:00.000Z",
    ...    "violationCode": ${getViolationCode[0][0]},
    ...    "permissionNumber": "",
    ...    "location": 2022,
    ...    "blockNumber": "",
    ...    "meterNumber": "MTR22",
    ...    "ticketId": "${ticketId}",
    ...    "chalkDate": "2022-08-22T11:00:00.000Z",
    ...    "courtDate": "2022-09-23T11:00:00.000Z",
    ...    "openBlockDocket": 0,
    ...    "commentPublic": "public comment-post",
    ...    "commentPrivate": "private comment-post",
    ...    "commentLocation": "location comment-post",
    ...    "isSourceManual": false,
    ...    "isWarning": false,
    ...    "modDigit": "1",
    ...    "snapVehicleModel": 1000,
    ...    "snapVehicleMake": 100,
    ...    "snapVehicleColor": 1,
    ...    "snapVehicleType": 1,
    ...    "snapVehicleState": 1,
    ...    "snapVehiclePlateType": 1,
    ...    "snapVehicleVin": "256265229298292",
    ...    "snapVehiclePlateLicense": "AWY4109"
    ...  }

    ${response}=    Send API Call    post    FlexAPI    ${base_URL}    /api/v1/contraventions/    status_code=201    data=${request_body}

    # Send a query to get the Object Uid
    ${getUid}=    Query    SELECT * FROM contravention WHERE con_ticket_id LIKE '${ticketId}'
    Log Many      @{getUid} 
    
    # Send a endpoint to write off citation
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${getUid[0][0]}/transferfine    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}       Citation (${ticketId}) is not in the correct status to be transferred.


FLXPRM-804
    [Tags]    P1    FLXPRM-804
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-804
    ...    Given I have the Edit Citation Privilege and a non existent citation is inserted
    ...    When I execute the service
    ...    Then the response shows the message:  "Contravention with ID of 999999 does not exist in the database."
    
    # Generate a random ticketId
    ${ticketId}    Generate Random String    8    [NUMBERS]

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${ticketId}/transferfine    status_code=404
    
    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}        Contravention with ID of ${ticketId} does not exist in the database.


FLXPRM-974
    [Tags]    P1    FLXPRM-974
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-974
    ...    Given I have the Edit Citation Privilege and not existent transferAgency is inserted
    ...    When I execute the service
    ...    Then the response shows the message:"TransferAgencyLookup with ID of 99999 does not exist in the database."

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Object Uid
    ${getUid}=    Query    SELECT * FROM contravention WHERE ROWNUM < 10
    Log Many      @{getUid} 

    # Send a POST to transfer agency
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "transferAgency": 9999,
    ...    "pendingTransferDate": "2022-10-07T04:00:00Z"
    ...  }

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${getUid[0][0]}/transferfine    status_code=404    data=${request_body}
    
    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}        TransferAgencyLookup with ID of 9999 does not exist in the database.


FLXPRM-1038
    [Tags]    P1    FLXPRM-1038
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1038
    ...    Given A non existent Email Address UID is inserted on the endpoint
    ...    When I execute the Delete Email Address service
    ...    Then the response shows 404 status code and the message: "EmailAddress with ID of 9999999 does not exist in the database."

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call  delete  synonyms  ${base_URL}  /api/v1/emailaddresses/999999   status_code=404

    # Compare results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    EmailAddress with ID of 999999 does not exist in the database.


FLXPRM-993
    [Tags]    P1    FLXPRM-993
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-993
    ...    Given I have the Edit Customer Privilege and am on an existent customer not having a group associated.
    ...    When I execute the service “Remove Allotment Group” using a non existent "relatedUid"
    ...    Then The service shows a success message .

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to find a customer that is not associated with an Allotmentgroup 
    ${getUid}=    Query   SELECT * FROM entity WHERE etl_uid_type = 1 AND ent_uid_related_group IS NULL AND ROWNUM < 10 ORDER BY ent_uid DESC
    Log Many      @{getUid} 

    # Send a Delete to remove a Allotmentgroup
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "relatedUid": 99999
    ...  }

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    delete    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[1][0]}/allotmentgroup    status_code=200    data=${request_body}


FLXPRM-987
    [Tags]    P1    FLXPRM-987
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-987
    ...    Given I have the Edit Customer Privilege and am on a new customer with a linked allotment group
    ...    When I execute the service “Remove Allotment Group”
    ...    Then The service gives a success message.

    # Create a random primaryId key
    ${primaryId}    Generate Random String    8
    ${primaryId}    Convert To Upper Case     ${primaryId}

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a request to create a new individual type customer --> Type = 1
    &{body}    Create Dictionary    subclassification=2000  type=1  primaryId=${primaryId}  
    ${response}     Send API Call    post    FlexAPI    ${base_URL}    /api/v1/entities    status_code=201    data=${body}

    # Send a query to get the created customer Uid
    ${getUid}=    Query   SELECT * FROM entity WHERE ent_primary_id LIKE '${primaryId}'
    Log Many      @{getUid}

    # Send a query to get the Allotmentgroup Uid
    ${groupbefore}    Query   SELECT * FROM entity WHERE etl_uid_type = 2 AND ROWNUM < 10 ORDER BY ent_uid DESC
    Log Many          @{groupbefore}

    # Send a request to insert the Allotmentgroup
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "relatedUid": ${groupbefore[0][0]}
    ...  }

    # Send a call to the endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}/allotmentgroup       status_code=200    data=${request_body}

    # Send a Get request to validate that the group was attached to the new customer
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}                      status_code=200    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["response"]["RelatedGroup"]["displayName"]}          ${groupbefore[0][14]}

    # Send a request to remove the group attached to the new customer
    ${response}=    Send API Call    delete    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}/allotmentgroup    status_code=200    data=${request_body}

    # Send a Get request to validate that the group was removed
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}                      status_code=200    data=${request_body}

    # Compare Results
    Dictionary Should Not Contain Key    ${response["response"]}    ${groupbefore[0][14]}


FLXPRM-998
    [Tags]    P1    FLXPRM-998
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-998
    ...    Given I want to view an email record and i dont have “View“ customer privilege on my user
    ...    When I execute the view Email Address service
    ...    Then The response shows status code “403“ and the message: "The user does not have permission to view this record."

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/emailaddresses/2000    status_code=403    keycloak_id=uinoview@t2systems.com    keycloak_pass=Auto@12345

    # Compare results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}     The user does not have permission to view this record.


FLXPRM-990
    [Tags]    P1    FLXPRM-990
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-990
    ...    Given I have the Edit Customer Privilege and am on an existent customer
    ...    When I execute the service “Remove Allotment Group” using a customer who already removed a group
    ...    Then The service shows a success message.

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the costumerUid
    ${getUid}=    Query   SELECT * FROM entity WHERE ROWNUM < 10 ORDER BY ent_uid DESC
    Log Many      @{getUid}

    # Send a query to get the Allotmentgroup Uid
    ${groupbefore}    Query   SELECT * FROM entity WHERE etl_uid_type = 2 AND ROWNUM < 10 ORDER BY ent_uid DESC
    Log Many          @{groupbefore}

    # Send a request to insert the Allotmentgroup
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "relatedUid": ${groupbefore[0][0]}
    ...  }

    # Send a call to the endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[1][0]}/allotmentgroup    status_code=200    data=${request_body}

    # Send a Get request to validate that the group was attached to the new customer
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[1][0]}                   status_code=200    data=${request_body}

    # # Compare Results
    Should Be Equal    ${response["response"]["RelatedGroup"]["displayName"]}          ${groupbefore[0][14]}

    # Send a request to remove the group attached to the new customer two times
    ${response}=    Send API Call    delete    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[1][0]}/allotmentgroup    status_code=200    data=${request_body}
    ${response}=    Send API Call    delete    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[1][0]}/allotmentgroup    status_code=200    data=${request_body}

    # Send a Get request to validate that the group was removed
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[1][0]}                   status_code=200    data=${request_body}

    # Compare Results
    Dictionary Should Not Contain Key    ${response["response"]}    ${groupbefore[0][14]}


FLXPRM-992
    [Tags]    P1    FLXPRM-992
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-992
    ...    Given I have the Edit Customer Privilege and am on an existent customer not having a group associated.
    ...    When I execute the service “Remove Allotment Group” using a customer who already removed a group
    ...    Then The service shows a success message.

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the costumerUid
    ${getUid}=    Query   SELECT * FROM entity WHERE ROWNUM < 10 ORDER BY ent_uid DESC
    Log Many      @{getUid}

    # Send a query to get the Allotmentgroup Uid
    ${groupbefore}    Query   SELECT * FROM entity WHERE etl_uid_type <> 2 AND ROWNUM < 10 ORDER BY ent_uid DESC
    Log Many          @{groupbefore}

    # Send a request to insert the Allotmentgroup
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "relatedUid": ${groupbefore[0][0]}
    ...  }

    # Send a request to remove the group attached to the new customer two times
    ${response}=    Send API Call    delete    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[1][0]}/allotmentgroup    status_code=200    data=${request_body}

    # Send a Get request to validate that the group was removed
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[1][0]}        status_code=200    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["response"]["RelatedGroup"]}    ${None}


FLXPRM-991
    [Tags]    P1    FLXPRM-991
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-991
    ...    Given I have the Edit Customer Privilege and am on an existent individual customer having a group associated.
    ...    When I execute the service “Remove Allotment Group” using a customer who already removed a group
    ...    Then The service shows a success message.

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get a customer created as Individual and has an attached group
    ${getUid}    Query   SELECT * FROM entity WHERE etl_uid_type = 1 AND ent_uid_related_group IS NOT NULL ORDER BY ent_uid DESC
    Log Many     @{getUid}

    # Send a query to find the group to which the customer belongs 
    ${groupUid}    Query   SELECT * FROM entity WHERE ent_uid = ${getUid[0][20]}
    Log Many       @{groupUid}

    # Send a request to insert the Allotmentgroup
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "relatedUid": ${groupUid[0][0]}
    ...  }

    # Send a Get request to validate that the group was attached to the new customer
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}        status_code=200    data=${request_body}

    # # Compare Results
    Should Be Equal    ${response["response"]["RelatedGroup"]["displayName"]}    ${groupUid[0][24]}

    # Send a request to remove the group attached to the new customer two times
    ${response}=    Send API Call    delete    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}/allotmentgroup    status_code=200    data=${request_body}

    # Send a Get request to validate that the group was removed
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}        status_code=200    data=${request_body}

    # Compare Results
    Dictionary Should Not Contain Key    ${response["response"]}    ${groupUid[0][24]}


FLXPRM-845
    [Tags]    P1    FLXPRM-845
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-845
    ...    Given I have the Edit Customer Privilege and am on a customer with an allotment group already associated
    ...    When I execute the set allotment service including another allotment group
    ...    Then the service response gives a success message and the new group UID is associated to the Entity

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get a customer created as Individual and has an attached group
    ${getUid}    Query   SELECT * FROM entity WHERE etl_uid_type = 1 AND ent_uid_related_group IS NOT NULL ORDER BY ent_uid DESC
    Log Many     @{getUid}

    # Send a query to find the group to which the customer belongs 
    ${groupbefore}    Query   SELECT * FROM entity WHERE ent_uid = ${getUid[0][20]}
    Log Many          @{groupbefore}

    # Send a Get request to validate that the group was attached to the new customer
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}        status_code=200

    # # Compare Results
    Should Be Equal    ${response["response"]["RelatedGroup"]["displayName"]}    ${groupbefore[0][24]}

    # Send a query to find the group to which the customer belongs 
    ${groupafter}     Query   SELECT * FROM entity WHERE ent_group_name NOT LIKE 'None' AND ent_uid <> ${getUid[0][20]}
    Log Many          @{groupafter}

    # Send a request to insert the Allotmentgroup
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "relatedUid": ${groupafter[0][0]}
    ...  }

    # Send a request to remove the group attached to the new customer two times
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}/allotmentgroup    status_code=200    data=${request_body}

    # Send a Get request to validate that the group was removed
    ${response}=    Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}        status_code=200    data=${request_body}

    # Compare Results
    Dictionary Should Not Contain Key    ${response["response"]}                                   ${groupbefore[0][24]}
    Should Be Equal                      ${response["response"]["RelatedGroup"]["displayName"]}    ${groupafter[0][24]}


FLXPRM-1051
    [Tags]    P2    FLXPRM-1051
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1051
    ...    Given I have a non existent Email Address record inserted on the endpoint
    ...    When I edit the email address and execute the service
    ...    Then The response shows the status code “404“ and the message: "EmailAddress with ID of 9999999 does not exist in the database."

    # Generate a random ticketId
    ${ticketId}    Generate Random String    8    [NUMBERS]

    # Send a POST to insert a Citation
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "type": 2001,
    ...    "email": "testqa@mail.rochester.edu"
    ...  }

    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${ticketId}    status_code=404    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    EmailAddress with ID of ${ticketId} does not exist in the database.


FLXPRM-1032
    [Tags]    P2    FLXPRM-1032
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1032
    ...    Given the Email Address has no relationships other than customer
    ...    When I execute the Delete Email Address service
    ...    Then The response shows a success message and status code “200“.

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Allotmentgroup Uid
    ${groupUid}    Query   select COE_UID, COE_EMAIL_ADDRESS, p.per_uid, pbh.prh_uid, a.adj_uid from cor_email e left join permission p on p.coe_uid_email_notify_address = e.coe_uid left join PRINT_BATCH_HOLDING pbh on pbh.coe_uid_email_address = e.coe_uid left join ADJUDICATION a on a.coe_uid_email = e.coe_uid where per_uid is null and prh_uid is null and adj_uid is null
    Log Many       @{groupUid}

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    delete    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${groupUid[0][0]}    status_code=200


FLXPRM-1041
    [Tags]    P2    FLXPRM-1041
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1041
    ...    Given A valid Email Address record without relationships 
    ...    When I execute the delete Email Address service
    ...    Then The response shows a Success message and the record is removed on the table “COR_EMAIL“

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Allotmentgroup Uid
    ${groupUid}    Query   select COE_UID, COE_EMAIL_ADDRESS, p.per_uid, pbh.prh_uid, a.adj_uid from cor_email e left join permission p on p.coe_uid_email_notify_address = e.coe_uid left join PRINT_BATCH_HOLDING pbh on pbh.coe_uid_email_address = e.coe_uid left join ADJUDICATION a on a.coe_uid_email = e.coe_uid where per_uid is null and prh_uid is null and adj_uid is null
    Log Many       @{groupUid}

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    delete    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${groupUid[0][0]}    status_code=200

    # Send a query to get a customer created as Individual and has an attached group
    ${emaildelete}    Query   SELECT * FROM cor_email WHERE coe_uid = ${groupUid[0][0]}
    Log Many          @{emaildelete}
    
    # Compare results
    Should Be Empty    ${emaildelete}


FLXPRM-805
    [Tags]    P2    FLXPRM-805
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-805
    ...    Given I have the Edit Citation Privilege and am on an unpaid citation
    ...    When I execute the service
    ...    Then the response shows a success message and transferAgency/pendingTransferDate are updated on the DB.

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Object Uid and the old Agency
    ${getUid}=    Query    SELECT * FROM contravention WHERE con_amount_due_cac > 0 AND ROWNUM < 10 ORDER BY con_uid DESC
    Log Many      @{getUid}

    # Send a query to get the AgencyUid
    ${AgencyUid}=    Query    SELECT tal_uid from transfer_agency_mlkp
    Log Many         @{AgencyUid}

    # Get a random AgencyUid from the list of Agencies
    ${randomAgency}      Evaluate    random.choice(${AgencyUid})
    ${randomAgency}      Convert To String    ${randomAgency}
    ${randomAgency}      Remove String        ${randomAgency}    )    (    ,
    ${randomAgency}      Convert To Integer   ${randomAgency}

    # Send a POST to transfer agency
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "transferAgency": ${randomAgency},
    ...    "pendingTransferDate": "2022-10-25T04:00:00Z"
    ...  }

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${getUid[1][0]}/transferfine    status_code=200    data=${request_body}

    # Send a query to get the new Transfer Agency
    ${newAgency}=    Query    SELECT * FROM contravention WHERE con_amount_due_cac > 0 AND ROWNUM < 10 ORDER BY con_uid DESC
    Log Many         @{newAgency}
    
    # Compare Results
    Should Be Equal    ${response["responseStatus"]}            SUCCESS
    Should Be Equal    ${randomAgency}                          ${newAgency[1][24]}


FLXPRM-849
    [Tags]    P1    FLXPRM-849    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-849
    ...    Given I have the Edit Customer Privilege and am on an individual customer with no allotment group
    ...    When I execute the Set Allotment Group service, adding an individual instead a group.
    ...    Then the service response gives a success message and the individual UID is associated to the entity

    #Sending random data to the PUT method
    ${primaryId}          Generate Random String    7
    ${primaryId}          Convert To Upper Case     ${primaryId}

    ${lastName}          Generate Random String    7
    ${lastName}          Convert To Upper Case     ${lastName}

    ${firstName}          Generate Random String    7
    ${firstName}          Convert To Upper Case     ${firstName}
    
    ${groupName}          Generate Random String    7
    ${groupName}          Convert To Upper Case     ${groupName}

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    
    # Send a query
    ${getUid}    Query    SELECT * FROM entity a, cor_address b WHERE a.ent_uid = b.cor_uid AND ROWNUM < 10
    Log Many     @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "subClassification": ${getUid[0][1]},
    ...    "prefix": ${getUid[0][2]},
    ...    "suffix": ${getUid[0][3]},
    ...    "type": 1,
    ...    "primaryId": "${primaryId}",
    ...    "lastName": "${lastName}",
    ...    "firstName": "${firstName}",
    ...    "groupName": "${groupName}",
    ...    "disallowChecks": true
    ...  }

    ${response}        Send API Call    post    FlexAPI    ${base_URL}    /api/v1/entities/    status_code=201    data=${request_body}

    # Send a query to get the new created customer
    ${getCustomer}    Query    SELECT * FROM entity where ent_primary_id LIKE '${primaryId}'
    Log Many          @{getCustomer}

    # Send a get to check Allotmentgroup
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getCustomer[0][0]}    status_code=200

    # Compare Results
    Should Be Equal    ${response["response"]["RelatedGroup"]}    ${None}

    # Get the group Uid
    ${groupUid}    Query    SELECT * FROM entity WHERE etl_uid_type = 1 AND ent_uid_related_group IS NOT NULL AND ent_group_name IS NOT NULL ORDER BY ent_uid DESC
    Log Many       @{groupUid}

    # Insert customer into a new group
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "relatedUid": "${groupUid [0][0]}"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/entities/${getCustomer[0][0]}/allotmentgroup    status_code=200    data=${request_body}

    # Send a get to check Allotmentgroup
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getCustomer[0][0]}    status_code=200    

    # Compare Results
    Should Be Equal    ${response["response"]["RelatedGroup"]["displayName"]}    ${groupUid[0][24]}


FLXPRM-843
    [Tags]    P2    FLXPRM-843
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-843
    ...    Given I have the Edit Customer Privilege and am on a group customer with no allotment group
    ...    When I execute the set allotment service
    ...    Then the service response gives a success message and the group UID is associated to the entity

    #Sending random data to the PUT method
    ${primaryId}          Generate Random String    7
    ${primaryId}          Convert To Upper Case     ${primaryId}

    ${lastName}          Generate Random String    7
    ${lastName}          Convert To Upper Case     ${lastName}

    ${firstName}          Generate Random String    7
    ${firstName}          Convert To Upper Case     ${firstName}
    
    ${groupName}          Generate Random String    7
    ${groupName}          Convert To Upper Case     ${groupName}

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'
    
    # Send a query
    ${getUid}    Query    SELECT * FROM entity a, cor_address b WHERE a.ent_uid = b.cor_uid AND ROWNUM < 10
    Log Many     @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "subClassification": ${getUid[0][1]},
    ...    "prefix": ${getUid[0][2]},
    ...    "suffix": ${getUid[0][3]},
    ...    "type": 2,
    ...    "primaryId": "${primaryId}",
    ...    "lastName": "${lastName}",
    ...    "firstName": "${firstName}",
    ...    "groupName": "${groupName}",
    ...    "disallowChecks": true
    ...  }

    ${response}        Send API Call    post    FlexAPI    ${base_URL}    /api/v1/entities/    status_code=201    data=${request_body}

    # Send a query to get the new created customer
    ${getCustomer}    Query    SELECT * FROM entity where ent_primary_id LIKE '${primaryId}'
    Log Many          @{getCustomer}

    # Send a get to check Allotmentgroup
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getCustomer[0][0]}    status_code=200

    # Compare Results
    Should Be Equal    ${response["response"]["RelatedGroup"]}    ${None}

    # Get the group Uid
    ${groupUid}    Query    SELECT * FROM entity WHERE ent_uid_related_group IS NOT NULL AND ent_group_name IS NOT NULL ORDER BY ent_uid DESC
    Log Many       @{groupUid}

    # Insert customer into a new group
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "relatedUid": "${groupUid [0][0]}"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/entities/${getCustomer[0][0]}/allotmentgroup    status_code=200    data=${request_body}

    # Send a get to check Allotmentgroup
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${getCustomer[0][0]}    status_code=200    

    # Compare Results
    Should Be Equal    ${response["response"]["RelatedGroup"]["displayName"]}    ${groupUid[0][24]}


############################################################
######### Mail server is not integrated with AUTOQA3 #######
############################################################
FLXPRM-1113
    [Tags]    P3    FLXPRM-1113    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1113
    ...    In Order To have create new communication with a customer
    ...    As A Flex User
    ...    I Want to be able to quickly generate a letter to a customer from the Flex UI while on the customer record

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a querry to get the addressUid from COR_ADDRESS
    ${getaddressUid}    Query    SELECT * FROM cor_address WHERE ROWNUM < 10
    Log Many            @{getaddressUid}

    # Send a querry to get the emailAddressUid from COR_EMAIL
    ${getemailAddressUid}    Query    SELECT * FROM cor_email WHERE ROWNUM < 10
    Log Many                 @{getemailAddressUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...        "objectUid": ${getaddressUid[0][0]},
    ...        "reportUid": 20,
    ...        "addressUid": ${getaddressUid[0][0]},
    ...        "emailAddressUid": ${getemailAddressUid}[0][0],
    ...        "tableAbbrev": "ENT",
    ...        "deliveryFormat": "XX"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/letters/generateLetter    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Invalid deliveryFormat: XX


FLXPRM-1112
    [Tags]    P3    FLXPRM-1112
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1112
    ...    In Order To have create new communication with a customer
    ...    As A Flex User
    ...    I Want to be able to quickly generate a letter to a customer from the Flex UI while on the customer record

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...        "objectUid": 3340,
    ...        "reportUid": 20,
    ...        "addressUid": 3340,
    ...        "emailAddressUid": 3440,
    ...        "tableAbbrev": "XX",
    ...        "deliveryFormat": "PDFAttachment"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/letters/generateLetter    status_code=500    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Invalid tableAbbrev


FLXPRM-1111
    [Tags]    P3    FLXPRM-1111    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1111
    ...    In Order To have create new communication with a customer
    ...    As A Flex User
    ...    I Want to be able to quickly generate a letter to a customer from the Flex UI while on the customer record

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a querry to get the addressUid from COR_ADDRESS
    ${getaddressUid}    Query    SELECT * FROM cor_address WHERE ROWNUM < 10
    Log Many            @{getaddressUid}

        # Send a querry to get the emailAddressUid from COR_EMAIL
    ${getemailAddressUid}    Query    SELECT * FROM cor_email WHERE ROWNUM < 10
    Log Many                 @{getemailAddressUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...        "objectUid": ${getaddressUid[0][0]},
    ...        "reportUid": 20,
    ...        "addressUid": ${getaddressUid[0][0]},
    ...        "emailAddressUid": XX,
    ...        "tableAbbrev": "ENT",
    ...        "deliveryFormat": "PDFAttachment"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/letters/generateLetter    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Unexpected character encountered while parsing value: X. Path 'emailAddressUid', line 5, position 24.


FLXPRM-1110
    [Tags]    P3    FLXPRM-1110    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1110
    ...    In Order To have create new communication with a customer
    ...    As A Flex User
    ...    I Want to be able to quickly generate a letter to a customer from the Flex UI while on the customer record

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "objectUid": 3340,
    ...    "reportUid": 20,
    ...    "addressUid": XX,
    ...    "emailAddressUid": 3440,
    ...    "tableAbbrev": "ENT",
    ...    "deliveryFormat": "PDFAttachment"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/letters/generateLetter    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Unexpected character encountered while parsing value: X. Path 'addressUid', line 5, position 19.


FLXPRM-1109
    [Tags]    P3    FLXPRM-1109    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1109
    ...    In Order To have create new communication with a customer
    ...    As A Flex User
    ...    I Want to be able to quickly generate a letter to a customer from the Flex UI while on the customer record

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "objectUid": 3340,
    ...    "reportUid": XX,
    ...    "addressUid": 3340,
    ...    "emailAddressUid": 3440,
    ...    "tableAbbrev": "ENT",
    ...    "deliveryFormat": "PDFAttachment"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/letters/generateLetter    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Unexpected character encountered while parsing value: X. Path 'reportUid', line 4, position 18.


FLXPRM-1108
    [Tags]    P3    FLXPRM-1108    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1108
    ...    In Order To have create new communication with a customer
    ...    As A Flex User
    ...    I Want to be able to quickly generate a letter to a customer from the Flex UI while on the customer record

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "objectUid": XXXX,
    ...    "reportUid": 20,
    ...    "addressUid": 3340,
    ...    "emailAddressUid": 3440,
    ...    "tableAbbrev": "ENT",
    ...    "deliveryFormat": "PDFAttachment"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/letters/generateLetter    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Unexpected character encountered while parsing value: X. Path 'objectUid', line 2, position 18.


FLXPRM-1107
    [Tags]    P3    FLXPRM-1107    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1107
    ...    In Order To have create new communication with a customer
    ...    As A Flex User
    ...    I Want to be able to quickly generate a letter to a customer from the Flex UI while on the customer record

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to an active email
    ${getEmail}    Query    SELECT * FROM cor_email WHERE coe_rank = 1
    Log Many       @{getEmail}

    # Send a query the address information
    ${getAddress}    Query    SELECT * FROM cor_address WHERE cor_uid = ${getEmail[0][0]}
    Log Many         @{getAddress}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "objectUid": ${getAddress[0][2]},
    ...    "reportUid": 20,
    ...    "addressUid": ${getAddress[0][0]},
    ...    "emailAddressUid": ${getEmail[0][0]},
    ...    "tableAbbrev": "ENT",
    ...    "deliveryFormat": "PDFAttachment"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/letters/generateLetter    status_code=200    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["responseStatus"]}    SUCCESS


FLXPRM-1048
    [Tags]    P2    FLXPRM-1048
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1048
    ...    Given I have a valid Email Address record leaving Email value in blank
    ...    When I edit the email address and execute the service
    ...    Then The response shows the status code “500“ and the message: "ORA-01407: cannot update (\"FLEXADMIN\".\"COR_EMAIL\".\"COE_EMAIL_ADDRESS\") to NULL"

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    Select * FROM cor_email WHERE ROWNUM < 10
    Log Many     @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "type": ${getUid[0][1]},
    ...    "email": ""
    ...  }
    
    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${getUid[0][0]}    status_code=400    data=${request_body}
    
    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    The Email Address [] is related to an unsupported object.


FLXPRM-1050
    [Tags]    P2    FLXPRM-1050
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1050
    ...    Given I have a valid Email Address record
    ...    When I edit the email address and execute the service
    ...    Then The response shows the status code “200“ and a Success message.

    # Create a random email address
    ${email}    Generate Random String    8
    ${email}    Catenate    ${email}@mail.com

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUidBefore}    Query    Select * FROM cor_email WHERE ROWNUM < 10
    Log Many           @{getUidBefore}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "type": ${getUidBefore[0][1]},
    ...    "email": "${email}",
    ...    "permitForSale": true,
    ...    "sourceObjectType": ${getUidBefore[0][9]},
    ...    "sourceObjectUid": ${getUidBefore[0][2]}
    ...  }
    
    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${getUidBefore[0][0]}    status_code=200    data=${request_body}

    # Send a query
    ${getUidAfter}     Query    Select * FROM cor_email WHERE ROWNUM < 10
    Log Many           @{getUidAfter}
    
    # Compare Results
    Should Not Be Equal    ${getUidBefore[0][4]}    ${getUidAfter[0][4]}


FLXPRM-1001
    [Tags]    P2    FLXPRM-1001    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1001
    ...    Given I want to view an email record after it was removed
    ...    When I execute the view Email Address service
    ...    Then The response shows status code “404“ and the message:  "EmailAddress with ID of 168875 does not exist in the database."

    # Create a random email address
    ${email}    Generate Random String    8
    ${email}    Catenate    ${email}@mail.com

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get email info
    ${getemailinfo}    Query    Select * FROM cor_email WHERE ROWNUM < 10
    Log Many           @{getemailinfo}

    # Send a query to get the correct type
    ${gettypeUid}    Query    SELECT * FROM coe_add_type_lkp WHERE cel_uid > 1
    Log Many         @{gettypeUid}

    # Send endpoit to create a new email
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "type": ${gettypeUid[0][0]},
    ...    "email": "${email}",
    ...    "permitForSale": true,
    ...    "sourceObjectType": ${getemailinfo[0][9]},
    ...    "sourceObjectUid": ${getemailinfo[0][2]}
    ...  }

    ${response}        Send API Call    post    FlexAPI    ${base_URL}    /api/v1/emailaddresses    status_code=201    data=${request_body}

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE coe_email_address LIKE '${email}'
    Log Many     @{getUid}

    # Send endpoit to delete the created email
    ${response}        Send API Call    delete    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${getUid[0][0]}    status_code=200    

    # Send a Get request to validate that the email was removed
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${getUid[0][0]}    status_code=404
    
    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    EmailAddress with ID of ${getUid[0][0]} does not exist in the database.


FLXPRM-996
    [Tags]    P2    FLXPRM-996
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-996
    ...    Given I want to view an email record type “Other” inserting a valid record UID on the endpoint
    ...    When I execute the view Email Address service
    ...    Then The response shows status code “200“ and a success message having the inserted address information

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE cel_uid_type = 1
    Log Many     @{getUid}

    # Send a Get request to validate that the email was removed
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${getUid[0][0]}    status_code=200
    
    # Compare Results
    Should Be Equal    ${response["status"]["responseStatus"]}    SUCCESS


FLXPRM-994
    [Tags]    P2    FLXPRM-994    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-994
    ...    Given I want to view an email record type “Appeal” inserting a valid record UID on the endpoint
    ...    When I execute the view Email Address service
    ...    Then The response shows status code “200“ and a success message having the inserted address information

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE cel_uid_type = 2002
    Log Many     @{getUid}

    # Send a Get request to validate that the email was removed
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${getUid[0][0]}    status_code=200
    
    # Compare Results
    Should Be Equal    ${response["status"]["responseStatus"]}    SUCCESS


FLXPRM-995
    [Tags]    P2    FLXPRM-995    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-995
    ...    Given I want to view an email record type “Home/Personal” inserting a valid record UID on the endpoint
    ...    When I execute the view Email Address service
    ...    Then The response shows status code “200“ and a success message having the inserted address information

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE cel_uid_type = 2000
    Log Many     @{getUid}

    # Send a Get request to validate that the email was removed
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${getUid[0][0]}    status_code=200
    
    # Compare Results
    Should Be Equal    ${response["status"]["responseStatus"]}    SUCCESS


FLXPRM-997
    [Tags]    P2    FLXPRM-997    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-997
    ...    Given I want to view an email record type “Work/School” inserting a valid record UID on the endpoint
    ...    When I execute the view Email Address service
    ...    Then The response shows status code “200“ and a success message having the inserted address information

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE cel_uid_type = 2001 AND ROWNUM < 10
    Log Many     @{getUid}

    # Send a Get request to validate that the email was removed
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/emailaddresses/${getUid[0][0]}    status_code=200
    
    # Compare Results
    Should Be Equal    ${response["status"]["responseStatus"]}    SUCCESS


FLXPRM-1060
    [Tags]    P3    FLXPRM-1060    
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1060

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM entity WHERE ROWNUM < 10
    Log Many           @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "to": "bd-luiz.meireles@t2systems.com",
    ...    "cc": "XXXYZ",
    ...    "bcc": "",
    ...    "subject": "testin",
    ...    "body": "testing",
    ...    "manuallyEnteredTo": true
    ...  }
    
    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}/sendemail    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Email Could Not Be Sent To 'bd-luiz.meireles@t2systems.com; XXXYZ': The specified string is not in the form required for an e-mail address.

FLXPRM-1061
    [Tags]    P3    FLXPRM-1061    
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1061

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM entity WHERE ROWNUM < 10
    Log Many           @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "to": "bd-luiz.meireles@t2systems.com",
    ...    "cc": "",
    ...    "bcc": "XXYZ",
    ...    "subject": "testin",
    ...    "body": "testing",
    ...    "manuallyEnteredTo": true
    ...  }
    
    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}/sendemail    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Email Could Not Be Sent To 'bd-luiz.meireles@t2systems.com; XXYZ': The specified string is not in the form required for an e-mail address.


FLXPRM-1058
    [Tags]    P3    FLXPRM-1058    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1058

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM entity WHERE ROWNUM < 10
    Log Many           @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "to": "bd-luiz.meireles@t2systems.com",
    ...    "cc": "",
    ...    "bcc": "",
    ...    "subject": "testin",
    ...    "body": "testing",
    ...    "manuallyEnteredTo": true
    ...  }
    
    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/entities/${getUid[0][0]}/sendemail    status_code=200    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["responseStatus"]}    SUCCESS


FLXPRM-1074
    [Tags]    P3    FLXPRM-1074    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1074

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE ROWNUM < 10
    Log Many           @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "orderedAddressUids": [
    ...    ${getUid[0][0]},
    ...    ${getUid[1][0]},
    ...    ${getUid[2][0]}
    ...    ]
    ...  }
    
    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailaddresses/priority    status_code=200    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["responseStatus"]}    SUCCESS


FLXPRM-1075
    [Tags]    P3    FLXPRM-1075    NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1075

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE ROWNUM < 10
    Log Many           @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "orderedAddressUids": [
    ...    ${getUid[0][0]},
    ...    999999,
    ...    ${getUid[2][0]}
    ...    ]
    ...  }
    
    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailaddresses/priority    status_code=404    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    EmailAddress with ID of 999999 does not exist in the database.


FLXPRM-1076
    [Tags]    P3    FLXPRM-1076   NotReady
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1076

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE ROWNUM < 10
    Log Many           @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "orderedAddressUids": [
    ...    ${getUid[0][0]},
    ...    162XXXX2,
    ...    ${getUid[2][0]}
    ...    ]
    ...  }
    
    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailaddresses/priority    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Input string '162XXXX2' is not a valid integer. Path 'orderedAddressUids[1]', line 5, position 8.


FLXPRM-1077
    [Tags]    P3    FLXPRM-1077
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1077

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE ROWNUM < 10
    Log Many           @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "orderedAddressUids": [
    ...    ${getUid[0][0]},
    ...    16200022222222222222222222222222222,
    ...    ${getUid[2][0]}
    ...    ]
    ...  }
    
    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailaddresses/priority    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    JSON integer 16200022222222222222222222222222222 is too large or small for an Int32. Path 'orderedAddressUids[1]', line 1, position 67.



FLXPRM-1381
    [Tags]    P3    FLXPRM-1381    
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1381
    ...    Given the endpoint is successfully connected to the service
    ...    When I send a valid request to the endpoint having an invalid table on the endpoint
    ...    Then the response shows the message: "Invalid tableAbbrev"

    # Send a Get request to validate that the email was removed
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/letters?tableAbbrev=XXX&objectuid=9999        status_code=500
    
    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Invalid tableAbbrev


FLXPRM-972
    [Tags]    P2    FLXPRM-972
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-972
    ...    Given I have the Edit Citation Privilege and not inserting value for transferAgency
    ...    When I execute the service
    ...    Then the response shows the message: "Error converting value {null} to type 'System.Int32'.

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Object Uid
    ${getUid}=    Query    SELECT * FROM contravention WHERE ROWNUM < 10
    Log Many      @{getUid} 

    # Send a POST to transfer agency
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "transferAgency": 2001,
    ...    "pendingTransferDate": "2022-10-07T04:00:00Z"
    ...  }

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/contraventions/${getUid[0][0]}/transferfine    status_code=400    data=${request_body}


    Should Be Equal    ${response["status"]["errors"][0]["message"]}        Citation (NEWCIT0004) is not in the correct status to be transferred.


FLXPRM-1368
    [Tags]    P3    FLXPRM-1368    
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1368
    ...    Service: Bulk Permit Content Manager- invalid request

    # Send a Get request to validate that the email was removed
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/999999/EntityBulkPermit?includeHistorical=false&includeContentManagerMetadata=true&page=0&size=200        status_code=404
    
    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Entity with ID of 999999 does not exist in the database.


FLXPRM-1233
    [Tags]    P3    FLXPRM-1233    
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1233
    ...    Service: Properties Content Manager - invalid request

    # Send a Get request to validate that the email was removed
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/999999/EntityProperty?includeHistorical=true&includeContentManagerMetadata=true        status_code=404
    
    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Entity with ID of 999999 does not exist in the database.


FLXPRM-1400
    [Tags]    P2    FLXPRM-1400    
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1400
    ...    Given there is a customer record associated with the email address
    ...    When I execute the service Customer/Email Content Manager
    ...    Then I see the status code “200“ and the customer record displayed on the response
    ...    And the associated customer is visible on the DB

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM entity WHERE coe_uid_hghst_rnked_emil_cac IS NOT NULL AND ROWNUM < 10 ORDER BY ent_uid DESC
    Log Many     @{getUid}

    # Send a query
    ${emailUid}  Query   SELECT * FROM cor_email WHERE ent_uid_entity = ${getUid[0][0]}
    Log Many     @{emailUid}

    # Send a Get request to validate that the email was removed
    ${response}        Send API Call    get    FlexAPI    ${base_URL}    /api/v1/entities/${emailUid[0][0]}/EmailAddressCustomer?includeHistorical=false&includeContentManagerMetadata=true   status_code=200
    
    # Compare Results
    Should Be Equal    ${response["response"]["content"][0]["HighestRankedEmailAddress"]["email"]}        ${emailUid[0][4]}


FLXPRM-1524
    [Tags]    P3    FLXPRM-1524    
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1524
    ...    Given there is an associated email address with the customer
    ...    When I execute the service Customer/Email Relations inserting invalid emailUID
    ...    Then I see the status code “404“ and the message: "EmailAddress with ID of 99999999 does not exist in the database."

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "tableAbbrev": "ENT",
    ...    "sourceObjUid": "2005",
    ...    "startDate": "2022-12-06T11:00:00.970Z",
    ...    "endDate": "2022-12-12T11:00:00.970Z"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailAddresses/99999999/relation    status_code=404    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    EmailAddress with ID of 99999999 does not exist in the database.


FLXPRM-1522
    [Tags]    P3    FLXPRM-1522    
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1522
    ...    Given there is an associated email address with the customer
    ...    When I execute the service Customer/Email Relations inserting a past date on endDate
    ...    Then I see the status code “400“ and the message: "Relationship End Date must be later than the Start Date. "
    
    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE ROWNUM < 10
    Log Many           @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "tableAbbrev": "ENT",
    ...    "sourceObjUid": "${getUid}[0][2]",
    ...    "startDate": "2022-12-06T11:00:00.970Z",
    ...    "endDate": "2022-10-30T11:00:00.970Z"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailAddresses/${getUid[0][0]}/relation    status_code=400    data=${request_body}

    # Compare Results
    Set Test Variable    ${message}       ${response["status"]["errors"][0]["message"]}
    ${message}           Strip String     ${message}
    Should Be Equal    ${message}    Relationship End Date must be later than the Start Date.


FLXPRM-1520
    [Tags]    P3    FLXPRM-1520
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1520
    ...    Given there is an associated email address with the customer
    ...    When I execute the service Customer/Email Relations
    ...    Then I see the status code “400“ and the message: Error converting value {null}

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE ROWNUM < 10
    Log Many           @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "tableAbbrev": "ENT",
    ...    "sourceObjUid": "${getUid}[0][2]",
    ...    "startDate": null,
    ...    "endDate": "2022-12-12T11:00:00.970Z"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailAddresses/${getUid[0][0]}/relation    status_code=400    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Error converting value {null} to type 'System.DateTime'. Path 'startDate', line 1, position 65.


FLXPRM-1523
    [Tags]    P3    FLXPRM-1523    
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1523
    ...    Given there is an associated email address with the customer
    ...    When I execute the service Customer/Email Relations inserting invalid EntUID
    ...    Then I see the status code “404“ and the message: "Entity with ID of 99999999 does not exist in the database."

    # Connect to AUTOQA3 oracle database
    Create Session    FlexAPI    ${base_URL}
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query
    ${getUid}    Query    SELECT * FROM cor_email WHERE ROWNUM < 10
    Log Many           @{getUid}

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "tableAbbrev": "ENT",
    ...    "sourceObjUid": "999999",
    ...    "startDate": "2022-12-06T11:00:00.970Z",
    ...    "endDate": "2022-12-12T11:00:00.970Z"
    ...  }

    ${response}        Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailAddresses/${getUid[0][0]}/relation    status_code=404    data=${request_body}

    # Compare Results
    Should Be Equal    ${response["status"]["errors"][0]["message"]}    Entity with ID of 999999 does not exist in the database.


FLXPRM-1519
    [Tags]    P3    FLXPRM-1519
    [Documentation]    https://t2systems.atlassian.net/browse/FLXPRM-1519
    ...    Given there is an associated email address with the customer
    ...    When I execute the service Customer/Email Relations
    ...    Then I see the status code “200“ and the message “Success“

    # Connect to AUTOQA3 oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    # Send a query to get the Object Uid
    ${emailUid}=    Query    SELECT * FROM cor_email WHERE coe_end_date IS NULL
    Log Many      @{emailUid} 

    # Send a request to edit Classification
    ${headers}=          Create Dictionary    Content-type=application/json
    ${request_body}=     Catenate
    ...  {
    ...    "tableAbbrev": "ENT",
    ...    "sourceObjUid": "${emailUid}[0][2]",
    ...    "startDate": "2022-12-06T11:00:00.970Z",
    ...    "endDate": "2022-12-12T11:00:00.970Z"
    ...  }

    # Send a call to the synonyms endpoint
    ${response}=    Send API Call    put    FlexAPI    ${base_URL}    /api/v1/emailAddresses/${emailUid[0][0]}/relation    status_code=200    data=${request_body}

    ${emailafter}=   Query    SELECT * FROM cor_email WHERE coe_uid = ${emailUid[0][0]}

    # Compare Results
    ${emailafter[0][11]}    Convert To String         ${emailafter[0][11]}
    Should Be Equal        ${emailafter[0][11]}       0
