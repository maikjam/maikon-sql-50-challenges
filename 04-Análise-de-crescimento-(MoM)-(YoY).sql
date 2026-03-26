/*
3.  Análise de crescimento mensal (MoM) e anual (YoY).Padrão standard


[Sales].[SalesPerson] representa o total de vendas por vendedor 
	[SalesYTD] ano atual 
	[SalesLastYear] ultimo ano 

SalesOrderHeader
	[OrderDate]
*/
-- janela1 totalvendas/mensal  totalvendas/anoatual
-- janela2 faz o mesmo porem uso o lag nao mudo a logica so uso e select diferenete 
-- mes atual uso na construcao o lag na entrega 
-- resoluçao uma cte com janela1 e cte janela2 select principal calculo do acrecimo por mes e ano 
-- simples nao tem id so valores e o  acrscimo 


-- cte entrega os dados pedidos para comparaçao 
WITH TotalAtual AS (
SELECT 
	YEAR(soh.OrderDate) AS Ano,
	MONTH(soh.OrderDate) AS Mes,
	ROUND(SUM(soh.TotalDue),2) AS TotalVendas  
FROM Sales.SalesOrderHeader AS SOH
GROUP BY 
	YEAR(soh.OrderDate),
	MONTH(soh.OrderDate)
)
--motor para fazer a comparação MOM YOY estrutura padrao 
SELECT 
    ta.Mes,
    ta.ano,
    LAG(TotalVendas) OVER (ORDER BY Mes) AS VendasMesAnterior,
    (TotalVendas - LAG(TotalVendas) OVER (ORDER BY Mes)) / LAG(TotalVendas) OVER (ORDER BY Mes) * 100 AS PercentualMoM
FROM TotalAtual as ta;
	