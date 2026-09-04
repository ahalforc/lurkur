# lurkur-ios

SwiftUI Reddit reader replacing the legacy Flutter app (`apps/flutter/`).

**Product spec:** [docs/SPEC.md](docs/SPEC.md)  
**Glossary:** [CONTEXT.md](CONTEXT.md)

## Coding style

- Standard SwiftUI practices; keep theming minimal.
- Simple business logic; keep state management minimal (`@Observable` / environment).
- Follow package boundaries and import rules in the SPEC (App / Core / Features).
