const fs = require('fs');
const path = require('path');

function main() {
    const monthAbb = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const whatMonths = monthAbb.slice(0, 3); // start from Jan to current end month
    const whatYear = 2023;

    // Reading files in

    // All departments except A&E
    // Before July 2023
    const path1 = "E:/Documents/Work/Projects/1. Personal/Julia/Projects/Closed Charts/Data/1. Raw data/2023/All/Before July 2023";
    readFiles(path1);

    // July 2023 onwards
    const path2 = "E:/Documents/Work/Projects/1. Personal/Julia/Projects/Closed Charts/Data/1. Raw data/2023/All/July 2023 onwards/";
    readFiles(path2);
}

function readFiles(directoryPath) {
    console.log(`Files in directory '${directoryPath}':`);
    fs.readdir(directoryPath, (err, files) => {
        if (err) {
            console.error(`Error reading directory '${directoryPath}': ${err.message}`);
            return;
        }
        files.forEach(file => {
            console.log(path.join(directoryPath, file));
        });
    });
}

main();
