## ADDED Requirements
### Requirement: Project Structure
Auth Service SHALL follow the standard microservice project structure.

#### Scenario: Directory Layout
- **WHEN** setting up the project
- **THEN** the system SHALL create directories for src/main/java, src/test/java, src/main/resources
- **THEN** the system SHALL organize code by domain, application, infrastructure, and presentation layers

#### Scenario: Configuration Files
- **WHEN** setting up the project
- **THEN** the system SHALL create application.yml for configuration
- **THEN** the system SHALL create Dockerfile for containerization
- **THEN** the system SHALL create pom.xml with necessary dependencies

### Requirement: Database Schema
Auth Service SHALL initialize the database schema on startup.

#### Scenario: Schema Creation
- **WHEN** the service starts
- **THEN** the system SHALL create users table
- **THEN** the system SHALL create oauth_clients table
- **THEN** the system SHALL create necessary indexes

### Requirement: Docker Configuration
Auth Service SHALL be containerizable with Docker.

#### Scenario: Docker Image
- **WHEN** building the Docker image
- **THEN** the system SHALL use OpenJDK 17 as base image
- **THEN** the system SHALL expose port 8080
- **THEN** the system SHALL include all necessary dependencies
