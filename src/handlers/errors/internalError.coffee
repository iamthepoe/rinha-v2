handleInternalError = (res) ->
    res.statusCode = 500
    res.end()

module.exports = handleInternalError;