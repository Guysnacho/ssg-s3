const { version } = require("aws-sdk/package.json");

exports.handler = async () => ({ version });
