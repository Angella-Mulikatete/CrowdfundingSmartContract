// SPDX-License-Identifier: MIT
pragma solidity >=0.3.2 <0.9.0;

contract CrowdFunding{

    struct Campaign{
        // uint256 id;
        string title;
        string description;
        address payable benefactor;
        uint256 goal;
        uint deadline;
        uint amountRaised;
        bool ended;
    }
    
       address public owner;
       uint public campaignCount;

    //    mapping(uint => Campaign) public campaigns;

    Campaign[] public campaigns;




    event CampaignCreated(uint256 id, string title, address benefactor, uint goal, uint deadline);
    event DonationReceived(uint campaignId, address donor, uint amount);
    event CampaignEnded(uint campaignId);

    constructor() {
        owner = msg.sender;
    }

        modifier onlyOwner {
            require(msg.sender == owner, "Only the contract owner can perform this action");
            _;
        }

    // Modifier to check if the campaign's deadline has passed
        modifier onlyBeforeDeadline(uint _campaignId) {
              require(block.timestamp < campaigns[_campaignId].deadline, "Campaign deadline has passed");
          _;
        }

    // Modifier to check if the campaign has passed
        modifier onlyAfterDeadline(uint _campaignId) {
            require(block.timestamp >= campaigns[_campaignId].deadline, "Campaign deadline has not yet passed");
            require(!campaigns[_campaignId].ended, "Campaign has already ended");
            _;
        }
    

    //creating a new campaign

    function createCampaign(string memory _title, string memory _description, address payable _benefactor, uint _goal, uint _durationInSeconds)
             public payable onlyOwner{
            require(_goal > 0, "Goal must be greater than zero");
            require(_durationInSeconds > 0, "Duration must be greater than zero");

            uint _deadline = block.timestamp + _durationInSeconds;

            Campaign memory newCampaign = Campaign({
                // id: campaigns[msg.sender].length,
                title: _title,
                description: _description,
                benefactor: _benefactor,
                goal : _goal,
                deadline : _deadline,
                amountRaised: 0,
                ended: false
            });

            campaigns.push(newCampaign);

            // campaigns[msg.sender].push(newCampaign);
            emit CampaignCreated(campaigns.length -1, newCampaign.title, newCampaign.benefactor, newCampaign.goal, newCampaign.deadline);
          
    }

    //making donations

    function donate(uint _campaignId) public payable onlyBeforeDeadline(_campaignId) {

       // require(msg.value >= 0, "Donation amount must be greater than zero");

        Campaign storage campaign = campaigns[_campaignId];
        campaign.amountRaised += msg.value;

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

// Function to end a campaign automatically 
    function endCampaign(uint _campaignId) public onlyAfterDeadline(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
         campaign.ended = true;

        // Transfer funds to benefactor
        (bool success, ) = payable(campaign.benefactor).call{value: campaign.amountRaised}("");
        require(success, "Transfer failed");

        emit CampaignEnded(_campaignId);
    }

 // getting the details of a campaign
    function getCampaignDetails(uint _campaignId) public view returns (
        string memory title,
        string memory description,
        address benefactor,
        uint goal,
        uint deadline,
        uint amountRaised,
        bool ended
    ) {
        Campaign storage campaign = campaigns[_campaignId];
        return (
            campaign.title,
            campaign.description,
            campaign.benefactor,
            campaign.goal,
            campaign.deadline,
            campaign.amountRaised,
            campaign.ended
        );
    }


    // Function to withdraw left funds 
    function withdrawFunds() public onlyOwner {
        uint balance = address(this).balance;
        payable(owner).transfer(balance);
    }


}