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

export const handleLogIn = async (email: string, password: string) => {
  alert("Logging in");

  if (!email || email == "" || !password || password == "") {
    alert("Invalid login");
    return;
  }

  const req: LogInRequest = {
    method: "LOGIN",
    email: email,
    password: password,
  };
  fetch(`${process.env.NEXT_PUBLIC_APIGW}/auth`, {
    method: "POST",
    body: JSON.stringify(req),
  })
    .then(async (res) => {
      const body = await res.json();
      console.debug(body);
      return body;
    })
    .catch((err) => {
      console.error(err);
      alert("Failed to log you in. Please try again later.");
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
    throw new Error("Mission failed");
  }

  const req: SignUpRequest = {
    method: "SIGNUP",
    email,
    password,
    fname,
    lname,
  };
  fetch(`${process.env.NEXT_PUBLIC_APIGW}/auth`, {
    method: "POST",
    body: JSON.stringify(req),
  })
    .then(async (res) => {
      const body = await res.json();
      console.debug(body);
      return body;
    })
    .catch((err) => {
      console.error(err);
      alert("Failed to sign you up. Please try again later.");
    });
};
