var TokenVestingFactory = artifacts.require("./TokenVestingFactory.sol");

module.exports = async (deployer) => {
  await deployer.deploy(TokenVestingFactory);  
};

