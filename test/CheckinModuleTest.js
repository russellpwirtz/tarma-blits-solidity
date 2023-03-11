const { expect } = require("chai");

const CheckinModule = artifacts.require("CheckinModule");
const Blit = artifacts.require("Blit");
const Tarma = artifacts.require("Tarma");

contract("CheckinModule", (accounts) => {
  const [owner, user] = accounts;
  let checkinModule;
  let erc20Token;
  let ierc1155Token;

  beforeEach(async () => {
    erc20Token = await Blit.new();
    checkinModule = await CheckinModule.new(erc20Token.address, { from: owner });
    ierc1155Token = await Tarma.new(erc20Token.address, checkinModule.address, checkinModule.address);
    await erc20Token.mint(checkinModule.address, 1000000000000);
  });

  it("should revert if checkin has already been made today", async () => {
    await checkinModule.checkin(ierc1155Token.address, 1, 2, 3, 4, 5, { from: user });

    try {
      await checkinModule.checkin(ierc1155Token.address, 1, 2, 3, 4, 5, { from: user });
    } catch (error) {
      assert.equal(error.message.includes("Already checked in today"), true, "Wasn't already checked in today");
      return;
    }
  });

  // it("should transfer reward to the user", async () => {
  //   const happy = 3;
  //   const disciplined = 2;
  //   const energy = 1;

  //   const reward = await checkinModule.checkin(ierc1155Token.address, 1, 2, happy, disciplined, energy, { from: user });

  //   const expectedReward = happy * 2 + disciplined * 3 + energy;

  //   console.log(reward);

  //   expect(reward.toNumber()).to.equal(expectedReward * 2);

  //   const balance = await erc20Token.balanceOf(user);
  //   expect(balance.toNumber()).to.equal(reward.toNumber());
  // });
});