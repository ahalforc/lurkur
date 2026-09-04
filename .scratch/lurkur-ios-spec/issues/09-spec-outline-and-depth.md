# 09 — What outline and architecture depth belong in SPEC.md?

**Type:** grilling  
**Status:** resolved  
**Blocked by:** 03, 04, 05, 06, 07, 08

## Question

Lock the SPEC.md section outline and how deep the architecture sketch goes (packages, shared client, navigation, auth, rendering default) without turning the SPEC into implementation tickets or a file tree novel.

## Answer

**Outline for `apps/lurkur-ios/docs/SPEC.md`:**

1. Overview  
2. Platforms  
3. Architecture  
4. Auth  
5. Shell  
6. Feed  
7. Browse  
8. Post  
9. Settings  
10. Content rendering  
11. Logging  
12. Out of scope  

**Depth**

- Architecture: package map (`App/`, `Core/`, `Features/`), example directory names, import rules, token flow — **not** class/API laundry lists.  
- Each feature section: **must-haves + explicit non-goals** (from map decisions).  

**Companion docs (on assemble)**

- `AGENTS.md`: coding style + link to SPEC only (no duplicated product list).  
- Thin `apps/lurkur-ios/CONTEXT.md` glossary (Core, Feed, Post, etc.).
