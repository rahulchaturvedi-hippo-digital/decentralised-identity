dotnet build "AspNetCoreVerifiableCredentials.csproj" -c Debug -o .\bin\Debug\net6.
ngrok http 5000 & 
dotnet run --project "AspNetCoreVerifiableCredentials.csproj" -c Debug --no-build
