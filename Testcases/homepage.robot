*** Settings ***
Resource             ../Pages/homepage_keywords.robot
Test Setup           Abrir o navegador
Test Teardown        Fechar o navegador
Force Tags           homepage

*** Test Cases ***
Home: Caso de Teste 01 - Validando todos os menus do site
    [Documentation]    Este teste entra em todos os menus do site um por um
    ...                e valida que está na página correta
    [Tags]             menus    categorias
    Acessar a home page do site Amazon.com
    Validar todos os menus do site

Home: Caso de Teste 02 - Pesquisa de um Produto
    [Documentation]    Este teste verifica a busca de um produto no site
    [Tags]             busca_produtos
    Acessar a home page do site Amazon.com
    Digitar o nome do produto no campo de pesquisa        Console PlayStation®5
    Clicar no botão de pesquisa
    Verificar o resultado da pesquisa, listando o produto pesquisado

Home: Caso de Teste 03 - Adicionar Produto no Carrinho
    [Documentation]    Esse teste verifica a adição de um produto no carrinho de compras
    [Tags]             adicionar_carrinho
    Acessar a home page do site Amazon.com
    Digitar o nome do produto no campo de pesquisa        Console PlayStation®5
    Clicar no botão de pesquisa
    Verificar o resultado da pesquisa, listando o produto pesquisado
    Adicionar o produto escolhido no carrinho
    Verificar se o produto escolhido foi adicionado com sucesso

Home: Caso de Teste 04 - Remover Produto do Carrinho
    [Documentation]    Esse teste verifica a remoção de um produto no carrinho de compras
    [Tags]             remover_carrinho
    Acessar a home page do site Amazon.com
    Digitar o nome do produto no campo de pesquisa        Console PlayStation®5
    Clicar no botão de pesquisa
    Verificar o resultado da pesquisa, listando o produto pesquisado
    Adicionar o produto escolhido no carrinho
    Verificar se o produto escolhido foi adicionado com sucesso
    Remover o produto escolhido do carrinho
    Verificar se o carrinho fica vazio

Home: Caso de Teste 05 - Cadastrar um usuário no site
    [Documentation]    Este teste irá criar um usuário no site da Amazon.com.br
    ...                com um email ficticio que não será validado
    [Tags]             cadastrar_usuario
    Acessar a home page do site Amazon.com
    Clicar no link Comece aqui
    Preencher formulário de cadastrar novo usuario
    Validar que o link de validação foi enviado por email

Home: Caso de Teste 06 - Procurar uma TV 8k e colocar no carrinho a opção mais cara
    [Documentation]    Este teste irá realizar uma busca por TVs com resolução 8K
    ...                modelo ano 2022 e irá colocar no carrinho a que tiver o
    ...                maior preço encontrado desconsiderando os centavos
    [Tags]             adicionar_carrinho    busca_produtos
    Acessar a home page do site Amazon.com
    Selecionar o menu           Eletrônicos
    Selecionar o submenu        TV, Áudio e Cinema em Casa
    Selecionar o submenu        TVs
    Marcar a opção              8K
    Selecionar o produto de maior valor