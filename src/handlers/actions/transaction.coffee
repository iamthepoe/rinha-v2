require 'coffeescript/register'

{ once } = require 'node:events'

handleNotFound = require '../errors/notFound.coffee'
handleUnprocessableEntity = require '../errors/unprocessableEntity.coffee'
handleBadRequest = require '../errors/badRequest.coffee'
handleInternalError = require '../errors/internalError.coffee'
sql = require '../../connections/postgres.coffee'
utils = require '../../utils/utils.coffee'

validateTransaction = (transaction, res) ->
    data = JSON.parse transaction
    valueIsInvalid = data?.valor <= 0
    typeIsInvalid = !['c', 'd'].includes data?.tipo
    descriptionIsInvalid = data?.descricao?.length < 1 or data?.descricao?.length > 10

    if valueIsInvalid or typeIsInvalid or descriptionIsInvalid
        handleBadRequest res
        return false
    
    return data

insertTransaction = (transaction, id) -> 
    return sql"INSERT INTO transacoes (cliente_id, valor, tipo, descricao) VALUES (#{id}, #{transaction.valor}, #{transaction.tipo}, #{transaction.descricao})"

updateClientBalance = (transaction, id) ->
    return sql"UPDATE clientes SET saldo = saldo - #{transaction.valor} WHERE id=#{id}"

handleTransaction = (req, res, id) ->
    if req.method isnt 'POST' then return handleNotFound res
    
    data = await once req, 'data'
    transaction = validateTransaction data, res
    
    if !transaction
        return

    client = (await sql"SELECT * FROM clientes WHERE id=#{id}")[0]

    if !client
        handleNotFound res
        return

    if transaction.tipo == "d" and (client.saldo - transaction.valor) < -client.limite
        handleUnprocessableEntity res
        return
    
    responses = await Promise.allSettled [insertTransaction(transaction, id), updateClientBalance(transaction, id)]

    if responses[0].status == 'rejected' or responses[1].status == 'rejected'
        handleInternalError res
        return
    
    jsonResponse = JSON.stringify { saldo: client.saldo - transaction.valor, limite: client.limite }

    res.writeHead 200, utils.DEFAULT_HEADER
    res.end(jsonResponse)

module.exports = handleTransaction