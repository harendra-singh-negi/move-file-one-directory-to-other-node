const express = require("express");
const MainRoute = express.Router();

MainRoute.get("/", (req, res) => {
    res.send("<h1>Welcome to  Api Service </h1>");
});

module.exports = MainRoute;