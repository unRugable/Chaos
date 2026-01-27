# UnRugable.com

A token launcher platform on Base that provides permanent USDC backing for meme tokens, enabling instant refund ability and eliminating rug pull risks.

## Overview

UnRugable.com addresses the security issues common in meme token launches by implementing a permanent USDC backing mechanism. Every token launched through the platform is backed by USDC locked in the contract, with no withdrawal function available to creators. This creates a mathematical guarantee that users can always refund their tokens for USDC at a proportional rate.

## Core Mechanism

### Permanent USDC Backing

Each token is backed by USDC that remains locked in the contract. The refund value is calculated as: (your tokens × total USDC backing) ÷ circulating supply. This ratio cannot be manipulated by creators, as there is no mechanism to withdraw USDC from the contract outside of the refund process.

### Instant Refundability

Users can refund tokens at any time by transferring them to the contract address. Refunds are processed immediately with no waiting periods. A 1% fee is applied to refunds, split between the creator (0.3%), platform (0.2%), and permanent backing increase (0.5%).

### Fee Structure

All transactions carry a 1% fee:
- Creator receives 0.3% in tokens
- Platform receives 0.2% in tokens
- Backing receives 0.5%, permanently increasing the USDC backing

The backing fee creates an anti-dilution mechanism where the refund value increases over time as more transactions occur.

## Platform Features

### Token Launch

Creators can launch tokens with custom names and symbols. The launch process requires only gas fees; there are no platform fees or launch taxes. Tokens are deployed through a factory contract that tracks all launches and maintains metadata.

### Trading

Users can buy tokens by sending USDC directly to the token contract. Tokens are minted based on the current backing ratio. Users can also trade tokens peer-to-peer on DEXs without fees, or refund them directly to the contract for USDC.

### Transparency

All transactions are recorded on-chain and indexed by a subgraph for real-time data display. Contract source code can be verified on BaseScan, and creators can claim contract ownership to establish authenticity.

### Social Features

Each token has a dedicated chat room for community discussion. Creators have access to management tools and analytics for their tokens.

## Safety Guarantees

The platform eliminates traditional rug pull vectors:

- **No fund withdrawal**: USDC cannot be withdrawn by creators
- **Proportional refunds**: Refund value increases if others exit
- **Immutable contracts**: No upgrade mechanisms or admin controls
- **Mathematical guarantees**: Refund calculations are transparent and verifiable

Unlike traditional token launches where creators can withdraw liquidity, drain fees, or sell admin tokens, UnRugable tokens maintain their backing regardless of creator actions.

## Vision

UnRugable.com aims to create a sustainable token ecosystem where:

- Creators are incentivized through transaction fees rather than fund extraction
- Users have guaranteed exit liquidity through permanent backing
- Innovation can flourish without the fear of scams
- Transparency is built into every transaction

The platform provides a foundation for fair token launches where creator incentives align with long-term success, and user protection is mathematically guaranteed rather than trust-based.

## Platform Status

The platform is operational on Base. All contracts are non-upgradeable and immutable. Token launches are free except for network gas costs. The platform fee (0.2% of transactions) supports ongoing development and maintenance.

---

For technical documentation, deployment guides, and development information, see the project repository.
