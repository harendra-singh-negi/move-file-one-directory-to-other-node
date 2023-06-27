const express = require('express');
const app = express();
require('dotenv').config();
const FileTrasferRoute = require('./routes/FileTrasferRoute');
const MainRoute = require('./routes/MainRoute');

const port = process.env.PORT || 4005;

app.use('/', MainRoute);
app.use('/traferFile', FileTrasferRoute);

app.listen(port, () => {
    console.log("Server Date Time : " + new Date());
    console.log(`Server is listening on port http://localhost:${port}`);
});

