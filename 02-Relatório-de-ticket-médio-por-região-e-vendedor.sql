/*
DESAFIO: Relatório de Ticket Médio por Vendedor e Região
OBJETIVO: Calcular a média de vendas (Ticket Médio) cruzando fatos de pedidos 
          com dimensões de território e pessoa.

INSIGHT DE ARQUITETURA :
- ÂNCORA (FROM): [Sales].[SalesOrderHeader] -> O Coração do Evento Fato Gerador
- ENTIDADES (JOINs): [SalesPerson] e [SalesTerritory]  Granularidade Qualitativa
- MÉTRICA: [TotalDue] O Dado Quantitativo que será refinado Média
*/

-- 1. ENTIDADES (Consulta Secundária): Preparação dos dados de identificação
-- Mapeia quem é o vendedor, seu nome completo e onde ele atua.
WITH DadosVendas AS (
SELECT
	sp.BusinessEntityID,
	st.Name as Territorio,
	pp.FirstName,
	pp.LastName	
FROM Sales.SalesPerson AS sp 
JOIN Sales.SalesTerritory AS st
ON sp.TerritoryID = st.TerritoryID
JOIN Person.Person AS pp
ON pp.BusinessEntityID = sp.BusinessEntityID
)

-- 2. EVENTO (Consulta Principal): Processamento do fato gerador
-- Agrega os valores da SalesOrderHeader para extrair a métrica final.
SELECT
	soh.SalesPersonID,
	dv.FirstName + ' ' + dv.LastName AS NomeCompleto,
	dv.Territorio,
	-- Cálculo do fato: Média aritmética do valor total devido
	ROUND(AVG(TotalDue), 2) AS TiketMedio
FROM DadosVendas AS dv
-- JOIN com a CTE para enriquecer o evento com os nomes das entidades
JOIN Sales.SalesOrderHeader AS soh
ON soh.SalesPersonID = dv.BusinessEntityID
GROUP BY 
	soh.SalesPersonID,
	dv.Territorio,
	dv.FirstName + ' ' + dv.LastName 

