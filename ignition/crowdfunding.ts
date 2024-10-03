import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const crowdFundingModule = buildModule("crowdFundingModule", (m) => {

    const crowdfund = m.contract("CrowdFunding");

    return { crowdfund };
});

export default crowdFundingModule;
