import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";
import chai from "chai";
import chaiAsPromised from "chai-as-promised";

chai.use(chaiAsPromised);

describe("DigitalVendingMachine", function () {
  let DigitalVendingMachine: ContractFactory;
  let digitalVendingMachine: Contract;
  let deployer: any;
  let addy1: any;

  beforeEach(async function () {
    DigitalVendingMachine = await ethers.getContractFactory(
      "DigitalVendingMachine"
    );
    [deployer, addy1] = await ethers.getSigners();

    digitalVendingMachine = await DigitalVendingMachine.deploy();
    await digitalVendingMachine.deployed();
  });

  it("Should deploy the smart contract properly", async function () {
    expect(ethers.utils.isAddress(digitalVendingMachine.address)).to.be.true; //will test both of these utility functions to see if they both work.
    expect(digitalVendingMachine.address).to.be.a("string").that.has.length(42);
  });

  it("Test that deployer is owner", async function () {
    expect(await digitalVendingMachine.owner()).to.equal(deployer.address);
  });

  it("Should mint 100 sodas on deployment", async function () {
    expect(
      await digitalVendingMachine.sodaBalances(digitalVendingMachine.address)
    ).to.equal(100);
  });

  it("Should Allow for owner to add 100 sodas", async function () {
    await digitalVendingMachine.connect(deployer).addSodas(100);
    expect(
      await digitalVendingMachine.sodaBalances(digitalVendingMachine.address)
    ).to.equal(200);
  });

  it("Should not allow for non-owner to add sodas", async function () {
    const addSodasPromise = digitalVendingMachine.connect(addy1).addSodas(100);
    await expect(addSodasPromise).to.be.rejectedWith(
      "Only owner can call this function"
    );
  });

  it("Should not let random address purchase Sodas with insufficient funds", async function () {
    await expect(
      digitalVendingMachine
        .connect(addy1)
        .purchaseSoda(1, { value: ethers.utils.parseEther("0.5") })
    ).to.be.revertedWith("You must pay at least 1 Ether per soda");
    // You should wait for the promise to be rejected before asserting that the exception was thrown. Here is how you can do this: Using the require statement in Solidity which triggers a revert operation (an exception) for a certain condition. the chai library, which is often used for testing Ethereum contracts, includes the revertedWith function. This function allows you to test that a transaction is reverted and produces a specific revert reason.
  });

  it("Should let random address purchase Sodas with sufficient funds", async function () {
    await digitalVendingMachine
      .connect(addy1)
      .purchaseSoda(1, { value: ethers.utils.parseEther("1") });
    expect(await digitalVendingMachine.sodaBalances(addy1.address)).to.equal(1);
  });
});
