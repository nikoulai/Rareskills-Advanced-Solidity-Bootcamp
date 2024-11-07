Mutation testing report:
Number of mutations: 56
Killed: 42 / 56

Mutations:

[+] Survivors
Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem2/PrimeNFT.sol
Line nr: 11
Result: Lived
Original line:
function safeMint(address to, uint256 tokenId) public onlyOwner {

    Mutated line:
             function safeMint(address to, uint256 tokenId) public  {

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/RewardToken.sol
Line nr: 14
Result: Lived
Original line:
require(msg.sender == minter, "Only minter can mint");

    Mutated line:
                 require(msg.sender != minter, "Only minter can mint");

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/RewardToken.sol
Line nr: 14
Result: Lived
Original line:
require(msg.sender == minter, "Only minter can mint");

    Mutated line:
                 require(msg.sender != minter, "Only minter can mint");

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/RewardToken.sol
Line nr: 15
Result: Lived
Original line:
\_mint(to, amount);

    Mutated line:

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/SCEcosystem1.sol
Line nr: 41
Result: Lived
Original line:
\_safeMint(\_msgSender(), totalSupply - 1);

    Mutated line:
                 _safeMint(_msgSender(), totalSupply + 1);

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/SCEcosystem1.sol
Line nr: 31
Result: Lived
Original line:
\_setDefaultRoyalty(\_msgSender(), FEE_NUMERATOR);

    Mutated line:

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/SCEcosystem1.sol
Line nr: 41
Result: Lived
Original line:
\_safeMint(\_msgSender(), totalSupply - 1);

    Mutated line:

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/SCEcosystem1.sol
Line nr: 44
Result: Lived
Original line:
function mintWithDiscount(bytes32[] calldata proof, uint256 index) external payable maxSupply {

    Mutated line:
             function mintWithDiscount(bytes32[] calldata proof, uint256 index) external payable  {

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/SCEcosystem1.sol
Line nr: 72
Result: Lived
Original line:
function withdraw() external onlyOwner {

    Mutated line:
             function withdraw() external  {

[*] Done!
Mutation testing report:
Number of mutations: 56
Killed: 42 / 56

Mutations:

[+] Survivors
Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem2/PrimeNFT.sol
Line nr: 11
Result: Lived
Original line:
function safeMint(address to, uint256 tokenId) public onlyOwner {

    Mutated line:
             function safeMint(address to, uint256 tokenId) public  {

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/RewardToken.sol
Line nr: 14
Result: Lived
Original line:
require(msg.sender == minter, "Only minter can mint");

    Mutated line:
                 require(msg.sender != minter, "Only minter can mint");

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/RewardToken.sol
Line nr: 14
Result: Lived
Original line:
require(msg.sender == minter, "Only minter can mint");

    Mutated line:
                 require(msg.sender != minter, "Only minter can mint");

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/RewardToken.sol
Line nr: 15
Result: Lived
Original line:
\_mint(to, amount);

    Mutated line:

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/SCEcosystem1.sol
Line nr: 41
Result: Lived
Original line:
\_safeMint(\_msgSender(), totalSupply - 1);

    Mutated line:
                 _safeMint(_msgSender(), totalSupply + 1);

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/SCEcosystem1.sol
Line nr: 31
Result: Lived
Original line:
\_setDefaultRoyalty(\_msgSender(), FEE_NUMERATOR);

    Mutated line:

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/SCEcosystem1.sol
Line nr: 41
Result: Lived
Original line:
\_safeMint(\_msgSender(), totalSupply - 1);

    Mutated line:

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/SCEcosystem1.sol
Line nr: 44
Result: Lived
Original line:
function mintWithDiscount(bytes32[] calldata proof, uint256 index) external payable maxSupply {

    Mutated line:
             function mintWithDiscount(bytes32[] calldata proof, uint256 index) external payable  {

Mutation:
File: /Users/nikos/Desktop/rareskills-advanced-solidity/week2/src/Ecosystem1/SCEcosystem1.sol
Line nr: 72
Result: Lived
Original line:
function withdraw() external onlyOwner {

    Mutated line:
             function withdraw() external  {

[*] Done!
