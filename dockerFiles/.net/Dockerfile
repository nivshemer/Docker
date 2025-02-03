FROM mcr.microsoft.com/dotnet/sdk:8.0

ENV PATH="$PATH:/root/.dotnet/tools"

COPY ./app /app

COPY ./entry-point.sh /

WORKDIR /app

EXPOSE 8070/tcp

ENTRYPOINT ["/entry-point.sh"]
