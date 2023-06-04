// typechain is where your import comes from. turns the contract into typse that can be utilised by eithers.
// specific to factorytype and contracttype represent your original contract. One is used to call functions and one to deploy the chain. 
//types:
import { Contract } from "ethers";
import { foo, foo__factory } "typechain";
import * as hre from "hardhat";

//formula on how to deploy a contract 

describe("foo.sol"), function () {
  //first variable is a representation fo your contract but with a lower case. 
  let foo: Contract; 
  let fooFactory: any;
  //contract type offers you access to functions with in the contract. This is made possible through the ethers library.
  //variablename:type
  //any type works for everything expect deploy.

  // The beforeEach function is a part of Mocha's testing lifecycle hooks. It's a function that is run before each test in your test suite, typically used for setting up the test environment.
  beforeEach(async () => {
    fooFactory = await hre.ethers.getContractFactory("foo");
    foo = await fooFactory.deploy();
    //if there is a contructor put that inside the perenthasis. 
}) 
}



// <script src="https://gist.github.com/Joshua-Jack/d578c02e6cb01374bfd0c8c30d7c6597.js"></script>
// upgradetest.ts
import chaiAsPromised from 'chai-as-promised'
import { expect, use } from 'chai'
import { Contract, ContractFactory, Signer } from 'ethers'
import { ethers } from 'hardhat'
import { ACL } from '../../../typechain'

use(chaiAsPromised)

//all your global variables for testing. 
describe('RewardToken.sol', async function () {
    let accountsAddresses: string[]
    let signers: Signer[]
    let ACL
    let acl: ACL
    let Portfolio: ContractFactory;
    let portfolio: Contract;
    let Reward: ContractFactory;
    let reward: Contract;
    let Factory: ContractFactory;
    let factory: Contract;
    const REVERT_MSG = 'REWARD: Caller does not have proper access'

    //beore statement only runs once.
    before(async () => {
        signers = await ethers.getSigners()
        accountsAddresses = await Promise.all(
            signers.map((signer: Signer) => {
                return signer.getAddress()
            })
        )
    })
    //runs before each it statement. 
    beforeEach(async () => {
        ACL = await ethers.getContractFactory('ACL');
        acl = await ACL.deploy()
        await acl.deployed()
        await acl.initialize(accountsAddresses[1])
        await acl.connect(signers[1]).createRole('MANAGER', accountsAddresses[0])
        await acl.connect(signers[1]).createRole('CORE', accountsAddresses[0])
      Factory = await ethers.getContractFactory('RewardFactory')
      // You can deploy multiple contracts 
        factory = await Factory.deploy();
      factory.initialize(acl.address); //Becuase there is no contructor. 
        Portfolio = await ethers.getContractFactory('Portfolio') //creating the instance with an uppercase. and then using that instance to deploy and call functions 
        portfolio = await Portfolio.deploy()
        await portfolio.initialize('testUrl', acl.address)
        await portfolio.connect(signers[0]).authorizedMint(accountsAddresses[2])
        await factory.createNewReward(
            'TestReward',
            'Test1',
            portfolio.address,
            ['Test Token', 'This is just a test, and only a test', 'www.google.com', 'https://gateway.pinata.cloud/ipfs/QmeAKDXvQyGUdvwRSvazCyj4CYeN6qrcpQr4Lmgf7Cc2UC', 'thumb_image_url_example', 'example_animation_url'],
            [{trait_type: 'Test One', value: 'Value For Test 1'}]
        )

        const rewardAddress = await factory.getRewardAddress('TestReward')

        Reward = await ethers.getContractFactory('RewardToken');
        reward = await Reward.deploy();
        reward = reward.attach(rewardAddress);
    })

    it('Should deploy and initialize properly', async () => {
        expect(reward.address).to.not.equal(ethers.constants.AddressZero); //used a lot to make sure it deployed correctly.
      expect(await reward.portfolioAddress()).to.equal(portfolio.address);
      // when you call a function. foo.add(1, 2)
      // they are passing the parameters as into your function. and .to.equal( what you put in return function)
    })

    it('Factory should revert if name already exists', async () => {
        await expect(factory.createNewReward(
            'TestReward',
            'Test1',
            portfolio.address,
            ['Test Token', 'This is just a test, and only a test', 'www.google.com', 'https://gateway.pinata.cloud/ipfs/QmeAKDXvQyGUdvwRSvazCyj4CYeN6qrcpQr4Lmgf7Cc2UC', 'thumb_image_url_example', 'example_animation_url'],
            [{trait_type: 'Test One', value: 'Value For Test 1'}]
        )).to.be.rejectedWith('REWARD_FACTORY: Reward Already exists')

        await expect(factory.connect(signers[3]).createNewReward(
            'TestReward',
            'Test1',
            portfolio.address,
            ['Test Token', 'This is just a test, and only a test', 'www.google.com', 'https://gateway.pinata.cloud/ipfs/QmeAKDXvQyGUdvwRSvazCyj4CYeN6qrcpQr4Lmgf7Cc2UC', 'thumb_image_url_example', 'example_animation_url'],
            [{trait_type: 'Test One', value: 'Value For Test 1'}]
        )).to.be.rejectedWith('Factory: Caller does not have access')
    })

    it('Should allow proper entity to mint to portfolio ID', async () => {
        await reward.connect(signers[0]).mint(1);
        const rewards = await portfolio.getRewardTokensForPortfolio(1);
        expect(rewards.length).to.equal(1);
        expect(rewards[0].name).to.equal('TestReward');
        expect(rewards[0].contractAddress).to.equal(reward.address);
        expect(rewards[0].tokenId).to.equal(1);
        //Test Revert expect to go wrong. 
        await expect(reward.connect(signers[1]).mint(2)).to.be.rejectedWith(REVERT_MSG)
    })

    it('Should allow proper entity to replace metadata', async () => {
        await reward.connect(signers[0]).mint(1);
        await reward.connect(signers[0]).replaceMetadata(1, ['Replaced metadata', 'This is replaced metadata', 'www.github.io', 'new image data', 'new thumb image', 'new animation url'])
        const metadata = await reward.tokenIdToMetadata(1);
        expect(metadata.name).to.equal('Replaced metadata');
        expect(metadata.external_url).to.equal('www.github.io');
        expect(metadata.image).to.equal('new image data');

        //Test Revert
        await expect(reward.connect(signers[1]).replaceMetadata(1, ['aa', 'aa', 'aa', 'aa', 'aa', 'aa'])).to.be.rejectedWith(REVERT_MSG);

        await expect(reward.connect(signers[0]).replaceMetadata(1, ['', 'aa', 'aa', '', 'aa', 'aa'])).to.be.rejectedWith('RewardToken: Cannot update with no name or image')
    })

    it('Should allow proper entity to update metadata', async () => {
        await reward.connect(signers[0]).mint(1);
        //Update Image
        await reward.connect(signers[0]).updateMetadataValue(1, 0, 'brand spanking new image');
        //Update Thumb
        await reward.connect(signers[0]).updateMetadataValue(1, 1, 'new thumb');
        //Update external URL
        await reward.connect(signers[0]).updateMetadataValue(1, 2, 'New External URL');
        //Update description
        await reward.connect(signers[0]).updateMetadataValue(1, 3, 'New Description');
        //Update animation URL
        await reward.connect(signers[0]).updateMetadataValue(1, 4, 'New Animation URL');
        const m2 = await reward.tokenIdToMetadata(1); //assign the return data from the function inside the variable. 
      // const/let results = foo.add(2, 2); this will assign the return to that variable and if there is no return, it is a transaction hash. //transaction hash to make sure it even goes through: 
      // Let tx = await foo.add(1,2); 
      // Console.log(tx, “function fires”);
        
        expect(m2.image).to.equal('brand spanking new image')
        expect(m2.thumb).to.equal('new thumb');
        expect(m2.external_url).to.equal('New External URL');
        expect(m2.description).to.equal('New Description');
        expect(m2.animation_url).to.equal('New Animation URL');

        //Test Revert
        await expect(reward.connect(signers[2]).updateMetadataValue(1, 0, 'Failure')).to.be.rejectedWith(REVERT_MSG)
    })

    it('Should allow proper entity to replace all attributes', async () => {
        await reward.connect(signers[0]).mint(1);
        await reward.connect(signers[0]).replaceAttributes(1, [{trait_type: 'Replaced', value: 'New Value'}])
        const attributes = await reward.tokenIdToAttributes(1, 0);
        expect(attributes.trait_type).to.equal('Replaced');
        expect(attributes.value).to.equal('New Value');

        //Test Revert
        await expect(reward.connect(signers[2]).replaceAttributes(1, [{trait_type: 'Failure', value: 'Failure'}])).to.be.rejectedWith(REVERT_MSG)
    })

    it('Should allow proper entity to add attribute', async () => {
        await reward.connect(signers[0]).mint(1);
        await reward.connect(signers[0]).updateAttribute(1, 0, {trait_type: 'Added', value: 'Added1'});
        const attributes = await reward.getAllTokenAttributes(1);
        expect(attributes.length).to.equal(2);
        expect(attributes[0].value).to.equal('Value For Test 1');
        expect(attributes[1].value).to.equal('Added1')

        //Test Revert
        await expect(reward.connect(signers[1]).updateAttribute(1, 0, {trait_type: 'Fail', value: 'Fail'})).to.be.rejectedWith(REVERT_MSG);
    })

    it('Should allow proper entity to remove attribute', async () => {
        await reward.connect(signers[0]).mint(1);
        await reward.connect(signers[0]).updateAttribute(1, 2, {trait_type: 'Test One', value: 'Value For Test 1'});
        const attributes = await reward.getAllTokenAttributes(1);
        expect(attributes.length).to.equal(0);

        //Test Revert
        await expect(reward.connect(signers[2]).updateAttribute(1, 2, {trait_type: '', value: ''}))
    })

    it('Should allow proper entity to change attribute', async () => {
        await reward.connect(signers[0]).mint(1);
        await reward.connect(signers[0]).updateAttribute(1, 1, {trait_type: 'Test One', value: 'Changed'});
        const attributes = await reward.getAllTokenAttributes(1);
        expect(attributes[0].value).to.equal('Changed');

        //Test Revert
        await expect(reward.connect(signers[2]).updateAttribute(1, 1, {trait_type: '', value: ''})).to.be.rejectedWith(REVERT_MSG)
    })

    it('Should not allow transfer of token', async () => {
        await reward.connect(signers[0]).mint(1);
        await expect(reward.transferFrom(portfolio.address, accountsAddresses[5], 1)).to.be.rejected;
        //Difficult to test since tokens are owned by the portfolio address....
    })

    it('Should return valid string for tokenURI', async () => {
        await reward.connect(signers[0]).mint(1);
        const url =  await reward.tokenURI(1);
        expect(url).to.equal('data:application/json;base64,eyJuYW1lIjogIlRlc3QgVG9rZW4gIzEiLCAiZGVzY3JpcHRpb24iOiAiVGhpcyBpcyBqdXN0IGEgdGVzdCwgYW5kIG9ubHkgYSB0ZXN0IiwgImltYWdlIjogImh0dHBzOi8vZ2F0ZXdheS5waW5hdGEuY2xvdWQvaXBmcy9RbWVBS0RYdlF5R1VkdndSU3ZhekN5ajRDWWVONnFyY3BRcjRMbWdmN0NjMlVDIiwgInRodW1iIjogInRodW1iX2ltYWdlX3VybF9leGFtcGxlIiwgImV4dGVybmFsX3VybCI6ICJ3d3cuZ29vZ2xlLmNvbSIsICJhbmltYXRpb25fdXJsIjogImV4YW1wbGVfYW5pbWF0aW9uX3VybCIsICJhdHRyaWJ1dGVzIjogW3sidHJhaXRfdHlwZSI6ICJUZXN0IE9uZSIsInZhbHVlIjogIlZhbHVlIEZvciBUZXN0IDEifV19')
    })
})
@ReyesBTC
 
Add heading textAdd bold text, <Cmd+b>Add italic text, <Cmd+i>
Add a quote, <Cmd+Shift+.>Add code, <Cmd+e>Add a link, <Cmd+k>
Add a bulleted list, <Cmd+Shift+8>Add a numbered list, <Cmd+Shift+7>Add a task list, <Cmd+Shift+l>
Directly mention a user or team
Reference an issue or pull request
Leave a comment
No file chosen
Attach files by dragging & dropping, selecting or pasting them.
Styling with Markdown is supported
Footer
© 2023 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
