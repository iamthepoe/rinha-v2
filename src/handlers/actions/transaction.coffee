require 'coffeescript/register'

{ once } = require 'node:events'

handleNotFound = require '../errors/notFound.coffee'
handleUnprocessableEntity = require '../errors/unprocessableEntity.coffee'
handleBadRequest = require '../errors/badRequest.coffee'
handleInternalError = require '../errors/internalError.coffee'
sql = require '../../connections/postgres.coffee'
utils = require '../../utils/utils.coffee'

validateTransaction = (transaction, res, id) ->
    data = JSON.parse transaction
    fieldIsMissing = !data?.valor || !data?.descricao || !data?.tipo
    valueIsInvalid = data?.valor <= 0
    typeIsInvalid = !['c', 'd'].includes data?.tipo
    descriptionIsInvalid = data?.descricao?.length < 1 or data?.descricao?.length > 10
    idIsNaN = isNaN(+id)
    isInvalidTransaction = valueIsInvalid or typeIsInvalid or descriptionIsInvalid or idIsNaN or fieldIsMissing
    
    if isInvalidTransaction
        handleBadRequest res
        return false
    
    return data

callTransactionProcedure = (transaction, id) ->
    return sql"CALL PROCESSAR_TRANSACAO(#{id}, #{transaction.descricao}, #{transaction.tipo}, #{transaction.valor}, 0::varchar)"

getNewBalance = (transactionProcedureData) -> return transactionProcedureData[0].result.split ':'

handleTransaction = (req, res, id) ->
    if req.method isnt 'POST' then return handleNotFound res
    
    data = await once req, 'data'
    transaction = validateTransaction data, res, id
    
    if !transaction
        return

    client = (await sql"SELECT * FROM clientes WHERE id=#{id}")[0]

    if !client
        handleNotFound res
        return

    if transaction.tipo == "d" and (client.saldo - transaction.valor) < -client.limite
        handleUnprocessableEntity res
        return
    
    procedureResponse = await callTransactionProcedure(transaction, id)
    [saldo, limite] = getNewBalance procedureResponse

    if procedureResponse.status == 'rejected'
        handleInternalError res
        return
    
    jsonResponse = JSON.stringify { saldo: Number(saldo), limite: Number(limite) }

    res.writeHead 200, utils.DEFAULT_HEADER
    res.end(jsonResponse)

module.exports = handleTransaction