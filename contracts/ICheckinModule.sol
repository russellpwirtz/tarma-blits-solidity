// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @title ICheckinModule
 * @dev This contract allows users to do daily checkins on ERC1155 tokens, earning ERC20 tokens as payment.
 *
 */
interface ICheckinModule {
    /**
     * @dev The checkin reward is based on attributes such as happiness, discipline, and energy.
     * A given tokenId for an nft contract can only check in once daily.
     * Missing a daily checkin causes a diminished reward.
     *
     * @param nftContract The ERC1155 contract address.
     * @param tokenId The token ID to be checked in.
     * @param sender The owner of the NFT to be checked in
     * @param multiplier The amount of tokens earned for this checkin. A multiplier can be set for special events, promotions or any other reason.
     * @param happy A value between 1-5 representing the level of happiness of the user when doing the checkin.
     * @param disciplined A value between 1-5 representing the level of discipline of the user when doing the checkin.
     * @param energy A value between 1-5 representing the level of energy of the user when doing the checkin.
     * @return uint256 The number of tokens earned for this checkin.
     */
    function checkin(
        IERC1155 nftContract,
        uint256 tokenId,
        address sender,
        uint256 multiplier,
        uint256 happy,
        uint256 disciplined,
        uint256 energy
    ) external returns (uint256);

    /**
     * @dev Get the timestamp of the last checkin for a specific token.
     *
     * @param nftContract The ERC1155 contract address.
     * @param tokenId The token ID to check.
     * @return uint256 The timestamp of the last checkin for a specific token.
     */
    function getLastCheckin(
        IERC1155 nftContract,
        uint256 tokenId
    ) external view returns (uint256);

    /**
     * @dev Gets the total amount of tokens earned by the user since the contract creation.
     * @return uint256 The total number of tokens earned by the user.
     */
    function getCumulativeEarned(
        address sender
    ) external view returns (uint256);

    /**
     * @dev Emitted when a checkin is performed.
     *
     * @param nftContract The ERC1155 contract address.
     * @param tokenId The token ID to be checked in.
     * @param paymentContractAddress The ERC20 payment token contract address that was used for payment.
     * @param amountEarned The number of tokens earned for this checkin.
     * @param sender The address of the sender who performed the checkin.
     */
    event CheckedIn(
        address indexed nftContract,
        uint256 indexed tokenId,
        address paymentContractAddress,
        uint256 amountEarned,
        address sender
    );
}
