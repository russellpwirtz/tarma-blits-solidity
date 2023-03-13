const { expect } = require("chai");

const CheckinModule = artifacts.require("CheckinModule");
const Blit = artifacts.require("Blit");
const ERC1155Token = artifacts.require("ERC1155Token");
const truffleAssert = require('truffle-assert');

contract("CheckinModule", (accounts) => {
  const [owner, user] = accounts;
  let dailyCheckinModule;
  let instantCheckinModule;
  let erc20Token;
  let erc1155Token;
  let dailyCheckinCooldown = 86400;

  beforeEach(async () => {
    erc20Token = await Blit.new();

    dailyCheckinModule = await CheckinModule.new(erc20Token.address, dailyCheckinCooldown, { from: owner });
    instantCheckinModule = await CheckinModule.new(erc20Token.address, 0, { from: owner });

    erc1155Token = await ERC1155Token.new();
    await erc20Token.mint(dailyCheckinModule.address, 1000 * 10 ^ 18);
    await erc20Token.mint(instantCheckinModule.address, 1000 * 10 ^ 18);
    await erc1155Token.mint(user, 0, { from: owner });
  });

  it("should revert if checkin has already been made today", async () => {
    await dailyCheckinModule.checkin(erc1155Token.address, 0, 2, 3, 4, 5, { from: user });

    try {
      await dailyCheckinModule.checkin(erc1155Token.address, 0, 2, 3, 4, 5, { from: user });
    } catch (error) {
      assert.equal(error.message.includes("Already checked in today"), true, "Wasn't already checked in today");
      return;
    }
  });

  it("should transfer initial reward to the user", async () => {
    const tokenId = 0;
    const happy = 3;
    const disciplined = 2;
    const energy = 1;
    const multiplier = 2;

    const expectedReward = 100; // initial reward
    const reward = await dailyCheckinModule.checkin(erc1155Token.address, tokenId, multiplier, happy, disciplined, energy, { from: user });
    truffleAssert.eventEmitted(reward, 'CheckedIn', (args) => {
      return args.amountEarned == expectedReward
        && args.address == user.address
        && args.tokenId == tokenId;
    });
  });

  it("should transfer additional rewards to the user", async () => {
    const tokenId = 0;
    const happy = 3;
    const disciplined = 2;
    const energy = 1;
    const multiplier = 2;

    // initial checkin
    let expectedReward = 100;
    let reward = await instantCheckinModule.checkin(erc1155Token.address, tokenId, multiplier, happy, disciplined, energy, { from: user });
    truffleAssert.eventEmitted(reward, 'CheckedIn', (args) => {
      return args.amountEarned == expectedReward
        && args.address == user.address
        && args.tokenId == tokenId;
    });

    // second checkin
    expectedReward = (happy * 2 + disciplined * 3 + energy) * multiplier;
    reward = await instantCheckinModule.checkin(erc1155Token.address, tokenId, multiplier, happy, disciplined, energy, { from: user });
    truffleAssert.eventEmitted(reward, 'CheckedIn', (args) => {
      return args.amountEarned == expectedReward
        && args.address == user.address
        && args.tokenId == tokenId;
    });
  });
});
