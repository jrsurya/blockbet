// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

// 1. Deploy mocks when we are on a local anil chain
// 2. Keep track of contract address across different chain

contract HelperConfig is Script {
    //if we are on a local anvil, we dploy mocks
    // otherwise, grab the existing address for the live network

    NetworkConfig public activeNeworkConfig;

    constructor() {
        if (block.chainid == 11155111)
            activeNeworkConfig = getSepoliaEthConfig();
        else {
            activeNeworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed; // eth/usd price feed
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // pricefeed address
        NetworkConfig memory sepoliaconfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaconfig;
    }

    function getMainNetEthConfig() public pure returns (NetworkConfig memory) {
        // pricefeed address
        NetworkConfig memory mainNetconfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainNetconfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNeworkConfig.priceFeed != address(0))
            return activeNeworkConfig;
        // 1. deploy the mocks contract
        // 2. return the mock address for the price feed
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        NetworkConfig memory anvilNetconfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilNetconfig;
    }
}
