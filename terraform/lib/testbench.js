const { handler } = require("./auth");

handler()
  .then((res) => console.log(res))
  .catch((err) => console.error(err))
  .finally(() => console.log("Finish handler execution"));
