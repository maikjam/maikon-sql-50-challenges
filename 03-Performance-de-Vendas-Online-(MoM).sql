/*
EXERCICIO QUE ME PASSOU JA DIZENDO O QUE USAR 
Desafio 01: Performance de Vendas Online (MoM)


Foco: Agregação Simples e Funções de Janela.

Tabela: Sales.SalesOrderHeader
Filtro: OnlineOrderFlag = 1
Campos esperados: Ano, Mes, FaturamentoMensal, FaturamentoMesAnterior, Crescimento_MoM_Perc.
Nota Técnica: Lembre-se que no AdventureWorks 2022, o campo TotalDue inclui impostos e frete. 
Se quiser apenas o valor líquido das vendas, use SubTotal.

*/

--LOGICA QUE EU ESCRIVI COMO VEJO O QUE DEVE SER FEITO 

-- FILTRO DE ANO E MES COMPARADOS AO ANO ANTERIOR SOMANDO TOTAL DE VENDAS COM UM FILTRO SEPARANDO QUAIS FORAM VENDAS ONLINES 
-- E TRAZENDO AS TABELAS Ano, Mes, FaturamentoMensal, FaturamentoMesAnterior, Crescimento_MoM_Perc.

-- APAGA HISTORICO DE ESTRUTURAS PARA RODAR EM UMA AREA LIMPA
IF EXISTS (SELECT * FROM sys.indexes 
WHERE name = 'IX_TotalVendasOnline' AND object_id = OBJECT_ID('Sales.SalesOrderHeader'))
DROP INDEX IX_TotalVendasOnline ON Sales.SalesOrderHeader;
GO

-- CRIAÇÃO DE UM INDEX ORDENADO POR DATA PARA FACILITAR A BUSCA POR COMPRAS ONLINE 
CREATE INDEX IX_TotalVendasOnline 
ON Sales.SalesOrderHeader (OrderDate) 
INCLUDE (TotalDue)
WHERE OnlineOrderFlag = 1 ;


--FILTRO AGRUPADO TOTAL/VALOR/VENDAS/ONLINE 
WITH TotalVendasOnline AS (
SELECT
	YEAR(OrderDate) AS  Ano,
	MONTH(OrderDate) AS  Mes,
	ROUND(SUM(TotalDue),2) AS TotalVendas 

FROM Sales.SalesOrderHeader AS soh
WHERE OnlineOrderFlag = 1  -- FILTRA SE HOUVE VENDA ONLINE INSDA PRECISA 
GROUP BY 
	YEAR(OrderDate),
	MONTH(OrderDate) 
),
-- AGORA O LAG PRA FAZER COMPARAÇAO DOS ANOS RECORRENTES DESSE FILTRO 
VendasMesAno AS (
SELECT 
	tvo.Ano,
	tvo.Mes,
	tvo.TotalVendas,
	--LAG tabela perio de se for 0 nao retorne e ordene ano e mes
	LAG(tvo.TotalVendas, 1, 0) OVER ( ORDER BY Mes, Ano) VendasAnterior
FROM TotalVendasOnline AS tvo
)
-- 
SELECT 
	vma.Ano,
	vma.Mes,
	vma.TotalVendas,
	vma.VendasAnterior,
	ROUND(((vma.TotalVendas - vma.VendasAnterior ) / NULLIF(vma.VendasAnterior, 0) * 100), 2) AS Crescimento_MoM_Perc
FROM VendasMesAno AS vma
ORDER BY
	vma.Ano,
	vma.Mes