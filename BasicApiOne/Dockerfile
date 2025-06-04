# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# This stage is used when running from VS in fast mode (Default for Debug configuration)
# FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
FROM registry.redhat.io/rhel8/dotnet-80:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080

RUN mkdir basic-api-one

# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Development
#WORKDIR /src
# WORKDIR .
# COPY ["BasicApiOne/BasicApiOne.csproj", "BasicApiOne/"]
# COPY BasicApiOne.csproj basic-api-one
COPY . .
#RUN dotnet restore ./BasicApiOne/BasicApiOne.csproj
RUN dotnet restore "./BasicApiOne.csproj"
COPY . .
# WORKDIR "/src/basic-api-one"
RUN dotnet build "./BasicApiOne.csproj" -c $BUILD_CONFIGURATION -o /app/build

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Development
RUN dotnet publish "./BasicApiOne.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BasicApiOne.dll"]