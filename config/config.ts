const node_env = process.env.NODE_ENV || 'dev'


const {tokens , contracts,vaultAddress, devAddress, block_explorer} = require("./config_" + node_env).default


const dotenv = require('dotenv')
const envFile = `${__dirname}/.env.${node_env}`
dotenv.config({ path: envFile})

const private_key = process.env.PRIVATE_KEY_DEPLOYER
const private_key_test_1 = process.env.PRIVATE_KEY_TEST_1
const private_key_test_2 = process.env.PRIVATE_KEY_TEST_2
const infura_api_key = process.env.INFURA_API_KEY

export default {
    tokens: tokens,
    contracts: contracts,
    block_explorer: block_explorer,
    devAddress: devAddress,
    private_key: private_key,
    private_key_test_1: private_key_test_1,
    private_key_test_2: private_key_test_2,
    infura_api_key: infura_api_key,
    vaultAddress:vaultAddress,
}