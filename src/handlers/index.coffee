require 'coffeescript/register'

module.exports = {
    notFound: require('./errors/notFound.coffee'),
    internalError: require('./errors/internalError.coffee'),
    unprocessableEntity: require('./errors/unprocessableEntity.coffee'),
    badRequest: require('./errors/badRequest.coffee'),
    transaction: require('./actions/transaction.coffee'),
    extract: require('./actions/extract.coffee'),
}
