# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-05-03

### Added

*   Initial release of OD&H TorProxy Docker image.
*   Supports Socks5, HTTP, and Shadowsocks proxy protocols.
*   Includes Lyrebird, Meek, and Snowflake pluggable transports for censorship circumvention.
*   Uses Tor DNS resolver for enhanced privacy.
*   Multi-platform image (x86\_64, ARM, etc.).
*   Configurable via environment variables and volume mounts.
*   Kubernetes deployment example.

### Changed

*   Rebranded the TorProxy Docker image for Oblivion Development & Hosting (OD&H).
*   Improved documentation with clearer instructions and examples.
*   Enhanced security by requiring a password for the Tor control port.
*   Optimized the Dockerfile for reduced image size and faster builds.
*   Updated Tor configuration to include security best practices.

### Fixed

*   Addressed potential DNS leaks by enforcing the use of Tor DNS resolver.
*   Resolved minor configuration issues.

### Security

*   Implemented password hashing for Tor control port authentication.
*   Added security considerations section to the README.
