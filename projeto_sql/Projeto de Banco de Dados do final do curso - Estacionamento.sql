-- Criando o Banco de Dados
CREATE DATABASE estacionamento;
USE estacionamento;

-- Criando a Tabela de Usuários (Operadores)
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(40) NOT NULL,
    matricula INT NOT NULL UNIQUE
);

-- Criando a Tabela de Clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(60) NOT NULL,
    contato VARCHAR(15) NOT NULL
);

-- Criando a Tabela de Veículos
CREATE TABLE veiculos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('carro', 'moto') NOT NULL,
    marca VARCHAR(20) NOT NULL,
    modelo VARCHAR(20) NOT NULL,
    placa VARCHAR(7) UNIQUE NOT NULL,
    cliente INT,
    FOREIGN KEY (cliente) REFERENCES clientes(id) ON DELETE SET NULL
);

-- Criando a Tabela de Estacionamento
CREATE TABLE estacionamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    operador INT NOT NULL,
    cliente INT,
    veiculo INT,
    data DATE NOT NULL,
    hora TIME NOT NULL,
    status ENUM('estacionado', 'vagou') NOT NULL DEFAULT 'estacionado',
    FOREIGN KEY (operador) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (cliente) REFERENCES clientes(id) ON DELETE SET NULL,
    FOREIGN KEY (veiculo) REFERENCES veiculos(id) ON DELETE SET NULL
);

-- Inserindo os Usuários
INSERT INTO usuarios (nome, matricula) VALUES ('Ricardo', 8112024);

-- Inserindo os Clientes
INSERT INTO clientes (nome, contato) VALUES 
('Danielle', '997490929'),
('Fabio', '912309870'),
('Henrique', '987731230'),
('Tatiane', '999966770'),
('Jorge', '905439985'),
('Isabel', '977848854');

-- Inserindo os Veículos
INSERT INTO veiculos (tipo, marca, modelo, placa, cliente) VALUES 
('carro', 'Chevrolet', 'Onix', 'DN3E11', 1),
('moto', 'Honda', 'CB-500', 'FB4E11', 2),
('moto', 'Yamaha', 'Teneré', 'HQ2910', 3),
('moto', 'Honda', 'Bis', 'TT6D11', 4),
('carro', 'VW', 'Virtus', 'JR8D11', 5),
('carro', 'Renault', 'Sandero', 'IS6E11', 6);

-- Inserindo os Registros no Estacionamento
INSERT INTO estacionamento (operador, cliente, veiculo, data, hora, status) VALUES 
(1, 2, 2, '2024-11-02', '09:00', 'vagou'),
(1, 4, 4, '2024-11-02', '11:00', 'vagou'),
(1, 6, 6, '2024-11-02', '13:30', 'estacionado'),
(1, 3, 3, '2024-11-02', '15:25', 'estacionado'),
(1, 1, 1, '2024-11-03', '10:00', 'estacionado'),
(1, 6, 6, '2024-11-03', '12:00', 'vagou'),
(1, 3, 3, '2024-11-03', '14:00', 'estacionado'),
(1, 5, 5, '2024-11-04', '10:30', 'estacionado');

-- Cadastrando Matheus e sua moto
INSERT INTO clientes (nome, contato) VALUES ('Matheus', '993210589');
SET @id_matheus = LAST_INSERT_ID();
INSERT INTO veiculos (tipo, marca, modelo, placa, cliente) VALUES ('moto', 'BMW', 'XXT', 'FV6E10', @id_matheus);
SET @id_moto = LAST_INSERT_ID();
INSERT INTO estacionamento (operador, cliente, veiculo, data, hora, status) VALUES (1, @id_matheus, @id_moto, '2024-11-04', '16:00', 'estacionado');

-- Consulta de Veículos no Estacionamento
SELECT v.tipo, v.placa, v.modelo, c.nome AS proprietario, c.contato, e.data, e.hora, u.nome AS operador
FROM estacionamento e
JOIN veiculos v ON e.veiculo = v.id
JOIN clientes c ON e.cliente = c.id
JOIN usuarios u ON e.operador = u.id
WHERE e.status = 'estacionado';

-- Consulta do Segundo Veículo Estacionado no dia 02/11/2024
SELECT v.tipo, v.placa, v.modelo, c.nome AS proprietario, c.contato, e.data, e.hora, u.nome AS operador
FROM estacionamento e
JOIN veiculos v ON e.veiculo = v.id
JOIN clientes c ON e.cliente = c.id
JOIN usuarios u ON e.operador = u.id
WHERE e.data = '2024-11-02'
ORDER BY e.hora ASC
LIMIT 1 OFFSET 1;

-- Contagem de Motos e Carros no Estacionamento
SELECT v.tipo, COUNT(*) AS total
FROM estacionamento e
JOIN veiculos v ON e.veiculo = v.id
WHERE e.status = 'estacionado'
GROUP BY v.tipo;

-- Listar Clientes em Ordem Decrescente
SELECT * FROM clientes ORDER BY nome DESC;

-- Atualizar o Status dos Veículos Estacionados no dia 02/11/2024 para 'vagou'
UPDATE estacionamento SET status = 'vagou' WHERE data = '2024-11-02';

-- Atualizar o Status da Moto de Matheus para 'vagou'
UPDATE estacionamento e
JOIN veiculos v ON e.veiculo = v.id
JOIN clientes c ON e.cliente = c.id
SET e.status = 'vagou'
WHERE c.nome = 'Matheus' AND v.tipo = 'moto';

-- Excluir Matheus e sua moto sem afetar o histórico do estacionamento
DELETE FROM veiculos WHERE cliente = (SELECT id FROM clientes WHERE nome = 'Matheus');
DELETE FROM clientes WHERE nome = 'Matheus';
