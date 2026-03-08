# Domain Reference: Identity & Authentication

Load this reference when a feature involves authentication, authorization,
user management, OAuth/OIDC, or access control.

## Domain Checklist

Walk through each item with the user. For each, determine: IN SCOPE, DEFERRED, or EXCLUDED.

### Authentication Flows
- [ ] Login flow (username/password, OAuth authorization code)
- [ ] Logout flow (session termination, token revocation)
- [ ] Token refresh (access token expiry, refresh token rotation)
- [ ] Multi-factor authentication (TOTP, SMS, email verification)
- [ ] Password reset / recovery
- [ ] Account lockout (failed attempt thresholds, unlock mechanism)
- [ ] Remember me / persistent sessions
- [ ] External IdP federation (SAML, OIDC from customer IdPs)

### Authorization Model
- [ ] Role-based access control (RBAC) — roles, role hierarchy
- [ ] Permission-based access — granular permissions per role
- [ ] Claims-based authorization — custom claims on tokens
- [ ] Policy-based authorization — framework-level policy enforcement
- [ ] Tenant isolation — users see only their tenant's data
- [ ] Resource-level authorization — per-object access control
- [ ] API scope enforcement — OAuth scopes on endpoints

### Application / Client Management
- [ ] Application registration (confidential, public, device clients)
- [ ] Client ID and secret generation
- [ ] Client secret rotation
- [ ] Redirect URI management (registration, validation)
- [ ] Allowed grant types configuration
- [ ] Application metadata (name, description, logo)
- [ ] Application enable/disable lifecycle
- [ ] Application deletion (soft delete, cascade rules)

### Scope & Consent Management
- [ ] Scope definition (API scopes, identity scopes)
- [ ] Scope assignment to applications
- [ ] User consent flows (prompt, remember, revoke)
- [ ] Scope display names and descriptions

### Token Lifecycle
- [ ] Access token format (JWT, reference tokens)
- [ ] Access token lifetime configuration
- [ ] Refresh token lifetime and rotation policy
- [ ] ID token claims configuration
- [ ] Token introspection endpoint
- [ ] Token revocation endpoint

### User Management
- [ ] User creation (admin-created, self-registration)
- [ ] User profile management (name, email, phone)
- [ ] User activation / deactivation
- [ ] User deletion (soft delete, POPIA right-to-erasure)
- [ ] Bulk user operations (import, export, bulk status change)
- [ ] User search and filtering

### Role & Permission Management
- [ ] Role CRUD (create, assign, revoke)
- [ ] Permission CRUD
- [ ] Role-permission mapping
- [ ] Default roles for new users
- [ ] Role hierarchy / inheritance

### Multi-Tenancy
- [ ] Tenant provisioning
- [ ] Tenant isolation strategy (schema-per-tenant, row-level, db-per-tenant)
- [ ] Cross-tenant operations (super-admin only)
- [ ] Tenant-specific configuration (branding, policies)

### Audit & Compliance
- [ ] Audit logging — all auth events (login, logout, failed attempts)
- [ ] Audit logging — all CRUD operations on users, roles, apps
- [ ] Audit log retention policy
- [ ] Audit log search and export
- [ ] POPIA compliance (purpose limitation, data minimization)
- [ ] SOC 2 evidence (access control, change management)

## Technical Patterns

_These patterns are framework-agnostic. Your project's CLAUDE.md specifies which frameworks implement them._

### OAuth/OIDC Entities (typical)
- Application: ClientId, DisplayName, RedirectUris, Permissions, Type, ClientSecret
- Authorization: Subject, Application, Scopes, Status, Type
- Token: Type, Subject, Application, ExpirationDate, Status
- Scope: Name, DisplayName, Resources, Description

### User Entities (typical)
- User: extends base user with TenantId, FullName, IsActive, LastLogin
- Role: extends base role with TenantId, Description, IsSystem
- UserClaim, RoleClaim: custom claims for authorization

### Authorization Patterns
- Policy-based authorization on endpoints
- Custom handlers for resource-level auth
- Claims/token-based tenant context extraction
- Tenant middleware — resolve tenant from token claims

### API Patterns
- Endpoints grouped by resource: /api/v1/applications, /api/v1/users, /api/v1/roles
- Cursor-based pagination for large lists
- ETag-based concurrency for updates
- Consistent error response format with problem details (RFC 7807)

### Security Patterns
- Client secrets: hashed (BCrypt or equivalent), never stored in plaintext, shown once on creation
- Redirect URIs: exact match validation, no wildcards in production
- PKCE: enforced for public clients, optional for confidential
- Rate limiting: per-tenant, per-endpoint for sensitive operations
- CORS: strict origin allowlist per application
- CSP headers: prevent XSS in admin UI

### Frontend Auth Patterns
- Route guards for authentication, roles, and permissions
- HTTP interceptor for token refresh
- Forms with server-side validation error mapping
- Pessimistic UI updates for destructive operations (delete, revoke)
- Optimistic UI updates for non-destructive (edit, toggle)
