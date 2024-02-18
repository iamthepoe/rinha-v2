postgres = require 'postgres'

connectionString = process.env.DATABASE_URL ? 'postgres://postgres:@localhost:5432/rinha'
sql = postgres connectionString, { max: 10 }

module.exports = sql