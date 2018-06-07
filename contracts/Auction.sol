pragma solidity ^0.4.18;
contract Auction {
    enum Verificationstate {Init, Verified, Finish}
    struct Bidder {
        uint commit;
        bytes cipher;
        bool paidBack;
        bool existing;
    }
    Verificationstate public state;
    bool withdrawLock;
    mapping(address => Bidder) public bidders;
    address[] public indexs;
    //Auction Parameters
    address public auctioneerAddress;
    uint    public bidEnd;
    uint    public revealEnd;
    uint    public verifyEnd;
    uint    public maxBiddersCount;
    uint    public fairnessFees;
    string  public auctioneerRSAPublicKey; 
    //these values are set when the auctioneer determines the winner
    address public winner;
    uint    public highestBid;   
    uint    public secondHighestBid;
    bool    public testing; 
    //Constructor = Setting all Parameters and auctioneerAddress as well
    function Auction(uint _bidInterval, uint _revealInterval, uint _verifyInterval, uint _maxBiddersCount, uint _fairnessFees, string _auctioneerRSAPublicKey,  bool _testing) public payable {
        require(msg.value == _fairnessFees);
        auctioneerAddress = msg.sender;
        bidEnd = block.number + _bidInterval;
        revealEnd = bidEnd + _revealInterval;
        verifyEnd = revealEnd + _verifyInterval;
        maxBiddersCount = _maxBiddersCount;
        fairnessFees = _fairnessFees;
        auctioneerRSAPublicKey = _auctioneerRSAPublicKey; 
        testing = _testing; 
        state = Verificationstate.Init;
    }
    function Bid(uint commit) public payable {
        require(block.number < bidEnd || testing);   //during bidding Interval  
        require(indexs.length < maxBiddersCount); //available slot    
        require(msg.value == fairnessFees);  //paying fees
        require(bidders[msg.sender].existing == false);
        bidders[msg.sender] = Bidder(commit, "", false,true);
        indexs.push(msg.sender);
    }
    function Reveal(bytes cipher) public {
        require((block.number < revealEnd && block.number > bidEnd) || testing);
        require(bidders[msg.sender].existing); //existing bidder
        bidders[msg.sender].cipher = cipher;
    }
    
    function Verify() public {
        require ((block.number < verifyEnd && block.number > revealEnd)|| testing);        
        require (msg.sender == auctioneerAddress);    
                        
        state = Verificationstate.Verified;
    }
    function Withdraw() public {
        require(state == Verificationstate.Verified || block.number>verifyEnd);
        require(msg.sender != winner);
        require(bidders[msg.sender].paidBack == false && bidders[msg.sender].existing == true);
        require(withdrawLock == false);
        withdrawLock = true;
        msg.sender.transfer(fairnessFees);
        bidders[msg.sender].paidBack = true;
        withdrawLock = false;
    }
    function WinnerPay() public payable {
        require(state == Verificationstate.Verified);
        require(msg.sender == winner);
        require(msg.value >= highestBid - fairnessFees);
    }
    function Destroy() public {
        selfdestruct(auctioneerAddress);
    }
}