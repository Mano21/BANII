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
(3, '11000100000', 'Pedro', 51, 'Cobrasol', 'São José', 'câmbio', 2),
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
(2, '20000220000', 'Paulo', 24, 'Saguaçú', 'Joinville', 2),
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



---consultas:

--1)      Mostre o nome e a função dos mecânicos.
create view fun_mecanico(nome,funcao) as
select m.nome,m.funcao
from mecanico m


--2)      Mostre o nome e veículos dos clientes.
create view cliente_veiculo(nome,modelo,marca) as
select c.nome,v.modelo,v.marca
from cliente c join veiculo v on(c.codc = v.codv)

drop view cliente_veiculo

select nome,modelo,marca
from cliente_veiculo


--3)      Mostre o nome dos mecânicos, o nome dos clientes, o nome dos veículos e a data e hora dos consertos realizados.
create view mecanico_cliente(nomem,nomec,modelo,data,hora) as
select m.nome,c.nome,v.modelo,con.data,con.hora
from mecanico m, cliente c join veiculo v on(c.codc = v.codv) join conserto con on (con.codm = v.codv)


select nomem,nomec,modelo,data,hora
from mecanico_cliente

--4)      Mostre o ano dos veículos e a média de quilometragem para cada ano.
create view media_veiculos(ano,avgquilometragem) as 
select v.ano,avg(v.quilometragem)
from veiculo v
group by ano

select ano,avgquilometragem
from media_veiculos

--5)      Mostre o nome dos mecânicos e o total de consertos feitos por um mecânico em cada dia.
create view conserto_mecanico(nomem,totconserto) as
select m.nome,count(*)
from mecanico m join conserto con using(codm)
group by m.nome,data

drop view conserto_mecanico

select nomem,totconserto
from conserto_mecanico

select * from mecanico

select * from conserto

--6)      Mostre o nome dos setores e o total de consertos feitos em um setor em cada dia.
create view setor_conserto(nomes,totconsert) as
select s.nome,count(*)
from setor s join mecanico m using(cods) join conserto con


--7)      Mostre o nome das funções e o número de mecânicos que têm uma destas funções.

--8)      Mostre o nome dos mecânicos e suas funções e, para os mecânicos que estejam alocados a um setor, informe também o número e nome do setor.

--9)      Mostre o nome das funções dos mecânicos e a quantidade de consertos feitos agrupado por cada função.
