# Ensembles.jl changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Support for calling noisy-only version of `EnsembleKalmanFilters.assimilate_data` in EnsembleKalmanFiltersExt.

### Changed

- Simplified `split_clean_noisy` to be more generic.
- Fixed call to `NormalizingFlowFilters.assimilate_data` to pass only one set of observations.

### Removed

- Support for Julia <1.9.

## [v1.1.0] - 2024-11-05

### Added

- Extension for `Statistics.std`

### Changed

- Extensions for `Statistics.mean` and `Statistics.var` accept a `state_keys` kwarg.

## [v1.0.0] - 2024-11-04

### Added

First tagged version.
