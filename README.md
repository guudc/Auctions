# NFT Auction Platform - Smart Contract Documentation

## Overview

This NFT Auction Platform is a decentralized application built on Ethereum that enables ERC1155 NFT auctions using ERC20 tokens as the bidding currency. The system consists of two main contracts:

1. **Escrow Contract**: Handles the secure holding of NFTs and bidding tokens during auctions
2. **Auction Contract**: Manages the auction lifecycle including bidding, claiming, and reverting transactions

## Contracts

### Escrow.sol

The Escrow contract securely holds NFTs and ERC20 tokens during auctions and facilitates transfers between parties.

**Key Features:**
- Holds ERC1155 NFTs and ERC20 tokens securely
- Provides transfer functions for successful auctions
- Includes revert functions for failed or cancelled auctions

**Main Functions:**
- `transferNftFromEscrowtoBidder()`: Transfers NFT to winning bidder
- `transferAmounFromEscrowtoSeller()`: Transfers tokens to seller
- `revertAmount()`: Returns tokens to original owner
- `revertNft()`: Returns NFT to original owner

### Auction.sol

The main auction contract that manages the entire auction lifecycle.

**Key Features:**
- Creates new auctions for ERC1155 NFTs
- Handles bidding process with ERC20 tokens
- Manages auction time limits
- Provides admin functions for claim and revert operations

**Main Functions:**
- `aution()`: Creates a new auction
- `bid()`: Places a bid on an auction
- `claimBid()`: Allows seller to claim winning bid
- `removeNftAuction()`: Allows seller to cancel auction
- `revertAuction()`: Reverts auction after expiration

## Installation & Deployment

### Prerequisites
- Node.js and npm
- Hardhat or Truffle framework
- OpenZeppelin contracts

### Steps
1. Install dependencies:
```bash
npm install @openzeppelin/contracts
```

2. Compile contracts:
```bash
npx hardhat compile
```

3. Deploy contracts:
```bash
npx hardhat run scripts/deploy.js --network <network-name>
```

## Usage Workflow

### For Sellers

1. **Approve NFT Transfer**: Grant the auction contract permission to transfer your NFT
2. **Create Auction**: Call `aution()` with token ID and duration (in days)
3. **Monitor Bids**: Track bids as they come in
4. **Claim Winning Bid**: After auction ends, call `claimBid()` to receive tokens and transfer NFT
5. **Cancel Auction**: If needed, call `removeNftAuction()` to cancel before end

### For Bidders

1. **Approve Token Transfer**: Grant the auction contract permission to transfer your ERC20 tokens
2. **Place Bid**: Call `bid()` with token ID and bid amount
3. **Increase Bid**: Call `bid()` again to increase your bid
4. **Receive Refund**: If outbid or auction cancelled, tokens are automatically returned

## Security Features

- Time-limited auctions with automatic expiration
- Escrow protection for both NFTs and bidding tokens
- Only auction creator can claim or cancel auctions
- Automatic refunds for outbid bidders
- Secure transfer functions with validation checks

## Key Data Structures

### Auction Structure
```solidity
struct auction {
    address escrow;        // Escrow contract address
    uint256 tokenId;       // NFT token ID
    uint256 duration;      // Auction end time
    address seller;        // Seller address
    bool claim;            // Claim status
    uint256 bidder;        // Placeholder for bidder tracking
}
```

### Bid Structure
```solidity
struct Bid {
    uint256 amount;        // Bid amount
    uint256 duration;      // Bid time
    address bidder;        // Bidder address
}
```

## Events

The contracts emit events for important actions (implementation needed):
- AuctionCreated: When a new auction is created
- BidPlaced: When a bid is placed
- AuctionClaimed: When an auction is successfully claimed
- AuctionCancelled: When an auction is cancelled
- AuctionReverted: When an auction expires and is reverted

## File Structure

```
contracts/
├── Escrow.sol          # Escrow contract for holding assets
└── Auction.sol         # Main auction contract
```

## Important Notes

1. **Approvals Required**: Both sellers and bidders must approve the auction contract to transfer their assets
2. **Time Calculations**: Auction durations are calculated in days (86400 seconds per day)
3. **Token Compatibility**: The auction works with any ERC1155 NFTs and ERC20 tokens
4. **Gas Considerations**: Complex auctions may require significant gas for operations
5. **Testing**: Thoroughly test all functions before deploying to mainnet

## License

MIT License - See SPDX-License-Identifier in contract headers

## Audit Notes

This code has not been professionally audited. Use in production at your own risk after thorough testing and security review.

## Future Improvements

- Add royalty support for NFT creators
- Implement Dutch auctions (descending price)
- Add batch operations for multiple auctions
- Implement off-chain signatures for gas efficiency
- Add governance features for platform management
- Implement multi-chain compatibility

## Contact

For questions about this auction platform, refer to the contract comments and code documentation.
