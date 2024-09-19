// All AWS SDK Clients are available under the @aws-sdk namespace. You can install them locally to see functions and types
import {
  GetSecretValueCommand,
  ListSecretsCommand,
  SecretsManagerClient,
} from "@aws-sdk/client-secrets-manager";
import { Handler } from "aws-lambda";
import postgres from "postgres";

/** @type {Handler} */
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
    return handleLogin(payload.email, payload.password, creds);
  } else if (payload.method == "SIGNUP") {
    return await handleSignUp(payload, creds);
  }
};

/**
 *
 * @param {*} event
 * @returns {{ method: "LOGIN" | "SIGNUP", email: string, password: string, fname: string, lname: string, } | undefined}
 */
const isValidPayload = (event) => {
  if (
    event?.method == "SIGNUP" &&
    event?.email &&
    event?.email.length > 0 &&
    event?.password &&
    event?.password.length > 0 &&
    event?.fname &&
    event?.fname.length > 0 &&
    event?.lname &&
    event?.lname.length > 0
  ) {
    return event;
  } else if (
    event?.method == "LOGIN" &&
    event?.email &&
    event?.email.length > 0 &&
    event?.password &&
    event?.password.length > 0
  ) {
    return event;
  } else return undefined;
};

/**
 *
 * @param email {string}
 * @param password {string}
 * @param {{username: string, password: string}} creds
 */
const handleLogin = (email, password, creds) => {
  console.log("Handling login");

  return {
    statusCode: 201,
    statusDescription: "user created",
    headers: {
      "cloudfront-functions": { value: "generated-by-CloudFront-Functions" },
      location: { value: "https://aws.amazon.com/cloudfront/" },
    },
  };
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

  const res = await sql`INSERT into member
    (email, password, fname, lname) VALUES
    (${email}, ${password}, ${fname}, ${lname})
    
    returning *
    `
    .then((res) => {
      return {
        statusCode: 201,
        id: res[0].id,
        statusDescription: "user created",
      };
    })
    .catch((err) => {
      console.error("Ran into an issue signing you up");
      console.error(err);
      return {
        statusCode: 500,
        error: err.message,
      };
    });

  if (res.error) throw new Error(res.error);
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
