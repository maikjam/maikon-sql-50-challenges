/*
Desafio 13: Monitoramento de Inventário - Alerta de Ruptura
Foco: Agrupamento e Inteligência de Suprimentos.

Tabelas: Production.ProductInventory (pi) e Production.Product (p).
Lógica do KPI: Se Quantity_Total < SafetyStockLevel, marcar como 'REPOR IMEDIATAMENTE',
caso contrário, 'ESTOQUE OK'.
Campos: ProductID, ProductName, Quantity_Total, SafetyStockLevel, Status_Estoque.
Nota Técnica: Use SUM(Quantity) com GROUP BY e CASE WHEN.
Objetivo: Criar gatilhos de automação para ordens de compra e prevenção de falta de produto.

1. A Abordagem Vencedora: LEFT JOIN + GROUP BY
Esta é a recomendada para performance e escalabilidade. Ela trata os dados como conjuntos (blocos).
*/
-- usando LEFT JOIN
SELECT 
    p.ProductID,
    p.Name AS NomeProduto,
    -- COALESCE garante que produtos sem estoque apareçam como 0 em vez de NULL
    COALESCE(SUM(pi.Quantity), 0) AS QuantityTotal,
    p.SafetyStockLevel AS EstoqueReserva,
    -- A lógica de negócio fica centralizada no SELECT final
    CASE 
        WHEN COALESCE(SUM(pi.Quantity), 0) < p.SafetyStockLevel 
            THEN 'REPOR IMEDIATAMENTE'
        ELSE 'ESTOQUE OK'
    END AS StatusEstoque
FROM Production.Product p
-- LEFT JOIN garante que nenhum produto da tabela 'Product' seja excluído, 
-- mesmo que não tenha saldo no inventário.
LEFT JOIN Production.ProductInventory pi
    ON p.ProductID = pi.ProductID
GROUP BY 
    p.ProductID, 
    p.Name, 
    p.SafetyStockLevel;

/*
2. A Abordagem com CTE e Subquery Correlacionada
Esta é funcional e organizada, mas pode ser mais lenta porque a subquery no SELECT pode ser executada linha a linha.
*/

-- SUBQUERY
WITH TotalProduto AS (
    SELECT
        pp.ProductID,
        pp.Name AS NomeProduto,
        -- Subquery Correlacionada: Para cada produto (pp), o SQL dispara uma busca na pbi
        COALESCE((
            SELECT SUM(Quantity) 
            FROM Production.ProductInventory AS pbi
            WHERE pp.ProductID = pbi.ProductID -- O "elo" que pode tornar a query lenta
            ), 0) AS QuantityTotal,
        SafetyStockLevel AS EstoqueReserva
    FROM Production.Product AS pp 
)

SELECT 
    ProductID,
    NomeProduto,
    QuantityTotal,
    EstoqueReserva,
    -- O CASE aqui fica mais limpo pois utiliza o alias da CTE
    CASE 
        WHEN QuantityTotal < EstoqueReserva THEN 'REPOR IMEDIATAMENTE'
        ELSE 'Estoque Ok'
    END AS StatusEstoque
FROM TotalProduto;