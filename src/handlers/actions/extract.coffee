require 'coffeescript/register'
handleNotFound = require '../errors/notFound.coffee'

handleExtract = (req, res) ->
    if req.method isnt 'GET' then handleNotFound res
    res.statusCode = 200
    res.end()

module.exports = handleExtract