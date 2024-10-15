-- name: InsertProduct :one
INSERT INTO
    products (
        name,
        description,
        price,
        image_url
    )
VALUES ($1, $2, $3, $4) RETURNING id;

-- name: GetProduct :one
SELECT * FROM products WHERE id = $1;

-- name: GetProducts :many
WITH product_count AS (
    SELECT COUNT(*) AS total FROM products
)
SELECT p.id, p.name, p.description, p.price, p.image_url, p.created_at, p.updated_at,
       pc.total,
       CEIL(pc.total::float / $1::int) AS total_pages,
       CASE
           WHEN (pc.total - $2) < $1 THEN (pc.total - $2)
           ELSE $1
       END AS adjusted_limit
FROM products p, product_count pc
ORDER BY p.created_at DESC
LIMIT $1
OFFSET $2;
