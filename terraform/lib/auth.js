// import { Handler } from "aws-lambda";
// All AWS SDK Clients are available under the @aws-sdk namespace. You can install them locally to see functions and types
// const { RDSClient, ListTagsForResourceCommand } = require("@aws-sdk/client-rds");
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

  if (payload.method == "LOGIN") {
    return handleLogin(payload.email, payload.password);
  } else if (payload.method == "SIGNUP") {
    return await handleSignUp(payload);
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
 */
const handleLogin = (email, password) => {
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
 * @param { method: "SIGNUP", email: string, password: string, fname: string, lname: string } payload
 */
const handleSignUp = async (payload) => {
  console.log("Handling sign up");

  const client = new SecretsManagerClient({ region: process.env.AWS_REGION });
  const listCommand = new ListSecretsCommand({
    region: process.env.AWS_REGION,
    // For some reason plain text filtering isn't working. Need to fix this if we're gonna have multiple secrets
    // Filters: [{ Key: "name", Values: "rds" }],
  });

  const res = await client.send(listCommand);
  if (!res.SecretList || res.SecretList.length == 0)
    return {
      statusCode: 500,
      statusDescription: "database creds not found",
    };

  const getSecretCommand = new GetSecretValueCommand({
    SecretId: res.SecretList[0].Name,
  });
  const secret = await client.send(getSecretCommand);

  if (!secret || !secret?.SecretString) {
    return {
      statusCode: 500,
      statusDescription: "database creds not found in secret",
    };
  }

  const creds = JSON.parse(secret.SecretString);

  creds != undefined
    ? console.log("Successfully fetched DB creds")
    : console.error("Mission failed, we'll get em next time");

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
