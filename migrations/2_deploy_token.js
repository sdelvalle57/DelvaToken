var DelvaToken = artifacts.require("./DelvaToken.sol");

module.exports = async (deployer) => {
  await deployer.deploy(DelvaToken);  
};
