pragma solidity ^0.4.21;
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract SafeEscrow is Ownable {

    enum State {
        CREATED,
        IN_PROGRESS,
        RESOLVED
    }

    State public state;
    uint256 public price;
    address public buyer;

    event EscrowCreated(address indexed seller);
    event EscrowConfirmedPurchase(address indexed buyer);
    event EscrowConfirmedReceived(address indexed buyer);


    function SafeEscrow(uint256 _price) public payable Ownable() {
        require(msg.value > 0);
        // In theory we could not check if the amount is even,
        // because checking it is more expensive than 1 wei that could be lost
        // (and it actually never lost because we always destroy smart contract
        // at the end) but if the seller creates contract sending odd price,
        // they probably have made a mistake.
        require(_price * 2 == msg.value);

        price = _price;
        state = State.CREATED;
        emit EscrowCreated(owner);
    }

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    modifier onlyBuyer {
        require(msg.sender == buyer);
        _;
    }

    function cancel() public onlyOwner inState(State.CREATED) {
        selfdestruct(msg.sender);
    }

    function confirmPurchase() payable public inState(State.CREATED) {
        require(msg.value == price * 2);
        state = State.IN_PROGRESS;
        buyer = msg.sender;
        emit EscrowConfirmedPurchase(msg.sender);
    }

    function confirmReceived() public onlyBuyer inState(State.IN_PROGRESS) {
        state = State.RESOLVED;
        // We could use withdraw technique here, but it doesn't make sense
        // for the buyer to provide such function, because they can acheive
        // the same result by not confirming.
        buyer.transfer(price);
        // Forward rest of the money.
        selfdestruct(owner);

        emit EscrowConfirmedReceived(msg.sender);
    }
}

// DEPRECATED: please use SafeEscrow instead as it is harder to create your
// escrow with wrong amount
contract Escrow is SafeEscrow {
    function Escrow() public payable SafeEscrow(msg.value / 2) {
    }
}
