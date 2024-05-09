require("@nomicfoundation/hardhat-toolbox");
// require("@nomiclabs/hardhat-ethers");

const path = require('path')
const res = require('dotenv').config();

// Beware: NEVER put real Ether into testing accounts.
const MM_1_PRIVATE_KEY = process.env.METAMASK_1_PRIVATE_KEY;
const MM_2_PRIVATE_KEY = process.env.METAMASK_2_PRIVATE_KEY;
const MM_3_PRIVATE_KEY = process.env.METAMASK_3_PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    rpc: {
      url: "http://134.155.50.136:8506",
      chainId: 1337,
      accounts: [MM_1_PRIVATE_KEY, MM_2_PRIVATE_KEY, MM_3_PRIVATE_KEY]
    }
  }
};