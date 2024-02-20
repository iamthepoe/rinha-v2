require 'coffeescript/register'

handle = require './handlers'
http = require 'node:http'
PORT = process.env.PORT ? 8000

validateRequest = (req, res) ->
    if !req.url then handle.notFound res

    [path, entity, id, action] = req.url.split '/'

    if entity isnt 'clientes' then handle.notFound res

    if !['transacoes', 'extrato'].includes(action) then handle.notFound res

    return [path, entity, id, action]

server = http.createServer((req, res) ->
    try
        if !req.url then handle.notFound res
        [path, entity, id, action] = validateRequest req, res
        
        if action is 'transacoes' then return handle.transaction req, res, id
        
        if action is 'extrato' then return handle.extract req, res, id

        return res.end()
    catch error
        console.error error
        return handle.internalError res
).listen PORT, ()-> console.log "Server running at http://localhost:#{PORT}/"

module.exports = server