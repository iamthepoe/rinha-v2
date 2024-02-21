require 'coffeescript/register'
handleNotFound = require '../errors/notFound.coffee'
utils = require '../../utils/utils.coffee'
sql = require '../../connections/postgres.coffee'

handleExtract = (req, res, id) ->
    if req.method isnt 'GET' then return handleNotFound res
    if isNaN(+id) then return handleNotFound res
    getBalance = sql"SELECT limite, saldo FROM clientes WHERE id = #{id};"
    getLastTransactions = sql"SELECT valor, tipo, descricao, realizada_em FROM transacoes WHERE cliente_id = #{id} ORDER BY realizada_em DESC LIMIT 10;"

    [ balance, lastTransactions ] = await Promise.allSettled [ getBalance, getLastTransactions ]
    
    if balance.value.length is 0 then return handleNotFound res
    
    data = JSON.stringify { 
        saldo: { 
            total: balance.value[0].saldo,
            limite: balance.value[0].limite, 
            data_extrato: new Date().toISOString() 
        }, 
        ultimas_transacoes: lastTransactions.value
    }
    
    res.writeHead 200, utils.DEFAULT_HEADER
    res.end(data)

module.exports = handleExtract