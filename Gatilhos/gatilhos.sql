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


--Descrição: Considerando o BD de uma oficina mecânica desenvolvido nas últimas aulas (e disponível na página da disciplina), faça a especificação dos seguintes gatilhos em PostgreSQL:

--1)      Gatilho para impedir a inserção ou atualização de Clientes com o mesmo CPF.

create or replace function Verificar_cpf_cliente() returns trigger as 
$$

declare
	cncpf bigint default 0;

begin
	select count (cpf) into cncpf from cliente where cpf = new.cpf;
	raise notice '%', cncpf;

	if cncpf > 0 then
		raise exception 'CPF ja cadastrado...';
	end if;
	return new;

end;
$$
Language plpgsql;

create trigger Verificar_cpf_cliente before insert or update on cliente for each row execute procedure Verificar_cpf_cliente();

insert into cliente values(10,20000200000,'Ana',20,'América','Joinville',1);

insert into cliente values(16,20000200055,'Ana',20,'América','Joinville',1);

insert into cliente values(17,20000200066,'Ana',20,'América','Joinville',1);


select * from cliente

--2)      Gatilho para impedir a inserção ou atualização de Mecânicos com idade menor que 20 anos.

create or replace function idade_mec() returns trigger as
$$
begin
	if new.idade < 20 then
		raise exception 'Mecanico com idade inferior a 20 anos...';
	end if;
	return new;
end;
$$
Language plpgsql;

create trigger idade_mec before insert or update on mecanico for each row execute procedure idade_mec();

select * from mecanico

insert into mecanico values(6,'10000200020','Brunno',19,'Bom Retiro','Joinville','som',1);

--3)      Gatilho para atribuir um cods (sequencial) para um novo setor inserido.

create sequence codsSeq start 10;

create or replace function codsSeq() returns trigger as 
$$
begin
	new.cods := nextval('codsSeq');
	return new;
end;
$$
Language plpgsql;

create trigger codsSeq before insert or update on setor for each row execute procedure codsSeq();

drop function codsSeq() cascade

insert into setor(cods,nome) values(4,'Pintura2');

select * from setor

--4)      Gatilho para impedir a inserção de um mecânico ou cliente com CPF inválido.
create or replace function validaCPF() returns trigger as 
$$
DECLARE
valido boolean := false;
cpf text;
cont integer;
b integer;
        
BEGIN
        b:=0;
        cont:=11;
        IF(cod_cpf = 11111111111 OR
           cod_cpf = 22222222222 OR
           cod_cpf = 33333333333 OR
           cod_cpf = 44444444444 OR
           cod_cpf = 55555555555 OR
           cod_cpf = 66666666666 OR
           cod_cpf = 77777777777 OR
           cod_cpf = 88888888888 OR
           cod_cpf = 99999999999) THEN
            RETURN valido;
        END IF;
        cpf := CAST(cod_cpf AS TEXT);
        WHILE (length(cpf) < 11) LOOP
                cpf := '0'||cpf;
        END LOOP;

        FOR i IN 1..9 LOOP
            cont := cont - 1;
            b := b + (CAST(substr(cpf,i,1) AS INT) * cont);
        END LOOP;

        IF((b % 11) < 2) THEN
            IF(((b % 11) < 2) AND CAST(substr(cpf,10,1) AS INT) <> 0) THEN        
                RETURN valido;
            ELSE
                valido :=true;
                RETURN valido;
            END IF;
        ELSE
            IF((11-(b % 11)) <> CAST(substr(cpf,10,1) AS INT)) THEN
                RETURN valido;
            ELSE
                valido:=true;
                RETURN valido;
            END IF;
        END IF;

        b:=0;
        cont:=11;
        FOR i IN 1..10 LOOP            
            b := b + (CAST(substr(cpf,i,1) AS INT) * cont);
            cont := cont - 1;
        END LOOP;

        IF((b % 11) < 2) THEN
            IF(((b % 11) < 2) AND CAST(substr(cpf,11,1) AS INT) <> 0) THEN        
                RETURN valido;
            ELSE
                valido :=true;
                RETURN valido;
            END IF;
        ELSE
            IF((11-(b % 11)) <> CAST(substr(cpf,11,1) AS INT)) THEN
                RETURN valido;
            ELSE
                valido:=true;
                RETURN valido;
            END IF;
        END IF;
    END
$$
LANGUAGE plpgsql;

drop function validaCPF()

create trigger validaCPF before insert or update on mecanico for each row execute procedure validaCPF();

create trigger validaCPF before insert or update on cliente for each row execute procedure validaCPF();


--5)      Gatilho para impedir que um mecânico seja removido caso não exista outro mecânico com a mesma função.

create or replace function impedir_Mecanico() returns trigger as
$$
declare 
	cont_funcao integer;
begin
	select count (*) into cont_funcao from mecanico where funcao = old.funcao;
	if cont_funcao <= 1 then 
		raise exception 'Operacao impossivel';
	end if;
	return old;
end;
$$

LANGUAGE plpgsql;

create trigger impedir_Mecanico before insert or update on mecanico for each row execute procedure impedir_Mecanico();

drop function impedir_Mecanico() cascade




--6)      Gatilho que ao inserir, atualizar ou remover um mecânico, reflita as mesmas modificações na tabela de Cliente. Em caso de atualização, 
--se o mecânico ainda não existir na tabela de Cliente, deve ser inserido.


create or replace function mec() returns trigger as
$$
begin

if select m.cpf,m. nome, m.idade, m.endereco, m.cidade from mecanico m
where NOT EXISTS ( SELECT  *
            FROM   cliente c
            WHERE   c.cpf=m.cpf and c.nome = m.nome and c.idade = m.cidade and c.idade= m.idade and c. endereco = m.endereco)
    else
        set c.cpf=m.cpf and c.nome = m.nome and c.idade = m.cidade and c.idade= m.idade and c. endereco = m.endereco;

end;
$$
LANGUAGE plpgsql;

create trigger mec before insert or update on cliente for each row execute procedure mec();



--7)      Gatilho para impedir que um conserto seja inserido na tabela Conserto se o mecânico já realizou mais de 20 horas extras no mês.

create or replace function hora_max() returns trigger as
$$
declare
	hora integer default 0;
begin
	select count (*) into hora from conserto where codm = new.codm;
	if hora > 20 then
		raise exception 'Maximo de horas atingido.... BAN :X';
	end if;
	return new;

end;
$$
LANGUAGE plpgsql;

create trigger hora_max before insert or update on conserto for each row execute procedure hora_max();

select * from mecanico

select * from conserto

insert into conserto values (1,3,'14/06/2014','16:00')

insert into conserto values (1,3,'20/06/2014','20:00')

insert into conserto values (1,6,'25/06/2014','12:00')

--Nota: Para a implementação dos gatilhos devem ser utilizadas as funções implementadas no exercício 10, quando possível.


