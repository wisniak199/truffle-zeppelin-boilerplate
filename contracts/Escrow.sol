pragma solidity ^0.4.21;
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract Escrow is Ownable {
    uint256 public price;

    enum State {
        CREATED,
        IN_PROGRESS,
        RESOLVED
    }

    State public state;
    uint256 public amount;
    address public buyer;

    event ConfirmedPurchase(address indexed buyer);
    event ConfirmedReceived(address indexed buyer);


    function Escrow() public payable Ownable() {
        require(msg.value > 0);
        // We don't check if the amount is even, because checking it
        // is more expensive than 1 wei that could be lost, and it is never
        // lost because we always destroy smart contract at the end.
        amount = msg.value / 2;
        state = State.CREATED;
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
        require(msg.value == amount * 2);
        state = State.IN_PROGRESS;
        buyer = msg.sender;
        emit EscrowConfirmed(msg.sender);
    }

    function confirmReceived() public onlyBuyer inState(State.IN_PROGRESS) {
        state = State.RESOLVED;
        // We could use withdraw technique here, but it doesn't make sense
        // for the buyer to provide such function, because they can acheive
        // the same result by not confirming.
        buyer.transfer(amount);
        // Forward rest of the money.
        selfdestruct(owner);

        emit ConfirmedReceived(msg.sender);
    }
}