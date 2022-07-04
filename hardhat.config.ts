import { task } from "hardhat/config";
import 'hardhat-typechain'
import 'hardhat-contract-sizer'
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-waffle'
import '@openzeppelin/hardhat-upgrades'

import config from './config/config'

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (args, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(await account.address);
    }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

export default {
    networks: {
        hardhat: {
            allowUnlimitedContractSize: false,
            gas:30000000,
            mining: {
                auto: false,
                interval: 15000
              },
        },
        rinkeby: {
            url: `https://rinkeby.infura.io/v3/${config.infura_api_key}`,
            accounts: [
                config.private_key,
                // config.private_key_test_1,
                // config.private_key_test_2
            ],
            gasPrice: 10000000000,
            gas:30000000,
        },
        arbitum_rinkeby: {
            url: 'https://rinkeby.arbitrum.io/rpc',
            accounts: [config.private_key],
            gasPrice: 'auto',
            gas: 100000000,
          },
        mainnet: {
            url: `https://mainnet.infura.io/v3/${config.infura_api_key}`,
            accounts: [config.private_key],
        }
    },
    solidity: {
        version: '0.8.4',
        settings: {
            optimizer: {
                enabled: true,
            }
        },
    },
    contractSizer: {
        alphaSort: true,
        runOnCompile: false,
        disambiguatePaths: false,
        strict: true,
    },
};