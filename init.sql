CREATE TABLE IF NOT EXISTS clientes (
    id INT NOT NULL PRIMARY KEY,
    limite int NOT NULL CHECK (limite > 0),
    saldo int NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS transacoes (
    pessoa_id int NOT NULL,
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
