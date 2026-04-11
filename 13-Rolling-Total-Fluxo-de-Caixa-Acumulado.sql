
/*
Desafio 11: Rolling Total - Fluxo de Caixa Acumulado
Foco: Funções de Janela com enquadramento (Frame).

Tabelas: Sales.SalesOrderHeader (soh).
Cálculo: Soma acumulada do faturamento dia após dia (Running Total).
Lógica do KPI: Exibir o saldo acumulado histórico ao lado do faturamento diário.
Nota Técnica: SUM(TotalDue) OVER(ORDER BY OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW).
Objetivo: Simular o comportamento de um extrato bancário de fluxo de caixa.
*/

SELECT
	sub.DataDia,
	sub.TotalDia,
	--Soma acumulada do faturamento dia após dia (Running Total)
	SUM(sub.TotalDia) OVER(ORDER BY sub.DataDia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM (
	-- SubQuery Traz data e o total vedas por dia dentro de todo periodo
	SELECT
		CAST(OrderDate AS DATE) AS DataDia,
		SUM(TotalDue) AS TotalDia
	FROM Sales.SalesOrderHeader
	-- Agrupa por dia 
	GROUP BY CAST(OrderDate AS DATE)
) AS sub
ORDER BY sub.DataDia