const express = require('express');
const query = require('../db/DbQuery');
const { StartFileTrasfer } = require('../services/FileTrasferService');
const FileTrasferRoute = express.Router();
FileTrasferRoute.get('/', async (req, res) => {
    const sql = process.env.GET_ALL_TENENT_LIST;
    // query.getPostQuery(req, res, sql);
    query.getReturnData(sql).then((response) => {
        const { data, status } = response;
        if (status) {
            data.map(v => {
                StartFileTrasfer(v);
            })
        } else {
            console.log("🚀 ~ file: FileTrasferRoute.js:12 ~ FileTrasferRoute.get ~ data:", data)
        }
    }).catch((err) => {
        console.log("🚀 ~ file: FileTrasferRoute.js:14 ~ query.getReturnData ~ err:", err)

    })
    res.status(200).send("Success");
});


module.exports = FileTrasferRoute;
