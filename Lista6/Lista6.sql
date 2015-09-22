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


--Descrição: Considerando o BD de uma oficina mecânica desenvolvido nas últimas aulas (e disponível na página da disciplina), faça a especificação das seguintes 
--funções em PostgreSQL. Defina o tipo de cada função (Immutable, Stable ou Volatile), para que o otimizador do PL/pgSQL possa aplicar o melhor tipo de cache.

--1)      Função para inserção e exclusão de um Setor.

CREATE OR REPLACE FUNCTION ins_setor(pcods int,pnome varchar) RETURNS int AS 
$$
	declare linhasafetadas int;
	begin
		insert into setor values(pcods,pnome);
		get diagnostics linhasafetadas = row_count;
		raise notice 'Linhas Afetadas %',linhasafetadas;
		return linhasafetadas;
	end;

$$

LANGUAGE plpgsql;


select ins_setor(5,'teste');
select ins_setor(6,'pintura');

select * from setor;

drop function ins_setor(pcods int,pnome varchar);



create or replace function exc_setor(pcods int) returns int as
$$

	declare linhasafetadas int default 0;
	begin
		delete from setor where cods = pcods;
		get diagnostics linhasafetadas = row_count;
		raise notice 'Linhas Afetadas %',linhasafetadas;
		return linhasafetadas;
	end;

$$
LANGUAGE plpgsql;

select exc_setor(6);

select * from setor;


--2)      Função para inserção e exclusão de um Mecânico.

create or replace function inser_mecanico(pcodm int, mcpf bigint,pnome varchar,midade int,endm character varying(50),cidm character varying(50),funcm character varying(50),pcods int) returns int as
$$

	declare linhasafetadas int default 0;

	begin
		insert into mecanico values (pcodm,mcpf,pnome,midade,endm,cidm,funcm,pcods);
		get diagnostics linhasafetadas = row_count;
		raise notice 'Linhas Afetadas %',linhasafetadas;
		return linhasafetadas;
	end;
$$

LANGUAGE plpgsql;

select inser_mecanico(7,10010101011,'Mauricio',35,'Saguaçu','Joinville','Lataria',3);

select * from mecanico;


create or replace function exc_mecanico(pcodm int) returns int as
$$

	declare linhasafetadas int default 0;

	begin
		delete from mecanico where codm = pcodm;
		get diagnostics linhasafetadas = row_count;
		raise notice 'Linhas Afetadas %',linhasafetadas;
		return linhasafetadas;
	end;
$$

LANGUAGE plpgsql;

select exc_mecanico(7);

select * from mecanico;



--3)      Função para inserção e exclusão de uma Cliente.

select * from cliente;


create or replace function inser_cliente(pcodc int, clicpf bigint,cnome varchar,cidade int,endc character varying(50),cidc character varying(50),ccodv int) returns int as
$$

	declare linhasafetadas int default 0;

	begin
		insert into cliente values (pcodc,clicpf,cnome,cidade,endc,cidc,ccodv);
		get diagnostics linhasafetadas = row_count;
		raise notice 'Linhas Afetadas %',linhasafetadas;
		return linhasafetadas;
	end;
$$

LANGUAGE plpgsql;



select inser_cliente(9,10010101011,'Antonio',25,'Bom Retiro','Joinville',6);

select * from cliente;


create or replace function exc_cliente(pcodc int) returns int as
$$

	declare linhasafetadas int default 0;

	begin
		delete from cliente where codc = pcodc;
		get diagnostics linhasafetadas = row_count;
		raise notice 'Linhas Afetadas %',linhasafetadas;
		return linhasafetadas;
	end;
$$

LANGUAGE plpgsql;

select exc_cliente(7);

--4)      Função para inserção e exclusão de um Veículo.


select * from veiculo;

create or replace function inser_veiculo(pcodv int, vrenavam bigint,vmodelo character varying(50),vmarca character varying(50),vano int,vquilom float) returns int as
$$

	declare linhasafetadas int default 0;

	begin
		insert into veiculo values (pcodv,vrenavam,vmodelo,vmarca,vano,vquilom);
		get diagnostics linhasafetadas = row_count;
		raise notice 'Linhas Afetadas %',linhasafetadas;
		return linhasafetadas;
	end;
$$

LANGUAGE plpgsql;


select inser_veiculo(8,'20017001129','C30','Volvo','2016',4000.000);


create or replace function exc_veiculo(pcodv int) returns int as
$$

	declare linhasafetadas int default 0;

	begin
		delete from veiculo where codv = pcodv;
		get diagnostics linhasafetadas = row_count;
		raise notice 'Linhas Afetadas %',linhasafetadas;
		return linhasafetadas;
	end;
$$

LANGUAGE plpgsql;

select exc_veiculo(8);

--5)      Função para inserção e exclusão de um Conserto.

select * from conserto

create or replace function inser_conserto(pcodcm int, pcodcv int, pdatac date, phorac time) returns int as
$$

	declare linhasafetadas int default 0;

	begin
		insert into conserto values (pcodcm, pcodcv, pdatac, phorac);
		get diagnostics linhasafetadas = row_count;
		raise notice 'Linhas Afetadas %',linhasafetadas;
		return linhasafetadas;
	end;
$$

LANGUAGE plpgsql;

select inser_conserto(3,2,'15/06/2014','15:00');


select * from conserto


create or replace function exc_conserto(pcodcm int,pcodcv int) returns int as
$$

	declare linhasafetadas int default 0;

	begin
		delete from conserto where codm = pcodcm and codv = pcodcv;
		get diagnostics linhasafetadas = row_count;
		raise notice 'Linhas Afetadas %',linhasafetadas;
		return linhasafetadas;
	end;
$$

LANGUAGE plpgsql;

select exc_conserto(3,2);


--6)      Função para calcular a média geral de idade dos Mecânicos e Clientes.

create or replace function calc_media_mec_cli() returns float as
$$

	declare vidade int default 0;
		somaidade int default 0;
		resultado float default 0;
		quant int default 0;

	begin
		for vidade in select idade from mecanico loop
			somaidade := somaidade + vidade;
			quant := quant + 1;
		end loop;
		for vidade in select idade from cliente loop
			somaidade := somaidade + vidade;
			quant := quant + 1;
		end loop;
		resultado := somaidade/quant;
		return resultado;
	end;

$$

LANGUAGE plpgsql;

select calc_media_mec_cli();

--7)      Uma única função que permita fazer exclusão de um Setor, Mecânico, Cliente ou Veículo.

CREATE FUNCTION exclusao(pcods int,nomes character varying(50)) returns void as
$$
BEGIN
	delete from setor where cods = pcods;
END;
$$
LANGUAGE plpgsql;



CREATE FUNCTION exclusao(int, bigint, character varying(50), int, character varying (500), character varying(500),character varying(500), int) returns void as
$$
DECLARE
cod_m alias for $1;
cpf_m alias for $2;
nome_m alias for $3;
idade_m alias for $4;
endereco_m alias for $5;
cidade_m alias for $6;
funcao_m alias for $7;
cods_m alias for $8;


BEGIN
	delete from mecanico where codm=cod_m;
END;
$$
LANGUAGE plpgsql;



CREATE FUNCTION exclusao(int, bigint, character varying(50), int, character varying (500), character varying(500),int) returns void as
$$
DECLARE
cod_c alias for $1;
cpf_c alias for $2;
nome_c alias for $3;
idade_c alias for $4;
endereco_c alias for $5;
cidade_c alias for $6;
codv_c alias for $7;


BEGIN
	delete from cliente where codc=cod_c;
END;
$$
LANGUAGE plpgsql;


CREATE FUNCTION exclusao(int, bigint, character varying(50),character varying (50),int,float) returns void as
$$
DECLARE
cod_v alias for $1;
renavam_v alias for $2;
mod_v alias for $3;
marca_v alias for $4;
ano_v alias for $5;
quilom_v alias for $6;



BEGIN
	delete from veiculo where codv=cod_v;
END;
$$
LANGUAGE plpgsql;



--8)      Considerando que na tabela Cliente apenas codc é a chave primária, faça uma função que remova clientes com CPF repetido, 
--deixando apenas um cadastro para cada CPF. Escolha o critério que preferir para definir qual cadastro será mantido: 
--aquele com a menor idade, que 
--possuir mais consertos agendados, etc. Para testar a função, não se esqueça de inserir na tabela alguns clientes
-- com este problema.




CREATE or replace FUNCTION cpf_repetido() returns void as
$$
DECLARE
d record;
BEGIN
	for d in select * from cliente
	    group  by codc, cpf, nome, idade, endereco, cidade, codv
	    having count(cpf) >1
	loop
	    delete from cliente where cpf=d.cpf;
	    insert into cliente values (d.cpf);
	end loop;
	return;

END;
$$
LANGUAGE plpgsql;

select cpf_repetido();



--9)   Função para calcular se o CPF é válido*.

CREATE OR REPLACE FUNCTION public."validaCPF"(cod_cpf BIGINT) RETURNS boolean as 
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


--10)   Função que calcula a quantidade de horas extras de um mecânico em um mês de trabalho. O número de horas extras é calculado a partir das horas que excedam as 160 horas de trabalho mensais. O número de horas mensais trabalhadas é
-- calculada a partir dos consertos realizados. Cada conserto tem a duração de 1 hora.

CREATE or replace FUNCTION hora_extra() returns time as
$$
DECLARE
horas time;
BEGIN

	if ((select sum(hora) from conserto c join mecanico m using (codm))>'160:00:00') then
		horas=((select sum(hora) from conserto c join mecanico m using (codm))-'160:00:00');
	end if;
	return horas;
END;
$$
LANGUAGE plpgsql;


select hora_extra();



--* Como calcular se o CPF é válido:

--O CPF é composto por onze algarismos, onde os dois últimos são chamados de dígitos verificadores, ou seja, os dois últimos dígitos são criados a partir dos nove primeiros. O cálculo é feito em duas etapas utilizando o módulo de divisão 11. Para exemplificar melhor será usado um CPF hipotético, por exemplo, 222.333.444-XX.

--O primeiro dígito é calculado com a distribuição dos dígitos colocando-se os valores 10,9,8,7,6,5,4,3,2 conforme a representação abaixo:

--2 2 2 3 3 3 4 4 4

--10 9 8 7 6 5 4 3 2

--Na seqüência multiplica-se os valores de cada coluna:

--2    2    2    3    3    3    4    4    4

--10  9    8    7    6    5    4    3    2

--20 18  16  21  18  15  16  12   8

--Em seguida efetua-se o somatório dos resultados (20+18+...+12+8), o resultado obtido (144) deve ser divido por 11. Considere como quociente apenas o valor inteiro, o resto da divisão será responsável pelo cálculo do primeiro dígito verificador. 144 dividido por 11 tem-se 13 de quociente e 1 de resto da divisão. Caso o resto da divisão seja menor que 2, o primeiro dígito verificador se torna 0 (zero), caso contrário subtrai-se o valor obtido de 11. Como o resto é 1 então o primeiro dígito verificador é 0 (222.333.444-0X).

--Para o cálculo do segundo dígito será usado o primeiro dígito verificador já calculado. Monta-se uma tabela semelhante a anterior só que desta vez é usado na segunda linha os valores 11,10,9,8,7,6,5,4,3,2, já que é incorporado mais um algarismo para esse cálculo.

--2    2   2  3  3  3  4  4  4  0

--11 10  9  8  7  6  5  4  3  2

--Na próxima etapa é feita como na situação do cálculo do primeiro dígito verificador, multiplica-se os valores de cada coluna:

--2     2    2    3    3    3    4    4    4   0

--11  10   9    8    7    6    5    4    3   2

--22  20  18  24  21  18  20  16  12  0

--Depois efetua-se o somatório dos resultados: 22+20+18+24+21+18+20+16+12+0=171.

--Agora, pega-se esse valor e divide-se por 11. Considere novamente apenas o valor inteiro do quociente, e com o resto da divisão, no caso 6, usa-se para o cálculo do segundo dígito verificador, assim como na primeira parte. Se o valor do resto da divisão for menor que 2, esse valor passa automaticamente a ser zero, caso contrário é necessário subtrair o valor obtido de 11 para se obter o dígito verificador, nesse caso 11-6=5. Portanto, chega-se ao final dos cálculos e descobre-se que os dígitos verificadores do CPF hipotético são os números 0 e 5, portanto o CPF fica:

--222.333.444-05
