require("dotenv").config();
var mysql = require("mysql");
function GetDbConnect(name = "") {
    let dbName = name === "" ? process.env.SAFE_LANES_DB_NAME : name;
    // switch (type) {
    //     case "safe-lanes":
    //         db = SAFE_LANES_DB;
    //         break;
    //     default:
    //         break;
    // }

    const db = mysql.createPool({
        connectionLimit: 10,
        host: process.env.SAFE_LANES_DB_HOST,
        user: process.env.SAFE_LANES_DB_USER,
        password: process.env.SAFE_LANES_DB_PASS,
        database: dbName,
    });


    return db;
}
module.exports = { GetDbConnect };