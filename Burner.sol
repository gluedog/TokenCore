/* The Burner v0.2, pre-release.
*  ~by gluedog
*
* The Burner is Billionaire Token's version of a "Faucet" - an evil, twisted Faucet. 
* Just like a Faucet, people can use it to get some extra coins. 
* Unlike a Faucet, the Burner will also burn coins and reduce the maximum supply in the process of giving people extra coins.
*/

pragma solidity ^0.4.8;

contract XBL_ERC20Wrapper
{
    function transferFrom(address from, address to, uint value) returns (bool success);
    function transfer(address _to, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    function burn(uint256 _value) returns (bool success);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function totalSupply() constant returns (uint256 total_supply);
    function burnFrom(address _from, uint256 _value) returns (bool success);
}

contract XBL_RaffleWrapper
{
    function getLastWeekStake(address user_addr) public returns (uint256 last_week_stake);
}

contract TheBurner
{
    bool DEBUG = true;

    XBL_ERC20Wrapper ERC20_CALLS;
    XBL_RaffleWrapper RAFFLE_CALLS;

    uint8 public extra_bonus; /* The percentage of extra coins that the burner will reward people for. */

    address public burner_addr;
    address public raffle_addr;
    address owner_addr;
    address XBLContract_addr;

    function TheBurner()
    {
        XBLContract_addr = 0x49AeC0752E68D0282Db544C677f6BA407BA17ED7;
        raffle_addr = 0x0; /* Do we have a raffle address? */

        if (DEBUG == false)
        {
            ERC20_CALLS = XBL_ERC20Wrapper(XBLContract_addr);
            RAFFLE_CALLS = XBL_RaffleWrapper(raffle_addr);
        }

        extra_bonus = 5; /* 5% reward for burning your own coins, provided the burner has enough. */
        burner_addr = address(this);
        owner_addr = msg.sender;
    }

    modifier onlyOwner() 
    {
        require (msg.sender == owner_addr);
        _;
    }

    function setRaffleAddress(address _raffle_addr) onlyOwner
    {
        /* Allows the owner to set the raffle address */
        raffle_addr = _raffle_addr;
        RAFFLE_CALLS = XBL_RaffleWrapper(raffle_addr);
    }

    function getPercent(uint8 percent, uint256 number) returns (uint256 result)
    {
        return number * percent / 100;
    }

    function registerBurn(uint256 tokens_registered) returns (int8 registerBurn_STATUS)
    {
        /* This will just throw if bad input */
        address user_addr = msg.sender;

        uint256 actual_allowance = ERC20_CALLS.allowance(user_addr, burner_addr);
        require (actual_allowance >= tokens_registered); // Is the user bullshitting us?

        uint256 own_supply = ERC20_CALLS.balanceOf(burner_addr);
        uint256 eligible_reward = tokens_registered + getPercent(extra_bonus, tokens_registered);
        require (eligible_reward <= own_supply); // Do we have enough tokens to give out?

        uint256 prev_week_stake = RAFFLE_CALLS.getLastWeekStake(user_addr);
        require (tokens_registered <= prev_week_stake); // Did he have enough tickets in last week's Raffle ?

        /* Reaching this point means we can give out the reward */

        /* Burn their tokens and give them their reward */
        ERC20_CALLS.burnFrom(user_addr, tokens_registered);
        ERC20_CALLS.transfer(user_addr, eligible_reward);
    }


    /* <<<--- Debug ONLY functions. These will be removed from the final version --->>> */
    /* <<<--- Debug ONLY functions. These will be removed from the final version --->>> */
    /* <<<--- Debug ONLY functions. These will be removed from the final version --->>> */

    function setXBLAddr(address _XBLContract_addr) public onlyOwner
    {
        /* Debugging purposes. This will be hardcoded in the original version. */
        XBLContract_addr = _XBLContract_addr;
        ERC20_CALLS = XBL_ERC20Wrapper(XBLContract_addr);
    }
}
