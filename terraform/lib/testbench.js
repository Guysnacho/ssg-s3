/**
 * This file helps you test lambda handler code locally. Good ol manual testing.
 * Runnable with `node .\testbench.js` from the command line (assuming you have node installed)
 * 
 * How To - Install all packages used in the lambda locally, they aren't already because AWS
 * provides them in the lambda environment`npm i <package_name>`
 */

const { handler } = require("./auth/index");

handler()
  .then((res) => console.log(res))
  .catch((err) => console.error(err))
  .finally(() => console.log("Finish empty event test"));

handler({
  method: "LOGIN",
  email: "test",
  password: "test",
  fname: "test",
  lname: "test",
})
  .then((res) => console.log(res))
  .catch((err) => console.error(err))
  .finally(() => console.log("Finish valid request test"));
