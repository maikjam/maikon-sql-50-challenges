/*

Desafio 05: Análise de Pareto - Curva ABC de Produtos
Foco: Identificar quais produtos representam 80% do faturamento acumulado.
Tabelas: Sales.SalesOrderDetail (sod) e Production.Product (p).
Lógica do KPI: Calcular o faturamento por produto e o acumulado. Criar coluna Curva_ABC: 
Se PercentualAcumulado <= 80%, marcar como 'PRODUTO CLASSE A', caso contrário, 'OUTROS'.
Nota Técnica: Aplicar SUM(Faturamento) OVER(ORDER BY Faturamento DESC) para o acumulado.
Objetivo: Apoiar a gestão estratégica de estoque e priorização de vendas.
*/
-- Densidade de lucro por unidade de tempo
-- Quanto lucro eu gero por cliente / produto / negócio dentro de um período específico.
-- obejtivo extrair dados onde mostram qual produto traz maior rentabilidade indiferente de seu valor 
-- isso faz com que possamos ser mais acertivo na adimistraçao de reposição de estoque 
-- itens com mais saida e retorno financeiro real sao diferentes de itens caros empacados
-- Analise de pareto ABC tras um caminho de menos esforço e recurso
-- fazendo os gastos ser uma vertende de retorno rapido 
-- analisar o preco de cada produto 
-- quantidade Total de Venda do produto e receita 
-- avaliar por classe A retorno maior, Classe B retorno medio, Classe C retorno minimo 
-- tudo em porcentagem %
-- avaliar por classe A retorno maior, Classe B retorno medio, Classe C retorno minimo 
-- maior receita e menor venda = classe A retorno maior
-- maior que C menor que A = Classe B retorno medio
-- maior menor receita maior Venda == Classe C retorno minimo 
-- extrair as base a ser analisadas isolar o que interessa 


-- 1. Soma total de vendas e quantidade agrupada por ID
WITH TotalProduto AS (
SELECT 
	pp.ProductId, 
	pp.Name,
	SUM(sod.LineTotal) ReceitaTotal,-- valor total de venda por id
	SUM(sod.OrderQTY) TotalProduto -- quantidade de pedidios 
FROM Production.Product AS pp
JOIN Sales.SalesOrderDetail AS sod
ON pp.ProductID = sod.ProductID
GROUP BY 
	pp.ProductID,
	pp.Name
),

-- 2. Cálculo do percentual unitário de cada produto sobre o total
PorcentualUnitario AS (
SELECT
	tp.ProductID,
	tp.Name,
	tp.ReceitaTotal * 100 / NULLIF(SUM(tp.ReceitaTotal) OVER() , 0) AS Porcentagem
FROM TotalProduto AS tp
),

-- 3. Cálculo da porcentagem acumulada 
PorcentualAcumulado AS (
SELECT 
	pu.ProductID,
	pu.Name,
	CAST(
	ROUND(SUM(pu.Porcentagem) OVER (ORDER BY pu.Porcentagem DESC ),2) 
									AS DECIMAL(10,2)) AS Acumulado

FROM PorcentualUnitario AS pu
)

-- 4. Consulta principal com a classificação ABC Pareto
SELECT 
	pa.ProductID,
	pa.Name,
	CASE 
		WHEN pa.Acumulado <= 80 THEN 'PRODUTO CLASSE A'
		WHEN pa.Acumulado <= 95 THEN 'PRODUTO CLASSE B'
		ELSE 'PRODUTO CLASSE C'
	END
FROM PorcentualAcumulado AS pa
