//SPDX-License-Identifier: Unlicensed
import "@openzeppelin/contracts/access/Ownable.sol";
pragma solidity ^0.8.0;

contract KnowledgeDance is Ownable{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(uint256 => address) private _owners;
    event Transfer (address indexed from, address indexed to, uint256 value); 
    event Approval(address indexed owner, address indexed spender, uint256 value);
    string public TokenName;
    string public TokenSymbol;
    uint public totalSupply = 0;
    uint public maximumSupply = 1000000*10**6;
    uint mintableTokens = 500000;
    uint mintedTokens = 0;
    uint256 public fee = 0.001 ether; //0.001ether per token since 1 ether for 1000 tokens
    modifier sufficientBalance(address _spender, uint _value){
        require(_value <= _balances[_spender] , "Insufficient Balance.");
        _;
    }

    modifier sufficientApproval(address _owner, address _spender, uint _value){
        require(_value <= _allowances[_owner][_spender], "Insufficient allowance given to this user.");
        _;
    }

    modifier validAddress(address _address){
        require(_address != address(0), "Invalid address");
        _;
    }
    constructor(string memory name, string memory symbol){
        name = "Knowledge Dance";
        TokenName = name;
        symbol = "KD";
        TokenSymbol = symbol;
        _balances[msg.sender] = maximumSupply;
    }

    function decimal() public view virtual returns(uint8) {
        return 6;
    }

    function balanceOf(address account) public view virtual returns(uint256){
        return _balances[account];
    }

    function allowance(address account, address spender) public view virtual returns(uint256 remaining){
       return _allowances[account][spender];
    }
    function approve (address spender, uint256 amount) public validAddress(spender) returns(bool){
        address owner = msg.sender;
        _allowances[owner][spender] += amount; //increment the amount of allowance given to spender each time approve function is called in the same spender address
        emit Approval(owner, spender, amount);

        return true;
    }
    function transfer(address to, uint256 amount) public virtual sufficientBalance(msg.sender, amount) validAddress(to) returns(bool){
        address owner = msg.sender;
        _balances[owner] = _balances[owner] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer (owner, to , amount);

        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual sufficientBalance(from, amount) sufficientApproval(msg.sender, from, amount) validAddress(to) returns (bool){
        _allowances[msg.sender][from] = _allowances[msg.sender][from] - amount;
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to , amount);

        return true;
    }

   function buyToken(address to, uint256 amount) public payable {
        uint256 price = amount * fee;
        require(mintedTokens < mintableTokens , "Not enough mintable tokens available");
        require(msg.value >= price, "Insufficienct Ether");
        _buyToken(to, amount);
    }

    function _buyToken(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        
        _beforeTokenTransfer(address(0), account, amount);

        totalSupply += amount*10**6;
        maximumSupply += amount*10**6;
        mintedTokens += amount*10**6;
        _balances[account] += amount*10**6;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    //Withdraw the ether paid by buyers for tokens to owner's address.
    function withdraw() public onlyOwner{
        require(address(this).balance > 0, "0 Ether available for withdrawal");
        payable(owner()).transfer(address(this).balance);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}