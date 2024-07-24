async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Token = await ethers.getContractFactory("Token");
  const token1 = await Token.deploy("Token1", "TK1", ethers.utils.parseEther("10000"));
  await token1.deployed();

  const token2 = await Token.deploy("Token2", "TK2", ethers.utils.parseEther("10000"));
  await token2.deployed();

  const SimpleDEX = await ethers.getContractFactory("SimpleDEX");
  const dex = await SimpleDEX.deploy(token1.address, token2.address);
  await dex.deployed();

  console.log("Token1 deployed to:", token1.address);
  console.log("Token2 deployed to:", token2.address);
  console.log("SimpleDEX deployed to:", dex.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
