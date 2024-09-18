#How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace

In order to determine all present NFTs, it could firstly look for mint events from the block the marketpalce was deployed until the `latest` block. This can be done by using as index the signature of the event. In the same way it could look for transfer events (or combine transfer event with the indexed tokenId) to know the current owner of the NFT.
