/*
Desafio 05: Sazonalidade por Categoria (YoY)
Foco: Joins Complexos e Particionamento de Dados.

Tabelas: * Sales.SalesOrderHeader (soh)
Sales.SalesOrderDetail (sod)
Production.Product (p)
Production.ProductSubcategory (ps)
Production.ProductCategory (pc)
Regra: O faturamento deve vir da SalesOrderDetail (LineTotal) para garantir a precisão por produto.
Requisito: O cálculo de YoY deve usar LAG(Faturamento, 12) e obrigatoriamente um PARTITION BY pc.
Name para que o crescimento de "Bikes" não se misture com "Clothing".

-- sempre usar regra pra sazonalidade
-- periodo > ja trazer o periodo com filtro do valor total 
-- entidade > separar o produto,categoria,subcategoria 
-- evento > fitro junto com periodo

-- agora e so subidividir o codigo seguindo cada cte ate o evento que sera o codigo principal 

-- CATEGROIA NAME, PRODUCTCATEGORYID 
-- SUBCATEGORIA NAME ,PRODUCTSUBCATEGORY,PRODUCTCATEGORY
-- PRODUCTID PRODUCTID, NAME
--SALESORDERDETAIL SALESORDERID, LINETOTAL, PRODUCTID


  DESAFIO 05: Sazonalidade por Categoria (YoY)
  ESTRATÉGIA: Arquitetura de dados em duas camadas (Warehouse + Analytics).
  OBJETIVO: Identificar padrões de crescimento mensal por produto e categoria.
*/

-- Isola e prepara os dados brutos, garantindo a granularidade correta.
WITH VendasCategoria AS (
SELECT 
	sod.ProductID,
	SUM(sod.lineTotal) AS TotalMes, --soma cada produto vendido 
	pp.Name AS Nome_Produto,
	psc.Name AS SubCategoria,
	pc.Name AS Categoria,
	FORMAT(soh.OrderDate, 'yyyy-MM') AS MesReferencia -- compacta ordens de vendas por peridodo de mes 

-- Join Path baseado na Tabela Fato para garantir a linhagem correta dos dados.
FROM Sales.SalesOrderDetail AS sod

JOIN Production.Product AS pp
ON sod.ProductID = pp.ProductID

JOIN Production.ProductSubcategory AS psc
ON pp.ProductSubcategoryID = psc.ProductSubcategoryID

JOIN Production.ProductCategory AS pc
ON psc.ProductCategoryID = pc.ProductCategoryID

JOIN Sales.SalesOrderHeader AS soh
ON sod.SalesOrderID = soh.SalesOrderID

-- Agrupa vendas por produto mês para análise de transações individuais
GROUP BY  
	sod.ProductID,
	pp.Name,
	psc.Name,
	pc.Name,
	FORMAT(soh.OrderDate, 'yyyy-MM')
)
-- filtro sobre o dado processado para extrair porcentagens de crescimento.
SELECT 
	vc.ProductID,
	vc.MesReferencia,
	vc.Nome_Produto,
	vc.Categoria,
	VC.Subcategoria,
	-- Window Function (LAG): Recupera o faturamento do período anterior para cálculo de variação.
    -- O PARTITION BY garante que a comparação ocorra estritamente dentro do histórico de cada produto.
	ROUND((vc.TotalMes / LAG(vc.totalMes, 1) OVER(PARTITION BY vc.ProductID ORDER BY vc.MesReferencia) 
	-1) * 100 ,2)AS Pct_Prev_Cresc
FROM VendasCategoria AS vc

