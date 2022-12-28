*** Settings ***
Resource           ../Pages/carrinho_keywords.robot
Resource           ../Pages/homepage_keywords.robot
Test Setup         Abrir o navegador
Test Teardown      Fechar o navegador
Force Tags         carrinho_compras

*** Test Cases ***
Carrinho: Caso de Teste 01 - Fazer checkout de um produto com pagamento em boleto
    [Documentation]        Este teste incluirá um produto no carrinho de compras
    ...                    E fará o checkout escolhendo como forma de pagamento
    ...                    a opção de boleto bancário
    [Tags]                 carrinho_compras
    Acessar a home page do site Amazon.com
    Realizar login no site da Amazon
    Digitar o nome do produto no campo de pesquisa        Console PlayStation®5
    Clicar no botão de pesquisa
    Verificar o resultado da pesquisa, listando o produto pesquisado
    Adicionar o produto escolhido no carrinho
    Verificar se o produto escolhido foi adicionado com sucesso
    Clicar no botão ir para o carrinho
    Validar que a quantidade de produtos e valores estão corretos no carrinho
    Clicar no botão fechar pedido
    Preencher endereço para envio do produto
    Aguardar pagina carregar
    Selecionar forma de pagamento                         Boleto
    Aguardar pagina carregar
    Clicar no botão confirmar pedido
    Aguardar pagina carregar
    Validar que o pedido foi realizado
