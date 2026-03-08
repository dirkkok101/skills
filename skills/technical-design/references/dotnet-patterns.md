# .NET/C# Pattern Reference for Technical Design

This reference contains detailed patterns for the API specification phase. Read this when generating `api-spec.md`.

---

## CQRS Pattern (MediatR)

### Command Pattern
```csharp
// Command (write operation)
public record Create{Resource}Command(
    string Name,
    string Description,
    Guid? ParentId
) : IRequest<{Resource}Response>;

// Handler (primary constructor)
public class Create{Resource}CommandHandler(
    IApplicationDbContext context,
    IMapper mapper) : IRequestHandler<Create{Resource}Command, {Resource}Response>
{
    public async Task<{Resource}Response> Handle(
        Create{Resource}Command request,
        CancellationToken cancellationToken)
    {
        var entity = new {Resource}Entity
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Description = request.Description,
            CreatedAt = DateTime.UtcNow
        };

        context.{Resources}.Add(entity);
        await context.SaveChangesAsync(cancellationToken);

        return mapper.Map<{Resource}Response>(entity);
    }
}
```

### Query Pattern
```csharp
// Query (read operation)
public record Get{Resource}ByIdQuery(Guid Id) : IRequest<{Resource}Response>;

// List query with pagination
public record Get{Resources}Query(
    int Page = 1,
    int PageSize = 20,
    string? Search = null
) : IRequest<PaginatedList<{Resource}Response>>;

// Handler (primary constructor)
public class Get{Resource}ByIdQueryHandler(
    IApplicationDbContext context,
    IMapper mapper) : IRequestHandler<Get{Resource}ByIdQuery, {Resource}Response>
{
    public async Task<{Resource}Response> Handle(
        Get{Resource}ByIdQuery request,
        CancellationToken cancellationToken)
    {
        var entity = await context.{Resources}
            .FirstOrDefaultAsync(x => x.Id == request.Id, cancellationToken)
            ?? throw new NotFoundException(nameof({Resource}), request.Id);

        return mapper.Map<{Resource}Response>(entity);
    }
}
```

---

## DTO Patterns

### Request DTOs (from client)
```csharp
// Create request
public record Create{Resource}Request(
    string Name,
    string Description,
    Guid? ParentId
);

// Update request
public record Update{Resource}Request(
    string Name,
    string Description
);

// Patch request (partial update)
public record Patch{Resource}Request(
    string? Name = null,
    string? Description = null
);
```

### Response DTOs (to client)
```csharp
// Single resource
public record {Resource}Response(
    Guid Id,
    string Name,
    string Description,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);

// List with pagination
public record PaginatedList<T>(
    List<T> Items,
    int TotalCount,
    int Page,
    int PageSize
);

// Summary (for list views)
public record {Resource}SummaryResponse(
    Guid Id,
    string Name,
    int ChildCount
);
```

---

## AutoMapper Profiles

```csharp
public class {Resource}MappingProfile : Profile
{
    public {Resource}MappingProfile()
    {
        // Entity → Response
        CreateMap<{Resource}Entity, {Resource}Response>();

        // Entity → Summary
        CreateMap<{Resource}Entity, {Resource}SummaryResponse>()
            .ForMember(d => d.ChildCount,
                opt => opt.MapFrom(s => s.Children.Count));
    }
}
```

---

## FluentValidation

```csharp
public class Create{Resource}RequestValidator(
    IApplicationDbContext context) : AbstractValidator<Create{Resource}Request>
{
    public Create{Resource}RequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Name is required")
            .MaximumLength(200).WithMessage("Name must not exceed 200 characters")
            .MustAsync(async (name, ct) =>
                !await context.{Resources}.AnyAsync(r => r.Name == name, ct))
            .WithMessage("A {resource} with this name already exists");

        RuleFor(x => x.Description)
            .MaximumLength(2000);

        RuleFor(x => x.ParentId)
            .MustAsync(async (id, ct) =>
                id == null || await context.{Parents}.AnyAsync(p => p.Id == id, ct))
            .WithMessage("Parent not found");
    }
}
```

---

## FastEndpoints Pattern

```csharp
// Create endpoint
public class Create{Resource}Endpoint(
    IApplicationDbContext context,
    IMapper mapper) : Endpoint<Create{Resource}Request, {Resource}Response>
{
    public override void Configure()
    {
        Post("/api/v1/{resources}");
        Policies("{PolicyName}");
    }

    public override async Task HandleAsync(
        Create{Resource}Request req, CancellationToken ct)
    {
        var entity = new {Resource}Entity
        {
            Id = Guid.NewGuid(),
            Name = req.Name,
            Description = req.Description,
            CreatedAt = DateTime.UtcNow
        };

        context.{Resources}.Add(entity);
        await context.SaveChangesAsync(ct);

        await SendCreatedAtAsync<Get{Resource}Endpoint>(
            new { id = entity.Id },
            mapper.Map<{Resource}Response>(entity),
            cancellation: ct);
    }
}

// Get by ID endpoint
public class Get{Resource}Endpoint(
    IApplicationDbContext context,
    IMapper mapper) : Endpoint<Get{Resource}Request, {Resource}Response>
{
    public override void Configure()
    {
        Get("/api/v1/{resources}/{id}");
        Policies("{PolicyName}");
    }

    public override async Task HandleAsync(
        Get{Resource}Request req, CancellationToken ct)
    {
        var entity = await context.{Resources}
            .FirstOrDefaultAsync(x => x.Id == req.Id, ct)
            ?? throw new NotFoundException(nameof({Resource}), req.Id);

        await SendOkAsync(mapper.Map<{Resource}Response>(entity), ct);
    }
}

// List endpoint with pagination
public class List{Resources}Endpoint(
    IApplicationDbContext context,
    IMapper mapper) : Endpoint<List{Resources}Request, PaginatedList<{Resource}Response>>
{
    public override void Configure()
    {
        Get("/api/v1/{resources}");
        Policies("{PolicyName}");
    }

    public override async Task HandleAsync(
        List{Resources}Request req, CancellationToken ct)
    {
        var query = context.{Resources}.AsQueryable();

        if (!string.IsNullOrWhiteSpace(req.Search))
            query = query.Where(x => x.Name.Contains(req.Search));

        var total = await query.CountAsync(ct);
        var items = await query
            .Skip((req.Page - 1) * req.PageSize)
            .Take(req.PageSize)
            .ToListAsync(ct);

        await SendOkAsync(new PaginatedList<{Resource}Response>(
            mapper.Map<List<{Resource}Response>>(items),
            total, req.Page, req.PageSize), ct);
    }
}

// Delete endpoint
public class Delete{Resource}Endpoint(
    IApplicationDbContext context) : Endpoint<Delete{Resource}Request>
{
    public override void Configure()
    {
        Delete("/api/v1/{resources}/{id}");
        Policies("{PolicyName}");
    }

    public override async Task HandleAsync(
        Delete{Resource}Request req, CancellationToken ct)
    {
        var entity = await context.{Resources}
            .FirstOrDefaultAsync(x => x.Id == req.Id, ct)
            ?? throw new NotFoundException(nameof({Resource}), req.Id);

        context.{Resources}.Remove(entity);
        await context.SaveChangesAsync(ct);
        await SendNoContentAsync(ct);
    }
}
```

---

## EF Core Configuration

```csharp
public class {Resource}EntityConfiguration
    : IEntityTypeConfiguration<{Resource}Entity>
{
    public void Configure(EntityTypeBuilder<{Resource}Entity> builder)
    {
        builder.HasKey(e => e.Id);

        builder.Property(e => e.Name)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(e => e.Description)
            .HasMaxLength(2000);

        builder.HasOne(e => e.Parent)
            .WithMany(p => p.Children)
            .HasForeignKey(e => e.ParentId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(e => e.Name).IsUnique();
        builder.HasIndex(e => e.CreatedAt);
    }
}
```

---

## Excel Import Pattern

```csharp
// Command
public record Import{Resources}Command(
    Stream FileStream,
    string FileName
) : IRequest<ImportResult>;

// Result
public record ImportResult(
    int TotalRows,
    int SuccessCount,
    int ErrorCount,
    List<ImportError> Errors
);

public record ImportError(int Row, string Column, string Message);

// Handler uses EPPlus or ClosedXML
// Pattern: Parse → Validate → Preview → Confirm → Process
// Batch processing: group rows into batches of 100
// Error accumulation: don't fail on first error
```

---

## Error Response Pattern

```csharp
// Standard error response
public record ErrorResponse(
    string Type,
    string Title,
    int Status,
    string? Detail = null,
    Dictionary<string, string[]>? Errors = null
);

// Common status codes for API spec
// 200 OK - Successful GET/PUT
// 201 Created - Successful POST
// 204 No Content - Successful DELETE
// 400 Bad Request - Malformed request
// 401 Unauthorized - Not authenticated
// 403 Forbidden - Not authorized
// 404 Not Found - Resource doesn't exist
// 409 Conflict - Duplicate or state conflict
// 422 Unprocessable - Validation failed
```
