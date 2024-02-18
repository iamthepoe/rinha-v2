require 'coffeescript/register'

module.exports = {
    notFound: require('./errors/notFound.coffee'),
    internalError: require('./errors/internalError.coffee'),
    transaction: require('./actions/transaction.coffee'),
    extract: require('./actions/extract.coffee')
}
