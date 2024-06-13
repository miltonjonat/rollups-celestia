import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction, DeployOptions } from "hardhat-deploy/types";
import { blobstreamDeploymentAddresses } from "./01_Blobstream";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();

  const opts: DeployOptions = {
    deterministicDeployment: true,
    from: deployer,
    log: true,
  };

  const { InputBox, Blobstream } = await deployments.all();

  const blobstreamAddress =
    Blobstream?.address || blobstreamDeploymentAddresses[hre.network.name];

  await deployments.deploy("CelestiaRelay", {
    ...opts,
    args: [InputBox.address, blobstreamAddress],
  });
};

export default func;
func.tags = ["CelestiaRelay"];
