/*
Desafio 12: Ranking de Performance de Vendedores (Top N)
Foco: Classificação competitiva e metas.

Tabelas: Sales.SalesPerson (sp) e Person.Person (p).
Requisito: Rankear os 5 melhores vendedores por SalesYTD.
Lógica do KPI: Aplicar ranking olímpico (empates dividem posição, pula-se o próximo número).
Nota Técnica: Utilize RANK() combinado com CONCAT para o nome completo.
Objetivo: Gerar rankings para dashboards de incentivo e bônus por performance.
*/
-- traz todos os 5 inclui empates
SELECT TOP 5 WITH TIES
	pp.BusinessEntityID,
	-- Monta o nome completo para exibição
	CONCAT(pp.FirstName,' ',pp.MiddleName,' ',pp.LastName) AS NomeCompleto, 
	-- Total de vendas acumuladas do vendedor
	sp.SalesYTD AS TotalVendas,
	-- Ranking baseado no total de vendas (maior para menor)
	-- Utiliza RANK() para aplicar regra de empate (ranking olímpico)
	RANK() OVER(ORDER BY sp.SalesYTD DESC) AS Rank

-- Relaciona dados pessoais com dados de vendas
FROM Person.Person AS pp
JOIN Sales.SalesPerson AS sp
ON pp.BusinessEntityID = sp.BusinessEntityID
-- Ordena para definir TOP e ranking corretamente
ORDER BY sp.SalesYTD DESC