// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ILockModule.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @title LockModule
 * @dev This contract allows users to lock ERC1155 tokens and unlock them by paying
 * with an ERC20 token. The contract defines what ERC20 payment will be required to later unlock.
 */
contract LockModule is ILockModule {
    struct Lock {
        uint256 _unlockCost;
        bool _isLocked;
        uint256 _unlockDate;
        address _paymentTokenAddress;
    }

    mapping(address => mapping(uint256 => Lock)) locks;

    /**
     * @dev This initializes the lock and emits an event. It defines the contract of the NFT
     * to lock, the nft ID, cost to unlock, as well as the erc20 contract of the payment token.
     * It doesn't actually require any payment; it simply defines what ERC20 payment will be
     * required to later unlock.
     * @param nftContract The address of the ERC1155 contract to lock the token.
     * @param tokenId The ID of the ERC1155 token to lock.
     * @param paymentToken The ERC20 contract address desired for payment.
     * @param cost The cost of the ERC20 token to unlock the token.
     * @return success Return 'true' if the initialization is successful.
     */
    function initialize(
        IERC1155 nftContract,
        uint256 tokenId,
        IERC20 paymentToken,
        uint256 cost
    ) external override returns (bool success) {
        require(
            locks[address(nftContract)][tokenId]._isLocked == false,
            "already locked"
        );

        locks[address(nftContract)][tokenId] = Lock({
            _unlockCost: cost,
            _isLocked: true,
            _unlockDate: 0,
            _paymentTokenAddress: address(paymentToken)
        });

        emit Initialized(
            address(nftContract),
            tokenId,
            address(paymentToken),
            cost,
            msg.sender
        );

        return true;
    }

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
    ) external override returns (bool success) {
        Lock storage lockObj = locks[address(nftContract)][tokenId];
        require(lockObj._isLocked == true, "not locked");
        require(lockObj._unlockDate == 0, "already unlocked");

        IERC20 paymentToken = IERC20(lockObj._paymentTokenAddress);
        require(
            paymentToken.transferFrom(
                msg.sender,
                address(this),
                lockObj._unlockCost
            )
        );

        lockObj._unlockDate = block.timestamp;

        emit Unlocked(msg.sender, tokenId, block.timestamp);

        return true;
    }

    /**
     * @dev Checks whether or not an NFT is still locked.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the ERC1155 token to unlock.
     * @return result Return 'true' if the token is locked, 'false' otherwise.
     */
    function isLocked(
        address nftContract,
        uint256 tokenId
    ) external view override returns (bool result) {
        return locks[nftContract][tokenId]._isLocked;
    }

    /**
     * @dev Returns the cost of the ERC20 token to unlock the ERC1155 token.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the ERC1155 token to unlock.
     * @return result Return the cost of the ERC20 token as uint256.
     */
    function unlockCost(
        address nftContract,
        uint256 tokenId
    ) external view override returns (uint256 result) {
        return locks[nftContract][tokenId]._unlockCost;
    }

    /**
     * @dev Returns the date the token was unlocked.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the ERC1155 token to unlock.
     * @return result Return the date the token was unlocked as uint256.
     */
    function getDateUnlocked(
        address nftContract,
        uint256 tokenId
    ) external view override returns (uint256 result) {
        return locks[nftContract][tokenId]._unlockDate;
    }
}
