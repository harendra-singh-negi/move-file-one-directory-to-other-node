const query = require('../db/DbQuery');
const fs = require('fs');
const path = require('path');
let SyncDataList = []
const folderPath = process.env.ATTECHMENT_MOVE_FOLDER_PATH;

const StartFileTrasfer = (datalist = {}) => {
    const { tuid, name, domain } = datalist;
    const attechmentSql = `CALL sails_master.SP_MoveActtechmentFile('${tuid}');`;
    query.getReturnData(attechmentSql, tuid).then((response) => {
        const { data, status } = response;
        // console.log("response",response);
        if (status) {
            SyncDataList = data.map(v => {
                let { attachmentFile, imoNumber } = v;
                const destinationPath = `${process.env.ATTECHMENT_MOVE_FOLDER_PATH}/${domain}/common-attachments/${imoNumber}`;
                let sourcePath = `${process.env.DEFAULT_ATTECHMENT_FOLDER_PATH}/${attachmentFile}`;
                sourcePath = path.normalize(sourcePath);
                if (!fs.existsSync(destinationPath)) {
                    try {
                        fs.mkdirSync(destinationPath, { recursive: true });
                        ChecckFileAvilability(sourcePath, destinationPath)
                    } catch (err) {
                        console.error('Error creating directory:', err);
                    }
                } else {
                    ChecckFileAvilability(sourcePath, destinationPath)
                }
                return path.basename(sourcePath);
            })
        }
    }).catch(error => {
        console.log("error", error);
    })
}
const MoveFile = (destinationPath, sourcePath) => {
    const fileName = path.basename(sourcePath);
    fs.rename(sourcePath, `${destinationPath}/${fileName}`, (err) => {
        if (err) {
            console.error('Error moving file:', err);
        } else {
            console.log('File moved successfully');
        }
    });
}

const ChecckFileAvilability = (sourcePath, destinationPath) => {
    fs.stat(sourcePath, (err, stats) => {
        if (err) {
            if (err.code === 'ENOENT') {
                // File does not exist
                // console.log('File does not exist.');
            } else {
                // Other error occurred
                console.error('Error reading the source file:', err);
            }
        } else {
            if (stats.isFile()) {
                CopyDataSourceToDestination(destinationPath, sourcePath)
                // It's a file
                // console.log('File exists.');
            } else if (stats.isDirectory()) {
                // It's a directory
                // console.log('The provided path is a directory, not a file.');
            }
        }
    });
}

const CopyDataSourceToDestination = (destinationFilePath, sourceFilePath) => {
    const fileName = path.basename(sourceFilePath);
    destinationFilePath += `/${fileName}`
    const readStream = fs.createReadStream(sourceFilePath);
    const writeStream = fs.createWriteStream(destinationFilePath);
    readStream.on('error', (err) => {
        console.error('Error reading the source file:', err);
    });
    writeStream.on('error', (err) => {
        console.error('Error writing to the destination file:', err);
    });
    writeStream.on('finish', () => {
        console.log(`${fileName} copied successfully.`);
    });
    readStream.pipe(writeStream);
}

const FindNewDataInFolder = (folderPath) => {
    const currentTime = new Date();
    fs.readdir(folderPath, (err, files) => {
        if (err) {
            console.error(`Error reading folder: ${err}`);
            return;
        }

        files.forEach((file) => {
            const filePath = path.join(folderPath, file);
            fs.stat(filePath, (err, stats) => {
                if (err) {
                    console.error(`Error getting file stats: ${err}`);
                    return;
                }
                const lastModifiedTime = stats.mtime;
                if (lastModifiedTime > currentTime) {
                    console.log(`File '${file}' has been updated.`);
                }
            });
        });
    });
}
const handleFileChange = (eventType, filename) => {
    console.log("🚀 ~ file: FileTrasferService.js:111 ~ handleFileChange ~ filename:", filename)
    if (filename !== null) {
        const filePath = path.join(folderPath, filename);
        console.log("🚀 ~ file: FileTrasferService.js:113 ~ handleFileChange ~ filePath:", filePath)
        if (!SyncDataList.includes(path.basename(filePath))) {
            const match = filePath.match(/\\([^\\]+)\\common-attachments\\/);
            const extractedText = match ? match[1] : null;
            if (extractedText !== null) {
                // const destinationFilePath = "D:/herendra/" + extractedText;
                const destinationFilePath = process.env.DEFAULT_ATTECHMENT_FOLDER_PATH + "/sails-attachments/" + extractedText + "/common-attachments";
                // console.log("destinationFilePath", destinationFilePath);
                if (['change', 'rename'].includes(eventType)) {
                    if (!fs.existsSync(destinationFilePath)) {
                        try {
                            fs.mkdirSync(destinationFilePath, { recursive: true });
                            ChecckFileAvilability(filePath, destinationFilePath)
                        } catch (err) {
                            console.error('Error creating directory:', err);
                        }
                    } else {
                        ChecckFileAvilability(filePath, destinationFilePath)
                    }
                }


                // const destinationFilePath = process.env.DEFAULT_ATTECHMENT_FOLDER_PATH + "/" + extractedText;
                // if (eventType === 'change') {
                //     console.log(`File '${filePath}' has been changed.`);

                // }
                // else if (eventType === 'rename') {
                //     // console.log(`File '${filePath}' has been added.`);

                // }
            }
        }
    }

};

const SyncDataOneFolderToOtherFolder = (sourceFolderPath, destinationFolderPath) => {
    // Read the source folder
    fs.readdir(sourceFolderPath, (err, files) => {
        if (err) {
            console.error('Error reading source folder:', err);
            return;
        }
        // Synchronize each file
        files.forEach((file) => {
            const sourceFilePath = path.join(sourceFolderPath, file);
            const destinationFilePath = path.join(destinationFolderPath, file);
            // Check if the destination file already exists
            fs.access(destinationFilePath, fs.constants.F_OK, (accessErr) => {
                if (accessErr) {
                    // Destination file doesn't exist, perform synchronization
                    fs.copyFile(sourceFilePath, destinationFilePath, (copyErr) => {
                        if (copyErr) {
                            console.error('Error synchronizing file:', copyErr);
                        } else {
                            console.log('File synchronized:', file);
                        }
                    });
                } else {
                    // console.log('File already exists, skipping synchronization:', file);
                }
            });
        });
    });
}


// Watch the folder for file changes
fs.watch(folderPath, { recursive: true }, handleFileChange);


module.exports = {
    StartFileTrasfer,
    MoveFile,
    ChecckFileAvilability,
    CopyDataSourceToDestination,
    FindNewDataInFolder,
    handleFileChange,
    SyncDataOneFolderToOtherFolder
}