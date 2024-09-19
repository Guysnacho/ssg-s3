-- Active: 1726216791298@@storefront-db.ct84ooq2shac.us-west-2.rds.amazonaws.com@5432@storefront
CREATE TABLE public.stock (
    sku SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    quantity SMALLINT NOT NULL DEFAULT 0,
    price INTEGER NOT NULL DEFAULT 0
);

DROP TABLE PUBLIC."order";

CREATE TABLE public.order (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    user_id UUID NOT NULL REFERENCES member (id),
    sku SERIAL NOT NULL,
    quantity SMALLINT NOT NULL DEFAULT 0
);

SELECT * from public.stock;

SELECT * from public.order;

-- Test your queries here before writing up production queries in the lambda
-- Invalid row, FK not present
INSERT into public.order (sku, quantity) VALUES (2, 1000);
SELECT * from public.order;
delete FROM public.order;