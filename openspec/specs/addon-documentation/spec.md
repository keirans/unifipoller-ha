## ADDED Requirements

### Requirement: DOCS.md for add-on store display
The add-on SHALL include a `DOCS.md` file in the add-on directory that is displayed in the HA Supervisor add-on store UI after installation.

#### Scenario: Documentation visible in Supervisor UI
- **WHEN** a user opens the add-on page in the Supervisor
- **THEN** the content of `DOCS.md` SHALL be rendered in the Documentation tab

### Requirement: DOCS.md covers configuration options
The `DOCS.md` SHALL document every option exposed in the `config.yaml` schema, including its type, valid values, default, and a description of its effect.

#### Scenario: User can configure without external reference
- **WHEN** a user reads `DOCS.md`
- **THEN** they SHALL find an explanation for every option available in the Supervisor config panel

### Requirement: DOCS.md includes prerequisite information
The `DOCS.md` SHALL state that a reachable UniFi Network Controller and at least one configured exporter (InfluxDB or Prometheus) are required before the add-on will function.

#### Scenario: Prerequisites clearly listed
- **WHEN** a user reads the Prerequisites section of `DOCS.md`
- **THEN** they SHALL know they need a UniFi controller and an exporter endpoint before installing

### Requirement: DOCS.md documents credential security guidance
The `DOCS.md` SHALL advise users to create a dedicated read-only UniFi controller account for the add-on rather than using admin credentials.

#### Scenario: Security recommendation present
- **WHEN** a user reads the Security section of `DOCS.md`
- **THEN** they SHALL see a recommendation to use a least-privilege controller account

### Requirement: README.md at repository root
The repository SHALL include a `README.md` that describes the add-on repository, links to the individual add-on `DOCS.md`, and provides the repository URL for adding to Home Assistant.

#### Scenario: Repository URL included
- **WHEN** a user reads the `README.md`
- **THEN** they SHALL find `https://github.com/keirans/unifipoller-ha` clearly presented as the URL to add in the HA Supervisor

### Requirement: Step-by-step repository installation instructions
The `README.md` SHALL include a dedicated Installation section with numbered steps guiding the user through adding the repository to Home Assistant and installing the add-on.

#### Scenario: User can follow instructions without prior add-on store knowledge
- **WHEN** a user reads the Installation section of `README.md`
- **THEN** they SHALL find the following steps in order:
  1. Navigate to Settings → Add-ons → Add-on Store in Home Assistant
  2. Click the menu icon (⋮) in the top-right corner and select Repositories
  3. Enter `https://github.com/keirans/unifipoller-ha` and click Add
  4. Find and click the UniFi Poller add-on in the store
  5. Click Install and wait for the image to download
  6. Configure the add-on options before starting

#### Scenario: One-click badge in README
- **WHEN** a user views the `README.md` on GitHub
- **THEN** they SHALL see an "Add Repository" badge or button that deep-links directly to the HA Supervisor repository dialog pre-filled with the repository URL

### Requirement: Architecture support documented
Both `DOCS.md` and `README.md` SHALL clearly state which CPU architectures are supported by the add-on.

#### Scenario: Unsupported architecture guidance
- **WHEN** a user on an unsupported architecture reads the documentation
- **THEN** they SHALL find a note that their architecture is not yet supported and a pointer to raise a request

### Requirement: Exporter model differences documented
The `DOCS.md` SHALL include a section explaining how InfluxDB and Prometheus exporters differ in their data delivery model, and the implications of running both simultaneously.

#### Scenario: User understands push vs pull distinction
- **WHEN** a user reads the Exporters section of `DOCS.md`
- **THEN** they SHALL find an explanation that InfluxDB is a push model (UniFi Poller writes data on each poll) and Prometheus is a pull model (Prometheus scrapes an exposed endpoint)

#### Scenario: Dual-exporter resource implications documented
- **WHEN** a user considers enabling both exporters
- **THEN** `DOCS.md` SHALL inform them that doing so results in two independent metric stores each with their own storage and retention requirements, and that an inbound network port must be open for Prometheus scraping

#### Scenario: Single controller limitation documented
- **WHEN** a user reads `DOCS.md`
- **THEN** they SHALL find a note that only a single UniFi controller is supported per add-on instance

### Requirement: Exporter compatibility table
The `DOCS.md` SHALL include a compatibility table listing the support status of each exporter version, distinguishing between officially supported, community-supported, and unsupported versions.

#### Scenario: InfluxDB version compatibility clear
- **WHEN** a user reads the compatibility table
- **THEN** they SHALL see that InfluxDB 1.8.x is officially supported, 1.10 and 1.11 are community-supported, and 2.x is not supported

#### Scenario: Prometheus version compatibility clear
- **WHEN** a user reads the compatibility table
- **THEN** they SHALL see that Prometheus 2.x is required

#### Scenario: Loki absence explained
- **WHEN** a user reads the compatibility table or looks for Loki support
- **THEN** they SHALL find a note that Loki is not supported in the current release

### Requirement: Community support definition in documentation
The `DOCS.md` SHALL define what "community-supported" means in context: that the version is not tested by maintainers but is reported to work by community members, and that issues should be raised with reproduction details.

#### Scenario: User understands community support scope
- **WHEN** a user running InfluxDB 1.10 reads the docs
- **THEN** they SHALL understand they can use the add-on but should not expect the same level of support as 1.8.x users

### Requirement: Contribution guide with local build instructions
The repository SHALL include a `CONTRIBUTING.md` at the root that explains how contributors can build and test the add-on container image locally without relying on CI.

#### Scenario: Contributor can build locally
- **WHEN** a contributor reads `CONTRIBUTING.md`
- **THEN** they SHALL find step-by-step instructions covering: cloning the repository, running `docker build` with the required `UNPOLLER_VERSION` build arg, and verifying the resulting image

#### Scenario: Contributor knows how to run the container locally
- **WHEN** a contributor reads `CONTRIBUTING.md`
- **THEN** they SHALL find an example `docker run` command demonstrating how to pass options as environment variables or a mounted config file for local smoke-testing

#### Scenario: Contributor understands lint requirements
- **WHEN** a contributor reads `CONTRIBUTING.md`
- **THEN** they SHALL find instructions for running the JSON and YAML lint checks locally using `jq` and `yq` before submitting a pull request

### Requirement: CONTRIBUTING.md explains Docker build context exclusion
The `CONTRIBUTING.md` SHALL include an explanation that the `openspec/` directory is excluded from Docker images via `.dockerignore`, stating the reason (HA Supervisor scans subdirectories for `config.yaml` files and would attempt to parse `openspec/config.yaml` as an add-on manifest) and confirming that this has no effect on CI builds.

#### Scenario: Contributor understands why openspec is excluded
- **WHEN** a contributor reads the Local Build section of `CONTRIBUTING.md`
- **THEN** they SHALL find a note that `openspec/` is listed in `.dockerignore` and an explanation that this prevents the HA Supervisor from misidentifying it as an add-on

### Requirement: OpenSpec referenced as the development workflow tool
The `CONTRIBUTING.md` SHALL include a section explaining that development tasks, proposals, and design decisions are tracked using OpenSpec, and directing contributors to the `openspec/` directory.

#### Scenario: Contributor finds OpenSpec guidance
- **WHEN** a contributor reads the Development Workflow section of `CONTRIBUTING.md`
- **THEN** they SHALL find a reference to OpenSpec, a brief explanation that it is used to manage change proposals and implementation tasks, and an instruction to run `openspec list` to see active changes

#### Scenario: Contributor knows where changes live
- **WHEN** a contributor wants to understand what is being worked on
- **THEN** they SHALL be directed to `openspec/changes/` for in-progress work and `openspec/specs/` for capability specifications
