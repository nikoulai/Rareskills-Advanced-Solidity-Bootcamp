// const ethers = require("ethers");

const { Worker, isMainThread, parentPort, workerData } = require('worker_threads');
const { getCreate2Address, utils } = require("solidity-create2-deployer");

const NUM_WORKERS = 1; // Number of CPU cores to use
const CHUNK_SIZE = 1000000; // How many salts each worker checks before reporting

// if (isMainThread) {
//     // Main thread code
    const bytecode = "0x6080604052348015600e575f80fd5b5060ce80601a5f395ff3fe6080604052348015600e575f80fd5b50600436106026575f3560e01c806306fdde0314602a575b5f80fd5b60306044565b604051603b91906081565b60405180910390f35b5f7f736d617278000000000000000000000000000000000000000000000000000000905090565b5f819050919050565b607b81606b565b82525050565b5f60208201905060925f8301846074565b9291505056fea264697066735822122050770b992357def94f1dbfa77d11ad2ce99f83defbb59c3249947263e4c6a71d64736f6c634300081a0033";
    
//     const workers = new Set();
    let startingSalt = 74206747;

//     // Create workers
//     for (let i = 0; i < NUM_WORKERS; i++) {
//         const worker = new Worker(__filename, {
//             workerData: {
//                 startingSalt: startingSalt + (i * CHUNK_SIZE),
//                 bytecode,
//                 workerId: i
//             }
//         });

//         workers.add(worker);

//         worker.on('message', (message) => {
//             if (message.found) {
//                 console.log('With salt:', utils.saltToHex(message.salt));
//                 console.log(`Worker ${message.workerId} found address:`, message.address);
//                 console.log('With salt:', utils.saltHex(message.salt));
//                 // Kill all workers
//                 for (let worker of workers) {
//                     worker.terminate();
//                 }
//             } else {
//                 console.log(`Worker ${message.workerId} tried ${message.tried} salts`);
//             }
//         });

//         worker.on('error', (err) => {
//             console.error(err);
//         });

//         worker.on('exit', () => {
//             workers.delete(worker);
//             if (workers.size === 0) {
//                 console.log('All workers finished');
//             }
//         });
//     }

// } else {
    // Worker thread code
    // const { startingSalt, bytecode, workerId } = workerData;
    let salt = startingSalt;

    while (true) {
        const computedAddress = getCreate2Address({
            salt: salt.toString(16),
            contractBytecode: bytecode,
        });

        if (computedAddress.toLowerCase().endsWith('badc0de')) {
            // parentPort.postMessage({
            //     found: true,
            //     address: computedAddress,
            //     salt: salt,
            //     workerId
            // });
            // break;
            break;
        }

        if ((salt - startingSalt) % CHUNK_SIZE === 0) {
            parentPort.postMessage({
                found: false,
                tried: CHUNK_SIZE,
                workerId
            });
        }

        salt++;
    }

    console.log('Done');

// }