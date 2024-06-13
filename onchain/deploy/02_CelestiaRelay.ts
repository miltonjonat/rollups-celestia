import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction, DeployOptions } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();

  const opts: DeployOptions = {
    deterministicDeployment: true,
    from: deployer,
    log: true,
  };

  const { InputBox, Blobstream } = await deployments.all();

  await deployments.deploy("CelestiaRelay", {
    ...opts,
    args: [InputBox.address, Blobstream.address],
  });
};

export default func;
func.tags = ["CelestiaRelay"];
