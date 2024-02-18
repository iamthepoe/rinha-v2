handleBadRequest = (res) ->
    res.statusCode = 400
    res.end()

module.exports = handleBadRequest