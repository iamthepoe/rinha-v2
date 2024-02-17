require 'coffeescript/register'

handleNotFound = require './notFound.coffee'
{ once } = require 'node:events'

handleTransaction = (req, res) ->
    if req.method isnt 'POST' then handleNotFound res

    data = await once req, 'data'
    item = JSON.parse data

    res.statusCode = 200
    res.end()

module.exports = handleTransaction;