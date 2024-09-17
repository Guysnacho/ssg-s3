/**
 * This file helps you test lambda handler code locally. Good ol manual testing.
 * Runnable with `node .\testbench.js` from the command line (assuming you have node installed)
 */

const { handler } = require("./auth");

handler()
  .then((res) => console.log(res))
  .catch((err) => console.error(err))
  .finally(() => console.log("Finish handler execution"));
