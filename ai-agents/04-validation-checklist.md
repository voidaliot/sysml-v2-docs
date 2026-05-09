# 04 — Validation Checklist

Run this checklist **before** returning any `.sysml` content to the user. The goal is to catch the mistakes that account for ~95% of bad outputs from a generative model. Treat each item as a yes/no gate.

---

## A. Lexical and structural

- [ ] **A1.** All keywords are lowercase.
- [ ] **A2.** Every element declaration ends with `;` or `{ … }`.
- [ ] **A3.** Every `{` has a matching `}`. Run a depth counter mentally if the file is large.
- [ ] **A4.** Every `[` has a matching `]`.
- [ ] **A5.** Every `(` has a matching `)`.
- [ ] **A6.** Every `'…'` (escaped name) and `"…"` (string) is closed on the same line.
- [ ] **A7.** Block comments `/* … */` are closed.
- [ ] **A8.** No `//` or `/* */` appears mid-expression inside a constraint body.

---

## B. Names and scoping

- [ ] **B1.** Every type reference (`: Type`, `:> Type`, `:>> Type`) refers to a name that is either declared earlier in the same file, declared in another file imported by this file, or in a standard-library package that is imported.
- [ ] **B2.** No name shadows a standard-library symbol (`Real`, `Integer`, `MassValue`, `Vehicle` if `Vehicle` happens to be in a library, etc.).
- [ ] **B3.** Qualified names use `::` (not `.`).
- [ ] **B4.** Feature paths use `.` (not `::`).
- [ ] **B5.** Every `import` references a real package — `ISQ`, `SI`, `ScalarValues`, `Geometry`, `Quantities`, or a user-defined one declared elsewhere.
- [ ] **B6.** Names with whitespace or special characters are wrapped in `'…'`.

---

## C. Definition vs usage

- [ ] **C1.** Reusable types use `*-def` (`part def`, `port def`, `requirement def`, …).
- [ ] **C2.** Specific occurrences in a context use the bare form (`part`, `port`, `requirement`, …).
- [ ] **C3.** I have **not** written `part def myCar { … }` when I meant a single instance called `myCar`.
- [ ] **C4.** Each major reusable concept has at least one corresponding usage that demonstrates it (otherwise the model is hard to verify).

---

## D. Modifiers and keyword order

- [ ] **D1.** Modifier order is `visibility → abstract → variation → variant → derived → readonly → ref → individual → snapshot → timeslice → direction → element-keyword → def?`.
- [ ] **D2.** `def` appears immediately after the element keyword (not before, not separated by a name).
- [ ] **D3.** `abstract` is only on definitions, not on usages.
- [ ] **D4.** `ref` is only on usages, not on definitions.
- [ ] **D5.** `in` / `out` / `inout` appear only on parameters and ports, not on parts.

---

## E. Specialization and redefinition

- [ ] **E1.** `:>` connects a definition to one or more parent definitions (covariant subtyping).
- [ ] **E2.** `:>>` redefines an inherited feature; the redefined name must exist in the parent.
- [ ] **E3.** I have not used `:>` where `:>>` is required (or vice versa).
- [ ] **E4.** Conjugate ports use the `~` prefix on the type, not a manually-flipped duplicate body.

---

## F. Multiplicity

- [ ] **F1.** Multiplicities are inside `[ ]` and appear after the name and type.
- [ ] **F2.** Bounds are non-negative integers or `*` for unbounded.
- [ ] **F3.** The lower bound does not exceed the upper bound.
- [ ] **F4.** Where the user said "exactly N", I wrote `[N]` (or omitted multiplicity for `[1]`).
- [ ] **F5.** Where the user said "optional", I wrote `[0..1]`.
- [ ] **F6.** Where the user said "many", I wrote `[0..*]` or `[1..*]` based on whether zero is allowed.

---

## G. Attributes and quantities

- [ ] **G1.** Every numeric attribute that has physical meaning uses a library quantity type (`MassValue`, `LengthValue`, `TimeValue`, …) — not a bare `Real`.
- [ ] **G2.** Every quantity literal includes a unit in `[ ]`: `1500 [kg]`, `30 [km/h]`, `100 [Pa]`.
- [ ] **G3.** Unit symbols are real SI symbols (`kg`, `m`, `s`, `A`, `K`, `mol`, `cd`, `Hz`, `N`, `Pa`, `J`, `W`, `V`, `Ω`, `°C`, `km`, `mm`, `min`, `h`, `km/h`, …).
- [ ] **G4.** Boolean / Integer / String / Real attributes use bare values without unit brackets.
- [ ] **G5.** I have used `==` (not `=`) for equality checks in expressions.

---

## H. Connections and topology

- [ ] **H1.** Every `connect a.x to b.y` references existing ports on existing parts.
- [ ] **H2.** Connection direction is consistent — out goes to in (or both endpoints are bidirectional).
- [ ] **H3.** Where the user described an interface contract, I used `interface def` — not just an inline `connect`.
- [ ] **H4.** I used `ref part` only when the part is owned elsewhere.

---

## I. Behavior

- [ ] **I1.** State machines use `exhibit state { state …; transition first … then …; }`.
- [ ] **I2.** `transition` clauses include both `first` and `then`.
- [ ] **I3.** Sequential actions use `first … then … then …` rather than ad-hoc syntax.
- [ ] **I4.** Pure computations are `calc def`, not `action def`.
- [ ] **I5.** Action parameters use `in`, `out`, or `inout` prefixes.

---

## J. Requirements

- [ ] **J1.** Every `requirement def` has exactly one `subject`.
- [ ] **J2.** Every `requirement def` has at least one `require constraint { … }`.
- [ ] **J3.** Every `requirement def` has a `doc /* … */` capturing the user's intent in plain language.
- [ ] **J4.** Constraint bodies are pure Boolean expressions — no statements, no side effects.
- [ ] **J5.** Constraint expressions use `and`, `or`, `not`, `xor`, `implies` — not `&&`, `||`, `!`.
- [ ] **J6.** Pre-conditions are in `assume constraint { … }`, not folded into `require`.
- [ ] **J7.** Sub-requirements are nested inside their parent, not declared as siblings.

---

## K. Satisfy / Verify links

- [ ] **K1.** `satisfy X` references a `requirement def` or `requirement` — not a part, action, or other element.
- [ ] **K2.** `verify X` similarly references a requirement.
- [ ] **K3.** A `satisfy` appears inside the part (or the relevant element) that claims to meet the requirement.
- [ ] **K4.** A `verify` appears inside an `objective` block of a `verification case`.

---

## L. Packages and imports

- [ ] **L1.** The file has at most one top-level `package`.
- [ ] **L2.** Imports are at the top of the package body.
- [ ] **L3.** Imports use `private` by default unless re-exporting is intended.
- [ ] **L4.** Wildcard imports (`Pkg::*`) are only used when many members are needed; otherwise specific imports are preferred.
- [ ] **L5.** No circular imports between user packages.

---

## M. `doc` comments

- [ ] **M1.** Every top-level definition has a `doc /* … */`.
- [ ] **M2.** Every requirement has a `doc /* … */` paraphrasing the user's "shall" sentence.
- [ ] **M3.** `doc` comments are inside the element body or directly attached to a sibling — never floating.

---

## N. Output hygiene

- [ ] **N1.** The file uses 4-space indentation consistently (or 2, but consistently).
- [ ] **N2.** There is one blank line between top-level definitions, no blank lines inside a small body.
- [ ] **N3.** The file ends with a newline.
- [ ] **N4.** I am returning **only the `.sysml` content** with minimal accompanying prose; the model speaks for itself.
- [ ] **N5.** If I made an assumption (units, defaults, structure), it appears as a `// ASSUMPTION:` comment in the output, or I asked the user a focused question instead.

---

## O. Final mental compile

Read the file end-to-end, in your head. Ask:

- Does it parse?
- Could a human reader, knowing nothing about the user's prompt, recover what the user asked for from the model alone?
- Is each element's name informative?
- Are all my `:>` chains rooted in a real type?
- Are there any dangling references (a name that appears in a `: T` or `verify R` that isn't declared anywhere)?

If any answer is "no" or "I'm not sure" — fix before returning.

---

## Quick reject patterns (immediate rewrite triggers)

If the draft contains any of these, rewrite:

| Pattern | Why |
|---|---|
| `Part def …`, `PORT def …` | Wrong case. |
| `part def myCar` (where myCar is a single instance) | Def/usage confusion. |
| `attribute mass = 1500;` (mass typed as `MassValue`) | Missing unit. |
| `require constraint { x = y }` | `=` in Boolean position. |
| `require constraint { x > 0 && y > 0 }` | `&&` not allowed. |
| `import StandardTypes::*` | Library doesn't exist. |
| `requirement def Foo { require constraint { … } }` (no subject) | Missing subject. |
| `satisfy myPart;` | Should be `satisfy SomeRequirement`. |
| Two top-level `package` blocks in one file | Invalid file structure. |
| `:>` between unrelated kinds (`part def X :> ActionDef`) | Wrong kind specialization. |
