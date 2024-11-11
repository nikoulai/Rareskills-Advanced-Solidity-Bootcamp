// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BondingCurve is ERC20, Ownable {
    uint256 public maxGasPrice = 1 * 10 ** 18; // Adjustable value

    uint256 public immutable a;
    uint256 public immutable b;

    event Purchase(address indexed buyer, uint256 tokensBought, uint256 price);
    event Sale(address indexed seller, uint256 tokensSold, uint256 price);

    constructor(uint256 _a, uint256 _b) ERC20("BondingCurve", "BC") Ownable(msg.sender) {
        // _mint(msg.sender, 1000000 * 10 ** decimals());

        a = _a;
        b = _b;
    }

    modifier validGasPrice() {
        require(tx.gasprice <= maxGasPrice, "Transaction gas price cannot exceed maximum gas price.");
        _;
    }

    function purchase(uint256 _tokensToBuy) public validGasPrice {
        uint256 newSupply = totalSupply() + _tokensToBuy;
        uint256 price = calculatePrice(totalSupply(), newSupply);
        _mint(msg.sender, _tokensToBuy);

        emit Purchase(msg.sender, _tokensToBuy, price);
    }

    function sell(uint256 _tokensToSell) public validGasPrice {
        uint256 newSupply = totalSupply() - _tokensToSell;
        uint256 price = calculatePrice(newSupply, totalSupply());
        _burn(msg.sender, _tokensToSell);

        emit Sale(msg.sender, _tokensToSell, price);
    }

    function calculatePurchasePrice(uint256 _tokensToBuy) public view validGasPrice returns (uint256) {
        uint256 newSupply = totalSupply() + _tokensToBuy;
        return calculatePrice(totalSupply(), newSupply);
    }

    function calculateSalePrice(uint256 _tokensToSell) public view validGasPrice returns (uint256) {
        uint256 newSupply = totalSupply() - _tokensToSell;
        return calculatePrice(newSupply, totalSupply());
    }

    function calculatePrice(uint256 _initialSupply, uint256 _finalSupply) public view returns (uint256) {
        return (_finalSupply - _initialSupply) * (a * (_finalSupply + _initialSupply) + b) / 2;
    }

    function setMaxGasPrice(uint256 gasPrice) public onlyOwner {
        maxGasPrice = gasPrice;
    }
}
