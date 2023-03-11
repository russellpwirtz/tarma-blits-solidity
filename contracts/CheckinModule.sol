// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ICheckinModule.sol";

contract CheckinModule is ICheckinModule {
    using SafeMath for uint256;

    struct CheckinRecord {
        uint256 timestamp;
        uint256 reward;
    }

    mapping(address => mapping(uint256 => CheckinRecord)) private checkins;
    mapping(address => uint256) private totalTokensEarned;

    ERC20 public paymentToken;

    constructor(address _paymentToken) {
        paymentToken = ERC20(_paymentToken);
    }

    function checkin(
        IERC1155 nftContract,
        uint256 tokenId,
        uint256 multiplier,
        uint256 happy,
        uint256 disciplined,
        uint256 energy
    ) external override returns (uint256) {
        require(happy >= 1 && happy <= 5, "Invalid happiness value");
        require(
            disciplined >= 1 && disciplined <= 5,
            "Invalid discipline value"
        );
        require(energy >= 1 && energy <= 5, "Invalid energy value");

        address sender = msg.sender;
        uint256 lastCheckin = getLastCheckin(nftContract, tokenId);

        require(
            block.timestamp > lastCheckin.add(1 days),
            "Already checked in today"
        );

        uint256 reward = getReward(happy, disciplined, energy).mul(multiplier);
        checkins[address(nftContract)][tokenId] = CheckinRecord(
            block.timestamp,
            reward
        );
        totalTokensEarned[sender] = totalTokensEarned[sender].add(reward);

        require(paymentToken.transfer(sender, reward), "Token transfer failed");

        emit CheckedIn(
            address(nftContract),
            tokenId,
            address(paymentToken),
            reward,
            sender
        );

        return reward;
    }

    function getLastCheckin(
        IERC1155 nftContract,
        uint256 tokenId
    ) public view override returns (uint256) {
        return checkins[address(nftContract)][tokenId].timestamp;
    }

    function getCumulativeEarned() public view override returns (uint256) {
        return totalTokensEarned[msg.sender];
    }

    function getReward(
        uint256 happy,
        uint256 disciplined,
        uint256 energy
    ) internal pure returns (uint256) {
        return happy.mul(2).add(disciplined.mul(3)).add(energy);
    }
}
