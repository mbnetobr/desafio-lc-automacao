*** Settings ***
Library            SeleniumLibrary
Library            String
Library            ExcellentLibrary
Variables          ../Variables/locators.py

*** Variables ***
${browser}                               headlesschrome
${url}                                   https://www.amazon.com.br/
${Xls_Menu}                              ${CURDIR}/../Data/Amazon.xlsx
${UserName}                              joseautomationtest@gmail.com
${Password}                              123456


*** Keywords ***
Abrir o navegador
    Open Browser                         browser=${browser}   options=add_experimental_option('excludeSwitches', ['enable-logging']);add_argument("--window-size=1920,1080")    #;add_argument("--incognito")
    Maximize Browser Window
    Set Selenium Implicit Wait           10s

Fechar o navegador
    Capture Page Screenshot
    Close All Browsers

Acessar a home page do site Amazon.com
    Go To                                ${url}
    Title Should Be                      Amazon.com.br | Tudo pra você, de A a Z.

Validar todos os menus do site
    Open Workbook                        ${Xls_Menu}
    Switch Sheet                         Menu
    ${Row}    Get Row Count
    ${Row}    Evaluate                   ${Row} + 1
    FOR    ${counter}    IN RANGE   2    ${Row}
        ${Menu}    Read From Cell        (1,${counter})
        ${Titulo}  Read From Cell        (2,${counter})
        ${Opt_Menu}    Replace String    ${Opt_Menu}            MENU            ${Menu}
        Click Element                    ${Opt_Menu}
        Wait Until Element Is Visible    ${Lbl_Voltar}
        Title Should Be                  ${Titulo}
        ${Opt_Menu}    Replace String    ${Opt_Menu}            ${Menu}         MENU
    END
    Close Workbook

Digitar o nome do produto no campo de pesquisa
    [Arguments]                          ${produto}
    Set Test Variable                    ${produto}
    Input Text                           ${Txt_Busca}           ${produto}

Clicar no botão de pesquisa
    Click Element                        ${Ico_Lupa}

Verificar o resultado da pesquisa, listando o produto pesquisado
    ${Disponivel}    Run Keyword And Return Status              Element Should Be Visible      ${Lbl_Disponivel}
    IF    ${Disponivel} == True
        Fail                             O produto ${produto} não foi encontrado no site
    END

Adicionar o produto escolhido no carrinho
    ${Lbl_Produto}    Replace String     ${Lbl_Produto}         PRODUTO                ${produto}
    ${Preco}          Get Text           (${Lbl_Produto}${Lbl_PrecoUnico})[1]
    Set Test Variable                    ${Preco}
    Click Element                        ${Lbl_Produto}
    Click Element                        ${Btn_AddCarrinho}

Verificar se o produto escolhido foi adicionado com sucesso
    Element Should Be Visible            ${Lbl_Adicionado}

Remover o produto escolhido do carrinho
    Click Link                           ${Lnk_IrCarrinho}
    Click Element                        ${Lnk_ExcluirProduto}

Verificar se o carrinho fica vazio
    Element Should Be Visible            ${Lbl_CarrinhoVazio}

Clicar no link Comece aqui
    Mouse Over                           ${Lbl_Contas}
    Click Link                           ${Lnk_ComeceAqui}

Preencher formulário de cadastrar novo usuario
    ${Nome}     Generate Random String   8
    ${Surname}  Generate Random String   6
    ${Email}    Generate Random String   8
    ${Senha}    Generate Random String   6
    Input Text                           ${Txt_Nome}            ${Nome} ${Surname}
    Input Text                           ${Txt_Email}           ${Email}@teste.com
    Input Password                       ${Txt_Senha}           ${Senha}
    Input Password                       ${Txt_RepeatSenha}     ${Senha}
    Click Element                        ${Btn_Continuar}

Validar que o link de validação foi enviado por email
    Page Should Contain                  Verificar o endereço de e-mail

Selecionar o menu
    [Arguments]                          ${Menu}
    ${Opt_Menu}     Replace String       ${Opt_Menu}            MENU            ${Menu}
    Click Element                        ${Opt_Menu}

Selecionar o submenu
    [Arguments]                          ${SubMenu}
    ${Lnk_SubMenu}  Replace String       ${Lnk_SubMenu}         SUBMENU         ${SubMenu}
    Click Link                           ${Lnk_SubMenu}

Marcar a opção
    [Arguments]                          ${Option}
    ${Opt_Opcao}    Replace String       ${Opt_Opcao}           OPCAO           ${Option}
    Click Element                        ${Opt_Opcao}

Selecionar o produto de maior valor
    ${index}    Get Element Count        ${Lbl_Preco}
    ${index}    Evaluate                 ${index} + 1
    ${MaiorValor}   Set Variable         0
    FOR    ${counter}    IN RANGE        1                      ${index}
        ${PrecoAtual}    Get Text        (${Lbl_Preco})[${counter}]
        ${PrecoAtual}    Convert To Number                      ${PrecoAtual}
        IF    ${PrecoAtual} > ${MaiorValor}
            ${MaiorValor}                Set Variable           ${PrecoAtual}
        END
    END
    ${MaiorValor}    Convert To String   ${MaiorValor}
    Set Test Variable                    ${produto}             ${MaiorValor}
    ${Lbl_Produto}    Replace String     ${Lbl_Produto}         PRODUTO                ${produto}
    ${Preco}          Get Text           ${Lbl_Produto}
    Set Test Variable                    ${Preco}
    Click Element                        ${Lbl_Produto}
    Click Element                        ${Btn_AddCarrinho}

Clicar no botão Faça seu login
    Mouse Over                           ${Lbl_Contas}
    Click Element                        ${Btn_Login}

Realizar login no site da Amazon
    Clicar no botão Faça seu login
    Input Text                           ${Txt_Email}           ${UserName}
    Click Element                        ${Btn_Continuar}
    Input Text                           ${Txt_Senha}           ${Password}
    Click Element                        ${Btn_FazerLogin}

Clicar no botão ir para o carrinho
    Click Link                           ${Btn_IrCarrinho}

Aguardar pagina carregar
    Wait Until Element Is Not Visible    ${Ico_Loading}