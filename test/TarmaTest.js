const { expect } = require("chai");

const CheckinModule = artifacts.require("CheckinModule");
const LockModule = artifacts.require("LockModule");
const Blit = artifacts.require("Blit");
const Tarma = artifacts.require("Tarma");
const truffleAssert = require('truffle-assert');

contract("Tarma", (accounts) => {
  const [owner, user] = accounts;
  let checkinModule;
  let lockModule;
  let blit;
  let tarma;

  beforeEach(async () => {
    blit = await Blit.new({ from: owner });
    checkinModule = await CheckinModule.new(blit.address, 0, { from: owner });
    lockModule = await LockModule.new({ from: owner });
    tarma = await Tarma.new(blit.address, lockModule.address, checkinModule.address, { from: owner });

    await blit.mint(checkinModule.address, 1000 * 10 ^ 18);
    await tarma.createTarma("buddyboy", 0, 1, user, { from: owner });
  });

  it("should pass", async () => {
    assert(true);
  });

  it("should transfer initial reward to the user", async () => {
    const tokenIndex = 0;
    const expectedReward = 100; // initial reward
    const reward = await tarma.checkin(tokenIndex, { from: user });

    truffleAssert.eventEmitted(reward, 'TarmaCheckedIn', (args) => {
      return args.amountEarned == expectedReward
        && args.owner == user
        && args.tokenId == 1;
    });
  });

  it("should transfer additional rewards to the user", async () => {
    const tokenIndex = 0;
    const tokenId = 1;
    const happy = 3;
    const disciplined = 2;
    const energy = 1;
    const multiplier = 2;

    // initial checkin
    let expectedReward = 100;
    let reward = await tarma.checkin(tokenIndex, { from: user });
    truffleAssert.eventEmitted(reward, 'TarmaCheckedIn', (args) => {
      return args.amountEarned == expectedReward
        && args.owner == user
        && args.tokenId == tokenId;
    });

    // second checkin
    expectedReward = 6;
    reward = await tarma.checkin(tokenIndex, { from: user });
    truffleAssert.eventEmitted(reward, 'TarmaCheckedIn', (args) => {
      return args.amountEarned == expectedReward
        && args.owner == user
        && args.tokenId == tokenId;
    });
  });
});
