export const AUTH_KEY = "storefront-uid";

type SignUpRequest = {
  method: "SIGNUP";
  email: string;
  password: string;
  fname: string;
  lname: string;
};

type LogInRequest = {
  method: "LOGIN";
  email: string;
  password: string;
};

export type AuthResponse = {
  statusCode: number;
  statusDescription: string;
  body?: { id: string };
};

export const handleLogIn = async (email: string, password: string) => {
  alert("Logging in");

  if (!email || email == "" || !password || password == "") {
    alert("Invalid login");
    return {
      statusCode: 403,
      statusDescription: "Invalid login",
    };
  }

  const req: LogInRequest = {
    method: "LOGIN",
    email: email,
    password: password,
  };
  return await fetch(`${process.env.NEXT_PUBLIC_APIGW}/auth`, {
    method: "POST",
    body: JSON.stringify(req),
  })
    .then(async (res) => {
      const body = await res.json();
      console.debug(body);
      return body as AuthResponse;
    })
    .catch((err) => {
      console.error(err);
      return {
        statusCode: 500,
        statusDescription: "Failed to log you in. Please try again later.",
      } satisfies AuthResponse;
    });
};

export const handleSignUp = async (
  email: string,
  password: string,
  fname: string,
  lname: string
) => {
  alert("Signing up");

  if (!email || email == "" || !password || password == "") {
    alert("Invalid signup request");
    return {
      statusCode: 403,
      statusDescription: "Invalid signup request",
    };
  }

  const req: SignUpRequest = {
    method: "SIGNUP",
    email,
    password,
    fname,
    lname,
  };
  return await fetch(`${process.env.NEXT_PUBLIC_APIGW}/auth`, {
    method: "POST",
    body: JSON.stringify(req),
  })
    .then(async (res) => {
      const body = await res.json();
      console.debug(body);
      return body as AuthResponse;
    })
    .catch((err) => {
      console.error(err);
      return {
        statusCode: 500,
        statusDescription: "Failed to sign you up. Please try again later.",
      } satisfies AuthResponse;
    });
};
