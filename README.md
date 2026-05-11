<div align="center">
  <img src=".github/resources/isotipo.png" height="180px" width="auto" alt="romm logo">

  <h3 style="font-size: 25px;">
    Cloud-Native Retro Gaming Platform
  </h3>

  <p>A self-hosted ROM manager and player, deployed on AWS with cloud-native infrastructure.</p>

</div>

# Overview

RomM (ROM Manager) allows you to scan, enrich, browse and play your game collection with a clean and responsive interface. With support for multiple platforms, various naming schemes, and custom tags, RomM is a must-have for anyone who plays on emulators.

This fork is configured for **cloud-native deployment on AWS**, featuring EC2 compute, RDS MariaDB database, and Docker containerization.

## Project Owner

**Umar Mushtaq Mughal** — [@UmarMushtaqMughal](https://github.com/UmarMushtaqMughal)

## Features

- Scan and enhance your game library with metadata from IGDB, Screenscraper, and MobyGames
- Fetch custom artwork from SteamGridDB
- Display your achievements from Retroachievements
- Metadata available for 400+ platforms
- Play games directly from the browser using EmulatorJS and RuffleRS
- Share your library with friends with limited access and permissions
- Supports multi-disk games, DLCs, mods, hacks, patches, and manuals
- Parse and filter by tags in filenames
- View, upload, update, and delete games from any modern web browser

## Cloud-Native Architecture

This project deploys RomM on AWS using the following infrastructure:

| Component | Service | Details |
|-----------|---------|---------|
| **Compute** | EC2 (t3.micro) | Ubuntu 24.04, Docker host |
| **Database** | RDS MariaDB | Managed database, Free Tier eligible |
| **Networking** | Security Group (RomM-SG) | Ports 22 (SSH), 8080 (Web), 3306 (DB) |
| **Access** | SSH Key Pair | RomMProjectKey |

## Quick Start

### Prerequisites

- AWS CLI configured with valid credentials
- Docker & Docker Compose installed on the EC2 instance
- SSH key pair (`RomMProjectKey.pem`)

### Deployment Steps

1. **SSH into the EC2 instance:**
   ```bash
   ssh -i RomMProjectKey.pem ubuntu@<EC2_PUBLIC_IP>
   ```

2. **Clone the repository:**
   ```bash
   git clone https://github.com/UmarMushtaqMughal/romm.git
   cd romm
   ```

3. **Configure the environment:**
   ```bash
   cp env.template .env
   # Edit .env with your RDS endpoint and credentials
   ```

4. **Launch with Docker Compose:**
   ```bash
   docker compose up -d
   ```

5. **Access RomM** at `http://<EC2_PUBLIC_IP>:8080`

## Project Structure

```
romm/
├── backend/          # Python backend API
├── frontend/         # Web frontend
├── docker/           # Docker configuration files
├── docker-compose.yml # Container orchestration
├── Dockerfile        # Application container image
├── entrypoint.sh     # Container entrypoint script
├── env.template      # Environment variable template
└── docs/             # Documentation
```

## License

This project is licensed under the terms of the [GPL-3.0 License](LICENSE).

---

<div align="center">
  <sub>Built and maintained by <a href="https://github.com/UmarMushtaqMughal">Umar Mushtaq Mughal</a></sub>
</div>
