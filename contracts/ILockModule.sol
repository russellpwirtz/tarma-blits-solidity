// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @title ILockModule
 * @dev This contract allows users to lock ERC1155 tokens and unlock them by paying
 * with an ERC20 token. The contract defines what ERC20 payment will be required to later unlock.
 */
interface ILockModule {
    /**
     * @dev This initializes the lock and emits an event. It defines the contract of the NFT
     * to lock, the nft ID, cost to unlock, as well as the erc20 contract of the payment token.
     * It doesn't actually require any payment; it simply defines what ERC20 payment will be
     * required to later unlock.
     * @param nftContract The address of the ERC1155 contract to lock the token.
     * @param tokenId The ID of the ERC1155 token to lock.
     * @param paymentToken The ERC20 contract address desired for payment.
     * @param unlockCost The cost of the ERC20 token to unlock the token.
     * @return success Return 'true' if the initialization is successful.
     */
    function initialize(
        IERC1155 nftContract,
        uint256 tokenId,
        IERC20 paymentToken,
        uint256 unlockCost
    ) external returns (bool success);

    /**
     * @dev This uses the ERC20 transferFrom method to send funds from the user to the contract, then
     * unlocks the NFT and emits an event.
     * @param nftContract The address of the ERC1155 contract the token is locked.
     * @param tokenId The ID of the ERC1155 token to unlock.
     * @return success Return 'true' if the token is unlocked successfully.
     */
    function unlock(
        IERC1155 nftContract,
        uint256 tokenId
    ) external returns (bool success);

    /**
     * @dev Checks whether or not an NFT is still locked.
     * @param nftContractAddress The address of the NFT contract.
     * @param tokenId The ID of the ERC1155 token to unlock.
     * @return result Return 'true' if the token is locked, 'false' otherwise.
     */
    function isLocked(
        address nftContractAddress,
        uint256 tokenId
    ) external view returns (bool result);

    /**
     * @dev Returns the cost of the ERC20 token to unlock the ERC1155 token.
     * @param nftContractAddress The address of the NFT contract.
     * @param tokenId The ID of the ERC1155 token to unlock.
     * @return result Return the cost of the ERC20 token as uint256.
     */
    function unlockCost(
        address nftContractAddress,
        uint256 tokenId
    ) external view returns (uint256 result);

    /**
     * @dev Returns the date the token was unlocked.
     * @param nftContractAddress The address of the NFT contract.
     * @param tokenId The ID of the ERC1155 token to unlock.
     * @return result Return the date the token was unlocked as uint256.
     */
    function getDateUnlocked(
        address nftContractAddress,
        uint256 tokenId
    ) external view returns (uint256 result);

    event Initialized(
        address indexed nftContractAddress,
        uint256 indexed tokenId,
        address indexed paymentTokenAddress,
        uint256 priceToUnlock,
        address sender
    );

    event Unlocked(
        address indexed sender,
        uint256 indexed tokenId,
        uint256 indexed unlockDate
    );
}
