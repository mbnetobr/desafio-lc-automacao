*** Settings ***
Library          SeleniumLibrary
Library          String
Library          Collections
Library          ExcellentLibrary
Library          DatabaseLibrary
Variables        ../../Resources/locators.py

*** Variables ***
${Xls_TablesName}                        ${CURDIR}/../../Data/Tables.xlsx

*** Keywords ***
Click on Advanced Search from the left menu
    Click Element                        ${Lbl_AdvSearch}

Click on the Search Type dropdown and select the table with a single name
    [Arguments]                          ${TableName}
    Click Element                        ${Lst_SearchType}
    ${Opt_TableName}    Replace String   ${Opt_TableName}                     TABLE NAME        ${TableName}
    Scroll Element Into View             ${Opt_TableName}
    Click Element                        ${Opt_TableName}

Click on the Search Type dropdown and select the table
    [Arguments]                          ${TableName}
    Click Element                        ${Lst_SearchType}
    ${Opt_SingleTable}  Replace String   ${Opt_SingleTable}                     TABLE NAME        ${TableName}
    Scroll Element Into View             ${Opt_SingleTable}
    Click Element                        ${Opt_SingleTable}

Select a boolean condition field from Conditions box
    Click Element                        ${Lbl_Field}
    Scroll Element Into View             ${Opt_FieldIsActive}
    Click Element                        ${Opt_FieldIsActive}
    Click Element                        ${Lbl_Operator}
    Sleep                                500ms
    Click Element                        ${Opt_OperIs}
    Click Element                        ${Lbl_Value}
    Click Element                        ${Opt_ValueTrue}

Select a second boolean condition field from Conditions box
    Click Element                        ${Lbl_Field2}
    Scroll Element Into View             ${Opt_FieldIsHistorical}
    Click Element                        ${Opt_FieldIsHistorical}
    Click Element                        ${Lbl_Operator2}
    Sleep                                500ms
    Click Element                        ${Opt_OperIs}
    Click Element                        ${Lbl_Value2}
    Click Element                        ${Opt_ValueFalse}

Select a third boolean condition field from Conditions box
    Click Element                        ${Lbl_Field3}
    Scroll Element Into View             ${Opt_FieldCountry}
    Click Element                        ${Opt_FieldCountry}
    Click Element                        ${Lbl_Operator3}
    Click Element                        ${Opt_OperContains}
    Input Text                           ${Txt_ValueInput2}                   Unit

Select a no boolean condition field from Conditions box
    Click Element                        ${Lbl_Field2}
    Click Element                        ${Opt_FieldCity}
    Click Element                        ${Lbl_Operator2}
    Click Element                        ${Opt_OperBegins}
    Input Text                           ${Txt_ValueInput}                    C

Select the Field from Conditions box
    [Arguments]                          ${Search}                            ${Position}
    Set Test Variable                    ${Search}
    Click Element                        (${Lbl_Field})[${Position}]
    ${Opt_FieldCondition}                Replace String                       ${Opt_FieldCondition}    SEARCH CONDITION    ${Search}
    Scroll Element Into View             ${Opt_FieldCondition}    
    Click Element                        ${Opt_FieldCondition}

Select the single Field from Conditions box
    [Arguments]                          ${Search}                            ${Position}
    Set Test Variable                    ${Search}
    Run Keyword If                       ${Position} == 1                     Click Element            ${Lbl_Field}
    Run Keyword If                       ${Position} == 2                     Click Element            ${Lbl_Value}
    ${Opt_SingleCondition}               Replace String                       ${Opt_SingleCondition}   SEARCH CONDITION    ${Search}
    Scroll Element Into View             ${Opt_SingleCondition}    
    Click Element                        ${Opt_SingleCondition}

Select the Operator from Conditions box
    [Arguments]                          ${Operator}                          ${Position}
    Click Element                        (${Lbl_Operator})[${Position}]
    # Run Keyword If                       ${Position} == 1                     Click Element            ${Lbl_Operator}
    Sleep                                500ms
    ${Opt_Operator}    Replace String    ${Opt_Operator}                      OPERATOR NAME            ${Operator}
    Scroll Element Into View             ${Opt_Operator}
    Click Element                        ${Opt_Operator}

Select the value from Value field
    [Arguments]                          ${Value}
    ${Opt_ValueBoolean}  Replace String  ${Opt_ValueBoolean}                  BOOLEAN                  ${Value}
    Click Element                        ${Lbl_Value}
    Sleep                                500ms
    Click Element                        ${Opt_ValueBoolean}

Select the look up value
    Click Element                        ${Lst_ValueType}

Click on Search button
    Click Element                        ${Btn_Search}

Validate the displayed message
    [Arguments]                          ${Message}
    ${Lbl_Message}    Replace String     ${Lbl_Message}    MESSAGE            ${Message}
    Wait Until Element Is Visible        ${Lbl_Message}
    Element Should Be Visible            ${Lbl_Message}

Click Add Condition button
    Click Element                        ${Btn_AddCondition}

Validate the search result
    Element Should Be Visible            ${Tab_Result}

Wait until search ends
    Wait Until Element Is Not Visible    ${Lbl_Loading}                       15s

Input the value on the field
    [Arguments]                          ${Info}
    Set Test Variable                    ${Info}
    Input Text                           ${Txt_Contratc}                      ${Info}

Click on the column Header
    ${Tab_HeaderName}   Replace String   ${Tab_HeaderName}                    HEADER NAME              ${Search}
    Scroll Element Into View             ${Tab_HeaderName}
    Click Element                        ${Tab_HeaderName}

Validate that the currency has the correct formatting
    ${Currency}    Get WebElements       ${Tab_CellResult}
    ${RowCount}    Get Element Count     ${Tab_CellResult}
    ${RowCount}    Evaluate              ${RowCount} - 1
    FOR    ${counter}    IN RANGE   0    ${RowCount}
        ${Value}   Get Text              ${Currency[${counter}]}
        Should Match Regexp              ${Value}                             [$]\\d+.\\d{2}
    END

Validate that column is ordered in alphabetical order
    [Arguments]                          ${ColumnName}
    ${Tab_ColumnInfo}   Replace String   ${Tab_ColumnInfo}    CONDITION       ${ColumnName}
    ${CoulumnInfo}    Get WebElements    ${Tab_CellResult}
    ${Count}    Get Element Count        ${Tab_CellResult}
    ${Count}    Evaluate                 ${Count} - 1
    ${Actual}   Create List
    FOR    ${i}    IN RANGE         0    ${Count}
        ${Value}    Get Text             ${CoulumnInfo[${i}]}
        Append To List                   ${Actual}                            ${Value}
    END
    Log Many                             ${Actual}
    ${sorted_list}    Sort Custom List   ${Actual}
    Log Many                             ${sorted_list}
    Lists Should Be Equal                ${Actual}                            ${sorted_list}

Validate that column is ordered in descending order
    [Arguments]                          ${ColumnName}
    ${alphabet_reverse}    Set Variable  zyxwvutsrqpomnlkjihgfedcbaZYXWVUTSRQPOMNLKJIHGFEDCBA9876543210_${SPACE}${EMPTY}
    ${CoulumnInfo}    Get WebElements    ${Tab_CellResult}
    ${Count}    Get Element Count        ${Tab_CellResult}
    ${Count}    Evaluate                 ${Count} - 1
    ${Actual}   Create List
    FOR    ${i}    IN RANGE         0    ${Count}
        ${Value}    Get Text             ${CoulumnInfo[${i}]}
        Append To List                   ${Actual}                            ${Value}
    END
    Log Many                             ${Actual}
    ${sorted_list}   Sort Custom List    ${Actual}                            ${alphabet_reverse}
    Log Many                             ${sorted_list}
    Lists Should Be Equal                ${Actual}                            ${sorted_list}

Validate that column is ordered in pre-defined alphabetical order
    [Arguments]                          ${ColumnName}
    ${Tab_ColumnInfo}   Replace String   ${Tab_ColumnInfo}    CONDITION       ${ColumnName}
    ${CoulumnInfo}    Get WebElements    ${Tab_ColumnInfo}
    ${Count}    Get Element Count        ${Tab_ColumnInfo}
    ${Actual}   Create List
    FOR    ${i}    IN RANGE         0    ${Count}
        ${Value}    Get Text             ${CoulumnInfo[${i}]}
        Append To List                   ${Actual}                            ${Value}
    END
    Log Many                             ${Actual}
    ${Sorted}    Evaluate                sorted(${Actual}, key=lambda v: v.upper())
    Log Many                             ${Sorted}
    Lists Should Be Equal                ${Actual}                            ${Sorted}

Validate that the search values displayed are sorted in alphabetical order
    ${ListValues}    Get WebElements     ${Lst_ListValue}
    ${Count}    Get Element Count        ${Lst_ListValue}
    ${Actual}   Create List
    FOR    ${i}    IN RANGE         2    ${Count}
        ${Value}    Get Text             ${ListValues[${i}]}
        Append To List                   ${Actual}                            ${Value}
    END
    Log Many                             ${Actual}
    ${Sorted}    Evaluate                sorted(${Actual}, key=lambda v: v.upper())
    Log Many                             ${Sorted}
    Lists Should Be Equal                ${Actual}                            ${Sorted}

Close the list
    ${ListValues}    Get WebElements     ${Lst_ListValue}
    Click Element                        ${ListValues[0]}

Include column
    [Arguments]                          ${ColumnNumber}
    ${Column}    Get WebElements         ${Chk_Columns}
    Click Element                        ${Column[${ColumnNumber}]}

Include column to the search
    [Arguments]                          ${ColumnName}
    ${Chk_ColumnName}   Replace String   ${Chk_ColumnName}                    COLUMN NAME          ${ColumnName}
    Scroll Element Into View             ${Chk_ColumnName}
    Click Element                        ${Chk_ColumnName}

Click on the first element found for the search
    [Arguments]                          ${SearchElement}
    Run Keyword If                       '${SearchElement}' == 'License Plate'    Click Element    ${Tab_PlateColumn1}
      ...  ELSE IF                       '${SearchElement}' == 'Drivers License'  Click Element    ${Tab_DriverColumn1}
      ...  ELSE IF                       '${SearchElement}' == 'Primary Street'   Click Element    ${Tab_PrimStreet}
      ...  ELSE IF                       '${SearchElement}' == 'Vehicle UID'      Click Element    ${Tab_VehicleUID}
      ...  ELSE IF                       '${SearchElement}' == 'Primary Email'    Click Element    ${Tab_PrimEmail}
      ...  ELSE IF                       '${SearchElement}' == 'Account Balance'  Click Element    ${Tab_AccountBalance}
      ...  ELSE IF                       '${SearchElement}' == 'Disallow Checks'  Click Element    ${Tab_DisallowChecks}
    IF    '${SearchElement}' == 'Customer UID'
        Click Element                    ${Lbl_CollumnName}
        Click Element                    ${Lbl_CollumnName}
        Sleep                            1s
        Click Element                    ${Tab_Customer}
    END

Select Value field info
    [Arguments]                          ${Value}
    Click Element                        ${Opt_Status}
    ${Lst_Status}    Replace String      ${Lst_Status}                        CHOOSE STATUS        ${Value}
    Sleep                                500ms
    Click Element                        ${Lst_Status}

Choose bolean value
    [Arguments]                          ${Boolean}
    Click Element                        ${Lbl_Field3}
    ${Lst_Status}    Replace String      ${Lst_Status}                        CHOOSE STATUS        ${Boolean}
    Sleep                                500ms
    Click Element                        ${Lst_Status}

Select a boolean value
    [Arguments]                          ${Boolean}
    ${Lst_Status}    Replace String      ${Lst_Status}                        CHOOSE STATUS        ${Boolean}
    Sleep                                500ms
    Click Element                        ${Lst_Status}

Read file and validate information for an invalid sheet
    [Arguments]                          ${SheetName}
    Open Workbook                        ${Xls_TablesName}
    Switch Sheet                         ${SheetName}
    ${Row}        Get Row Count
    ${Row}        Evaluate               ${Row} - 1
    FOR    ${counter}    IN RANGE   2    ${Row}
        ${TableName}   Read From Cell    (1,${counter})
        ${FiedlName}   Read From Cell    (2,${counter})
        ${Operator}    Read From Cell    (3,${counter})
        ${Message}     Read From Cell    (4,${counter})
        Click on the Search Type dropdown and select the table                ${TableName}
        Select the Field from Conditions box                                  ${FiedlName}      1
        Select the Operator from Conditions box                               ${Operator}       1
        Click on Search button
        Validate the displayed message                                        ${Message}
    END
    Close Workbook

Read file and validate information for a valid sheet
    [Arguments]                          ${SheetName}
    Open Workbook                        ${Xls_TablesName}
    Switch Sheet                         ${SheetName}
    ${Row}        Get Row Count
    ${Row}        Evaluate               ${Row} - 1
    FOR    ${counter}    IN RANGE   2    ${Row}
        ${TableName}   Read From Cell    (1,${counter})
        ${FiedlName}   Read From Cell    (2,${counter})
        ${Operator}    Read From Cell    (3,${counter})
        ${Value}       Read From Cell    (4,${counter})
        ${Message}     Read From Cell    (5,${counter})
        Click on the Search Type dropdown and select the table                ${TableName}
        Select the Field from Conditions box                                  ${FiedlName}      1
        Select the Operator from Conditions box                               ${Operator}       1
        Input the value on the field     ${Value}
        Click on Search button
        Wait Until Element Is Visible    ${Tab_CellResult}
        Element Should Be Visible        ${Tab_CellResult}
    END
    Close Workbook

Read file and validate information for a valid boolean sheet
    [Arguments]                          ${SheetName}
    Open Workbook                        ${Xls_TablesName}
    Switch Sheet                         ${SheetName}
    ${Row}        Get Row Count
    ${Row}        Evaluate               ${Row} - 1
    FOR    ${counter}    IN RANGE   2    ${Row}
        ${TableName}   Read From Cell    (1,${counter})
        ${FiedlName}   Read From Cell    (2,${counter})
        ${Operator}    Read From Cell    (3,${counter})
        ${Value}       Read From Cell    (4,${counter})
        ${FiedlName2}  Read From Cell    (5,${counter})
        ${Operator2}   Read From Cell    (6,${counter})
        ${Message}     Read From Cell    (7,${counter})
        Click on the Search Type dropdown and select the table                ${TableName}
        Select the Field from Conditions box                                  ${FiedlName}      1
        Select the Operator from Conditions box                               ${Operator}       1
        Click Element                    ${Opt_Status}
        Select a boolean value           ${Value}
        Click Add Condition button
        Select the Field from Conditions box                                  ${FiedlName2}     2
        Select the Operator from Conditions box                               ${Operator2}      2
        Click on Search button
        Wait Until Element Is Visible    ${Tab_CellResult}
        Element Should Be Visible        ${Tab_CellResult}
    END
    Close Workbook

Choose the OR condition
    Click Element                         ${Btn_Or}

Compare the values of the results
    ${CustomerUid}    Get Text            ${Lbl_CollValue1}
    ${CustomerUid}    Convert To Integer  ${CustomerUid}
    ${EmailAddress}   Get Text            ${Lbl_CollValue2}
    ${EmailUid}       Get Text            ${Lbl_CollValue3}
    ${EmailUid}       Convert To Integer  ${EmailUid}
    ${IsActive}       Get Text            ${Lbl_CollValue4}
    ${IsActive}       Convert To Boolean  ${IsActive}
    ${Priority}       Get Text            ${Lbl_CollValue5}
    ${Priority}       Convert To Integer  ${Priority}
    ${Type}           Get Text            ${Lbl_CollValue6}
    Should Be Equal                       ${CustomerUid}                   ${getUid[0][0]}
    Should Be Equal                       ${EmailAddress}                  ${getUid[0][1]}
    Should Be Equal                       ${EmailUid}                      ${getUid[0][2]}
    Should Be Equal                       ${IsActive}                      ${getUid[0][3]}
    Should Be Equal                       ${Priority}                      ${getUid[0][4]}

Get a valid Uid from table cor_email
    # Connect to oracle database
    Connect To Database Using Custom Params  cx_Oracle  'flexadmin', 'ame3m', '${oracle_Host}'

    ${request_query}=     Catenate
    ...  SELECT ent_uid_entity, coe_email_address, coe_uid, coe_is_active_cac, coe_rank, CEL_UID_TYPE
    ...  FROM cor_email
    ...  Order by ent_uid_entity DESC

    # Send a query
    ${getUid}    Query    ${request_query}
    Log Many     @{getUid}
    Set Test Variable                    ${getUid}

Validate that the section has data
    [Arguments]                          ${SecName}
    ${Lbl_SecName}  Replace String       ${Lbl_SecName}        SECTION        ${SecName}
    Scroll Element Into View             ${Lbl_SecName}
    ${Count}    Get Element Count        ${Lbl_SecName}
    Run Keyword If                       ${Count} == 0                        Fail    There is no ${SecName} attached to this customer

Click the arrow to collapse the section
    [Arguments]                          ${Section}
    ${Ico_ArrowCollap}  Replace String   ${Ico_ArrowCollap}    CONTENT        ${Section}
    Scroll Element Into View             ${Ico_ArrowCollap}
    Click Element                        ${Ico_ArrowCollap}

Validate that the section was collapsed
    [Arguments]                          ${Section}
    ${Ico_ArrowExpand}  Replace String   ${Ico_ArrowExpand}    CONTENT        ${Section}
    Scroll Element Into View             ${Ico_ArrowExpand}
    Element Should Be Visible            ${Ico_ArrowExpand}


############### Auxiliary Keywords ###############
Sort Custom List
    [Documentation]
    ...    Sort a list using a custom sort order
    ...    
    ...    This keyword sorts a list according to a custom sort order 
    ...    when given, or the default one when not provided. 
    ...    
    ...    Arguments:
    ...    - input_list    {list}      a list of strings to be sorted.
    ...    - alphabeth     {string}    a string of characters according to which order they must be sorted.
    ...    
    ...    Returns:        {list}      the sorted list.
    ...    
    [Arguments]                          ${input_list}                        ${alphabet}=${SPACE}_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz

    ${ns}    Create Dictionary           alphabet=${alphabet}                 input_list=${input_list}

    ${sorted}    Evaluate                sorted(input_list, key=lambda word: [alphabet.index(c) for c in word])     namespace=${ns} 
    [Return]                             ${sorted}