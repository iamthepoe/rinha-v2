require 'coffeescript/register'

handle = require './handlers'
http = require 'node:http'

validateRequest = (req, res) ->
    if !req.url then handle.notFound res

    [path, entity, id, action] = req.url.split '/'

    if entity isnt 'clientes' then handle.notFound res

    if isNaN(+id) then handle.notFound res

    if !['transacoes', 'extrato'].includes(action) then handle.notFound res

    return [path, entity, id, action]

server = http.createServer (req, res) ->
    if !req.url then handle.notFound res
    [path, entity, id, action] = validateRequest req, res
    
    if action is 'transacoes' then return handle.transaction req, res
    
    if action is 'extrato' then return handle.extract req, res

    res.end();

initServer = (port) ->
    server.listen port, () ->
        console.log "Server running at http://localhost:#{port}/"

initServer 8000

module.exports = initServer