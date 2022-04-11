//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract OTCTrade {
    address payable public _seller;
    address payable public _buyer;
    address payable public _feeReceiver;
    uint256 public _offerAmount;
    uint256 public _price;
    bool public _active = true;
    bool public _completed = false;
    uint256 public _fee;

    constructor(
        address seller_,
        address feeReceiver_,
        uint256 price_
    ) payable {
        // require(priceWithFee_ / 10000 * 10000 == priceWithFee_, "price too low");
        require(msg.value > 0, "transaction value cannot be 0");
        _seller = payable(seller_);
        _feeReceiver = payable(feeReceiver_);
        _offerAmount = msg.value;
        // _fee = priceWithFee_ * 200 / 10000;
        // _price = priceWithFee_ - priceWithFee_ * 200 / 10000;
        _price = price_;
    }

    modifier onlySeller() {
        require(msg.sender == _seller, "not seller");
        _;
    }

    modifier onlyActive() {
        require(_active == true, "trade is inactive");
        _;
    }

    modifier onlyNonCompleted() {
        require(_completed == false, "trade is completed");
        _;
    }

    function active() public view virtual returns (bool) {
        return _active;
    }

    function getTrade()
        external
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        return (_seller, _buyer, _offerAmount, _price, _active, _completed);
    }

    function completeTrade(address sender)
        external
        payable
        onlyActive
        onlyNonCompleted
        returns (bool)
    {
        require(msg.value == _price, "incorrect transaction amount");
        require(
            (msg.value / 10000) * 10000 == msg.value,
            "transaction amount too small"
        );
        uint256 fee = (msg.value * 300) / 10000;
        _buyer = payable(sender);
        _seller.transfer(msg.value - fee);
        _buyer.transfer(_offerAmount);
        _feeReceiver.transfer(fee);
        _completed = true;
        _active = false;
        return _completed;
    }

    function deleteTrade(address sender) external onlyActive returns (bool) {
        require(sender == _seller, "not seller");
        _active = false;
        return _active;
    }
}
