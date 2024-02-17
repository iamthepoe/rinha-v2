require 'coffeescript/register'
handleNotFound = require './notFound.coffee'

handleTransaction = (req, res) ->
    if req.method isnt 'POST' then handleNotFound res
    res.statusCode = 200
    res.end()

module.exports = handleTransaction;