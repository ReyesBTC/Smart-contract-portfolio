import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";

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
    expect(ethers.utils.isAddress(digitalVendingMachine.address)).to.be.true;
    //will test both of these utility functions to see if they both work.
    expect(digitalVendingMachine.address).to.be.a("string").that.has.length(42);
  });

  it("Test that deployer is owner", async function () {
    expect(await digitalVendingMachine.owner()).to.equal(deployer.address);
  });

  it("Log Owner", async function () {
    console.log("Contract Owner Address:", owner);
  });

  
});
