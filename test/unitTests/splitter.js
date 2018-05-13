import {createWeb3, deployContract, expectThrow} from 'ethworks-solidity';
import splitterJson from '../../build/contracts/Splitter.json';
import StandardTokenJson from '../../build/contracts/StandardTokenMock.json';

import chai from 'chai';
import bnChai from 'bn-chai';
import Web3 from 'web3';

const {expect} = chai;
const web3 = createWeb3(Web3);
chai.use(bnChai(web3.utils.BN));

async function expectError(promise) {
  try {
    await expectThrow(promise);
  } catch (error) {
    return;
  }
  throw Error('Expected error not received');
}

describe('Splitter', () => {
  const {BN} = web3.utils;
  let tokenOwner;
  let splitterOwner;
  let feeCollector;
  let addr1;
  let addr2;
  let addr3;
  let splitter;
  let splitterAddr;
  let tokenContract;
  let tokenAddr;
  let accounts;



  const tokensCap = new BN('100').mul(new BN('10').pow(new BN('18')));
  const someAmount = new BN('1').mul(new BN('10').pow(new BN('18')));
  const finney = new BN('1').mul(new BN('10').pow(new BN('15')));


  const balanceOf = async (client) => new BN(await web3.eth.getBalance(client));


  before(async () => {
    accounts = await web3.eth.getAccounts();
    [tokenOwner, splitterOwner, feeCollector, addr1, addr2, addr3] = accounts;
  });

  beforeEach(async () => {
    const splitterArgs = [[addr1, addr2], feeCollector];
    const tokenArgs = [tokenOwner, tokensCap];
    splitter = await deployContract(web3, splitterJson, tokenOwner, splitterArgs);
    splitterAddr = splitter.options.address;
    tokenContract = await deployContract(web3, StandardTokenJson, tokenOwner, tokenArgs);
    tokenAddr = tokenContract.options.address;
  });

  it('should be deployed successfully', async () => {
    const {address} = splitter.options;
    expect(address).to.not.be.null;

    const {address2} = tokenContract.options;
    expect(address2).to.not.be.null;

  });

  describe('Splitter basic', async() => {

    beforeEach(async() => {
      await tokenContract.methods.approve(splitter.options.address, someAmount).send({ from:tokenOwner });

    });

    it('check allowance', async() => {
      console.log(splitter.options.address);
      const allowance = await tokenContract.methods.allowance(tokenOwner, splitter.options.address).call();
      expect(allowance).to.be.eq.BN(someAmount);

      const balance = await tokenContract.methods.balanceOf(tokenOwner).call();
      expect(balance).to.be.eq.BN(tokensCap);
    });

    it('should be split', async () => {
      console.log(tokenAddr);
      console.log(splitter.options.address);
      console.log(tokenOwner);
      console.log(someAmount);
      //await tokenContract.methods.transferFrom(tokenOwner, tokenContract.options.address, someAmount).send({ from: tokenContract.options.address });
      const allowance = await tokenContract.methods.allowance(tokenOwner, splitter.options.address).call();
      console.log(allowance.toString());
      console.log(someAmount.toString());
      await splitter.methods.split(tokenAddr, someAmount).send({from: tokenOwner, value: finney});
      require(tokenAddress.balanceOf(address(this)) > 0);

    });
  


  });


});
