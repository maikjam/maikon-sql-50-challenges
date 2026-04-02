/*
Desafio 04: Detecção de Anomalias - Alta Densidade de Pedidos (Perfil B2B)
Foco: Identificar comportamentos atípicos de compra no mesmo dia.

Tabelas: Sales.SalesOrderHeader (soh).
Regra de Negócio: Encontrar clientes que realizaram mais de 3 pedidos em um único dia (Data da Ordem).
Lógica do KPI: Calcular a densidade de pedidos por cliente/dia. Criar coluna Alerta_Fraude: Se Qtd > 3,
marcar como 'ANOMALIA/REVISAR', caso contrário, 'NORMAL'.
Nota Técnica: Utilize COUNT(*) OVER(PARTITION BY CustomerID, OrderDate).
Objetivo: Simular um sistema de detecção de erros de integração ou fraude em missão crítica.
*/


-- Sales.SalesOrderHeader (soh)
	-- OrderDate, CustomerID, SalesOrderID

-- Calcula total pedidos por dia 
WITH ContagemPedido AS (
SELECT
	CustomerID,
	OrderDate,
	COUNT(*) OVER(PARTITION BY CustomerID, CAST(OrderDate AS DATE)) AS TotalDia
FROM Sales.SalesOrderHeader
) 

SELECT
	cp.CustomerID,
	cp.OrderDate,
	cp.TotalDia,
	-- Lógica do KPI solicitada no desafio
    CASE 
        WHEN TotalDia >= 2 THEN 'ANOMALIA/REVISAR'
        ELSE 'NORMAL'
    END AS Alerta_Fraude
-- Opcional: Filtrar para ver apenas as anomalias no topo
FROM ContagemPedido AS cp
ORDER BY TotalDia DESC, CustomerID;



-- Calcula total pedidos por mes 
WITH ContagemPedido AS (
SELECT
	CustomerID,
	OrderDate,
	COUNT(*) OVER(PARTITION BY CustomerID, MONTH(OrderDate)) AS TotalMes
FROM Sales.SalesOrderHeader
) 

SELECT
	cp.CustomerID,
	cp.OrderDate,
	cp.TotalMes
FROM ContagemPedido AS cp

--Calcula total pedidos por ano 
WITH ContagemPedido AS (
SELECT
	CustomerID,
	OrderDate,
	COUNT(*) OVER(PARTITION BY CustomerID, MONTH(OrderDate)) AS TotalAno
FROM Sales.SalesOrderHeader
) 

SELECT
	cp.CustomerID,
	cp.OrderDate,
	cp.TotalAno
FROM ContagemPedido AS cp


