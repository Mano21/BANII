-- Table: setor

-- DROP TABLE setor;

CREATE TABLE setor
(
  cods integer NOT NULL,
  nome character varying(50),
  CONSTRAINT setor_pkey PRIMARY KEY (cods)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE setor OWNER TO postgres;

-- Table: mecanico

-- DROP TABLE mecanico;

CREATE TABLE mecanico
(
  codm serial NOT NULL,
  cpf bigint,
  nome character varying(50),
  idade integer,
  endereco character varying(500),
  cidade character varying(500),
  funcao character varying(50),
  cods integer,
  CONSTRAINT mecanico_pkey PRIMARY KEY (codm),
  CONSTRAINT mecanico_cods_fkey FOREIGN KEY (cods)
      REFERENCES setor (cods) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE SET NULL
)
WITH (
  OIDS=FALSE
);
ALTER TABLE mecanico OWNER TO postgres;

-- Table: veiculo

-- DROP TABLE veiculo;

CREATE TABLE veiculo
(
  codv integer NOT NULL,
  renavam bigint,
  modelo character varying(50),
  marca character varying(50),
  ano integer,
  quilometragem float,
  CONSTRAINT veiculo_pkey PRIMARY KEY (codv)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE veiculo OWNER TO postgres;

-- Table: cliente

-- DROP TABLE cliente;

CREATE TABLE cliente
(
  codc integer NOT NULL,
  cpf bigint,
  nome character varying(50),
  idade integer,
  endereco character varying(500),
  cidade character varying(500),
  codv integer,
  CONSTRAINT cliente_pkey PRIMARY KEY (codc),
  CONSTRAINT cliente_codv_fkey FOREIGN KEY (codv)
      REFERENCES veiculo (codv) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE SET NULL
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cliente OWNER TO postgres;

-- Table: conserto

-- DROP TABLE conserto;

CREATE TABLE conserto
(
  codm integer NOT NULL,
  codv integer NOT NULL,
  data date NOT NULL,
  hora time without time zone,
  CONSTRAINT consulta_pkey PRIMARY KEY (codm, codv, data),
  CONSTRAINT consulta_codm_fkey FOREIGN KEY (codm)
      REFERENCES mecanico (codm) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT consulta_codv_fkey FOREIGN KEY (codv)
      REFERENCES veiculo (codv) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE conserto OWNER TO postgres;


-- Dados

INSERT INTO setor VALUES (1, 'Elétrica'),
(2, 'Mecânica'),
(3, 'Funilaria'),
(4, 'Pintura');

INSERT INTO mecanico VALUES (1, '10000100000', 'João', 40, 'América', 'Joinville', 'som', 1),
(2, '10000110000', 'Luiz', 42, 'Vila Nova', 'Joinville', 'motor', 2),
(3, '11000100000', 'Pedro', 51, 'Cobrasol', 'São José', 'cámbio', 2),
(4, '11000110000', 'Carlos', 28, 'Trindade', 'Florianópolis', 'estofado', null),
(5, '11000111000', 'Márcio', 33, 'Pantanal', 'Florianópolis', 'desamassa', 3);

INSERT INTO veiculo VALUES (1, '20000100000', 'Ka', 'Ford', '2013', 1200.300),
(2, '30000110000', 'Celta', 'GM', '2014', 1220.800),
(3, '41000100000', 'Palio', 'Fiat', '2012', 51000.200),
(4, '51000110000', 'C3', 'Citroen', '2015', 5000.700),
(5, '61000111000', 'Fox', 'VW', '2011', 79000.900),
(6, '71000111000', 'Palio', 'Fiat', '2010', 110000.450),
(7, '71000111111', 'Gol', 'VW', '2009', 130000.500);

INSERT INTO cliente VALUES (1, '20000200000', 'Ana', 20, 'América', 'Joinville', 1),
(2, '20000220000', 'Paulo', 24, 'Saguaçu', 'Joinville', 2),
(3, '22000200000', 'Lucia', 30, 'Vila Nova', 'Joinville', 3),
(4, '11000110000', 'Carlos', 28, 'Trindade', 'Florianópolis', 4),
(5, '51000110000', 'Carlos', 44, 'Centro', 'Florianópolis', 5),
(6, '71000111000', 'João', 38, 'Praia Comprida', 'São José', 6),
(7, '10000110000', 'Luiz', 42, 'Vila Nova', 'Joinville', 7);

INSERT INTO conserto VALUES (1, 1, '12/06/2014', '14:00'),
(1, 4, '13/06/2014', '10:00'),
(2, 1, '13/06/2014', '09:00'),
(2, 2, '13/06/2014', '11:00'),
(2, 3, '14/06/2014', '14:00'),
(2, 4, '14/06/2014', '17:00'),
(3, 1, '19/06/2014', '18:00'),
(3, 3, '12/06/2014', '10:00'),
(3, 4, '19/06/2014', '13:00'),
(4, 4, '20/06/2014', '13:00');

--1)Recupere o nome e o endereço de cada cliente.
--select nome,endereco from cliente

--2)Recupere o nome e a função dos mecânicos que trabalham no setor número 2 (cods 2).
--select nome,funcao from mecanico where cods = 2

--3)Recupere o CPF e o nome de todos os mecânicos que são clientes da oficina 
--(utilize operação de conjuntos).
--(select m.cpf,m.nome from mecanico m) intersect (select c.cpf,c.nome from cliente c)

--4)      Recupere as cidades das quais os mecânicos e clientes são oriundos.
--(select cidade from mecanico) union (select cidade from cliente)

--5)      Recupere as marcas distintas dos veículos dos clientes que moram em Joinville.
select distinct marca from veiculo v, cliente c where c.codv = v.codv and c.cidade = 'Joinville'

--6)      Recupere as funções distintas dos mecânicos da oficina.
select distinct funcao from mecanico

--7)      Recupere todas as informações dos clientes que têm idade maior que 25 anos.
select * from cliente where idade > 25

--8)      Recupere o CPF e o nome dos mecânicos que trabalham no setor de mecânica.
select m.cpf,m.nome,s.nome from mecanico m join setor s using (cods) where s.nome like 'Mec%' 

--9)      Recupere o CPF e nome dos mecânicos que trabalharam no dia 13/06/2014.
select m.cpf,m.nome,c.data from mecanico m join conserto c using (codm) where c.data = '13/06/2014'

--10)  Recupere o nome do cliente, o modelo do seu veículo, o nome do mecânico e sua função 
--para todos os consertos realizados (utilize join para realizar a junção).
select c.nome, v.modelo,m.nome,m.funcao from cliente c join veiculo v using (codv) join conserto con using (codv) join 
mecanico m using (codm)

--11)  Recupere o nome do mecânico, o nome do cliente e a hora do conserto para as serviços 
--realizados no dia 19/06/2014 (utilize join para realizar a junção).
select m.nome, cli.nome, c.hora from mecanico m join conserto c using (codm) join veiculo v using (codv)
join cliente cli using (codv) where c.data = '19/06/2014' order by c.hora


--12)   Recupere o código e o nome dos setores que foram utilizados entre os dias 12/06/2014 
--e 14/06/2014 (utilize join para realizar a junção).
select distinct s.cods,s.nome from setor s join mecanico m using (cods) join conserto c using (codm) where 
data between '12/06/2014' and '14/06/2014'

