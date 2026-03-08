# ASCII Diagram Conventions

All skills in this pipeline use ASCII diagrams instead of Mermaid.
These conventions ensure consistency across all generated artifacts.

## Architecture Diagrams (C4-based)

```
External actor:      [Actor Name]            square brackets
System under design: +======= Name =======+  double-line border
External system:     +------- Name -------+  single-line border
Data store:          |= Store Name |         pipes with = sign
Connection:          --- label --->          arrow with label
```

Rules:
- Double-border the system under design to distinguish from external
- Label every connection with protocol/technology and what data flows
- 3-7 elements per diagram maximum
- One diagram tells one story — don't combine levels

Example:
```
  [Tenant Admin]                         [Client App]
       |                                      |
       | HTTPS / manage users                 | HTTPS / auth tokens
       v                                      v
  +============================================+
  ||                                          ||
  ||         Identity Platform                ||
  ||                                          ||
  +============================================+
       |                        |
       | REST / user context    | events / audit
       v                        v
  +-----------+           +-----------+
  | Capstone  |           | Audit Log |
  +-----------+           +-----------+
```

## Sequence Diagrams

```
Participant:      Name at top, | lifeline below
Sync message:     -------->    label above the arrow
Response:         <--------    label above the arrow
Self-call:        |-----.
                  |<----'
Async / fire:     - - - - ->   dashed arrow
```

Blocks:
```
ALT block:
    |  ___ALT [condition]____________________________|
    |  |                                             |
    |  |  (true branch)                              |
    |  |_____________________________________________|
    |  | [else]                                      |
    |  |  (false branch)                             |
    |  |_____________________________________________|

LOOP block:
    |  ___LOOP [for each item]_______________________|
    |  |                                             |
    |  |  (repeated content)                         |
    |  |_____________________________________________|

OPT block:
    |  ___OPT [if condition]_________________________|
    |  |                                             |
    |  |  (optional content)                         |
    |  |_____________________________________________|
```

Rules:
- 3-5 participants maximum per diagram
- Label messages with actual endpoint or method names
- Show request AND response for every synchronous call
- Include error paths as ALT blocks
- Order participants left-to-right by interaction order
- Width under 80-100 characters
- One diagram per use case or critical flow

## Workflow / Process Map / Flowchart

```
Start/End:       ( Start )  or  ( End )       rounded parens
Process step:    +-------------------+
                 |  Step Name        |
                 +-------------------+
Decision:        < Question? >                angle brackets (ASCII diamond)
Branch labels:   Yes / No on lines from decision
Parallel fork:   ==========                   double line
Parallel join:   ==========                   double line
Swimlane:        |  Actor Name  |             vertical pipes with label
```

Rules:
- Label every decision branch (Yes/No, or named conditions)
- Maximum 5-6 decision points per diagram — split if more
- Consistent box widths where possible
- No crossing flow lines — restructure if they cross

## Activity Diagrams

Same as workflow conventions plus:
```
Initial node:    (@)       filled circle
Final node:      (X)       circle with X
Fork bar:        ==========
Join bar:        ==========
Guard:           [condition] on transition
Object node:     [ :ClassName ]  represents data object
```

Use activity diagrams ONLY when you need to show parallel processing
paths that flowcharts cannot express. Otherwise use a standard workflow.

## Data Flow Diagrams (DFD)

```
External entity:  [Entity Name]       square brackets
Process:          (N.N Process Name)  parentheses with number
Data store:       |= DN Store Name |  pipes with = sign and number
Data flow:        --- label --->      arrow with label describing data
```

Rules:
- Every data flow MUST have a label describing what data moves
- Every process must have at least one input AND one output
- Data stores connect ONLY to processes (never directly to external entities)
- External entities connect ONLY to processes

Levels:
- Context diagram: system as single box, show external entities only
- Level 0: major processes (3-7) within the system
- Level 1: decompose one Level 0 process (rarely needed)

## Class / Entity-Relationship Diagrams

```
+------------------+
|  ClassName       |
+------------------+
| + PublicProp     |     +  public
| - PrivateProp   |     -  private
| # ProtectedProp |     #  protected
+------------------+
| + Method(): Ret  |
+------------------+
```

Special markers:
```
<<abstract>>       above class name for abstract classes
<<interface>>      above class name for interfaces
<<enum>>           above class name for enumerations
```

Relationships:
```
Inheritance:     ---|>     child ---|> parent        (solid line, open arrow)
Implements:      ...|>    class ...|> interface      (dashed line, open arrow)
Composition:     *---     whole *--- part            (part cannot exist alone)
Aggregation:     o---     whole o--- part            (part can exist alone)
Association:     --->     one ---> another           (solid line, filled arrow)
Dependency:      ..->     one ..-> another           (dashed line)
```

Cardinality:
```
1---1    one to one
1---*    one to many
*---*    many to many (usually via junction table)
```

Rules:
- 5-10 classes per diagram maximum
- Show public properties relevant to domain behaviour
- Show key public methods that define the behavioral contract
- Hide: private helpers, framework infrastructure, auto-generated props
- Start diagrams after ~10-20% completion when core classes stabilise

## UI Mockups

Components:
```
TEXT INPUTS                  BUTTONS
[_______________]            [* PRIMARY *]        primary action
[John Smith_____]            [ Secondary ]        secondary action
[••••••••_______]            [+] Add              icon button
                             [ DANGER  ]          destructive action

SELECTION                    STATUS
[x] Checked                  ● Active
[ ] Unchecked                ○ Inactive
(o) Selected radio           ◐ Pending
( ) Unselected radio

DROPDOWN                     TOGGLE
[ Option Name       |v]     [    ●===] On
                             [===○    ] Off

NAVIGATION                   ALERTS
▶ Collapsed                  ✓ Success message          [✕]
▼ Expanded                   ⚠ Warning message          [✕]
← Back                       ✕ Error message            [✕]
                             ℹ Info message             [✕]

TABS                         PAGINATION
[ Active ]  Tab2   Tab3      [ < ]  1  2  3  [ > ]

BREADCRUMB                   PROGRESS
Home > Section > Page        [████████░░░░░░] 60%

STEPPER                      SEARCH
(1)────(2)────(3)            [ Search..._______ ] [🔍]
  ✓      ●      ○

TABLE SORT                   CHIP / TAG
Name          ↕              [ Tag One ✕]  [ Tag Two ✕]
```

Rules:
- Width 70-80 characters preferred, 100 absolute maximum
- Use realistic data ("John Smith", "alice@acme.com") not placeholders
- Show 3-5 sample rows in tables
- Distinguish primary from secondary buttons
- Create SEPARATE mockups for each state:
  - Populated (normal operation with data)
  - Empty (no data yet — include call-to-action)
  - Error (validation errors, server errors)
  - Loading (if async operations)
- Label every interactive element
- Align borders carefully — one character off breaks readability
