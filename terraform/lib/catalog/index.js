// All AWS SDK Clients are available under the @aws-sdk namespace. You can install them locally to see functions and types
import {
  GetSecretValueCommand,
  ListSecretsCommand,
  SecretsManagerClient,
} from "@aws-sdk/client-secrets-manager";
import postgres from "postgres";
// import { Handler } from "aws-lambda";

/** @type {Handler} */
const handler = async (event, context, callback) => {
  console.log(`Starting ${context?.functionName} invocation`);
  console.debug("Payload recieved");
  console.debug(event);

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

  const res = await fetchCatalog(creds);
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

/**
 * Fetch the full catalog of the store
 * @param {{username: string, password: string}} creds
 */
const fetchCatalog = async (creds) => {
  console.log("Fetching");

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

  // Perform our insert and select the price
  const res = await sql`SELECT * from public.stock`
    .then((res) => {
      return res;
    })
    .catch((err) => {
      console.error("Ran into an issue during the sale");
      console.error(err);
      return {
        statusCode: 500,
        error: err.message,
      };
    });

  return res;
};

export { handler };
