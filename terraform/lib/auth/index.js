// All AWS SDK Clients are available under the @aws-sdk namespace. You can install them locally to see functions and types
import {
  GetSecretValueCommand,
  ListSecretsCommand,
  SecretsManagerClient,
} from "@aws-sdk/client-secrets-manager";
import postgres from "postgres";

const handler = async (event, context, callback) => {
  console.log(`Starting ${context?.functionName} invocation`);
  console.debug("Payload recieved");
  console.debug(event);

  const payload = isValidPayload(event);

  // If bad request recieved
  if (!payload) throw new Error("bad request");

  const secret = await fetchDBSecret();

  if (!secret || secret == "")
    throw new Error("failed to fetch database creds");

  /** Database Credentials @type {{username: string, password: string} | undefined} */
  let creds;
  try {
    creds = JSON.parse(secret);
  } catch (error) {
    console.error(error);
    throw new Error("Failed to fetch db creds");
  }

  if (creds == undefined || !creds.password || !creds.username) {
    console.error("Mission failed, we'll get em next time");
    throw new Error("Invalid db creds");
  }
  console.log("Successfully fetched DB creds ✨");

  if (payload.method == "LOGIN") {
    const res = await handleLogin(payload.email, payload.password, creds);
    return JSON.stringify(res);
  } else {
    const res = await handleSignUp(payload, creds);
    return JSON.stringify(res);
  }
};

/**
 *
 * @param {*} event
 * @returns {{ method: "LOGIN" | "SIGNUP", email: string, password: string, fname: string, lname: string, } | undefined}
 */
const isValidPayload = (event) => {
  let payload;
  try {
    payload = JSON.parse(event?.body);
  } catch (error) {
    throw new Error("Invalid payload");
  }
  if (
    payload.method == "SIGNUP" &&
    payload.email &&
    payload.email.length > 0 &&
    payload.password &&
    payload.password.length > 0 &&
    payload.fname &&
    payload.fname.length > 0 &&
    payload.lname &&
    payload.lname.length > 0
  ) {
    return payload;
  } else if (
    payload.method == "LOGIN" &&
    payload.email &&
    payload.email.length > 0 &&
    payload.password &&
    payload.password.length > 0
  ) {
    return payload;
  } else return undefined;
};

/**
 *
 * @param email {string}
 * @param password {string}
 * @param {{username: string, password: string}} creds
 */
const handleLogin = async (email, password, creds) => {
  console.log("Handling login");

  // Build a client
  const sql = postgres({
    database: "storefront",
    user: creds.username,
    pass: creds.password,
    host: process.env.db_host,
    connection: {
      application_name: process.env.AWS_LAMBDA_FUNCTION_NAME,
    },
  });

  const res = await sql`SELECT * from public.member
  WHERE email = ${email} AND password = ${password}`
    .then((res) => {
      console.debug(res);
      if (res.length == 0) {
        return {
          statusCode: 404,
          statusDescription: "user not found",
        };
      } else {
        return {
          statusCode: 201,
          statusDescription: "user logged in",
          body: { id: res[0].id },
        };
      }
    })
    .catch((err) => {
      console.error("Ran into an issue signing you up");
      console.error(err);
      return {
        statusCode: 500,
        statusDescription: err.message,
      };
    });

  return res;
};

/**
 *
 * @param {{ method: "SIGNUP", email: string, password: string, fname: string, lname: string }} payload
 * @param {{username: string, password: string}} creds
 */
const handleSignUp = async ({ email, password, fname, lname }, creds) => {
  console.log("Handling sign up");

  // Build a client
  const sql = postgres({
    database: "storefront",
    user: creds.username,
    pass: creds.password,
    host: process.env.db_host,
    connection: {
      application_name: process.env.AWS_LAMBDA_FUNCTION_NAME,
    },
  });

  const res = await sql`INSERT into public.member
    (email, password, fname, lname) VALUES
    (${email}, ${password}, ${fname}, ${lname})
    
    returning *
    `
    .then((res) => {
      console.log("Successfully signed up");
      return {
        statusCode: 201,
        statusDescription: "user created",
        body: { id: res[0].id },
      };
    })
    .catch((err) => {
      console.error("Ran into an issue signing you up");
      console.error(err);
      return {
        statusCode: 500,
        statusDescription: err.message,
      };
    });

  return res;
};

const fetchDBSecret = async () => {
  const client = new SecretsManagerClient({ region: process.env.AWS_REGION });
  const listCommand = new ListSecretsCommand({
    region: process.env.AWS_REGION,
    // For some reason plain text filtering isn't working. Need to fix this if we're gonna have multiple secrets
    // Filters: [{ Key: "name", Values: "rds" }],
  });

  const res = await client
    .send(listCommand)
    .then((res) => res.SecretList)
    .catch((err) => {
      console.error(err);
      return new Error("Failed to fetch db secret");
    });
  if (typeof res == typeof Error || !res || res.length == 0) return undefined;

  const getSecretCommand = new GetSecretValueCommand({
    SecretId: res[0].Name,
  });
  const secret = await client
    .send(getSecretCommand)
    .then((res) => res.SecretString)
    .catch((err) => {
      console.error(err);
      return new Error("Failed to fetch db secret");
    });
  if (typeof res == typeof Error || !res || res.length == 0) return undefined;

  return secret;
};

export { handler };
