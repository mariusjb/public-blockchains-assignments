/* 
1. install openzeppelin
2. write smart contract
3. write deployment script with token input parameters
Token name etc can be input per deployment script or smart contract
*/



const hre = require("hardhat");

async function main() {

  const [signer1, signer2, signer3] = await hre.ethers.getSigners();

  // Pick the deployer (default is signer1).
  const deployer = signer3;

  console.log('Deploying contracts from account:', deployer.address);

  const CensorableToken = await ethers.getContractFactory('CensorableToken');
  
  const totalSupply = hre.ethers.parseEther('1000000');
  console.log(totalSupply);
  const censorableToken = await CensorableToken.deploy('MyToken', 'MT', 
                            totalSupply, deployer.address);

  await censorableToken.waitForDeployment();

  console.log('ERCensor20 deployed to:', censorableToken.target);

  const validator = await censorableToken._validator();

  console.log("Validator is " + validator);
  
  const censorableToken2 = await hre.ethers.getContractAt('CensorableToken',
    censorableToken.target,
    deployer); 

  const amount = totalSupply - hre.ethers.parseEther('10');
  console.log(amount);
  let tx = await censorableToken2.approve(validator, amount);

  await tx.wait();

  console.log("Allowance set for validator");
 

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
