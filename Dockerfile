# Imagen de la API. El pipeline la construye una sola vez y la promueve entre entornos.
# Ajustar PROJECT al .csproj de la API cuando el proyecto exista.
ARG PROJECT=src/Inventario.Api/Inventario.Api.csproj

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG PROJECT
WORKDIR /src
COPY . .
RUN dotnet restore "$PROJECT"
RUN dotnet publish "$PROJECT" -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
USER app
ENTRYPOINT ["dotnet", "Inventario.Api.dll"]
