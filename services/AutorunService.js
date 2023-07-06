const fs = require('fs');
const path = require('path');
const query = require('../db/DbQuery');
const { StartFileTrasfer, SyncDataOneFolderToOtherFolder } = require('./FileTrasferService');

// run wen server start
const TrasferDataWhenServerStarted = async () => {

    const sql = process.env.GET_ALL_TENENT_LIST;
    // query.getPostQuery(req, res, sql);
    query.getReturnData(sql).then((response) => {
        const { data, status } = response;
        if (status) {
            data.map(async (v) => {
                const { tuid, name, domain } = v;
                const FolderPath = process.env.ATTECHMENT_MOVE_FOLDER_PATH + `/${domain}/common-attachments`;
                const FolderPathList = await GetAllFolderList(FolderPath);
                FolderPathList.map((item) => {
                    const sourceFolderPath = FolderPath + "/" + item;
                    const destinationFolderPath = process.env.DEFAULT_ATTECHMENT_FOLDER_PATH + "/sails-attachments/" + domain + "/common-attachments";
                    SyncDataOneFolderToOtherFolder(sourceFolderPath, destinationFolderPath)
                })
                // console.log("🚀 ~ file: AutorunService.js:18 ~ query.getReturnData ~ data:", FolderPathList)
            })
        } else {
            console.log("🚀 ~ file: AutorunService.js:23 ~ query.getReturnData ~ l:", data)
        }
    }).catch((err) => {
        console.log("🚀 ~ file: AutorunService.js:23 ~ query.getReturnData ~ err:", err)
    })

}

const GetAllFolderList = async (directoryPath) => {
    let result = new Promise((resolve, reject) => {
        fs.readdir(directoryPath, { withFileTypes: true }, (err, files) => {
            if (err) {
                // console.error('Error reading directory:', err);
                return;
            }
            // Filter out folders only
            const folders = files.filter((file) => file.isDirectory());
            // Get the folder names
            const folderNames = folders.map((folder) => folder.name);
            resolve(folderNames);
        });
    });

    return await result;
}


module.exports = { TrasferDataWhenServerStarted }