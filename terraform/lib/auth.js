// import { Handler } from "aws-lambda";
// All AWS SDK Clients are available under the @aws-sdk namespace. You can install them locally to see functions and types
import { PostgrestClient } from "@supabase/postgrest-js";

const {
  SecretsManagerClient,
  ListSecretsCommand,
  GetSecretValueCommand,
} = require("@aws-sdk/client-secrets-manager");
const PackageJson = require("@aws-sdk/client-rds/package.json");
// const Handler = require("aws-lambda/handler");

/** @type {Handler} */
exports.handler = async (event, context, callback) => {
  console.log(`Starting ${context?.functionName} invocation`);
  console.debug("Payload recieved");
  console.debug(event);

  const payload = isValidPayload(event);

  // If bad request recieved
  if (!payload) {
    return {
      statusCode: 400,
      statusDescription: "bad request",
    };
  }

  const secret = await fetchDBSecret();

  if (!secret || !secret?.SecretString) {
    return {
      statusCode: 500,
      statusDescription: "failed to fetch database creds",
    };
  }

  /** Database Credentials @type {{username: string, password: string} | undefined} */
  let creds;
  try {
    creds = JSON.parse(secret.SecretString);
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      statusDescription: "Failed to fetch db creds",
    };
  }

  if (creds == undefined || !creds.password || !creds.username) {
    console.error("Mission failed, we'll get em next time");
    return {
      statusCode: 500,
      statusDescription: "Invalid db creds",
    };
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
      "client-version": PackageJson.version,
      location: { value: "https://aws.amazon.com/cloudfront/" },
    },
  };
};

/**
 *
 * @param {{ method: "SIGNUP", email: string, password: string, fname: string, lname: string }} payload
 * @param {{username: string, password: string}} creds
 */
const handleSignUp = async (payload, creds) => {
  console.log("Handling sign up");

  const db = new PostgrestClient(
    `postgresql://${creds.username}:${creds.password}@${process.env.db_host}:5432/postgres`
  );
  const { data, error, statusText } = await db
    .from("member")
    .insert({
      email: payload.email,
      password: payload.password,
      fname: payload.fname,
      lname: payload.lname,
    })
    .select()
    .single();

  if (error) {
    console.error("Ran into an issue signing you up");
    return {
      statusCode: 500,
      statusDescription: error.message,
    };
  }

  return {
    statusCode: 201,
    id: data.id,
    statusDescription: "user created",
  };
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
