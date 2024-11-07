# Ecosystem1:

## True positives

- Unused function parameter.

  function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) // operator, data

- SCEcosystem1.FEE_NUMERATOR (src/Ecosystem1/SCEcosystem1.sol#16) should be constant
  SCEcosystem1.MAX_SUPPLY (src/Ecosystem1/SCEcosystem1.sol#14) should be constant

- Staking.withdrawRewards(uint256) (src/Ecosystem1/Staking.sol#52-71) uses timestamp for comparisons
-     State variables written after the call(s):

## False positives

Reentrancy in Staking.unstake(uint256) (src/Ecosystem1/Staking.sol#73-85):
