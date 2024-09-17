// All AWS SDK Clients are available under the @aws-sdk namespace. You can install them locally to see functions and types
// import { RDSClient, ListTagsForResourceCommand } from "@aws-sdk/client-rds";
import packageJson from "@aws-sdk/client-rds/package.json";
import { Handler } from "aws-lambda/handler";

const handler: Handler = async (event, context, callback) => {
  console.log(`Starting ${context.functionName} invocation`);
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

  return {
    statusCode: 201,
    statusDescription: "user created",
    headers: {
      "cloudfront-functions": { value: "generated-by-CloudFront-Functions" },
      "client-version": packageJson.version,
      location: { value: "https://aws.amazon.com/cloudfront/" },
    },
  };
};

const isValidPayload = (
  event: any
):
  | {
      method: string;
      email: string;
      password: string;
      fname: string;
      lname: string;
    }
  | undefined => {
  if (
    event.method == "SIGNUP" &&
    event.email &&
    event.email.length > 0 &&
    event.password &&
    event.password.length > 0 &&
    event.fname &&
    event.fname.length > 0 &&
    event.lname &&
    event.lname.length > 0
  ) {
    return event;
  } else if (
    event.method == "LOGIN" &&
    event.email &&
    event.email.length > 0 &&
    event.password &&
    event.password.length > 0
  ) {
    return event;
  } else return undefined;
};

export default handler;
