## `BankAccount#__invariant__`

### Parameters


### Preconditions


### Returns
`unspecified`

### Observed State
| Field | Deep | Comparator |
|---|---:|---|


### Permitted Changes


### Required Changes
None.

### Invariants
- balance cannot be negative
- status is valid

### Allowed Exceptions

## `BankAccount#withdraw`

### Parameters
- `amount`: `Numeric`

### Preconditions
- positive amount
- active account

### Returns
`unspecified`

### Observed State
| Field | Deep | Comparator |
|---|---:|---|
| `balance` | No | `eql?` |
| `audit_log` | Yes | `eql?` |

### Permitted Changes
- `balance`
- `audit_log`

### Required Changes
None.

### Invariants
- balance cannot be negative
- status is valid

### Allowed Exceptions

