*** Settings ***
Documentation       Documentação da API: http://165.227.93.41/lojinha-arquivos/Swagger.pdf
Resource            ../Pages/lojinhaAPI_keywords.robot
Test Setup          Conectar API
Force Tags          APIs

*** Test Cases ***
API: Caso de Teste 01 - Adicionar um novo usuário no API da Lojinha
    Cadastrar um novo usuário
    Validar que o usuário foi cadastrado corretamente

API: Caso de Teste 02 - Cadastrar um novo produto na Lojinha
    Cadastrar novo produto
    Validar o status retornado            201        POST
    Validar mensagem                      Produto adicionado com sucesso                    POST
    Validar os dados do produto cadastrado

API: Caso de Teste 03 - Conferir lista de produtos
    Buscar lista de pdrodutos
    Validar o status retornado            200        GET
    Validar mensagem                      Listagem de produtos realizada com sucesso        GET

API: Caso de Teste 04 - Buscar por um produto específico
    Buscar pelo produto Id                148513
    Validar o status retornado            200          GET
    Validar mensagem                      Detalhando dados do produto                        GET
    Validar informações do produto encontrado


API: Caso de Teste 04 - Editar um produto
    Editar o produto de Id                148497
    Validar que apenas os dados editados foram alterados