-- Thiago Costa Santana
-- Apresentação Case 
-- Jump Start Turma 4

USE jump_case;


select * from CaseSQL_movies;
select * from CaseSQL_names;
select * from CaseSQL_ratings;
select * from CaseSQL_title_principals;


/*1 - Gerar um relatório contendo os 10 filmes mais lucrativos de todos os tempos,
 e identificar em qual faixa de idade/gênero eles foram mais bem avaliados.*/

/* Explicação:

Consulta para extrair informações sobre filmes mais lucrativos, incluindo orçamento, rendimento bruto e lucro, relacionando as avaliações por 
gênero e idade com as melhores avaliações. A coluna de lucros_filmes foi criada a partir da diferença entre o rendimento bruto e o orçamento,
com formatação de valores em dólar.
Para formatar as colunas orçamento e rendimento bruto, foi utilizada a função Concat para adicionar o símbolo de dólar, seguida da função Format 
para ajustar o número com separadores de milhar e duas casas decimais. Foi feita a conversão das colunas para número e remoção de caracteres desnecessários.
Os filtros foram realizados com CASE WHEN para as avaliações por gênero e idade, criando as colunas de média de votos para homens e mulheres e faixa etária.
No filtro WHERE, foram estabelecidas condições para evitar valores vazios ou zerados, e a restrição de que o lucro seja maior que zero, utilizando o 
(REPLACE(REPLACE(SUBSTRING_INDEX(coluna, ' ', - 1),',',''), '.', ''), garantindo que as colunas fossem convertidas para número sem trazer demais caracteres 
usando Unsigned para que a coluna não retorne valores negativos
A ordenação foi feita com base no lucro calculado, sem formatação em moeda para não interferir nos resultados finais.*/

 select * from CaseSQL_movies;
 select * from CaseSQL_ratings;
 -- COM CET
 
 WITH filmes_lucrativos AS (
    SELECT 
        m.title AS titulo,
        CONCAT('$', FORMAT(CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.budget, ' ', - 1),',',''), '.', ''), UNSIGNED), 2)) AS orcamento,
        CONCAT('$', FORMAT(CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.worlwide_gross_income, ' ', - 1),',',''), '.', ''), UNSIGNED), 2)) AS rendimento_bruto,
        CONCAT('$', FORMAT(((CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.worlwide_gross_income, ' ', - 1),',',''), '.', ''), UNSIGNED))
            - CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.budget, ' ', - 1),',',''), '.', ''), UNSIGNED)), 2)) AS lucros_filmes,
        males_allages_avg_vote AS avaliacao_homens,
        females_allages_avg_vote AS avaliacao_mulheres,
    CASE 
         WHEN males_allages_avg_vote > females_allages_avg_vote THEN
            CASE 
                WHEN males_allages_avg_vote >= 0 AND males_allages_avg_vote < 18 THEN 'Masc <18' 
                WHEN males_allages_avg_vote >= 18 AND males_allages_avg_vote < 30 THEN 'Masc 18-30' 
                WHEN males_allages_avg_vote >= 30 AND males_allages_avg_vote < 50 THEN 'Masc 30-50'
                ELSE 'Masc >50'
            END 
        WHEN males_allages_avg_vote = females_allages_avg_vote THEN 'Masc = Fem' 
        ELSE
            CASE 
                WHEN females_allages_avg_vote >= 0 AND females_allages_avg_vote < 18 THEN 'Fem <18' 
                WHEN females_allages_avg_vote >= 18 AND females_allages_avg_vote < 30 THEN 'Fem 18-30' 
                WHEN females_allages_avg_vote >= 30 AND females_allages_avg_vote < 50 THEN 'Fem 30-50'
                ELSE 'Fem >50'
            END
    END AS faixa_etaria
    FROM casesql_movies m
        INNER JOIN casesql_ratings r
		ON m.imdb_title_id = r.imdb_title_id
    WHERE
        m.budget IS NOT NULL
        AND m.worlwide_gross_income IS NOT NULL
        AND m.budget <> ''
        AND m.worlwide_gross_income <> ''
        AND CONVERT(REPLACE(SUBSTRING_INDEX(m.worlwide_gross_income, ' ', - 1),',',''), SIGNED)
            - CONVERT(REPLACE(SUBSTRING_INDEX(m.budget, ' ', - 1),',',''), SIGNED) > 0
)
SELECT * FROM filmes_lucrativos
ORDER BY 
    (CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(rendimento_bruto, ' ', - 1),',',''), '.', ''), UNSIGNED)
    - CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(orcamento, ' ', - 1),',',''), '.', ''), UNSIGNED)
) DESC
LIMIT 10;

  
 --   2° Exemplo VIEW
   
   CREATE OR REPLACE VIEW melhor_lucro AS
	SELECT 
    	m.title AS titulo,
    	CONCAT('$', FORMAT(CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.budget, ' ', - 1),',',''), '.', ''), UNSIGNED), 2)) AS orcamento,
    	CONCAT('$', FORMAT(CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.worlwide_gross_income, ' ', - 1),',',''), '.', ''), UNSIGNED), 2)) AS rendimento_bruto,
    	CONCAT('$', FORMAT(((CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.worlwide_gross_income, ' ', - 1),',',''), '.', ''), UNSIGNED))
        	- CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.budget, ' ', - 1),',',''), '.', ''), UNSIGNED)), 2)) AS lucros_filmes,
		GREATEST(r.males_0age_avg_vote, r.males_18age_avg_vote, r.males_30age_avg_vote, r.males_45age_avg_vote, 
    	r.females_0age_avg_vote, r.females_18age_avg_vote, r.females_30age_avg_vote, r.females_45age_avg_vote) AS media_votes,
    	(SELECT 
        	CASE 
            	WHEN media_votes = r.males_0age_avg_vote THEN 'Homens menores de 18 anos' 
            	WHEN media_votes = r.males_18age_avg_vote THEN 'Homens 18 anos a 30 anos' 
            	WHEN media_votes = r.males_30age_avg_vote THEN 'Homens 30 a 45 anos' 
            	WHEN media_votes = r.males_45age_avg_vote THEN 'Homens maiores de 45 anos' 
            	WHEN media_votes = r.females_0age_avg_vote THEN 'Mulheres menores de 18 anos' 
            	WHEN media_votes = r.females_18age_avg_vote THEN 'Mulheres 18 anos a 30 anos' 
            	WHEN media_votes = r.females_30age_avg_vote THEN 'Mulheres 30 a 45 anos' 
            	WHEN media_votes = r.females_45age_avg_vote THEN 'Mulheres maiores de 45 anos' 
        	END) AS faixa_melhor_avaliado  
    	FROM casesql_movies m
    	 INNER JOIN casesql_ratings r
        	ON m.imdb_title_id = r.imdb_title_id
    	WHERE 
        	m.budget IS NOT NULL
        	AND m.worlwide_gross_income IS NOT NULL
        	AND m.budget <> ''
        	AND m.worlwide_gross_income <> ''
        	AND CONVERT(REPLACE(SUBSTRING_INDEX(m.worlwide_gross_income, ' ', - 1),',',''), SIGNED)
            - CONVERT(REPLACE(SUBSTRING_INDEX(m.budget, ' ', - 1),',',''), SIGNED) > 0;
    
SELECT 
		titulo,
        orcamento,
        rendimento_bruto,
        max(lucros_filmes) as lucros_filmes,
        media_votes
FROM melhor_lucro
group by titulo, orcamento, rendimento_bruto, lucros_filmes, media_votes
ORDER BY 
	 (CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(rendimento_bruto, ' ', - 1),',',''), '.', ''), UNSIGNED)
    - CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(orcamento, ' ', - 1),',',''), '.', ''), UNSIGNED)
) DESC
LIMIT 10;

   
-- 2 - Quais os gêneros que mais aparecem entre os Top 10 filmes mais bem avaliados de cada ano, nos últimos 10 anos.

/* Explicação:

Criei uma consulta utilizando CTE onde na coluna gênero foi filtrada a primeira palavra presente em cada entrada. A coluna gênero foi trazida junto com a coluna criada "filmes_top10_ano".
 Converti a coluna 'year' em um número inteiro para evitar valores negativos. Realizei um filtro utilizando WHEREna coluna ano dentro do intervalo dos últimos 10 anos e nas colunas com maiores
médias de votos para obter os melhores filmes por ano. 
Utilizei a função ROW_NUMBER(), juntamente com PARTITION BY e ORDER BY, para atribuir um número sequencial a cada linha dentro de cada partição definida pelo ano, 
ordenando de forma decrescente pelas médias de avaliação dos filmes.
O resultado é uma lista com os top 10 filmes de cada ano, baseado em suas avaliações. A cláusula ORDER BY ano ASC no final da query garante a ordenação ascendente dos resultados pelo ano. */

-- CET 

select * from CaseSQL_movies;

WITH Top10Filmes AS (
  SELECT
		SUBSTRING_INDEX(genre, ',', 1) AS genero,
		CAST(year AS UNSIGNED) AS ano,
		avg_vote AS melhores_avaliacoes,
		ROW_NUMBER() OVER(PARTITION BY CAST(year AS UNSIGNED) ORDER BY avg_vote DESC) AS rn
  FROM casesql_movies
  WHERE CAST(year AS UNSIGNED) BETWEEN YEAR(CURDATE()) - 10 AND YEAR(CURDATE()) - 1
	AND avg_vote >= 8
)
SELECT
	  SUBSTRING_INDEX(GROUP_CONCAT(genero), ',', 1) AS genero,
	  COUNT(*) AS filmes_top10_ano,
      ano,
      ROUND(AVG(melhores_avaliacoes), 2) AS melhores_avaliacoes	  
FROM (
	  SELECT
			genero,
			ano,
			melhores_avaliacoes,
			rn
	FROM Top10Filmes
	WHERE rn <= 10
) AS sub
GROUP BY ano
ORDER BY ano ASC
LIMIT 10;

    
    
-- 3 - Quais os 50 filmes com menor lucratividade ou que deram prejuízo, nos últimos 30 anos. Considerar apenas valores em dólar ($).

/* Explicação:
Criei uma view com cálculo do menor lucro ou prejuízo de cada filme, subtração do valor da receita mundial do valor do orçamento é feita para cada filme.
Os valores são convertidos em números inteiros após remover caracteres especiais como vírgulas e pontos e filmes dos últimos 30 anos, realizado no filtro com a cláusula WHERE garantindo o retorno correto dos resultados implementados na view
Selecionando a view as colunas para apresentação como, título do filme, a receita bruta mundial, o orçamento. 
Foi realizado um CASE WHEN criando a coluna o tipo de lucro/prejuízo e o valor do lucro/prejuízo para os 50 filmes com menor lucratividade. 
Os filmes são ordenados em ordem crescente de lucro/prejuízo. Os valores de receita bruta mundial, orçamento
e lucro/prejuízo são formatados em dólar ($). */


select * from CaseSQL_movies;


CREATE OR REPLACE VIEW filmes_lucro_prejuizo AS
SELECT 
		title,
		worlwide_gross_income,
		budget,
		(CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(worlwide_gross_income, ' ', - 1),',',''), '.', ''), SIGNED)
		-  CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(budget, ' ', - 1),',',''), '.', ''), SIGNED)) AS lucro_prejuizo
FROM casesql_movies 
WHERE year = YEAR(NOW()) - 30 
    AND budget IS NOT NULL 
    AND worlwide_gross_income IS NOT NULL 
    AND budget <> '' 
    AND worlwide_gross_income <> '' 
    AND CONVERT(REPLACE(SUBSTRING_INDEX(worlwide_gross_income, ' ', - 1),',',''), SIGNED) 
    AND CONVERT(REPLACE(SUBSTRING_INDEX(budget, ' ', - 1),',',''), SIGNED);    
    
SELECT 
    title AS titulo, 
    CONCAT('$', FORMAT(CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(worlwide_gross_income, ' ', - 1),',',''), '.', ''), SIGNED), 2)) AS rendimento_bruto, 
    CONCAT('$', FORMAT(CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(budget, ' ', - 1),',',''), '.', ''), SIGNED), 2)) AS orcamento, 
    CASE 
        WHEN lucro_prejuizo < 0 THEN 'Prejuízo'
        WHEN lucro_prejuizo > 0 THEN 'Lucro'
        ELSE 'Neutro'
    END AS tipo_lucro_prejuizo,
    CONCAT('$', FORMAT(lucro_prejuizo, 2)) AS lucro_prejuizo
FROM filmes_lucro_prejuizo
ORDER BY lucro_prejuizo ASC
LIMIT 50;



-- 4) Selecionar os top 10 filmes baseados nas avaliações dos usuários, para cada ano, nos últimos 20 anos.

/* Explicação:

 Criei uma view dos top 10 filmes baseados nas melhores avaliações dos usuários, para cada ano, nos últimos 20 anos, 
com dados da tabela casesql_movies exibindo o título do filme, a avaliação dos usuários e o ano de lançamento. 
Com a criação de uma coluna ranking que foi calculada entre o ano, media avaliação e numero de votos os dados 
são ordenados em ordem decrescente de avaliação dos usuários e votos reforçando a condição do desempate limitado ao Top10Filmes. */

select * from CaseSQL_movies;
 
CREATE OR REPLACE VIEW top_filmes AS 
 SELECT 
		title AS titulo, 
		avg_vote AS melhor_avaliacao, 
		year AS ano_lancamento,
		RANK() OVER (PARTITION BY year ORDER BY avg_vote DESC, votes DESC) AS ranking_desempate
FROM casesql_movies 
WHERE 
        year BETWEEN YEAR(CURDATE()) - 20 AND YEAR(CURDATE()) 
ORDER BY 
		avg_vote DESC, votes DESC 
LIMIT 10;

SELECT * FROM top_filmes;


-- 5) Gerar um relatório com os top 10 filmes mais bem avaliados pela crítica e os top 10 pela avaliação de usuário, contendo também o budget dos filmes.

/* explicação:

Criei uma View com os top 10 filmes melhores avaliados pela crítica (metascore) e os top 10 pela avaliação dos usuários (avg_vote), 
incluindo também o orçamento dos filmes já com a coluna orçameto no padrão monetário em $ Dólar.
Na subconsulta criei top_avg_vote que seleciona as mesma colunas e as ordenada pelo orcamento fiz isso para conseguir deixar de forma
organizada as duas colunas sem utilização de funções adicionais para que consiga demostrar com a união entre elas.
Em seguida, faço a união das consultas os resultados das duas partes da consulta utilizando o comando UNION, e limita o resultado
final a 10. 
Esses dados podem ser usados para fornecer uma visão geral dos filmes com as melhores avaliações críticas e avaliações dos usuários, 
juntamente com informações sobre o orçamento de cada filme.*/

select * from CaseSQL_movies;

WITH top_metascore AS (
    SELECT 
        title AS titulo,
        metascore aval_critica,
        avg_vote AS aval_usuario, 
		CONCAT('$', FORMAT(CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(budget, ' ', - 1),',',''), '.', ''), UNSIGNED), 2)) AS orcamento
    FROM
        casesql_movies
    WHERE budget IS NOT NULL AND budget != ''
    ORDER BY metascore DESC
    LIMIT 10
),
top_avg_vote AS (
    SELECT 
        title AS titulo,
        metascore aval_critica,
        avg_vote AS aval_usuario, 
        CONCAT('$', FORMAT(CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(budget, ' ', - 1),',',''), '.', ''), UNSIGNED), 2)) AS orcamento
    FROM 
        casesql_movies
    WHERE budget IS NOT NULL AND budget != ''
    ORDER BY budget DESC
    LIMIT 10
)
	SELECT
		* 
	FROM 
		top_metascore
	UNION
	SELECT
		* 
	FROM 
		top_avg_vote
	LIMIT 10;


-- 6 - Gerar um relatório contendo a duração média de 5 gêneros a sua escolha.


/*Explicação:

Criei uma View ajustando os 5 generos em português.
Convertendo em media horas a coluna duração formatada
Trazendo o resultado media_duração dos 5 gêneros escolhidos */

select * from CaseSQL_movies;

CREATE OR REPLACE VIEW genero_media_duracao AS
SELECT 
    CASE
        WHEN genre = 'Comedy' THEN 'Comédia'
        WHEN genre = 'Drama' THEN 'Drama'
        WHEN genre = 'Horror' THEN 'Terror'
        WHEN genre = 'Crime' THEN 'Crime'
        WHEN genre = 'Romance' THEN 'Romance'
    END AS genero,
    CONCAT(LPAD(ROUND(AVG(duration) / 60), 2, '0'),':',
		LPAD(ROUND(AVG(duration) % 60), 2, '0'),'hs') AS media_duracao
FROM 
	casesql_movies
WHERE
    genre IN ('Comedy' , 'Drama', 'Horror', 'Crime', 'Romance')
GROUP BY genre
LIMIT 50;

SELECT * FROM genero_media_duracao;




/* 7 )Gerar um relatório sobre os 5 filmes mais lucrativos de um ator/atriz(que podemos filtrar), trazendo o nome, ano de exibição, e Lucro obtido. 
-- Considerar apenas valores em dólar($).*/
-- para teste Ator Marlon Brando, Atriz Brigitte Bardot

/* Explicação:

Criei uma procedure sobre os 5 filmes mais lucrativos de um ator/atriz que filtrei da tabela casesql_names.
Selecionei o título do filme, o ano de lançamento, o nome do ator/atriz, e o lucro obtido pelo filme.
Para calcular o lucro a procedure subtrai o orçamento do filme do rendimento_bruto e formata o resultado em formato monetário.
Além disso, a procedure filtra apenas por filmes em que ator/atriz atuou e que tiveram lucro positivo, a lista é ordenada em ordem decrescente 
de lucro e limitada aos 5 filmes mais lucrativos.*/


select * from CaseSQL_movies;
select * from CaseSQL_names;
select * from CaseSQL_title_principals;


DELIMITER //
DROP PROCEDURE IF EXISTS atores_5filmes_lucrativos;
CREATE PROCEDURE atores_5filmes_lucrativos() 
BEGIN 
    SELECT m.title AS titulo_filme, 
           m.year AS ano_lancamento, 
           n.name AS nome_atores, 
           CONCAT('$', FORMAT(((CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.worlwide_gross_income, ' ', - 1),',',''), '.', ''), UNSIGNED)) 
			- CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.budget, ' ', - 1),',',''), '.', ''), UNSIGNED)), 2)) AS lucros_filmes 
    FROM casesql_movies m 
		LEFT JOIN casesql_title_principals tp 
			ON m.imdb_title_id = tp.imdb_title_id 
		LEFT JOIN casesql_names n 
			ON tp.imdb_name_id = n.imdb_name_id 
    WHERE n.name = 'Marlon Brando' 
          AND (tp.category = 'actor' OR tp.category = 'actress') 
          AND CONVERT( REPLACE(SUBSTRING_INDEX(m.worlwide_gross_income, ' ', - 1),',','') , SIGNED) 
			- CONVERT( REPLACE(SUBSTRING_INDEX(m.budget, ' ', - 1),',','') , SIGNED) > 0 
    ORDER BY lucros_filmes DESC 
    LIMIT 5; 
END//

DELIMITER ;
CALL atores_5filmes_lucrativos();


-- 7) Exemplo CTE

WITH atores AS 
			( 
SELECT m.title AS titulo_filme,
       m.year AS ano_lancamento,
       n.name AS nome_atores,
       CONCAT('$', FORMAT(((CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.worlwide_gross_income, ' ', - 1),',',''), '.', ''), UNSIGNED))
			- CONVERT(REPLACE(REPLACE(SUBSTRING_INDEX(m.budget, ' ', - 1),',',''), '.', ''), UNSIGNED)), 2)) AS lucros_filmes
FROM casesql_movies m
	LEFT JOIN casesql_title_principals tp 
		ON m.imdb_title_id = tp.imdb_title_id
	LEFT JOIN casesql_names n ON tp.imdb_name_id = n.imdb_name_id
WHERE n.name = 'Marlon Brando'
      AND (tp.category = 'actor' OR tp.category = 'actress')
      AND CONVERT( REPLACE(SUBSTRING_INDEX(m.worlwide_gross_income, ' ', - 1),',','') , SIGNED)
			- CONVERT( REPLACE(SUBSTRING_INDEX(m.budget, ' ', - 1),',','') , SIGNED) > 0
ORDER BY lucros_filmes DESC
LIMIT 5
)  
  SELECT * FROM atores;
  
  

  
  /* 8 - Baseado em um filme que iremos selecionar, trazer um relatório contendo quais os atores/atrizes participantes,
  e pra cada ator trazer um campo com a média de avaliação da crítica dos últimos 5 filmes em que esse ator/atriz participou.*/
  
/* Explicação:

seleciona os atores/atrizes participantes de um filme específico 'que iremos selecionar), calcula a média de avaliação da crítica
dos últimos 5 filmes em que cada ator/atriz participou e apresenta um relatório com o título do filme, o nome do ator/atrizes e a
média de avaliação dos últimos 5 filmes, ordenando de forma decrescente pela média de avaliação.*/

-- opções filmes Avatar, Atlantis, Cleopatra
	select * from CaseSQL_movies;
	select * from CaseSQL_names;

WITH atores_5ultimos_filmes AS (
	  SELECT
			n.name AS ator_ou_atriz,
			m.title AS titulo_filme,
			m.metascore AS aval_critica,
			RANK() OVER (PARTITION BY n.name ORDER BY m.year DESC) AS ordem_filme
	  FROM casesql_movies m
		   LEFT JOIN casesql_title_principals p 
			 ON m.imdb_title_id = p.imdb_title_id
		   LEFT JOIN casesql_names n 
			 ON p.imdb_name_id = n.imdb_name_id
		WHERE m.title = 'Cleopatra'
			AND (p.category = 'actor' OR p.category = 'actress')
), medias_5_ultimos_filmes AS (
	SELECT
		ator_ou_atriz,
		MAX(titulo_filme) AS titulo_filme, 
		AVG(aval_critica) AS media_aval_critica
	FROM atores_5ultimos_filmes
	WHERE 
		ordem_filme <= 5 
	GROUP BY ator_ou_atriz
)
	SELECT
		  titulo_filme, 
		  ator_ou_atriz,
		 media_aval_critica
	FROM 
		medias_5_ultimos_filmes
	ORDER BY  media_aval_critica DESC
    limit 30;



-- 8) -  2° Exemplo avaliação ator


WITH Atores AS (
    SELECT 
        p.imdb_name_id,
        n.name AS Ator
    FROM casesql_title_principals AS p
     LEFT JOIN casesql_names AS n 
		ON p.imdb_name_id = n.imdb_name_id
     LEFT JOIN casesql_movies AS m 
		ON p.imdb_title_id = m.imdb_title_id
    WHERE 
        m.title = 'Avengers: Endgame'
),
UltimoS_5_filmes AS (
    SELECT 
        p.imdb_name_id,
        m.title,
        m.metascore,
        ROW_NUMBER() OVER (PARTITION BY p.imdb_name_id ORDER BY m.year DESC) AS row_num
    FROM casesql_title_principals AS p
		LEFT JOIN casesql_movies AS m 
			ON p.imdb_title_id = m.imdb_title_id
    WHERE 
        p.imdb_name_id IN (SELECT imdb_name_id FROM Atores)
)

SELECT 
    a.ator,
    AVG(l.metascore) AS media_avalcritica_5_filmes
FROM Atores AS a
LEFT JOIN UltimoS_5_filmes AS l 
    ON a.imdb_name_id = l.imdb_name_id AND l.row_num <= 5
GROUP BY 
    a.ator
ORDER BY 
   media_avalcritica_5_filmes DESC;



-- 9 - Gerar mais duas análises a sua escolha, baseado nessas tabelas (em uma delas deve incluir a análise exploratória de dois campos,
-- um quantitativo e um qualitativo, respectivamente).
-- Explicação Análise 1:
/*Fiz uma análise exploratória abordando os campos qualitativos (gênero, personagens) e quantitativos (avaliação do usuário, ano de lançamento) dos filmes 
entre 2016 e 2023, focando em filmes de ação, drama e terror com avaliação média acima de 8 , limitando a busca aos 30 primeiros resultados ordenados por
avaliação do usuário. 

Essa foi uma análise sobre a percepção dos usuários em relação a esses filmes durante esse período de tempo.

Foram verificados os gêneros mais populares entre os espectadores com filmes bem avaliados, a distribuição dos anos de lançamento dos filmes selecionados 
e a análise dos personagens cadastrados nos filmes.*/

select * from casesql_movies;
select * from casesql_title_principals;

-- 1° Análise

 
WITH analise_filmes AS (
    SELECT 
			m.title AS titulo,
			SUBSTRING_INDEX(m.genre, ',', 1) AS genero,
			COALESCE(tp.characters, 'Não Cadastrado') AS personagens,
			DATE_FORMAT(m.date_published, '%d/%m/%Y') AS ano_lancamento,
			m.avg_vote AS avaliacao_usuario
    FROM casesql_movies m
		LEFT JOIN casesql_title_principals tp 
            ON m.imdb_title_id = tp.imdb_title_id
    WHERE
			m.avg_vote > 8
			AND YEAR(m.date_published) BETWEEN 2016 AND 2023
			AND (m.genre LIKE '%Action%'
			OR m.genre LIKE '%Drama%'
			OR m.genre LIKE '%Horror%')
)
SELECT 
		titulo, 
        genero, 
        personagens, 
        ano_lancamento, 
        avaliacao_usuario
FROM analise_filmes
GROUP BY titulo, genero, personagens, ano_lancamento, avaliacao_usuario
ORDER BY avaliacao_usuario DESC
LIMIT 30;
		
        

 -- Explicação 2° Análise 
/*Essa view analisa os filmes lançados entre 2010 e 2020 em relação à média de duração dos filmes, apresentando o título do filme, 
personagens envolvidos (ou indicando como 'Não Cadastrado' caso não haja informação), o ano de lançamento e a média de duração em horas e minutos.
A análise apresentada é ordenada pela média de duração em ordemcrescente e limitada aos 30 primeiros resultados.*/

CREATE OR REPLACE VIEW analise_top_filmes AS
SELECT 
		MAX(m.title) AS titulo,
		COALESCE(tp.characters, 'Não Cadastrado') AS personagens,
		DATE_FORMAT(m.date_published, '%d/%m/%Y') AS ano_lancamento,
		CONCAT(LPAD(ROUND(AVG(duration) / 60), 2, '0'),':',
			LPAD(ROUND(AVG(duration) % 60), 2, '0'),'hs') AS media_duracao
FROM casesql_movies m
		LEFT JOIN casesql_title_principals tp 
		ON m.imdb_title_id = tp.imdb_title_id
WHERE
		YEAR(m.date_published) BETWEEN 2010 AND 2020
GROUP BY m.title, tp.characters, m.date_published;

SELECT 
		titulo, 
        personagens,
        ano_lancamento, 
        media_duracao 
FROM analise_top_filmes
GROUP BY titulo, personagens, ano_lancamento, media_duracao 
ORDER BY media_duracao
LIMIT 30;