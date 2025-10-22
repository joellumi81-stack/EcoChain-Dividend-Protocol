# 🌱 EcoChain Dividend Protocol

A blockchain-based incentive system that rewards users with dividends for performing eco-friendly actions. Users earn points through verified environmental activities and receive proportional dividends from a shared reward pool.

## 🌿 Features

- **🎯 Eco-Action Tracking**: Record and verify environmental activities
- **💚 Point System**: Earn points based on the impact of eco-friendly actions
- **💰 Dividend Distribution**: Receive STX dividends proportional to accumulated points
- **⏰ Epoch Management**: Time-based reward distribution cycles
- **🔒 Claim Intervals**: Prevent spam with cooldown periods between claims
- **📊 Analytics**: Track platform usage, points, and dividend distribution
- **🛡️ Admin Controls**: Platform fee collection and user management

## 🌍 How It Works

### User Journey
1. **🔐 Registration**: Users register to participate in the eco-reward system
2. **🌱 Eco-Actions**: Perform and record environmental activities (1-1000 points)
3. **📈 Point Accumulation**: Build up points across multiple epochs
4. **💸 Pool Funding**: Community and sponsors fund the dividend pool
5. **💰 Dividend Claims**: Claim proportional rewards based on point share

### Action Examples
- **Renewable Energy Usage** (500-800 points)
- **Public Transport/Cycling** (50-200 points)
- **Waste Reduction/Recycling** (100-400 points)
- **Tree Planting/Conservation** (300-700 points)
- **Energy Conservation** (150-500 points)

## 🔧 Contract Functions

### User Functions

#### `register`
Register as a new user in the platform.
```clarity
(register)
```

#### `record-eco-action`
Record an eco-friendly action and earn points.
```clarity
(record-eco-action points)
```
- **points**: Action impact points (1-1000)

#### `claim-dividend`
Claim your share of dividends from the pool.
```clarity
(claim-dividend)
```
- Requires 250 block cooldown between claims
- Returns proportional share based on points

#### `preview-dividend`
Preview potential dividend before claiming.
```clarity
(preview-dividend who)
```

### Pool Functions

#### `fund-dividend-pool`
Add funds to the dividend reward pool.
```clarity
(fund-dividend-pool amount)
```

### Epoch Management

#### `start-new-epoch`
Start a new reward distribution epoch.
```clarity
(start-new-epoch)
```

#### `close-epoch`
Close a specific epoch.
```clarity
(close-epoch epoch)
```

### Analytics Functions

#### `get-platform-stats`
Retrieve comprehensive platform statistics.

#### `get-user-share`
Get user's percentage share of total points.

#### `get-topline`
Get key platform metrics (pool size, users, actions).

### Admin Functions

#### `admin-withdraw-fees`
Withdraw accumulated platform fees (admin only).
```clarity
(admin-withdraw-fees to amount)
```

#### `reset-points`
Reset user's points (admin only).
```clarity
(reset-points who)
```

## 🛠️ Usage Examples

### Registering as a User
```bash
clarinet console
(contract-call? .eco-dividend register)
```

### Recording an Eco-Action
```bash
;; Record using public transport (150 points)
(contract-call? .eco-dividend record-eco-action u150)

;; Record tree planting activity (500 points)  
(contract-call? .eco-dividend record-eco-action u500)
```

### Funding the Dividend Pool
```bash
;; Add 10,000 µSTX to reward pool
(contract-call? .eco-dividend fund-dividend-pool u10000)
```

### Claiming Dividends
```bash
;; Preview your potential dividend
(contract-call? .eco-dividend preview-dividend tx-sender)

;; Claim your dividend share
(contract-call? .eco-dividend claim-dividend)
```

### Checking Platform Stats
```bash
(contract-call? .eco-dividend get-platform-stats)
(contract-call? .eco-dividend get-topline)
```

## 🔧 Development Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet)
- Node.js (for testing)

### Installation
```bash
git clone <repository>
cd EcoChain-Dividend-Protocol
clarinet check
```

### Testing
```bash
npm install
npm test
```

## 📖 Contract Details

- **Contract Name**: `eco-dividend`
- **Network**: Stacks Blockchain
- **Language**: Clarity
- **Lines of Code**: 279
- **Claim Interval**: 250 blocks (~17 hours)
- **Platform Fee**: 1% (10/1000)
- **Min Action Points**: 1
- **Max Action Points**: 1000

## 🛡️ Security Features

- ✅ Registration requirement to prevent spam
- ✅ Point range validation (1-1000)
- ✅ One action per user per epoch
- ✅ Cooldown period between dividend claims
- ✅ Platform fee mechanism for sustainability
- ✅ Admin controls for emergency management
- ✅ Overflow protection in calculations

## 💡 Economics Model

### Point System
- **Low Impact Actions**: 1-100 points (daily habits)
- **Medium Impact Actions**: 101-500 points (weekly activities)
- **High Impact Actions**: 501-1000 points (significant efforts)

### Dividend Distribution
- **Proportional Sharing**: `(user_points / total_points) * dividend_pool`
- **Platform Fee**: 1% deducted for platform sustainability
- **Claim Cooldown**: 250 blocks to prevent spam

### Funding Sources
- **Community Contributions**: Users can fund the pool
- **Sponsor Contributions**: Organizations funding environmental initiatives
- **Grant Programs**: Environmental foundations and DAOs
- **Carbon Credit Rewards**: Integration with carbon offset programs

## 🌍 Environmental Impact

### Tracked Actions
- **🔋 Energy**: Renewable energy usage, conservation
- **🚌 Transportation**: Public transport, cycling, walking
- **♻️ Waste**: Reduction, recycling, upcycling
- **🌳 Conservation**: Tree planting, habitat protection
- **💧 Water**: Conservation, cleanup activities
- **🏠 Lifestyle**: Sustainable living practices

### Impact Measurement
- **Direct Actions**: Immediate environmental benefits
- **Behavioral Change**: Long-term habit formation
- **Community Engagement**: Collective environmental action
- **Education & Awareness**: Spreading eco-consciousness

## 📊 Analytics Dashboard

Track key metrics:
- Total registered users and activity levels
- Points earned across different action categories
- Dividend pool growth and distribution patterns
- User engagement and retention rates
- Environmental impact quantification
- Geographic distribution of actions

## 🔄 Future Enhancements

- **🏆 Achievement System**: Badges and milestones
- **🤝 Partnerships**: Integration with environmental organizations
- **📱 Mobile App**: User-friendly action recording
- **🔗 Oracle Integration**: Automated action verification
- **🌐 Multi-chain**: Expansion to other blockchains
- **📊 Impact Reporting**: Detailed environmental impact analytics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `clarinet check`
5. Submit a pull request

## 📄 License

This project is open source. See LICENSE file for details.

## 🆘 Support

For questions or issues:
- Create an issue on GitHub
- Join our community discussions
- Check the documentation

---

*Building a sustainable future through blockchain incentives* 🌱💚
