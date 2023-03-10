
const LockModule = artifacts.require("LockModule");
const TestNFT = artifacts.require("TestNFT");
const TestERC20 = artifacts.require("TestERC20");

contract("LockModule", (accounts) => {
  let lockModule;
  let nft;
  let erc20;
  const tokenId = 1;
  const nftAmount = 1;
  const cost = 1000;

  beforeEach(async () => {
    nft = await TestNFT.new();
    erc20 = await TestERC20.new();
    lockModule = await LockModule.new();
    await nft.createToken(tokenId, nftAmount);
    await erc20.approve(lockModule.address, cost, { from: accounts[0] });
    await lockModule.initialize(nft.address, tokenId, erc20.address, cost, { from: accounts[0] });
  });

  it("should lock the NFT token", async () => {
    const isLocked = await lockModule.isLocked(accounts[0], tokenId);
    assert.equal(isLocked, true);
  });

  it("should initialize with correct parameters", async () => {
    const paymentToken = await lockModule.nftToPaymentToken(nft.address, tokenId);
    const unlockCost = await lockModule.nftToUnlockCost(nft.address, tokenId, accounts[0]);
    assert.equal(paymentToken, erc20.address, "Invalid payment token");
    assert.equal(unlockCost, cost, "Invalid unlock cost");
  });

  it("should unlock the NFT token with proper payment", async () => {
    const unlockBefore = await lockModule.nftToUnlockDate(nft.address, tokenId, accounts[0]);
    await lockModule.unlock(nft.address, tokenId, { from: accounts[0] });
    const unlockAfter = await lockModule.nftToUnlockDate(nft.address, tokenId, accounts[0]);
    assert.equal(unlockAfter - unlockBefore > 0, true, "Unlock date was not set");
  });

  it("should fail with insufficient allowance for payment", async () => {
    await erc20.approve(lockModule.address, cost - 10, { from: accounts[0] });
    try {
      await lockModule.unlock(nft.address, tokenId, { from: accounts[0] });
    } catch (error) {
      assert.equal(error.message.includes("Payment transfer failed"), true, "Invalid error message");
      return;
    }
    assert.fail("Expected to fail with insufficient allowance error");
  });

  it("should fail with insufficient balance for payment", async () => {
    await erc20.approve(lockModule.address, cost + 10, { from: accounts[0] });
    try {
      await lockModule.unlock(nft.address, tokenId, { from: accounts[1] });
    } catch (error) {
      assert.equal(error.message.includes("Insufficient balance for payment"), true, "Invalid error message");
      return;
    }
    assert.fail("Expected to fail with insufficient balance error");
  });
});