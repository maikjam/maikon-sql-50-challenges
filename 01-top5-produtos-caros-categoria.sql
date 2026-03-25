/* DESAFIO 01: Top 5 Produtos mais caros por categoria.
OBJETIVO: Identificar os itens de maior valor agregado dentro de cada nicho da AdventureWorks.

INSIGHT DE ARQUITETURA:
- Entidade (Produto): Definida como âncora no FROM pela sua granularidade qualitativa.
- Evento (Venda/Preço): Tabelas secundárias que trazem os dados quantitativos.
- A "âncora" do FROM deve mudar conforme o coração do problema de negócio.
*/

-- 1. CTE: Resolve o relacionamento entre Subcategoria e Categoria (Normalização)
WITH NomeCategoria AS (
SELECT
	psc.ProductSubCategoryID,
	pc.ProductCategoryID,
	pc.Name
FROM  Production.ProductSubCategory  AS psc
JOIN Production.ProductCategory  AS pc
ON psc.ProductCategoryID = pc.ProductCategoryID
),

--- 2. CTE: Aplica a Window Function para ranquear os preços por Categoria
MaiorPreco AS (
SELECT
	nc.Name,
	pp.ProductID,
	pp.ListPrice,
	-- ROW_NUMBER() garante exatamente 5 linhas por categoria, ignorando empates
	ROW_NUMBER () OVER(PARTITION BY nc.Name ORDER BY  pp.ListPrice desc) AS RankPreco
FROM Production.Product AS pp
JOIN NomeCategoria AS nc
ON pp.ProductSubCategoryID = nc.ProductSubCategoryID
)

-- 3. Consulta Principal: Filtro final de negócio
SELECT 
	mp.ProductID,
	mp.Name AS Categoria,
	mp.listPrice AS MaiorPreco
fROM MaiorPreco AS mp
WHERE RankPreco <= 5
