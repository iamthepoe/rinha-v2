require 'coffeescript/register'

{ it, describe, before, beforeEach, after, afterEach } = require 'node:test'
{ strictEqual, deepStrictEqual, ok }  = require 'node:assert'
sql = require '../src/connections/postgres.coffee'

deve = it
PORT = process.env.PORT ? 8000
URL = "http://localhost:#{PORT}"


describe 'API', ()=>
    _server = Object.create null
    id = 988; limite = 500; saldo = 10;
    
    before () ->
        _server = require '../src/server.coffee'
        await new Promise((resolve) -> _server.once 'listening', resolve)
        await sql"INSERT INTO clientes (id, limite, saldo) VALUES (#{id}, #{limite}, #{saldo});"
    
    after (done)-> 
        await Promise.all [sql"DELETE FROM clientes WHERE id=#{id}", sql"DELETE FROM transacoes WHERE cliente_id=#{id}"]
        _server.close done
        process.exit()
    
    describe 'transacoes', ()->
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

    describe 'extrato', ()->
        deve 'obter o extrato com sucesso', ()->
            res = await fetch "#{URL}/clientes/#{id}/extrato"
            data = await res.json()

            strictEqual data.saldo.total, 10
            strictEqual data.saldo.limite, 500
            strictEqual data.ultimas_transacoes.length, 2
            ok data.ultimas_transacoes.length<=10

            strictEqual data.ultimas_transacoes[0].valor, 10
            strictEqual data.ultimas_transacoes[0].tipo, 'd'
            strictEqual data.ultimas_transacoes[0].descricao, 'descricao'

            strictEqual data.ultimas_transacoes[1].valor, 10
            strictEqual data.ultimas_transacoes[1].tipo, 'c'
            strictEqual data.ultimas_transacoes[1].descricao, 'descricao'

            strictEqual res.status, 200
        
        deve 'dar pau se nao achar nada', ()->
            req1 = fetch "#{URL}/clientes/0/extrato"
            req2 = fetch "#{URL}/clientes/lol/extrato"

            [ res1, res2 ] = await Promise.all [ req1, req2 ]

            deepStrictEqual [res1.status , res2.status], [404, 404]
