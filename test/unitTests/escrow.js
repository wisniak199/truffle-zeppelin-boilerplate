

import EVMRevert from '../helpers/EVMRevert';

const BigNumber = web3.BigNumber;

const EscrowContract = artifacts.require('Escrow');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('Escrow', function ([seller, buyer]) {
    //let escrow;
    const price = new BigNumber(2);
    const doublePrice = price.mul(new BigNumber('2'));


    beforeEach(async function () {
      this.escrow = await EscrowContract.new({value: doublePrice, from:seller});
      console.log(this.escrow.address);
    });

    describe('Escrow', async () => {
        it('should be properly created', async () => {
            console.log(this.escrow);
            const actualPrice = await this.escrow.price().call();
            expect(actualPrice).to.eq.BigNumber(price);
        });

        it('Should not allow to create with an odd amount', async () => {

            await EscrowContract.new({from: buyer, value:new BigNumber('11')})
                .should.be.rejectedWith(EVMRevert);
        });

        it('Should not allow to confirm purchase without sending ether', async () => {

          console.log(this.escrow.address);
           await this.escrow.confirmPurchase().send({
                from: seller,
                value: 0
            }).should.be.rejectedWith(EVMRevert);
        });
    });


});
