/*
Desafio 08: Auditoria de Margem - Validade Temporal
Foco: Junção de tabelas com filtros de vigência histórica.

Tabelas: Sales.SalesOrderDetail (sod) e Production.ProductCostHistory (pch).
Lógica do KPI: Buscar o custo vigente na data exata da venda. Criar coluna Margem_Alerta: 
Se Margem < 10%, marcar como 'MARGEM CRÍTICA', caso contrário, 'MARGEM OK'.
Nota Técnica: Join usando OrderDate BETWEEN pch.StartDate AND ISNULL(pch.EndDate, GETDATE()).
Objetivo: Simular ambientes de auditoria financeira e controle de lucro real.
*/

-- 1 - Base dados separas as colunas usadas 
WITH CustoData AS (
	SELECT 
		sod.ProductID,
		sod.UnitPrice * sod.OrderQty AS VendaTotal,
		pch.StandardCost * sod.OrderQty AS CustoTotal,
		soh.OrderDate AS DataAtual,
		pp.Name AS NomeProduto

	FROM Sales.SalesOrderDetail as sod
	JOIN Production.ProductCostHistory AS pch ON sod.ProductID = pch.ProductID
	JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
	JOIN Production.Product AS pp ON sod.ProductID = pp.ProductID

	WHERE soh.OrderDate BETWEEN pch.StartDate AND ISNULL(pch.EndDate, GETDATE())
),

-- 2 Calculo porcentagem de custo
CalculoPorcentagem AS (
	SELECT
		*,
		-- Calculo de margel em pct reduzindo ruido divisão por 0
		(cd.VendaTotal - cd.CustoTotal) / NULLIF(cd.VendaTotal,0) * 100.0  AS MargenPct
	FROM CustoData AS cd
)
-- 3 consulta principal visualização das informações
SELECT
	ProductID AS ID_Produto,
	NomeProduto,
	VendaTotal,
	CustoTotal,
	DataAtual,
	MargenPct,

	-- Trata as execeções pedidas
	CASE 
		WHEN MargenPct < 10  THEN 'MARGEM CRÍTICA'
		ELSE 'MARGEM OK' 
	END AS Status
FROM CalculoPorcentagem

