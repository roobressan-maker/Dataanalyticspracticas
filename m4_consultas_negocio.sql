-- Motor utilizado: SQL Server (SSMS)

-- Pre-entrega 4: Extrayendo métricas clave con SQL

-- Base de datos: Ventas_Tech_DB (tabla ventas)

USE Ventas_Tech_DB;

-- === CONSULTA 1: RESUMEN EJECUTIVO MENSUAL ===
-- Total facturado, cantidad de pedidos y ticket promedio por mes

SELECT
   MONTH (fecha_venta)                      AS mes,
   SUM(cantidad * precio_unitario)         AS total_facturado,
   COUNT(*)                                AS cantidad_pedidos,
   AVG(cantidad * precio_unitario)         AS ticket_promedio

FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- Esperado: 1 fila (mes 3 | 6444.00 | 10 | 644.40)

-- === CONSULTA 2: RANKING DE PRODUCTOS ===

-- Top 5 de id_producto por total facturado, con unidades vendidas
SELECT TOP 5
    id_producto,
    SUM(cantidad)                           AS unidades_vendidas,
    SUM(cantidad * precio_unitario)         AS total_facturado
    FROM ventas
    GROUP BY id_producto 
    ORDER BY total_facturado DESC;

-- === CONSULTA 3: CLIENTES RECURRENTES ===
-- id_cliente con más de un pedido, con cantidad de pedidos y total gastado

SELECT
   id_cliente,
   COUNT(*)                                AS cantidad_pedidos,
   SUM(cantidad * precio_unitario)         AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- === CONSULTA 4: PRODUCTOS POR ENCIMA / POR DEBAJO DEL PROMEDIO ===
-- Se calcula el promedio de los totales por producto (no de las filas de ventas)
WITH total_por_producto AS (
   SELECT
       id_producto,
       SUM(cantidad * precio_unitario)     AS total_facturado
   FROM ventas
   GROUP BY id_producto
)

SELECT
   id_producto,
   total_facturado,
   CASE
       WHEN total_facturado > (SELECT AVG(total_facturado) FROM total_por_producto)
           THEN 'Por encima'
       ELSE 'Por debajo'
   END                                     AS posicion_vs_promedio
FROM total_por_producto
ORDER BY total_facturado DESC;

 -- === HALLAZGOS ===
 -- 1. El producto 1 concentra el 55,9% de la facturación (3.600 de 6.444) con solo
 --    3 unidades vendidas; junto con el producto 3 suman el 76,8% del total.
 -- 2. El producto 2 es el más vendido en unidades (13) pero genera solo el 5,6% de
 --    la facturación (364), porque su precio unitario es el más bajo (28).
 -- 3. Los 5 clientes hicieron exactamente 2 pedidos cada uno, pero el gasto está muy
 --    desparejo: los clientes 1 y 5 explican el 73,6% de lo facturado (4.740),
 --    mientras que el cliente 4 gastó 510.
