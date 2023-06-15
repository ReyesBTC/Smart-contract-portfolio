import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";

describe("SimpleStorage, contract", function () {
  let SimpleStorage: ContractFactory;
  let simpleStorage: Contract;
  let owner: any;
  let addr1: any;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    SimpleStorage = await ethers.getContractFactory("SimpleStorage");
    simpleStorage = await SimpleStorage.deploy();
    await simpleStorage.deployed();
  });

  it("Should deploy correctly", async function () {
    // Contract addresses in Ethereum are 42 characters long (including the '0x' prefix)
    expect(simpleStorage.address).to.be.a("string").that.has.length(42);
  });

  it("Get function should return 0", async function () {
    const initialBalance = await simpleStorage.getInfo();
    expect(initialBalance).to.equal("default");
  });

  // it("Get Info Correctly", async function () {
  //   const initialInfo = await simpleStorage.getInfo();
  //   expect(initialInfo).to.equal(0);
  // });

  it("Set info to test", async function () {
    await simpleStorage.addInfo("test"); // This function doesnt return a string. It returns the transaction receipt which then is stored in the setInfo constant.. That is why I cant store it in a variable.
    const getInfo = await simpleStorage.getInfo();
    expect(getInfo).to.equal("test");
  });
});
