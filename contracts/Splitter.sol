pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Splitter {
    using SafeMath for uint256;

    address public feeCollector;
    address[] public beneficiaries;
    uint256 public constant FEE = 1 finney;

    event FeeCollected(address indexed collector, uint amount);
    event TokensSplitted(ERC20 indexed token, address indexed sender, uint tokenAmount);

    constructor(address[] _beneficiaries, address _feeCollector) public {
        feeCollector = _feeCollector;
        beneficiaries = _beneficiaries;
    }

    modifier checkBeneficiaries(address[] _beneficiaries) {
        require(_beneficiaries.length > 1);
        for (uint i = 0; i < _beneficiaries.length; i++) {
            address beneficiarie = _beneficiaries[i];
            require(beneficiarie != address(0));
        }
        _;
    }

    modifier feeSend() {
        require(msg.value == FEE);
        _;
    }

    function split(ERC20 tokenAddress, uint tokenAmount) public payable feeSend {
        emit TokensSplitted(tokenAddress, msg.sender, tokenAmount);
        require(tokenAddress.transferFrom(msg.sender, address(this), tokenAmount));

        uint256 splittedAmount = tokenAmount.div(beneficiaries.length);
        uint256 remainderAmount = tokenAmount.sub(splittedAmount);

        /*require(tokenAddress.transfer(beneficiaries[0],
            splittedAmount.add(remainderAmount)));

        // Split rest.
        for (uint i = 1; i < beneficiaries.length; i++) {
            require(tokenAddress.transfer(beneficiaries[i], splittedAmount));
        }*/
    }

    modifier onlyFeeCollector() {
        require(msg.sender == feeCollector);
        _;
    }

    function withdrawFee() public onlyFeeCollector {
        withdrawFee(address(this).balance);
    }

    function withdrawFee(uint256 amount) public onlyFeeCollector {
        emit FeeCollected(feeCollector, amount);
        feeCollector.transfer(amount);
    }

}