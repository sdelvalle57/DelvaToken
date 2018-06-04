pragma solidity ^0.4.23;

import "./TokenVesting.sol";
import "./DelvaToken.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./SafeERC20.sol";

contract TokenVestingFactory is Ownable {
    event SetGlobalBalance(uint256 globalBalance);
    event AddPerson(address personAddress, string personName, uint256 amountAllocated);
    event VestingContractCreated(address beneficiary, address contractAddress);
    using SafeMath for uint256;
    using SafeERC20 for DelvaToken;
    
    struct Person {
        string name;
        uint256 amountAllocated; 
        address contractAddress;
    }

    DelvaToken public token;
    uint256 public start = now; 

    uint256 public cliff = 300;
    uint256 public duration = cliff + 600; // 20 secs

    uint256 public globalBalance;
    uint256 public currentBalance;
    
    bool revocable = true;

    address[] public people;
    mapping(address => Person) public mapPerson;    

    function setGlobalBalance(DelvaToken _token) external onlyOwner {
        require(_token != address(0), "Token cant be address(0)");
        require(globalBalance==0, "Global balance should be 0");
        globalBalance = currentBalance = _token.balanceOf(this);
        token = _token;
        emit SetGlobalBalance(globalBalance);
    }

    function addPerson(address _beneficiary, string _name, uint256 _amountAllocated) external onlyOwner {
        require(_amountAllocated > 0);
        require(_beneficiary != address(0));        
        require(globalBalance > 0);
        require(currentBalance >= _amountAllocated);  
        bytes memory name = bytes(mapPerson[_beneficiary].name);
        require(name.length == 0);
        currentBalance = currentBalance.sub(_amountAllocated);      
        Person memory newPerson = Person({
            name: _name,
            amountAllocated: _amountAllocated,
            contractAddress: address(0)
        });
        mapPerson[_beneficiary] = newPerson;
        people.push(_beneficiary);
        emit AddPerson(_beneficiary, _name, _amountAllocated);
        
    }

    function createVestingContract(address _beneficiary) external onlyOwner {
        require(_beneficiary != address(0));
        Person storage person = mapPerson[_beneficiary];
        require(person.contractAddress == 0, "person contract address should be 0");
        require(person.amountAllocated > 0, "person should have an amount allocated");
        require(globalBalance >= person.amountAllocated);
        TokenVesting tokenVesting = new TokenVesting(_beneficiary, cliff, duration, revocable);
        tokenVesting.transferOwnership(owner);
        person.contractAddress = address(tokenVesting);
        uint256 amountAllocated = person.amountAllocated;
        globalBalance = globalBalance.sub(amountAllocated);
        token.safeTransfer(address(tokenVesting), person.amountAllocated);
        emit VestingContractCreated(_beneficiary, address(tokenVesting));
    }

    function refund() external onlyOwner {
        require(currentBalance > 0);
        uint256 _currentBalance = currentBalance;
        currentBalance = 0;
        globalBalance = globalBalance.sub(_currentBalance);
        token.safeTransfer(owner, _currentBalance);
    }

    function getPeople() external view returns (address[]){
        return people;
    }

}