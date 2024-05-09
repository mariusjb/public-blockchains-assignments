const { ethers } = require("hardhat");

async function main() {
    // Load the ERC20 contract factory
    const [deployer] = await ethers.getSigners();

    // Deploy the ERC20 contract
    console.log("Deploying contracts with the account:", deployer.address);

    const CensorableToken = await ethers.getContractFactory("CensorableToken");

    // Deploy the CensorableToken contract
    const initialSupply = ethers.parseEther("1000");
    const initialOwner = deployer.address;
    const censorableToken = await CensorableToken.deploy(
        "MyToken",        // Name
        "MTK",            // Symbol
        initialSupply,    // Initial supply
        initialOwner      // Initial owner
    );

    console.log("CensorableToken deployed to:", censorableToken.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });