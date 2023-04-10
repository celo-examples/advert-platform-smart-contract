// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedAdvertising {
    struct Ad {
        uint256 id;
        address payable advertiser;
        string content;
        uint256 pricePerClick;
        uint256 budget;
        bool paused;
    }

    uint256 public adCounter;
    mapping(uint256 => Ad) public ads;

    function createAd(string memory _content, uint256 _pricePerClick, uint256 _budget) public payable {
        require(msg.value == _budget, "Budget must match the value sent.");

        adCounter++;
        ads[adCounter] = Ad({
            id: adCounter,
            advertiser: payable(msg.sender),
            content: _content,
            pricePerClick: _pricePerClick,
            budget: _budget,
            paused: false
        });
    }

    function getAvailableAds() public view returns (Ad[] memory) {
        uint256 availableAdCount = 0;

        for (uint256 i = 1; i <= adCounter; i++) {
            if (ads[i].budget >= ads[i].pricePerClick && !ads[i].paused) {
                availableAdCount++;
            }
        }

        Ad[] memory availableAds = new Ad[](availableAdCount);
        uint256 index = 0;

        for (uint256 i = 1; i <= adCounter; i++) {
            if (ads[i].budget >= ads[i].pricePerClick && !ads[i].paused) {
                availableAds[index] = ads[i];
                index++;
            }
        }

        return availableAds;
    }

    function handleClick(uint256 _adId, address payable _publisher) public {
        require(_adId <= adCounter, "Invalid Ad ID.");
        require(ads[_adId].budget >= ads[_adId].pricePerClick, "Insufficient budget.");

        ads[_adId].budget -= ads[_adId].pricePerClick;
        _publisher.transfer(ads[_adId].pricePerClick);
    }

    function updateAdContent(uint256 _adId, string memory _newContent) public {
        require(_adId <= adCounter, "Invalid Ad ID.");
        require(msg.sender == ads[_adId].advertiser, "Only the advertiser can update the ad content.");

        ads[_adId].content = _newContent;
    }

    function pauseAd(uint256 _adId) public {
        require(_adId <= adCounter, "Invalid Ad ID.");
        require(msg.sender == ads[_adId].advertiser, "Only the advertiser can pause the ad.");

        ads[_adId].paused = true;
    }

    function resumeAd(uint256 _adId) public {
        require(_adId <= adCounter, "Invalid Ad ID.");
        require(msg.sender == ads[_adId].advertiser, "Only the advertiser can resume the ad.");

        ads[_adId].paused = false;
    }

    function withdrawRemainingBudget(uint256 _adId) public {
        require(_adId <= adCounter, "Invalid Ad ID.");
        require(msg.sender == ads[_adId].advertiser, "Only the advertiser can withdraw the remaining budget.");

        uint256 remainingBudget = ads[_adId].budget;
        require(remainingBudget > 0, "No budget remaining to withdraw.");

        ads[_adId].budget = 0;
        ads[_adId].advertiser.transfer(remainingBudget);
    }
}
