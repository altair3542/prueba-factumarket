using MongoDB.Driver;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System.Text.Json;

// --- wiring Mongo ---
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var mongoUrl = Environment.GetEnvironmentVariable("MONGO_URL") ?? "mongodb://localhost:27017";
var mongo = new MongoClient(mongoUrl);
var db = mongo.GetDatabase("auditoria");
var events = db.GetCollection<AuditEvent>("events");
builder.Services.AddSingleton(events);

var app = builder.Build();
app.UseSwagger();
app.UseSwaggerUI();

// --- endpoints ---
app.MapPost("/events", async (AuditEventDto body, IMongoCollection<AuditEvent> col) =>
{
    var entity = new AuditEvent
    {
        EventId = string.IsNullOrWhiteSpace(body.EventId) ? Guid.NewGuid().ToString("n") : body.EventId!,
        Type = body.Type,
        ClienteId = body.ClienteId,
        FacturaId = body.FacturaId,
        Payload = body.Payload.HasValue ? JsonElementToObject(body.Payload.Value) : null,
        Timestamp = DateTimeOffset.UtcNow
    };

    await col.InsertOneAsync(entity);

    // Devolvemos el payload tal como vino (para evitar problemas de serialización de Bson en respuesta)
    return Results.Created($"/events/{entity.Id}", new {
        entity.Id, entity.EventId, entity.Type, entity.ClienteId, entity.FacturaId,
        Payload = body.Payload, entity.Timestamp
    });
});

app.MapGet("/auditoria/{facturaId}", async (string facturaId, IMongoCollection<AuditEvent> col) =>
{
    var data = await col.Find(x => x.FacturaId == facturaId)
                        .SortByDescending(x => x.Timestamp)
                        .Limit(200)
                        .ToListAsync();

    // Respondemos con objetos planos serializables por System.Text.Json
    var response = data.Select(e => new {
        e.Id, e.EventId, e.Type, e.ClienteId, e.FacturaId, e.Timestamp, e.Payload
    });

    return Results.Ok(response);
});

app.Run();

// --- helpers / modelos ---
static object? JsonElementToObject(JsonElement element)
{
    switch (element.ValueKind)
    {
        case JsonValueKind.Object:
            var dict = new Dictionary<string, object?>();
            foreach (var prop in element.EnumerateObject())
                dict[prop.Name] = JsonElementToObject(prop.Value);
            return dict;
        case JsonValueKind.Array:
            var list = new List<object?>();
            foreach (var item in element.EnumerateArray())
                list.Add(JsonElementToObject(item));
            return list;
        case JsonValueKind.String:
            if (element.TryGetDateTimeOffset(out var dto)) return dto;
            return element.GetString();
        case JsonValueKind.Number:
            if (element.TryGetInt64(out var l)) return l;
            if (element.TryGetDouble(out var d)) return d;
            return element.GetDecimal();
        case JsonValueKind.True:
        case JsonValueKind.False:
            return element.GetBoolean();
        default:
            return null;
    }
}

class AuditEvent
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string? Id { get; set; }
    public string EventId { get; set; } = Guid.NewGuid().ToString("n");
    public string Type { get; set; } = default!;
    public string? ClienteId { get; set; }
    public string? FacturaId { get; set; }
    public object? Payload { get; set; }   // diccionarios/listas/valores primitivos
    public DateTimeOffset Timestamp { get; set; }
}

record AuditEventDto(string? EventId, string Type, string? ClienteId, string? FacturaId, JsonElement? Payload);
