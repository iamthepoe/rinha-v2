require 'coffeescript/register'

{ once } = require 'node:events'

handleNotFound = require '../errors/notFound.coffee'
sql = require '../../connections/postgres.coffee'
utils = require '../../utils/utils.coffee'

handleTransaction = (req, res) ->
    if req.method isnt 'POST' then return handleNotFound res

    data = await once req, 'data'
    item = JSON.parse data
    console.log item

    res.writeHead 200, utils.DEFAULT_HEADER
    return res.end()

module.exports = handleTransaction;