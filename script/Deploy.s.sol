// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Market} from "../src/Market.sol";
import {MockSynth} from "../test/mocks/MockSynth.sol";
import {Base, BaseSepolia} from "./utils/Parameters.sol";
import {Script, console} from "@forge-std/Script.sol";

contract Deploy is Script {

    modifier broadcast() {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        _;
        vm.stopBroadcast();
    }

    function deploySystem(
        address numeraire,
        address index
    )
        public
        returns (Market market)
    {
        market = new Market(numeraire, index);
    }

    function deployMockTokens()
        public
        returns (MockSynth numeraire, MockSynth index)
    {
        numeraire = new MockSynth("Mock Numeraire", "mNUM");
        index = new MockSynth("Mock Index", "mIDX");
    }

}

/// @custom:deploy `make deploy_base`
contract DeployBase is Deploy, Base {

    function run() public broadcast {
        Market market =
            deploySystem({numeraire: BASE_NUMERAIRE, index: BASE_INDEX});
    }

}

// @dev steps to deploy and verify on Base Sepolia:
/// (1) load the variables in the .env file via `source .env`
/// (2) run `forge script script/Deploy.s.sol:DeployBaseSepolia --rpc-url
/// $BASE_SEPOLIA_RPC --etherscan-api-key $BASESCAN_API_KEY --broadcast --verify
/// -vvvv`
contract DeployBaseSepolia is Deploy, BaseSepolia {

    function run() public broadcast {
        (MockSynth numeraire, MockSynth index) = deployMockTokens();

        // deploy the market with the new mock tokens
        Market market =
            deploySystem({numeraire: address(numeraire), index: address(index)});
    }

}
