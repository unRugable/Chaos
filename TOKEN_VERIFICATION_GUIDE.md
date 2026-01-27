# Token Verification Guide - Using Remix IDE

## 🎯 Quick Start for Token Creators

This guide shows you how to verify your UnRugable token contract on BaseScan using the Remix online IDE. **No downloads required!**

---

## ⚠️ Prerequisites

### 1. Etherscan Account & API Key
**Required for BaseScan verification!**

- Go to https://etherscan.io and create a free account
- Login and go to your Dashboard → API Keys
- Click "Add" to create a new API key
- Name it something like "BaseScan Verification"
- **Copy your API key** - you'll need it in Remix!

**Why needed:** BaseScan uses Etherscan's universal EVM API. One API key works for all EVM networks including Base.

---

## 📋 Step-by-Step Instructions

### 1. Open Remix IDE
- Go to: https://remix.ethereum.org
- No installation needed - works in any web browser

### 2. Install Contract Verification Plugin
- Open **Plugin Manager** (right-hand side wall socket icon)
- Search for: `Contract Verification` (Maintained by Remix)
- Activate the plugin by clicking the small on/off button after the plugin name
- **Enter your Etherscan API key** in the plugin settings (from Prerequisites step above)

### 3. Create Contract File
- Create new file, name it `UnRugableToken.sol`
- Copy the UnRugable Token Contract Source Code (use "Copy All" button from unrugable.com/verify) and paste it to the `UnRugableToken.sol` file

### 4. Copy Contract Source Code
- Go to unrugable.com/verify
- Use the "Copy All" button to copy the complete contract source code
- Paste it into the `UnRugableToken.sol` file you created

### 5. Configure Compiler
- Click **"Solidity Compiler"** tab
- Open **Advanced Configurations**
- ✅ **Check "Use configuration file"**
- Click **"Update config remix.config.json"**
- Create a new file named `remix.config.json` and paste this configuration:

```json
{
  "solidity-compiler": {
    "language": "Solidity",
    "settings": {
      "viaIR": true,
      "optimizer": {
        "enabled": true,
        "runs": 200
      },
      "outputSelection": {
        "*": {
          "": [
            "ast"
          ],
          "*": [
            "abi",
            "metadata",
            "devdoc",
            "userdoc",
            "storageLayout",
            "evm.legacyAssembly",
            "evm.bytecode",
            "evm.deployedBytecode",
            "evm.methodIdentifiers",
            "evm.gasEstimates",
            "evm.assembly"
          ]
        }
      }
    }
  }
}
```

- Click **"Compile remix.config.json"**
- Click **"Compile UnRugableToken.sol"**

### 6. Verify on BaseScan
- Open the **"Contract Verification"** plugin tab
- Select **Network**: `Base Mainnet`
- **Contract Address**: Enter your token's address (e.g., `0x3e96b75ba40db5b1aa70c4eb07abc78436f04dc9`)

**Constructor Arguments:**
- The Remix plugin may auto-detect constructor arguments from the deployment transaction
- If needed, enter these values (first 3 addresses are FIXED for all UnRugable tokens):

| Parameter | Type | Value |
|-----------|------|--------|
| `_creator` | `address` | `0x7A1255992a4597083CF9E8468D17a60D73d8F6D4` |
| `_devFeeRecipient` | `address` | `0x4eaf3fe591898895102dfbc7487f45bab4454deb` |
| `_usdc` | `address` | `0x036CbD53842c5426634e7929541Ec2318f3dCf7E` |
| `name` | `string` | `"UnRugable"` (or your custom name - fetch from BaseScan) |
| `symbol` | `string` | `"UNR"` (or your custom symbol - fetch from BaseScan) |

⚠️ **Important Warning:** `_creator`, `_devFeeRecipient`, and `_usdc` addresses cannot be changed because the token is renounced at launch. Any modification to these 3 field values will fail token verification.

- Click **"Verify on BaseScan"**
- Wait for confirmation
- Your token is now verified! 🎉

---

## 🔍 Finding Your Token Information

If you don't know your token's name/symbol, you can find them on BaseScan:

1. Go to your token address on BaseScan
2. Look under "TokenTracker" or "ERC-20" section
3. The name and symbol are displayed there

Example: https://basescan.org/address/0x3e96b75ba40db5b1aa70c4eb07abc78436f04dc9
- Name: UnRugable
- Symbol: UNR

---

## ❓ Troubleshooting

### "Contract not found" error
- Make sure you're on **Base Mainnet** (not Base Sepolia)
- Double-check your contract address

### "Constructor arguments invalid" error
- Try leaving constructor arguments blank - BaseScan can usually auto-detect them from the deployment transaction

### "Bytecode does not match" error
- Make sure you're using compiler version **v0.8.31+commit.fd3a2265** (not 0.8.32)
- Verify the JSON configuration file matches exactly:
  - Compiler: v0.8.31+commit.fd3a2265
  - License: BUSL-1.1
  - Optimizer: Enabled, Runs: 200
  - viaIR: Enabled
  - Contract Name: UnrugableToken

### "Cannot find module @openzeppelin" or "File import callback not supported" error
- This happens when using "Single file" method with npm imports
- **Solution:** Use **"Standard JSON Input"** method instead (the contract source is already flattened)

### "Verification failed" error
- Ensure compiler version is exactly `0.8.31` (not 0.8.32)
- Make sure optimization is enabled with 200 runs and viaIR is enabled
- Verify all constructor arguments are correct (especially the first 3 addresses)
- Make sure you're on the correct network (Base Mainnet)

### Plugin not working
- Try refreshing Remix
- Reinstall the "Contract Verification" plugin
- Make sure your Etherscan API key is correctly entered in plugin settings

---

## ✅ After Verification

Once verified, your contract will show:

- ✅ Green checkmark indicating verified contract
- 📄 Full source code visible to everyone
- 🔍 Ability to read and interact with contract functions
- 📊 Better trust and transparency for users

### ⚠️ Important Note About Ownership

UnRugable tokens have **renounced ownership** for maximum security. This means:

- You **cannot** update contract metadata or add images on BaseScan after verification
- The contract information is **permanently locked** for security
- This prevents any future modifications and builds maximum trust
- Users know the contract will never change after deployment

---

## 🎯 Why Use Remix?

- ✅ **No downloads** - Works in any browser
- ✅ **User-friendly** - Visual interface
- ✅ **Automatic encoding** - Handles complex constructor args
- ✅ **Direct integration** - Connects directly to BaseScan
- ✅ **Free** - No cost to use

---

## 📞 Need Help?

If you encounter issues:
1. Check this guide again
2. Try the web-based tool at unrugable.com/verify
3. Contact UnRugable support

**Happy verifying! 🚀**