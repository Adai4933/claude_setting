---
name: c-readme
description: Write a polished README for the project
---

You are a technical writing specialist. Write a README for the user's project that is beautiful, informationally correct, and concise.

## Workflow: Write Project README

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Analyze Project
1. Read the project's source code, Makefile, and configuration files.
2. Identify the tech stack, prerequisites, entry points, and key features.
3. Find any existing README and note what can be kept or improved.
- **Validation:** List the key facts you discovered (name, purpose, stack, commands) before writing.

### Step 2: Draft README
1. Write the README following the template guidelines below.
2. Use the reference example README as inspiration for structure and tone — it demonstrates a well-organized README with clear sections for features, tech stack, API endpoints, setup, Docker, and development.
3. Adapt the structure to fit the current project's needs (not all sections may be relevant).
- **Validation:** Verify every section has accurate information by cross-referencing with the actual source code.

### Step 3: Validate Completeness
1. Check that a new contributor could set up and use the project by reading only the README.
2. Verify all commands in the README actually work.
3. Confirm all prerequisites and versions are accurate.
- **Validation:** Run any documented commands (like `make help`) to verify they work.

### Step 4: Finalize
1. Polish formatting — check for consistent heading levels, code block languages, and table alignment.
2. Remove any redundant or outdated information.
3. Ensure the README is concise — no walls of text.
- **Validation:** README is well-formatted and concise.

---

# README Writing Guidelines

Write a README that is beautiful, informative, and concise. Follow this structure:

## Structure

### Header
- Centered project logo (if available) or a styled title using HTML `<h1 align="center">`.
- One-line description in bold below the title.
- Badge row for key metadata (language version, platform, version).

```markdown
<p align="center">
  <img src="res/img/logo.svg" alt="Project Name" width="120" />
</p>

<h1 align="center">Project Name</h1>

<p align="center">
  <strong>One-line project description</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/python-3.13+-3776AB?logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/version-1.0.0-blue" alt="Version" />
</p>
```

### Overview
- 2-3 sentences describing what the project does.
- Bulleted list of key features.

### Quick Start
- Installation: `make install`
- Build/Run: show the primary commands
- Cleanup: `make clean` / `make uninstall`

### Prerequisites
- Table format with Requirement, Version, and Notes columns.

### Project Structure
- ASCII tree diagram of the key directories.

### Usage
- Table of all Makefile targets with descriptions.
- Code blocks for common workflows.

### Development
- How to format code: `make format`
- How to commit: `make commit`
- How to run tests: `make test`

### Troubleshooting
- Use collapsible `<details>` sections for common issues.

### Contributing
- Brief workflow (branch, change, format, PR).

### License
- One line.

## Style Rules

- Keep it concise — no walls of text.
- Use tables over prose for structured information.
- Use horizontal rules (`---`) to separate major sections.
- Use code blocks generously for commands.
- Prefer imperative mood ("Install dependencies" not "You can install dependencies by...").



# README Maintenance

After completing your task, update the README if: new deps added/removed, new commands/targets, new scripts/tools, config changes affecting setup, new user-facing features, or breaking changes. Do NOT update for internal refactors, bug fixes without behavior change, or style changes. Keep additions concise, remove outdated content.



---

## Reference Resources

### `readme-example.md`

```
# Solaris - Weather Station API

A mock weather station backend providing real-time sensor data, compliant with the OpenWeather Data Collector specification.

## Features

- Full HTTP API implementation with all required endpoints
- WebSocket streaming for state and sensor data
- Session recording with proper folder structure and metadata
- Docker containerization support
- Simulated sensors: 3 thermometers and 1 barometric pressure sensor

## Tech Stack

- **Python 3.13+** (managed via `uv`)
- **FastAPI** - Web framework
- **Uvicorn** - ASGI server
- **aiofiles** - Async file operations
- **aiohttp** - Async HTTP client
- **numpy** - Numerical operations
- **uvloop** - High-performance event loop

## API Endpoints

### HTTP Endpoints

- `GET /state` - Get current station state
- `POST /session/start` - Start recording a session
- `POST /session/stop` - Stop recording and save session data
- `GET /sensors` - List available sensors
- `POST /station/start` - Start the station
- `POST /station/stop` - Stop the station
- `POST /station/maintenance` - Enter maintenance mode
- `DELETE /station/maintenance` - Exit maintenance mode
- `GET /health` - Health check

### WebSocket Endpoints

- `WS /ws/state` - Stream station state (~30 messages/sec)
- `WS /ws/sensors/stream/<device_id>` - Stream sensor data
  - `thermo_indoor`, `thermo_outdoor`, `thermo_ground` - Temperature streams
  - `barometer` - Float pressure values in hPa

## Sensors

The weather station provides the following sensors:

1. **thermo_indoor** - Indoor temperature stream (Celsius)
2. **thermo_outdoor** - Outdoor temperature stream (Celsius)
3. **thermo_ground** - Ground temperature stream (Celsius)
4. **barometer** - Barometric pressure in hPa

## Station States

The station supports the following states:

- `OFF` - Station is not active
- `BOOT` - Station is booting
- `ACTIVE` - Ready for data collection
- `CALIBRATE` - Station is calibrating sensors
- `RECORD` - Station is recording a session
- `STOPPED` - Station has stopped operation
- `PAUSE` - Recording paused, can resume
- `MAINTENANCE` - Station is in maintenance mode

## Session Data Format

Sessions are saved to `/data/session_root` with the following structure:

```
YYYYMMDD_HHMMSS_NNNNNN/
├── session-metadata.json
├── data.parquet
└── .state.json
```

The `.state.json` file is created when the session is ready for processing.

## Docker Setup

### Build the Docker Image

```bash
docker build -t solaris:latest .
```

### Run the Container

```bash
docker run -d \
  -p 8080:8080 \
  -v /path/to/session_root:/data/session_root:rw \
  -v /path/to/scratch_space:/data/scratch_space:rw \
  -v /path/to/config.jsonc:/data/config.jsonc:ro \
  solaris:latest
```

### Docker Volumes

- `/data/session_root` - Session data storage (read-write)
- `/data/scratch_space` - Temporary/intermediate data (read-write, may be volatile)
- `/data/config.jsonc` - Station configuration (read-only)

## Development

### Prerequisites

- Python 3.13+
- [uv](https://github.com/astral-sh/uv) package manager

### Installation

```bash
# Install dependencies
uv pip install -e .

# Run the application
python -m solaris.main
# or
uvicorn solaris.app:app --host 0.0.0.0 --port 8080
```

### Testing

The API will be available at `http://localhost:8080`

Example requests:

```bash
# Get station state
curl http://localhost:8080/state

# Start station
curl -X POST http://localhost:8080/station/start

# Start recording
curl -X POST http://localhost:8080/session/start

# Stop recording
curl -X POST http://localhost:8080/session/stop \
  -H "Content-Type: application/json" \
  -d '{"is_success": true}'

# Get sensors
curl http://localhost:8080/sensors
```

## Configuration

See `config.jsonc` for an example configuration file. The configuration is read from `/data/config.jsonc` when running in Docker.

## License

Proprietary — © WorldEngine. All rights reserved.
```

---

## Completion Checklist

- [ ] All sections from the template are covered (where applicable).
- [ ] Commands in the README are accurate and tested.
- [ ] Prerequisites and versions are correct.
- [ ] README is concise and well-formatted.
- [ ] A new contributor can get started by reading the README alone.
