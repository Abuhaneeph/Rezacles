// This is an example test file. Hardhat will run every *.js file in `test/`,
// so feel free to add new ones.

// Hardhat tests are normally written with Mocha and Chai.

// We import Chai to use its asserting functions here.
const { expect } = require("chai");

// We use `loadFixture` to share common setups (or fixtures) between tests.
// Using this simplifies your tests and makes them run faster, by taking
// advantage of Hardhat Network's snapshot functionality.
const { time, loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

// `describe` is a Mocha function that allows you to organize your tests.
// Having your tests organized makes debugging them easier. All Mocha
// functions are available in the global scope.
//
// `describe` receives the name of a section of your test suite, and a
// callback. The callback must define the tests of that section. This callback
// can't be an async function.
describe("Rezacles contract", function () {
  // We define a fixture to reuse the same setup in every test. We use
  // loadFixture to run this setup once, snapshot that state, and reset Hardhat
  // Network to that snapshopt in every test.
  async function deployRezaclesFixture() {
    // Get the ContractFactory and Signers here.
    const UPGRADE_TIME=11 * 60;  //Time to Upgrade Level

    const unlockTime = (await time.latest()) + UPGRADE_TIME;

 
    const RezaclesFactory = await ethers.getContractFactory("Rezacles");
   
    const [deployer,addr1, addr2] = await ethers.getSigners();

    // To deploy our contract, we just have to call Token.deploy() and await
    // its deployed() method, which happens onces its transaction has been
    // mined.
    
    
    const Rezacles=await RezaclesFactory.deploy(deployer.address,ethers.utils.parseEther("1"));
    await Rezacles.deployed() 
    console.log(Rezacles.address)
   
    const UPLINE_BONUS_FEE=BigInt(ethers.utils.parseEther("1")/5);
  
    // Fixtures can return anything you consider useful for your tests
    return { Rezacles,unlockTime,UPLINE_BONUS_FEE, deployer, addr1, addr2 };
  }

  // You can nest describe calls to create subsections.
  describe("Rezacles Contract", function () {
    // `it` is another Mocha function. This is the one you use to define each
    // of your tests. It receives the test name, and a callback function.
    //
    // If the callback function is async, Mocha will `await` it.
   
      // We use loadFixture to setup our environment, and then assert that
      // things went well
     
      
      // `expect` receives a value and wraps it in an assertion object. These
      // objects have a lot of utility methods to assert values.

      // This test expects the owner variable stored in the contract to be
      // equal to our Signer's owner.
   


    it("Assert the Contract Owners Address,Upline Bonus and Staking Fee", async function () {
    
      const { Rezacles, deployer} = await loadFixture(deployRezaclesFixture);

      const BONUS_FEE=BigInt(ethers.utils.parseEther("1")/5);
      expect(await Rezacles.GENESIS_UPLINE()).to.equal(deployer.address);
     expect(await Rezacles.uplineBonus()).to.equal(BONUS_FEE);
      expect(await Rezacles.stakingFee()).to.equal(ethers.utils.parseEther("1"));
    
    });


    it("Assert REZTOKEN Balance should be 1000 after upgrading ", async function () {
    
      const {Rezacles,unlockTime,addr1} = await loadFixture(deployRezaclesFixture);

     await Rezacles.connect(addr1).registerWithGenesisId({value:ethers.utils.parseEther("1")});
     await time.increaseTo(unlockTime);
     const USER_ID=await Rezacles.User_ID(addr1.address);
     await Rezacles.connect(addr1).upgradeLevel(USER_ID);
     expect(await Rezacles.balanceOf(addr1.address)).to.equal(1000);
    
    
    });
   
    it("Assert Contract earned fee to equal upline bonus fee after downline upgrade ", async function () {
    
      const {Rezacles,unlockTime,UPLINE_BONUS_FEE,addr1} = await loadFixture(deployRezaclesFixture);

     await Rezacles.connect(addr1).registerWithGenesisId({value:ethers.utils.parseEther("1")});
     await time.increaseTo(unlockTime);
     const USER_ID=await Rezacles.User_ID(addr1.address);
     await Rezacles.connect(addr1).upgradeLevel(USER_ID); 
     expect(await Rezacles.getContractEarnedBonus()).to.equal(UPLINE_BONUS_FEE);
    });


    it("Assert First generation Upline Balance to equal upline bonus fee after downline upgrade ", async function () {
    
      const {Rezacles,unlockTime,UPLINE_BONUS_FEE,addr1,addr2} = await loadFixture(deployRezaclesFixture);

     await Rezacles.connect(addr1).registerWithGenesisId({value:ethers.utils.parseEther("1")});
     const USER_ID_ONE=await Rezacles.User_ID(addr1.address);
     await Rezacles.connect(addr2).registerWithReferralId(USER_ID_ONE,{value:ethers.utils.parseEther("1")});
     const USER_ID_TWO=await Rezacles.User_ID(addr2.address);
     await time.increaseTo(unlockTime);
     await Rezacles.connect(addr2).upgradeLevel(USER_ID_TWO); 
     expect(await Rezacles.Balance(addr1.address)).to.equal(UPLINE_BONUS_FEE);
    });

    it("Assert the Deployer Account Balance should be equal to the earned upline fee from the Contract", async function () {
    
      const {Rezacles,unlockTime,UPLINE_BONUS_FEE,addr1} = await loadFixture(deployRezaclesFixture);

     await Rezacles.connect(addr1).registerWithGenesisId({value:ethers.utils.parseEther("1")});
     const USER_ID_ONE=await Rezacles.User_ID(addr1.address);
     await time.increaseTo(unlockTime);
     await Rezacles.connect(addr1).upgradeLevel(USER_ID_ONE); 
     expect(await Rezacles.getContractEarnedBonus()).to.equal(UPLINE_BONUS_FEE);
    });


   it("Should revert when its not yet Time to upgrade Level",async function(){
    const {Rezacles,addr1} = await loadFixture(deployRezaclesFixture);
    await Rezacles.connect(addr1).registerWithGenesisId({value:ethers.utils.parseEther("1")});
    const USER_ID_ONE=await Rezacles.User_ID(addr1.address);
    await expect(Rezacles.connect(addr1).upgradeLevel(USER_ID_ONE)).to.be.revertedWith("Not yet Time to upgrade Level")
  }) 

  it("Should not Revert When its Time to Upgrade Level",async function(){
    const {Rezacles,unlockTime,addr1} = await loadFixture(deployRezaclesFixture);
    await Rezacles.connect(addr1).registerWithGenesisId({value:ethers.utils.parseEther("1")});
    const USER_ID_ONE=await Rezacles.User_ID(addr1.address);
    await time.increaseTo(unlockTime);
    await expect(Rezacles.connect(addr1).upgradeLevel(USER_ID_ONE)).not.to.be.reverted;
  }) 

  it("Should emit an event on Registration",async function(){
    const {Rezacles,addr2} = await loadFixture(deployRezaclesFixture);
    await expect(Rezacles.connect(addr2).registerWithGenesisId({value:ethers.utils.parseEther("1")})).to.emit(Rezacles, "Registered").withArgs(addr2.address);
  }) 



  });

});