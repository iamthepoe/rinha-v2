require 'coffeescript/register'

{ it, describe, before, beforeEach, after, afterEach } = require 'node:test'
{ strictEqual, deepStrictEqual }  = require 'node:assert'
sql = require '../src/connections/postgres.coffee'

deve = it
PORT = process.env.PORT ? 8000
URL = "http://localhost:#{PORT}"


describe 'API', ()=>
    _server = Object.create null
    id = 993; limite = 500; saldo = 10;
    
    before () ->
        _server = require '../src/server.coffee'
        await new Promise((resolve) -> _server.once 'listening', resolve)
        await sql"INSERT INTO clientes (id, limite, saldo) VALUES (#{id}, #{limite}, #{saldo});"
    
    after (done)-> 
        await sql"DELETE FROM clientes WHERE id=#{id}"
        _server.close done
        process.exit()

    deve 'criar uma transação de crédito com sucesso', ()->
        body = JSON.stringify { valor: 10, tipo: 'c', descricao: 'descricao' }
        res = await fetch "#{URL}/clientes/#{id}/transacoes", { method: 'POST', body }
        data = await res.json()
        deepStrictEqual data, { saldo: 20, limite: 500 }
        strictEqual res.status, 200
    
    deve 'criar uma transação de débito com sucesso', ()->
        body = JSON.stringify { valor: 10, tipo: 'd', descricao: 'descricao' }
        res = await fetch "#{URL}/clientes/#{id}/transacoes", { method: 'POST', body }
        data = await res.json()
        deepStrictEqual data, { saldo: 10, limite: 500 }
        strictEqual res.status, 200
    
    deve 'dar pau se o usuário não existir', ()->
        body = JSON.stringify { valor: 10, tipo: 'd', descricao: 'descricao' }
        res = await fetch "#{URL}/clientes/293012390/transacoes", { method: 'POST', body }
        strictEqual res.status, 404
    
    deve 'dar pau se o valor quebrar o limite (débito)', ()->
        body = JSON.stringify { valor: 100000, tipo: 'd', descricao: 'descricao' }
        res = await fetch "#{URL}/clientes/#{id}/transacoes", { method: 'POST', body }
        strictEqual res.status, 422

    deve 'dar pau se o id não for um número', ()->
        body = JSON.stringify { valor: 10, tipo: 'd', descricao: 'descricao' }
        res = await fetch "#{URL}/clientes/foo/transacoes", { method: 'POST', body }
        strictEqual res.status, 400

    deve 'dar pau se o valor não for um número inteiro e positivo', ()->
        body = JSON.stringify { valor: -10, tipo: 'd', descricao: 'descricao' }
        res = await fetch "#{URL}/clientes/foo/transacoes", { method: 'POST', body }
        strictEqual res.status, 400
        body = JSON.stringify { valor: 10.21, tipo: 'd', descricao: 'descricao' }
        res = await fetch "#{URL}/clientes/foo/transacoes", { method: 'POST', body }
        strictEqual res.status, 400

    deve 'dar pau se o tipo não for c ou d', ()->
        body = JSON.stringify { valor: 10, tipo: 'bora_bill', descricao: 'a' }
        res = await fetch "#{URL}/clientes/#{id}/transacoes", { method: 'POST', body }
        strictEqual res.status, 400

    deve 'dar pau se tiver algo faltando', ()->
        body = JSON.stringify { valor: 10, tipo: 'c' }
        res = await fetch "#{URL}/clientes/#{id}/transacoes", { method: 'POST', body }
        strictEqual res.status, 400

    deve 'dar pau se o tamanho da descrição não for de 1 a 10 caracteres', ()->
        body = JSON.stringify { valor: 10, tipo: 'd', descricao: '' }
        res = await fetch "#{URL}/clientes/#{id}/transacoes", { method: 'POST', body }
        strictEqual res.status, 400
        body = JSON.stringify { valor: 10, tipo: 'd', descricao: '12345678910' }
        res = await fetch "#{URL}/clientes/#{id}/transacoes", { method: 'POST', body }
        strictEqual res.status, 400
