require('dotenv').config();
require("@nomicfoundation/hardhat-chai-matchers");


const ALCHEMY_KEY=process.env.ALCHEMY_KEY;
const PRIVATE_KEY=process.env.PRIVATE_KEY;
const POLYGON_API =process.env.POLYGON_API;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
 // defaultNetwork: "localhost",
  networks: {
    hardhat: {
    },
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_KEY}`,
      accounts: [PRIVATE_KEY]
    },
    matic:{
      
      url:`https://polygon-mumbai.g.alchemy.com/v2/${POLYGON_API}`,
      accounts: [PRIVATE_KEY]
    }
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  }
}