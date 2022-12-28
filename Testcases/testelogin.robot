*** Settings ***
Library            DataDriver    ../Data/login.csv
Resource           ../Pages/homepage_keywords.robot
Test Setup         Abrir o navegador
Test Teardown      Fechar o navegador
Test Template      Validar logins

*** Test Cases ***
${Test_Case}
    [Documentation]        Este teste irá testar as variações do login sem no entanto
    ...                    precisar criar um teste diferente para cada situação.
    [Tags]                 login

*** Keywords ***
Validar logins
    [Arguments]                      ${Usuario}                  ${Senha}                 ${Mensagem}
    ${Mensagem}  Convert To String   ${Mensagem}
    Acessar a home page do site Amazon.com
    Clicar no botão Faça seu login
    Input Text                       ${Txt_Email}                ${Usuario}
    Click Element                    ${Btn_Continuar}
    ${HasPass}    Run Keyword And Return Status    Element Should Be Visible              ${Txt_Senha}
    IF    ${HasPass} == True
        Input Text                   ${Txt_Senha}                ${Senha}
        Click Element                ${Btn_FazerLogin}
    END
    Page Should Contain              ${Mensagem}