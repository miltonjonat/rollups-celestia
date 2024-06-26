import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction, DeployOptions } from "hardhat-deploy/types";
import {
  abi,
  bytecode,
  deployedBytecode,
} from "../blobstream-contracts/out/Blobstream.sol/Blobstream.json";

// official Blobstream X contract deployments
// ref: https://docs.celestia.org/developers/blobstream#deployed-contracts
export const blobstreamDeploymentAddresses: any = {
  sepolia: "0xF0c6429ebAB2e7DC6e05DaFB61128bE21f13cb1e",
  arbitrum_sepolia: "0xc3e209eb245Fd59c8586777b499d6A665DF3ABD2",
  base_sepolia: "0xc3e209eb245Fd59c8586777b499d6A665DF3ABD2",
};

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();

  const opts: DeployOptions = {
    deterministicDeployment: true,
    from: deployer,
    log: true,
  };

  if (!blobstreamDeploymentAddresses[hre.network.name]) {
    // deploy Blobstream if no deployment is known
    await deployments.deploy("Blobstream", {
      ...opts,
      contract: {
        abi,
        bytecode: bytecode.object,
        deployedBytecode: deployedBytecode.object,
      },
    });
  }
};

export default func;
func.tags = ["Blobstream"];
