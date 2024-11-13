CREATE TABLE member (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

CREATE TABLE public.stock (
    sku SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    quantity SMALLINT NOT NULL DEFAULT 0,
    price INTEGER NOT NULL DEFAULT 0,
    item_url TEXT NOT NULL
);

CREATE TABLE public.order (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    user_id UUID NOT NULL REFERENCES member (id),
    sku SERIAL NOT NULL,
    quantity SMALLINT NOT NULL DEFAULT 0
);

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
-- Seed DB
INSERT into public.stock (name, price, quantity, item_url) VALUES ('Bando Stone and The New World', 45, 3, 'https://t2.genius.com/unsafe/728x0/https%3A%2F%2Fimages.genius.com%2Ff19320aae82a75396d97def01ae89ff3.1000x1000x1.png');
INSERT into public.stock (name, price, quantity, item_url) VALUES ('alligator bites never heal - Doechii', 30, 2, 'https://shop.capitolmusic.com/cdn/shop/files/DoechiiABNHLPInsert.png?v=1724951711&width=800');
INSERT into public.stock (name, price, quantity, item_url) VALUES ('Nova - James Fauntleroy, Terrace Martin', 31, 4, 'https://images.squarespace-cdn.com/content/v1/5699291fa976afc919dbca7d/a701db3b-83c1-457b-a892-0c46b0e6749c/Nova+Artwork.jpg?format=500w');