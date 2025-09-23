A blockchain-based certificate system for verifying ore quality through lab testing results, preventing fraud in mineral trading.

## 🚀 Features

- 🏭 **Lab Registration**: Authorized laboratories can register on the platform
- 📜 **Digital Certificates**: Labs issue tamper-proof quality certificates
- 📱 **QR Code Verification**: Instant verification through QR code scanning
- 💼 **Export Contracts**: Link quality certificates to trade agreements
- ⏰ **Expiry Management**: Time-limited certificates ensure freshness
- 🔒 **Access Control**: Role-based permissions for labs and contract owner

## 🏗️ Contract Architecture

### Core Data Structures

- **Labs**: Registered testing facilities with certification credentials
- **Certificates**: Ore quality test results with metadata
- **Export Contracts**: Trade agreements linked to verified certificates
- **QR Code Lookup**: Fast certificate retrieval via QR codes

### Key Functions

- `register-lab`: Register authorized testing laboratory
- `issue-certificate`: Create new ore quality certificate
- `verify-certificate`: Validate certificate authenticity
- `verify-by-qr-code`: Quick verification via QR scanning
- `create-export-contract`: Link certificate to trade agreement
- `complete-export-contract`: Finalize trade transaction

## 📋 Usage Instructions

### 1️⃣ Deploy Contract
```bash
clarinet deployments generate --devnet
clarinet deployments apply --devnet
```

### 2️⃣ Register Laboratory
```clarity
(contract-call? .Ore-Quality-Verification-Oracle register-lab 
    "MetalTech Labs" 
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
    "ISO 17025:2017 Certified"
)
```

### 3️⃣ Issue Certificate
```clarity
(contract-call? .Ore-Quality-Verification-Oracle issue-certificate
    "BATCH-001-2024"
    u1
    "Grade A"
    u95
    "Gold: 95%, Silver: 3%, Copper: 2%"
    u365
    "QR-ORE-001-2024"
)
```

### 4️⃣ Verify Certificate
```clarity
(contract-call? .Ore-Quality-Verification-Oracle verify-certificate u1)
```

### 5️⃣ QR Code Verification
```clarity
(contract-call? .Ore-Quality-Verification-Oracle verify-by-qr-code "QR-ORE-001-2024")
```

### 6️⃣ Create Export Contract
```clarity
(contract-call? .Ore-Quality-Verification-Oracle create-export-contract
    u1
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
    u1000
    u50000
)
```

## 🔍 Certificate Verification Process

1. **Lab Testing**: Authorized lab conducts quality analysis
2. **Certificate Issuance**: Lab creates blockchain certificate with test results
3. **QR Generation**: System generates unique QR code for certificate
4. **Buyer Verification**: Buyers scan QR code to verify authenticity
5. **Export Integration**: Certificate links to export contracts for compliance

## 🛡️ Security Features

- **Owner-only lab registration**: Only contract owner can authorize labs
- **Lab authentication**: Only registered labs can issue certificates
- **Expiry enforcement**: Certificates automatically expire after set period
- **Immutable records**: Blockchain ensures tamper-proof certificate history
- **Access control**: Role-based permissions throughout system

## 🧪 Testing

```bash
npm install
npm test
```

## 📊 Data Validation

- Purity percentage: 0-100%
- Quality grades: Standardized mining industry classifications
- Lab certification: ISO compliance verification
- QR codes: Unique identifiers preventing duplication

## 🌍 Real-World Applications

- **Mining Companies**: Verify ore quality before purchase
- **Export/Import**: Compliance with international trade standards
- **Insurance**: Risk assessment based on verified quality data
- **Supply Chain**: End-to-end traceability of ore batches

## ⚡ Quick Start

1. Clone repository
2. Install Clarinet CLI
3. Deploy contract: `clarinet deployments apply`
4. Register your laboratory
5. Start issuing certificates

Ready to revolutionize ore trading with blockchain verification! 💎

## 🆕 Recent Enhancements

### Lab Blacklist Feature
- 🛡️ **Lab Blacklisting**: Contract owner can blacklist labs to prevent fraud
- 🔒 **Enhanced Security**: Immediate response to compromised laboratories
- 📊 **Blacklist Query**: Check lab blacklist status in real-time

### Updated Contract Architecture
- **Blacklisted Labs**: Registry of prohibited laboratories preventing certificate issuance

### New Key Functions
- `blacklist-lab`: Mark laboratory as blacklisted (owner-only)
- `is-lab-blacklisted`: Check if lab is blacklisted

### Usage Example: Blacklist a Lab
```clarity
(contract-call? .Ore-Quality-Verification-Oracle blacklist-lab u1)
```

### Enhanced Security Features
- **Lab blacklisting**: Owner-controlled mechanism to block fraudulent labs from issuing certificates
