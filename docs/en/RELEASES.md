# Release model

Miko Control Center uses standard [Semantic Versioning](https://semver.org/)
for package ordering and compatibility. The release names add project identity
without replacing the machine-readable version.

## Channels

### Lunar

Experimental builds for new interaction models, architecture changes and ideas
that still need real-world testing.

- Tag format: `v0.3.0-lunar.1`, `v0.3.0-lunar.2`, ...
- GitHub title: `Lunar · v0.3.0-lunar.1`
- Stability: prerelease; migration or rollback may be required.

### Silverstar

Regular stable releases suitable for everyday use on the supported system
profile.

- Tag format: standard SemVer, for example `v0.2.2` or `v0.3.0`.
- GitHub title: `Silverstar · v0.2.2`
- Stability: tested release with documented limitations.

### Cadence

Large, completed milestones that establish a new stable generation of the
project.

- Tag format: a major SemVer milestone, for example `v1.0.0` or `v2.0.0`.
- GitHub title: `Cadence · v1.0.0`
- Stability: stable generation with an explicit upgrade path.

## Promotion flow

An upcoming version may begin as `Lunar · v0.3.0-lunar.1`. Once its design,
behavior and migration path are stable, the prerelease suffix is removed and it
becomes `Silverstar · v0.3.0`. A sufficiently large and complete generation
is published as a Cadence major release.

The `VERSION` file always contains only the numeric SemVer value expected by
packaging and installation scripts.
