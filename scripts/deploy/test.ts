import { ethers } from "hardhat";
import config from '../../config/config';

async function main() {
   
    
    await grantMinter(config.contracts.MM_TRADING);
   
}


    

async function grantMinter(minter:string) {
    const mm = await ethers.getContractAt("MM", config.tokens.MM);
    const result = await mm.grantMinter(minter);
    console.log(` > nonce: ${result.nonce}`)
    // console.log(JSON.stringify(result, null, '	'))
    console.log(` > ${config.block_explorer}/tx/${result.hash}`);
    await result.wait();
}



main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });