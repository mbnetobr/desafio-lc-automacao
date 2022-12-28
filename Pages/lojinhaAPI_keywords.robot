*** Settings ***
Library                           RequestsLibrary
Library                           Collections
Library                           String

*** Variables ***
${BaseUrl}                        http://165.227.93.41/lojinha
${ProdCriado}                     {"produtonome": "B2Card", "produtovalor": 50.00, "produtocores": ["azul"], "componentes": [{"componentenome": "Automation", "componentequantidade": 1}]}

*** Keywords ***
######## SETUP E TEARDOWN - COMEÇO ########
Conectar API
    Create Session                   APILojinha              ${BaseUrl}
    Fazer login na API

Fazer login na API
    ${HEADERS}                        Create Dictionary      content-type=application/json
    ${resposta}                       POST On Session        APILojinha         ${BaseUrl}/login
    ...                               data={"usuariologin": "jcorreia", "usuariosenha": "123456"}
    ...                               headers=${HEADERS}
    ${Token}    Get From Dictionary   ${resposta.json()["data"]}                token
    Set Test Variable                 ${Token}

######## SETUP E TEARDOWN - FIM ########

Cadastrar um novo usuário
    ${username}    Generate Random String    6               [LETTERS]
    ${password}    Generate Random String    6
    ${HEADERS}                        Create Dictionary      content-type=application/json
    ${resposta_POST}                  POST On Session        APILojinha         ${BaseUrl}/usuario
    ...                               data={"usuarionome": "${username}", "usuariologin": "${username}", "usuariosenha": "${password}"}
    ...                               headers=${HEADERS}
    Log                               ${resposta_POST.text}
    Set Test Variable                 ${resposta_POST}

Validar que o usuário foi cadastrado corretamente
    Should Be Equal As Strings        ${resposta_POST.status_code}                   201
    Should Be Equal                   ${resposta_POST.reason}                        Created
    Should Be Equal                   ${resposta_POST.json()["message"]}             Usuário adicionado com sucesso

Cadastrar novo produto
    ${HEADERS}                        Create Dictionary      content-type=application/json        token=${Token}
    ${resposta_POST}                  POST On Session        APILojinha         ${BaseUrl}/produto
    ...                               data={"produtonome": "B2Card", "produtovalor": 50.00, "produtocores": ["azul"], "componentes": [{"componentenome": "Automation", "componentequantidade": 1}]}
    ...                               headers=${HEADERS}
    Log                               ${resposta_POST.text}
    Set Test Variable                 ${resposta_POST}

Validar o status retornado
    [Arguments]                       ${Status}              ${Request}
    Run Keyword If                    "${Request}" == "POST"                    Should Be Equal As Strings        ${resposta_POST.status_code}        ${Status}
    Run Keyword If                    "${Request}" == "GET"                     Should Be Equal As Strings        ${resposta_GET.status_code}         ${Status}

Validar mensagem
    [Arguments]                       ${Mensagem}            ${Request}
    Run Keyword If                    "${Request}" == "POST"                    Should Be Equal                   ${resposta_POST.json()["message"]}  ${Mensagem}
    ...    ELSE IF                    "${Request}" == "GET"                     Should Be Equal                   ${resposta_GET.json()["message"]}   ${Mensagem}

Validar os dados do produto cadastrado
    ${resposta_POST.json()}  To Json  ${ProdCriado}

Buscar lista de pdrodutos
    ${HEADERS}                        Create Dictionary      content-type=application/json        token=${Token}
    ${resposta_GET}                   GET On Session         APILojinha         ${BaseUrl}/produto
    ...                               headers=${HEADERS}
    Log                               ${resposta_GET.text}
    Set Test Variable                 ${resposta_GET}

Buscar pelo produto Id
    [Arguments]                       ${ProdUid}
    Set Test Variable                 ${ProdUid}
    ${HEADERS}                        Create Dictionary      content-type=application/json        token=${Token}
    ${resposta_GET}                   GET On Session         APILojinha         ${BaseUrl}/produto/${ProdUid}
    ...                               headers=${HEADERS}
    Log                               ${resposta_GET.text}
    Set Test Variable                 ${resposta_GET}

Validar informações do produto encontrado
    Should Be Equal As Strings        ${resposta_GET.json()["data"]["produtoid"]}                               ${ProdUid}
    Should Be Equal As Strings        ${resposta_GET.json()["data"]["produtonome"]}                             B2Card
    Should Be Equal As Strings        ${resposta_GET.json()["data"]["produtovalor"]}                            50
    Should Be Equal As Strings        ${resposta_GET.json()["data"]["produtocores"]}                            ['azul']
    Should Be Equal As Strings        ${resposta_GET.json()["data"]["componentes"][0]["componentenome"]}        Automation
    Should Be Equal As Strings        ${resposta_GET.json()["data"]["componentes"][0]["componentequantidade"]}  1

Editar o produto de Id
    [Arguments]                       ${ProdUid}
    Set Test Variable                 ${ProdUid}
    ${HEADERS}                        Create Dictionary      content-type=application/json        token=${Token}
    #### Coletando os dados do produto antes da alteração
    ${dados_antes}                    GET On Session         APILojinha         ${BaseUrl}/produto/${ProdUid}
    ...                               headers=${HEADERS}
    Log                               ${dados_antes.text}
    Set Test Variable                 ${dados_antes}
    #### Editando as informações do produto
    ${ProdNome}    Generate Random String    6               [LETTERS]
    Set Test Variable                 ${ProdNome}
    ${CompNome}    Generate Random String    6               [LETTERS]
    Set Test Variable                 ${CompNome}
    ${resposta_PUT}                   PUT On Session         APILojinha         ${BaseUrl}/produto/${ProdUid}
    ...                               data={"produtonome": "${ProdNome}", "produtovalor": 50.00, "produtocores": ["azul"], "componentes": [{"componentenome": "${CompNome}", "componentequantidade": 1}]}
    ...                               headers=${HEADERS}
    Log                               ${resposta_PUT.text}
    Set Test Variable                 ${resposta_PUT}
    #### Coletando os dados do produto após as alterações
    ${dados_depois}                   GET On Session         APILojinha         ${BaseUrl}/produto/${ProdUid}
    ...                               headers=${HEADERS}
    Log                               ${dados_depois.text}
    Set Test Variable                 ${dados_depois}

Validar que apenas os dados editados foram alterados
    Should Be Equal As Strings        ${dados_antes.json()["data"]["produtoid"]}                           ${dados_depois.json()["data"]["produtoid"]}
    Should Not Be Equal               ${dados_antes.json()["data"]["produtonome"]}                         ${dados_depois.json()["data"]["produtonome"]}
    Should Be Equal As Strings        ${dados_antes.json()["data"]["produtovalor"]}                        ${dados_depois.json()["data"]["produtovalor"]}
    Should Be Equal As Strings        ${dados_antes.json()["data"]["produtocores"]}                        ${dados_depois.json()["data"]["produtocores"]}
    Should Not Be Equal               ${dados_antes.json()["data"]["componentes"][0]["componentenome"]}    ${dados_depois.json()["data"]["componentes"][0]["componentenome"]}