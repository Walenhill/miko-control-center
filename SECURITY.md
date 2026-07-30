# Security policy

Miko Control Center invokes local system tools and can expose diagnostic
information. Do not include tokens, tunnel credentials, private addresses,
hostnames, command output or personal device identifiers in bug reports.

Report a security issue privately through GitHub's security advisory feature
when available. Do not open a public issue containing credentials or an
exploitable privileged command path.

The installer operates only in user XDG directories. The project does not
install sudoers rules, polkit policies or system services.
