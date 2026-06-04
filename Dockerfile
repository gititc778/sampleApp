FROM mcr.microsoft.com/dotnet/sdk:6.0

WORKDIR /src

COPY *.csproj ./
RUN dotnet restore

COPY . ./

RUN dotnet publish -c Release -o /app/publish

WORKDIR /app/publish

EXPOSE 5000

ENV ASPNETCORE_URLS=http://0.0.0.0:5000

ENTRYPOINT ["dotnet", "sampleApp.dll"]