
/*
Desafio 09: Pivot Table - Faturamento Trimestral por Categoria
Foco: Reestruturação de dados (Linhas para Colunas).
Tabelas: Sales.SalesOrderDetail (sod), Production.Product (p), ProductCategory (pc).
Visão: Exibir uma linha por categoria e quatro colunas (Q1, Q2, Q3, Q4) com a soma das vendas.
Lógica do KPI: Comparar o desempenho entre trimestres de forma horizontal.
Nota Técnica: Cláusula PIVOT ou SUM(CASE WHEN DATEPART(QUARTER...) THEN ... END).
Objetivo: Facilitar a leitura de relatórios de fechamento de ano para a diretoria.
*/

-- 1. CAMADA DE EXTRAÇÃO E TRANSFORMAÇÃO (SILVER LAYER)
-- Consolida vendas brutas e segmenta por trimestre para análise de sazonalidade.
WITH BaseDados AS (
	SELECT
		pc.Name AS Categoria,
		DATEPART(QUARTER, soh.OrderDate) AS Trimestre, -- o índice 1-4
		sod.LineTotal AS TotalTrimestre

	FROM Sales.SalesOrderDetail AS sod 
	JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
	JOIN Production.Product AS pp ON sod.ProductID = pp.ProductID
	JOIN Production.ProductSubcategory AS psc ON pp.ProductSubcategoryID = psc.ProductSubcategoryID
	JOIN Production.ProductCategory AS pc ON psc.ProductCategoryID = pc.ProductCategoryID
)
-- 2. CAMADA DE APRESENTAÇÃO (GOLD LAYER)
-- Pivotagem de linhas para colunas, permitindo a comparação de Quarter over Quarter (QoQ).
SELECT 
	Categoria,
	--Tratamento de campos nulos
    ISNULL([1], 0) AS Trimestre_1,
    ISNULL([2], 0) AS Trimestre_2,
    ISNULL([3], 0) AS Trimestre_3,
    ISNULL([4], 0) AS Trimestre_4
	
FROM BaseDados 
-- Pivotagem: agrupa cada valor dentro do seu periodo
	PIVOT(
		SUM(TotalTrimestre)
		FOR Trimestre IN([1],[2],[3],[4])
	) AS PivoltTable
ORDER BY Categoria


