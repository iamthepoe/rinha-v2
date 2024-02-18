handleUnprocessableEntity = (res) ->
    res.statusCode = 422
    res.end()

module.exports = handleUnprocessableEntity