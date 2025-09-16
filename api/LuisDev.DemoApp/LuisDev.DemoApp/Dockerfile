# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443


# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["api/LuisDev.DemoApp/LuisDev.DemoApp/LuisDev.DemoApp.csproj", "api/LuisDev.DemoApp/LuisDev.DemoApp/"]
RUN dotnet restore "api/LuisDev.DemoApp/LuisDev.DemoApp/LuisDev.DemoApp.csproj"
COPY . .
WORKDIR "/src/api/LuisDev.DemoApp/LuisDev.DemoApp"
RUN dotnet build "./LuisDev.DemoApp.csproj" -c $BUILD_CONFIGURATION -o /app/build

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./LuisDev.DemoApp.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "LuisDev.DemoApp.dll"]

#docker build -t luisticktes.azurecr.io/luisticktes-api:0 -f ./api/LuisDev.DemoApp/LuisDev.DemoApp/Dockerfile .
#docker run -p luisticktes.azurecr.io/luisticktes-api:0


