# Decentralized Climate Change Adaptation Funding System

A comprehensive blockchain-based platform for managing climate adaptation funding, risk assessment, and impact measurement across vulnerable communities worldwide.

## System Overview

This system consists of five interconnected smart contracts that facilitate transparent, efficient, and accountable climate adaptation funding:

### 1. Climate Risk Assessment Contract (`climate-risk-assessment.clar`)
- Evaluates climate vulnerability scores for regions and communities
- Tracks climate risk indicators (temperature, precipitation, sea level, extreme events)
- Provides risk-based prioritization for funding allocation
- Maintains historical climate data and projections

### 2. Adaptation Project Funding Contract (`adaptation-project-funding.clar`)
- Manages funding proposals for climate resilience projects
- Handles project approval, milestone tracking, and fund disbursement
- Supports multiple funding sources and transparent allocation
- Tracks project lifecycle from proposal to completion

### 3. Impact Measurement Contract (`impact-measurement.clar`)
- Measures and verifies the effectiveness of climate adaptation investments
- Tracks key performance indicators (KPIs) for funded projects
- Provides impact scoring and comparative analysis
- Maintains long-term impact data for accountability

### 4. International Climate Finance Contract (`international-climate-finance.clar`)
- Facilitates climate funding transfers from developed to developing nations
- Manages international climate commitments and pledges
- Tracks compliance with global climate finance goals
- Provides transparent reporting on international fund flows

### 5. Community Resilience Contract (`community-resilience.clar`)
- Builds and tracks local capacity for climate change adaptation
- Manages community-led resilience initiatives
- Provides training and resource allocation for local communities
- Measures community preparedness and adaptive capacity

## Key Features

- **Transparent Funding**: All transactions and allocations are recorded on-chain
- **Risk-Based Allocation**: Funding prioritized based on climate vulnerability assessments
- **Impact Verification**: Measurable outcomes tracked throughout project lifecycle
- **Community Empowerment**: Local communities have direct access to funding and resources
- **International Coordination**: Facilitates global climate finance cooperation
- **Data Integrity**: Immutable records of climate data, funding, and impact metrics

## Contract Architecture

Each contract operates independently while sharing common data structures for interoperability:

- **Standardized Risk Metrics**: Common vulnerability scoring across all contracts
- **Unified Project Tracking**: Consistent project lifecycle management
- **Shared Impact Indicators**: Standardized measurement criteria
- **Common Access Controls**: Role-based permissions for different stakeholders

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Basic understanding of Clarity smart contracts

### Installation
\`\`\`bash
git clone <repository-url>
cd climate-funding-contracts
npm install
clarinet check
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

### Deployment
\`\`\`bash
clarinet deploy --testnet
\`\`\`

## Usage Examples

### Assessing Climate Risk
\`\`\`clarity
(contract-call? .climate-risk-assessment assess-region-risk
"coastal-bangladesh"
{temperature-change: u25, sea-level-rise: u30, extreme-events: u40})
\`\`\`

### Submitting Funding Proposal
\`\`\`clarity
(contract-call? .adaptation-project-funding submit-proposal
"Mangrove Restoration Project"
u1000000
"coastal-bangladesh"
u365)
\`\`\`

### Recording Impact Metrics
\`\`\`clarity
(contract-call? .impact-measurement record-impact
u1
{lives-protected: u5000, infrastructure-secured: u10, economic-benefit: u2000000})
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Contact

For questions or support, please open an issue in the repository.
