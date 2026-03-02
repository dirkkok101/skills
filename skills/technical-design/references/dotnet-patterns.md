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

// Handler
public class Create{Resource}CommandHandler
    : IRequestHandler<Create{Resource}Command, {Resource}Response>
{
    private readonly IApplicationDbContext _context;
    private readonly IMapper _mapper;

    public Create{Resource}CommandHandler(
        IApplicationDbContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

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

        _context.{Resources}.Add(entity);
        await _context.SaveChangesAsync(cancellationToken);

        return _mapper.Map<{Resource}Response>(entity);
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

// Handler
public class Get{Resource}ByIdQueryHandler
    : IRequestHandler<Get{Resource}ByIdQuery, {Resource}Response>
{
    private readonly IApplicationDbContext _context;
    private readonly IMapper _mapper;

    public async Task<{Resource}Response> Handle(
        Get{Resource}ByIdQuery request,
        CancellationToken cancellationToken)
    {
        var entity = await _context.{Resources}
            .FirstOrDefaultAsync(x => x.Id == request.Id, cancellationToken)
            ?? throw new NotFoundException(nameof({Resource}), request.Id);

        return _mapper.Map<{Resource}Response>(entity);
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
public class Create{Resource}RequestValidator
    : AbstractValidator<Create{Resource}Request>
{
    public Create{Resource}RequestValidator(IApplicationDbContext context)
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

## Controller Pattern

```csharp
[ApiController]
[Route("api/v1/{resources}")]
[Authorize]
public class {Resources}Controller : ControllerBase
{
    private readonly IMediator _mediator;

    public {Resources}Controller(IMediator mediator)
        => _mediator = mediator;

    [HttpGet]
    [ProducesResponseType(typeof(PaginatedList<{Resource}Response>), 200)]
    public async Task<IActionResult> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] string? search = null)
    {
        var result = await _mediator.Send(
            new Get{Resources}Query(page, pageSize, search));
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof({Resource}Response), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetById(Guid id)
    {
        var result = await _mediator.Send(new Get{Resource}ByIdQuery(id));
        return Ok(result);
    }

    [HttpPost]
    [ProducesResponseType(typeof({Resource}Response), 201)]
    [ProducesResponseType(422)]
    public async Task<IActionResult> Create(
        [FromBody] Create{Resource}Request request)
    {
        var command = new Create{Resource}Command(
            request.Name, request.Description, request.ParentId);
        var result = await _mediator.Send(command);
        return CreatedAtAction(nameof(GetById),
            new { id = result.Id }, result);
    }

    [HttpPut("{id:guid}")]
    [ProducesResponseType(typeof({Resource}Response), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> Update(
        Guid id, [FromBody] Update{Resource}Request request)
    {
        var command = new Update{Resource}Command(
            id, request.Name, request.Description);
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    [ProducesResponseType(204)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _mediator.Send(new Delete{Resource}Command(id));
        return NoContent();
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
