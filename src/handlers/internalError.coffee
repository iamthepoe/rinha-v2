handleNotFound = (res) ->
    res.statusCode = 404
    res.end()

module.exports = handleNotFound;