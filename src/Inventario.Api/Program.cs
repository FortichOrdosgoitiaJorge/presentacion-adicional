var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Endpoint de salud: lo usan el pipeline y los balanceadores para verificar el servicio
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

app.Run();

// Necesario para que las pruebas de integración puedan levantar la aplicación
public partial class Program { }
