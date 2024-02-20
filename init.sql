--inspired/stolen from H4ad, who stole/was inspired by that guy who knows a lot of C#, and he forgot his name

CREATE TABLE IF NOT EXISTS clientes (
    id INT NOT NULL PRIMARY KEY,
    limite int NOT NULL CHECK (limite > 0),
    saldo int NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS transacoes (
    cliente_id int NOT NULL,
    valor int NOT NULL,
    tipo CHAR(1) NOT NULL,
    descricao varchar(10) NOT NULL,
    realizada_em TIMESTAMP NOT NULL DEFAULT NOW()
);

INSERT INTO clientes (id, limite, saldo)
VALUES 
    (1, 100000, 0),
    (2, 80000, 0),
    (3, 1000000, 0),
    (4, 10000000, 0),
    (5, 500000, 0);

CREATE OR REPLACE PROCEDURE PROCESSAR_TRANSACAO(
    cliente_id INT,
    descricao VARCHAR(10),
    tipo CHAR(1),
    valor INT,
    INOUT result VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    var_saldo INT;
    var_limite INT;
BEGIN
    IF tipo = 'c' THEN
        UPDATE clientes SET saldo = saldo + valor WHERE id = cliente_id RETURNING saldo, limite INTO var_saldo, var_limite;
    ELSE
        UPDATE clientes SET saldo = saldo - valor WHERE id = cliente_id RETURNING saldo, limite INTO var_saldo, var_limite;
    END IF;

    IF NOT FOUND THEN
        result = "-1"
        RETURN;
    ELSE
        INSERT INTO transacoes (cliente_id, valor, tipo, descricao) VALUES (cliente_id, valor, tipo, descricao);
        COMMIT;
        result = CONCAT(var_saldo::varchar, ':', var_limite::varchar);
    END IF;
END;
$$;