# ERC721A:

## Where does it save gas?

### 1. Removing redundant storage

ERC721Enumerable uses multiple data structures in order to save token's metadata. ERC721A removes this redundant storage. This reduces the complexity of the contract and saves gas costs.

### 2. Updating the owner’s balance once per batch mint request

ERC721A updates the owner's balance once per batch mint request, instead of updating the storage every time a token is minted.

### 3. Updating the owner data once per batch mint request,

This is similar to the above optimization. This updates the ownwer's data once per batch and it uses a implicit way to infer the owner of the tokens when they are consecutively minted.

## Where does it add cost?

### 1. Additional logic to infer the owner of the tokens, because it has to iterate the tokens until it finds the owner.
