import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction, DeployOptions } from "hardhat-deploy/types";
import {
  abi,
  bytecode,
  deployedBytecode,
} from "../blobstream-contracts/out/Blobstream.sol/Blobstream.json";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();

  const opts: DeployOptions = {
    deterministicDeployment: true,
    from: deployer,
    log: true,
  };

  await deployments.deploy("Blobstream", {
    ...opts,
    contract: {
      abi,
      bytecode: bytecode.object,
      deployedBytecode: deployedBytecode.object,
    },
  });
};

export default func;
func.tags = ["Blobstream"];
