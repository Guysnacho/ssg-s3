-- ALWAYS KEEP THESE SEPARATE IN REAL LIFE
-- CREATE TABLE member (id UUID PRIMARY KEY DEFAULT gen_random_uuid ())
-- CREATE TABLE auth (
--     id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
--     email TEXT NOT NULL,
--     password TEXT NOT NULL,
--     fname TEXT NOT NULL,
--     lname TEXT NOT NULL,
-- )

CREATE TABLE member (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    email TEXT NOT NULL,
    password TEXT NOT NULL,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

SELECT * from public.member;

-- Test your queries here before writing up production queries in the lambda
INSERT into
    member (email, password, fname, lname)
VALUES (
        'email',
        'password',
        'fname',
        'lname'
    );