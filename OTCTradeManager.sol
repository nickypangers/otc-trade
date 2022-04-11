//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./OTCTrade.sol";
import "./SampleToken.sol";

interface IToken {
    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function allowance(address, address) external view returns (uint256);
}

contract OTCTradeManager {
    address payable private owner;

    struct Trade {
        uint256 id;
        address seller;
        address tradeAddress;
    }

    Trade[] public trades;
    uint256 public tradeIndex = 0;

    constructor() {
        owner = payable(msg.sender);
    }

    function testTokenAllowance(address tokenAddress)
        public
        view
        returns (uint256)
    {
        return IToken(tokenAddress).allowance(msg.sender, address(this));
    }

    function testTransferToken(
        address tokenAddress,
        address receipient,
        uint256 amount
    ) public returns (bool) {
        // bool approved = IToken(tokenAddress).approve(address(this), amount);
        // tokenAddress.delegatecall(abi.encodeWithSelector(IToken.approve.selector, address(this), amount));
        IToken(tokenAddress).transferFrom(msg.sender, receipient, amount);
        return true;
    }

    function createTrade(uint256 _price) external payable returns (address) {
        require(msg.value > 0, "transaction value cannot be 0");
        require(_price > 0, "price cannot be 0");
        OTCTrade otcTrade = new OTCTrade{value: msg.value}(
            msg.sender,
            0xA0DF2787A29e6Bca09a7A23E0539808Ac5b10b7A,
            _price
        );
        Trade memory trade = Trade(tradeIndex, msg.sender, address(otcTrade));
        trades.push(trade);
        tradeIndex++;
        return trade.tradeAddress;
    }

    function getTrade(uint256 id)
        external
        view
        returns (
            address seller,
            address buyer,
            uint256 offerAmount,
            uint256 price,
            bool active,
            bool completed
        )
    {
        Trade memory trade = trades[id];
        OTCTrade otcTrade = OTCTrade(trade.tradeAddress);
        (seller, buyer, offerAmount, price, active, completed) = otcTrade
            .getTrade();
    }

    function makeTrade(uint256 id) public payable returns (bool) {
        OTCTrade otcTrade = OTCTrade(trades[id].tradeAddress);
        bool completed = otcTrade.completeTrade{value: msg.value}(msg.sender);
        return completed;
    }

    function deleteTrade(uint256 id) public payable returns (bool) {
        OTCTrade otcTrade = OTCTrade(trades[id].tradeAddress);
        bool active = otcTrade.deleteTrade(msg.sender);
        return active;
    }
}
