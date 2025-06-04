#FROM registry.redhat.io/ubi8/ubi-minimal:8.9 AS certificate
#
#RUN microdnf -y install curl
#RUN microdnf -y install openssl
#
#RUN curl -o ./BXS-ROOTBancorpSouth\ Root\ Certificate\ Authority.crt http://certs.bank.ad.bxs.com/pki/BXS-ROOTBancorpSouth%20Root%20Certificate%20Authority.crt
#RUN openssl x509 -inform DER -in BXS-ROOTBancorpSouth\ Root\ Certificate\ Authority.crt -outform PEM -out /tmp/BancorpSouthCertificate.crt

FROM registry.redhat.io/rhel8/dotnet-80:8.0 AS build-env

USER 0
WORKDIR /src
RUN mkdir basic-api-one

# copy all neccessary files
COPY BasicApiOne/*.csproj ./basic-api-one
COPY ContainerApps.sln ContainerApps.sln


COPY ./nuget.config ./
ENV DOTNET_RESTORE_CONFIGFILE=./nuget.config

ENV DOTNET_NUGET_SIGNATURE_VERIFICATION=false

RUN dotnet restore "./basic-api-one/BasicApiOne.csproj"

#COPY BasicApiOne ./basic-api-one
COPY . .

#ENV DOTNET_TEST_PROJECTS=accounts-orchestrator-tests

# Remove source files after assemble, not needed to run
ENV DOTNET_RM_SRC=true

ENV DOTNET_STARTUP_PROJECT=basic-api-one/BasicApiOne.csproj

RUN /usr/libexec/s2i/assemble

RUN chown -R 1001:0 /opt/app-root && fix-permissions /opt/app-root

USER 1001

# build runtime image
FROM registry.redhat.io/rhel8/dotnet-80-runtime:8.0

USER 0

COPY --from=build-env /opt/app-root /opt/app-root

RUN chown -R 1001:0 /opt/app-root && fix-permissions /opt/app-root

# Run container by default as user with id 1001 (default)
USER 1001

ENTRYPOINT ["/usr/libexec/s2i/run"]