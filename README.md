# ClarityTokenHub

A fungible token implementation on the Stacks blockchain using the Clarity smart contract language, following the SIP-010 standard.

## Project Overview

ClarityTokenHub implements a fully-functional fungible token called "MyClarityToken" (symbol: MCT) on the Stacks blockchain. This implementation adheres to the SIP-010 fungible token standard to ensure compatibility with wallets, exchanges, and other applications in the Stacks ecosystem.

## Features

- SIP-010 compliant fungible token
- Token transfer functionality with optional memo support
- Controlled minting (restricted to contract owner)
- Secure token burning
- Standard token information accessors (name, symbol, decimals, etc.)
- Comprehensive security checks and error handling

## Smart Contract Details

### Token Information
- **Name:** MyClarityToken
- **Symbol:** MCT
- **Decimals:** 6
- **Contract Owner:** Set to the deployer of the contract (tx-sender)

### Functions

#### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-balance` | Returns the token balance for a given principal |
| `get-total-supply` | Returns the total token supply |
| `get-name` | Returns the token name ("MyClarityToken") |
| `get-symbol` | Returns the token symbol ("MCT") |
| `get-decimals` | Returns the number of decimals (6) |
| `get-token-uri` | Returns the URI for token metadata |

#### Public Functions

| Function | Description |
|----------|-------------|
| `transfer` | Transfers tokens between accounts with optional memo |
| `mint` | Creates new tokens (restricted to contract owner) |
| `burn` | Destroys existing tokens (requires owner approval) |

### Error Codes

| Error Code | Description |
|------------|-------------|
| `err-owner-only` (u100) | Operation restricted to contract owner |
| `err-not-token-owner` (u101) | Operation restricted to token owner |
| `err-not-enough-balance` (u102) | Insufficient token balance |

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development toolkit
- [Stacks CLI](https://docs.stacks.co/understand-stacks/command-line-interface) - Command line interface for Stacks blockchain

### Installation

1. Create a new Clarinet project:
```bash
clarinet new clarity-token-hub
cd clarity-token-hub
```

2. Add the token contract to your project:
```bash
# Create the contract file
touch contracts/my-token.clar

# Copy the contract code into this file
```

3. Update the Clarinet configuration:
```bash
# Edit Clarinet.toml to include your new contract
```

### Testing

Create unit tests to verify contract functionality:

```bash
# Create a test file
touch tests/my-token_test.ts

# Run tests
clarinet test
```

Example test scenarios:
- Token minting by owner
- Token transfer between accounts
- Failed transfers due to insufficient balance
- Authorization checks for protected functions

## Deployment

### Testnet Deployment

Deploy your contract to the Stacks testnet:

```bash
# Configure your testnet wallet
stacks config setup

# Deploy the contract
stacks deploy --testnet my-token.clar
```

### Mainnet Deployment

For production deployment:

```bash
# Deploy to mainnet (requires STX for transaction fees)
stacks deploy --mainnet my-token.clar
```

## Interacting with the Contract

### Using Clarity Console

```bash
# Start Clarity console
clarinet console

# Mint tokens
(contract-call? .my-token mint u1000 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

# Check balance
(contract-call? .my-token get-balance 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Using Stacks Explorer

You can also interact with deployed contracts using the [Stacks Explorer](https://explorer.stacks.co/).

## Security Considerations

- Only the contract owner can mint new tokens
- Burns and transfers are protected by ownership checks
- Balance validation prevents overspending
- The contract implements the widely-reviewed SIP-010 standard

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request
````

## Resources

- [Clarity Documentation](https://docs.stacks.co/clarity/overview)
- [SIP-010 Standard](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md)
- [Stacks Blockchain](https://www.stacks.co/)