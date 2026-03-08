# Domain Reference: General B2B SaaS

Load this reference when a feature involves multi-tenancy, administration,
configuration, notifications, webhooks, billing, or onboarding.

## Domain Checklist

### Multi-Tenancy
- [ ] Tenant provisioning and onboarding workflow
- [ ] Tenant isolation strategy (data, configuration, branding)
- [ ] Tenant-level feature flags
- [ ] Tenant limits and quotas (users, storage, API calls)
- [ ] Tenant suspension and reactivation
- [ ] Tenant data export
- [ ] Tenant deletion (data retention, cascade)

### Administration & Configuration
- [ ] System settings (global defaults)
- [ ] Tenant settings (overrides global)
- [ ] User preferences (overrides tenant)
- [ ] Configuration change audit trail
- [ ] Configuration validation before save
- [ ] Configuration rollback / reset to defaults

### Notifications
- [ ] Email notifications (transactional, digest)
- [ ] In-app notifications (bell icon, notification center)
- [ ] Notification preferences per user
- [ ] Notification templates (customisable per tenant)
- [ ] Notification delivery tracking (sent, opened, failed)

### Webhooks & Integrations
- [ ] Webhook registration (URL, events, secret)
- [ ] Webhook delivery with retry (exponential backoff)
- [ ] Webhook signature verification (HMAC)
- [ ] Webhook delivery logs
- [ ] API key management (create, rotate, revoke)
- [ ] Rate limiting per API key / tenant

### Data Import / Export
- [ ] CSV/Excel import with validation
- [ ] Import preview and error reporting
- [ ] Bulk operations with progress tracking
- [ ] Data export (CSV, Excel, PDF)
- [ ] Scheduled exports

### Search & Filtering
- [ ] Full-text search across entities
- [ ] Faceted filtering (status, date range, category)
- [ ] Saved filters / views per user
- [ ] Server-side pagination (cursor or offset)
- [ ] Sort by multiple columns

### Audit Trail
- [ ] Who changed what, when (actor, action, timestamp, before/after)
- [ ] Audit log retention policy
- [ ] Audit log search and filtering
- [ ] Audit log export for compliance

## Technical Patterns

### Multi-Tenancy (EF Core)
- Global query filter: `.HasQueryFilter(e => e.TenantId == currentTenantId)`
- TenantId on every entity, set automatically via SaveChanges interceptor
- Tenant resolution: from JWT claim, from subdomain, or from header

### Pagination
- Cursor-based: `?after={lastId}&limit=20` — preferred for large datasets
- Offset-based: `?page=1&pageSize=20` — simpler but slower at scale
- Always return: items, totalCount, hasNextPage, cursor/pageInfo

### Background Jobs
- IHostedService for simple scheduled tasks
- Hangfire or similar for complex job queues
- Idempotency keys on all background operations
- Dead letter queue for failed jobs

### Angular Patterns
- Smart/dumb component pattern (container loads data, presentational renders)
- Reactive forms with async validators for server-side checks
- NgRx or signal-based state for complex page state
- Infinite scroll or virtual scroll for large lists
- Skeleton loaders during data fetch
