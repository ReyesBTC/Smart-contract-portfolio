import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";
import chai from "chai";
import chaiAsPromised from "chai-as-promised";

chai.use(chaiAsPromised);

describe("Ecommerce", function () {
  let Ecommerce: ContractFactory;
  let ecommerce: Contract;
  let owner: any;
  let addr1: any;
  let addr2: any;
  let addr3: any;

  beforeEach(async function () {
    Ecommerce = await ethers.getContractFactory("Ecommerce");
    ecommerce = await Ecommerce.deploy();
    await ecommerce.deployed();

    [owner, addr1, addr2, addr3] = await ethers.getSigners();
  });

  it("should register a new seller correctly", async function () {
    const sellerInfo = {
      userName: "seller1",
      sellerId: addr1.address,
      age: 19,
      joined: Date.now(),
      active: true,
      sellerProductList: [],
    };
    await ecommerce.connect(addr1).registerSeller(sellerInfo);

    const registeredSeller = await ecommerce.SellerRegistry(addr1.address);

    expect(registeredSeller.userName).to.equal(sellerInfo.userName);
    expect(registeredSeller.age).to.equal(sellerInfo.age);
    expect(registeredSeller.active).to.equal(sellerInfo.active);
    expect(registeredSeller.sellerProductList.length).to.equal(
      sellerInfo.sellerProductList.length
    );
  });

  it("should not allow a user under 18 to register", async function () {
    const sellerInfo = {
      userName: "seller2",
      sellerId: addr2.address,
      age: 17,
      joined: Date.now(),
      active: true,
      sellerProductList: [],
    };
    await expect(
      ecommerce.connect(addr2).registerSeller(sellerInfo)
    ).to.be.rejectedWith("Must be 18 years or older");
  });

  it("should not allow a user to register twice", async function () {
    const sellerInfo = {
      userName: "seller3",
      sellerId: addr3.address,
      age: 22,
      joined: Date.now(),
      active: true,
      sellerProductList: [],
    };
    await ecommerce.connect(addr3).registerSeller(sellerInfo);
    await expect(ecommerce.connect(addr3).registerSeller(sellerInfo)).to.be
      .rejected;
  });
});
