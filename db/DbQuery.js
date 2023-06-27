const { GetDbConnect } = require("./Connection");
// const auth = require("./dbAuth");



async function getPostQuery(req, res, sql, dbname = "") {

    // if (auth.dbAuth(req)) {
    let db = GetDbConnect(dbname);
    db.getConnection(function (error, connection) {
        if (error) {
            res.status(403).send({ status: false, data: error });
        }
        // Use the connection
        connection.query(sql, function (error, result, fields) {
            // When done with the connection, release it.
            connection.release();
            if (error) {
                res.status(403).send({ status: false, data: error });
            } else {
                if (Array.isArray(result)) {
                    if (sql.toLowerCase().includes("call ")) {
                        res.status(200).send({ status: true, data: result[0] });
                    } else {
                        res.status(200).send({ status: true, data: result });
                    }
                } else {
                    res.status(200).send({ status: true, data: result });
                }
            }
        });
        // connection.destroy();
    });
    // } else {
    //     console.log("error access denied");
    //     res.status(401).send({ status: false, data: "access denied" });
    // }
}
async function getReturnData(sql, dbname = "") {
    let db = GetDbConnect(dbname);
    return new Promise((resolve, reject) => {
        db.getConnection(function (error, connection) {
            if (error) {
                reject({ status: false, data: error })
            }
            // Use the connection
            connection.query(sql, function (error, result, fields) {
                // When done with the connection, release it.
                connection.release();
                if (error) {
                    reject({ status: false, data: error });
                } else {
                    if (Array.isArray(result)) {
                        if (sql.toLowerCase().includes("call ")) {
                            resolve({ status: true, data: result[0] });
                        } else {
                            resolve({ status: true, data: result });
                        }
                    } else {
                        resolve({ status: true, data: result });
                    }
                }
            });
        });
    })
}

async function onlyPostQuery(req, res, sql, dbname = "") {
    // if (auth.dbAuth(req)) {
    let db = GetDbConnect(dbname);
    db.getConnection(function (error, connection) {
        if (error) {
            res.status(403).send({ status: false, data: error });
        }
        // Use the connection
        connection.query(sql, function (error, result, fields) {
            // When done with the connection, release it.
            connection.release();
            if (error) {
                res.status(403).send({ status: false, data: error });
            } else {
                res
                    .status(200)
                    .send({ status: true, data: "Data saved successfully" });
            }
        });
        // connection.destroy();
    });
    // } else {
    //     console.log("error");
    //     res.status(401).send({ status: false, data: "access denied" });
    // }
}
module.exports = { getPostQuery, onlyPostQuery, getReturnData };