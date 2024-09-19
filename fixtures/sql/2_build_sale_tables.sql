CREATE TABLE public.stock (
    sku SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    quantity SMALLINT NOT NULL DEFAULT 0,
    price INTEGER NOT NULL DEFAULT 0,
    item_url TEXT NOT NULL
);

-- Seed DB
INSERT into public.stock (name, price, quantity, item_url) VALUES ('Bando Stone and The New World', 45, 3, 'https://t2.genius.com/unsafe/728x0/https%3A%2F%2Fimages.genius.com%2Ff19320aae82a75396d97def01ae89ff3.1000x1000x1.png');
INSERT into public.stock (name, price, quantity, item_url) VALUES ('alligator bites never heal - Doechii', 30, 2, 'https://shop.capitolmusic.com/cdn/shop/files/DoechiiABNHLPInsert.png?v=1724951711&width=800');
INSERT into public.stock (name, price, quantity, item_url) VALUES ('Nova - James Fauntleroy, Terrace Martin', 31, 4, 'https://images.squarespace-cdn.com/content/v1/5699291fa976afc919dbca7d/a701db3b-83c1-457b-a892-0c46b0e6749c/Nova+Artwork.jpg?format=500w');

CREATE TABLE public.order (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    user_id UUID NOT NULL REFERENCES member (id),
    sku SERIAL NOT NULL,
    quantity SMALLINT NOT NULL DEFAULT 0
);

SELECT * from public.stock;
SELECT * from public.order;

CREATE or REPLACE function public.handle_sale ()
returns trigger as
$$
  declare results RECORD;
  begin
    SELECT sku, quantity INTO results FROM public.stock WHERE sku = new.sku;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'item not found';
    ELSEIF results.quantity - new.quantity < 1 THEN
        RAISE EXCEPTION 'not enough in stock';
    END IF;
    UPDATE public.stock SET quantity = quantity - new.quantity WHERE sku = new.sku;
    return new;
  END;
$$ language plpgsql;

-- trigger the function every time a user is created
create trigger on_sale_init
  after insert on public.order
  for each row execute procedure public.handle_sale();

-- ========================= ========================= ========================= =========================
-- Test your queries here before writing up production queries in the lambda
-- Invalid row, FK not present
INSERT into public.order (sku, quantity) VALUES (2, 1000);

-- ========================= ========================= ========================= =========================
-- Add stock user
-- INSERT into
--     member (email, password, fname, lname)
-- VALUES (
--         'email',
--         'password',
--         'fname',
--         'lname'
--     );
-- SELECT * from member;
-- -- Init an invalid sale
-- INSERT into public.order (user_id, sku, quantity) VALUES ('your_user_id_here', 2, 1000);
-- -- Init a valid sale
-- INSERT into public.order (user_id, sku, quantity) VALUES ('9b3b9b36-8fe5-4bbd-b655-c212704e4c79', 2, 1);

-- delete FROM public.order;
-- delete FROM public.stock;
-- delete FROM public.member;

-- -- Seed after manually running tests
-- INSERT into public.stock (name, price, quantity, item_url) VALUES ('Bando Stone and The New World', 45, 3, 'https://t2.genius.com/unsafe/728x0/https%3A%2F%2Fimages.genius.com%2Ff19320aae82a75396d97def01ae89ff3.1000x1000x1.png');
-- INSERT into public.stock (name, price, quantity, item_url) VALUES ('alligator bites never heal - Doechii', 30, 2, 'https://shop.capitolmusic.com/cdn/shop/files/DoechiiABNHLPInsert.png?v=1724951711&width=800');
-- INSERT into public.stock (name, price, quantity, item_url) VALUES ('Nova - James Fauntleroy, Terrace Martin', 31, 4, 'https://images.squarespace-cdn.com/content/v1/5699291fa976afc919dbca7d/a701db3b-83c1-457b-a892-0c46b0e6749c/Nova+Artwork.jpg?format=500w');