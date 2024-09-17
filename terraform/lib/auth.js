// import { RDSClient, ListTagsForResourceCommand } from "@aws-sdk/client-rds";
import packageJson from "@aws-sdk/client-rds/package.json";

exports.handler = async (event, context, callback) => {
  console.log(`Starting ${context.functionName} invocation`);
  console.log("Event recieved");
  console.log(event);

  return { version: packageJson.version };
};
