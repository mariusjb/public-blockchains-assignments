const { ethers } = require("hardhat");

async function main() {
    // Load the ERC20 contract factory
    const [deployer] = await ethers.getSigners();

    // Deploy the ERC20 contract
    console.log("Deploying contracts with the account:", deployer.address);

    const NFT = await ethers.getContractFactory("NFTminter_template");

    // Deploy the nft contract
    const nft = await NFT.deploy();

    console.log("NFT deployed to:", nft.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });