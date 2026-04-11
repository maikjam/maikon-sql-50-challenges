
/*
Desafio 07: Churn Analysis - Tempo de Re-compra
Foco: Retenção de clientes e ciclo de vida.
Tabelas: Sales.SalesOrderHeader (soh).
Requisito: Calcular a diferença de dias entre a última compra e a compra atual de cada cliente.
Lógica do KPI: Criar coluna Status_Fidelidade: Se Dias_Desde_Ultima_Compra > 90, 
marcar como 'RISCO DE CHURN', caso contrário, 'ATIVO'.
Nota Técnica: Utilize LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) e DATEDIFF.
Objetivo: Municiar times de CRM para ações de recuperação de clientes inativos.
*/

-- CTE 1: Mapeia o intervalo de dias entre cada compra consecutiva do cliente
WITH TotalDias AS (
SELECT 
	CustomerID,
	OrderDate AS DataAtual,
	-- Busca a data da compra imediatamente anterior para comparação
	LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS DataAnterior,
	-- Calcula a diferença em dias entre a compra atual e a anterior
	DATEDIFF(DAY,
			LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate), 
			OrderDate) AS DiasEntreCompras -- calculo de dias entre compras
FROM Sales.SalesOrderHeader 
),
-- CTE 2: Classifica o cliente com base no maior "gap" (intervalo) de compra encontrado
FiltroEstatus AS (
SELECT 
	td.CustomerID,
	-- Filtro se o cliente ficou > 90 dias sem comprar em algum momento, é Risco de Churn
	CASE WHEN MAX(td.DiasEntreCompras) > 90 THEN 'RISCO DE CHURN'
	ELSE 'ATIVO'
	END AS StatusCliente
FROM TotalDias AS td
GROUP BY td.CustomerID
)
-- Consulta Final: Consolida os dados de saúde com a identificação nominal (CRM)
SELECT 
	fe.CustomerID AS ID,
	pp.FirstName+' '+LastName AS Nome,
	fe.StatusCliente
FROM FiltroEstatus AS fe
JOIN Person.Person AS pp 
ON fe.CustomerID = pp.BusinessEntityID


	

		



	