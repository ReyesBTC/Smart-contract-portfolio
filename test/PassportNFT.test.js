// Import the necessary libraries. `expect` is used for assertions (checking expected values)
// `ethers` is used for Ethereum related operations, such as creating contracts.
const { expect } = require("chai");
const { ethers } = require("hardhat");

// The `describe` function is used to group tests. Each test file can have multiple `describe` groups.
// Here, we're creating a group for all tests related to the PassportNFT and Rewards contracts.
describe("PassportNFT and Rewards", function () {
  // These variables will be shared among all tests in this `describe` group.
  let owner;
  let addr1;
  let PassportNFT;
  let Rewards;
  let passportNFT;
  let rewards;

  // The `beforeEach` function is run before each test within the same `describe` group.
  // We use it to deploy our contracts and prepare the testing environment before each test.
  beforeEach(async function () {
    // Get the list of addresses available for testing. The first account is typically the deployer/owner.
    [owner, addr1] = await ethers.getSigners();

    // We retrieve the PassportNFT contract factory and deploy a new instance of the contract.
    PassportNFT = await ethers.getContractFactory("PassportNFT");
    passportNFT = await PassportNFT.deploy();
    await passportNFT.deployed();

    // We retrieve the Rewards contract factory and deploy a new instance of the contract, passing the address of the previously deployed PassportNFT.
    Rewards = await ethers.getContractFactory("Rewards");
    rewards = await Rewards.deploy(passportNFT.address);
    await rewards.deployed();
  });

  it("Should return the right name and symbol", async function () {
    expect(await passportNFT.name()).to.equal("PassportNFT");
    expect(await passportNFT.symbol()).to.equal("PSPT");
    // expect(await rewards.name()).to.equal("Rewards");
  });

  // We create a new group of tests specifically for minting functionality.
  describe("Minting", function () {
    // The `it` function defines a single test. The first parameter is the test description.
    it("Should mint a new PassportNFT", async function () {
      // We call the `mint` function to mint a new NFT for addr1.
      await passportNFT.safeMint(addr1.address);
      // We then check if the balance of addr1 has increased by 1.
      expect(await passportNFT.balanceOf(addr1.address)).to.equal(1);
    });

    it("Should mint and send rewards", async function () {
      // We mint and send a reward to addr1. The `connect(owner)` part is used to specify the caller of the function.
      await rewards.connect(owner).mintAndSendReward(addr1.address, 1, 10, 1);
      // We then check if the balance of the reward for addr1 is 10.
      expect(await rewards.balanceOf(addr1.address, 1)).to.equal(10);
    });
  });

  // More tests...
});
