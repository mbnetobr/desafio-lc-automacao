*** Settings ***
Resource           homepage_keywords.robot
Variables          ../Variables/locators.py

*** Variables ***
${Telefone}                          41999999999
${CEP}                               80035260
${Numero}                            33
${Complemento}                       Apt 31 B
${Bairro}                            Cabral

*** Keywords ***
Validar que a quantidade de produtos e valores estão corretos no carrinho
    Element Should Contain           ${Lbl_SubTotal}                Subtotal (1 item):
    ${CheckPrice}    Get Text        ${Lbl_CheckPrice}
    ${CheckPrice}    Remove String   ${CheckPrice}                  R$
    ${CheckPrice}    Strip String    ${CheckPrice}
    Should Be Equal                  ${CheckPrice}                  ${Preco}

Clicar no botão fechar pedido
    Click Element                    ${Btn_FecharPedido}

Preencher endereço para envio do produto
    Input Text                       ${Txt_Telefone}                ${Telefone}
    Input Text                       ${Txt_Cep}                     ${CEP}
    Set Focus To Element             ${Txt_Endereco}
    Sleep                            2s
    Input Text                       ${Txt_ResNumero}               ${Numero}
    Input Text                       ${Txt_ResComplemento}          ${Complemento}
    Click Element                    ${Btn_UsarEndereco}

Selecionar forma de pagamento
    [Arguments]                      ${MeioPag}
    Run Keyword If                   "${MeioPag}" == "Boleto"       Click Element            ${Ico_Boleto}
    ...    ELSE IF                   "${MeioPag}" == "PIX"          Click Element            ${Ico_Pix}
    ...    ELSE IF                   "${MeioPag}" == "Cartão"       Click Element            ${Btn_AddCartao}
    Click Element                    ${Btn_ContinuePedido}

Clicar no botão confirmar pedido
    Click Element                    ${Btn_ConfirmPedido}

Validar que o pedido foi realizado
    Page Should Contain              Obrigado, Seu pedido foi feito e será processado após o pagamento do Boleto