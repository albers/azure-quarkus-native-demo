# azure-quarkus-native-demo

This project illustrates problems I have when compiling a Quarkus application that uses
[Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=java)
to a [native image](https://quarkus.io/guides/building-native-image).

To narrow down the problem, I created two applications that do the same thing:
They connect to an Azure Service Bus topic subscription and log incoming messages to the console.

### [servicebus-connection-string](servicebus-connection-string/README.md)

This application uses a connection string for authentication.
It can be compiled to a native image with minimal tweaks.
This project merely exists to prove that the native image build works when the Azure Identity library is not present.

### [servicebus-workload-id](servicebus-workload-id/README.md)

This application uses Workload Identity for authentication, which requires the addition of the
Azure Identity library.

> The presence of the Azure Identity library causes the native image build to fail,
> even when wrapped by the [quarkus-azure-services](https://github.com/quarkiverse/quarkus-azure-services) Quarkus extension.  
> **This is where I need help.**

### [infra](infra/README.md)

This is a Terraform-based infrastructure project that creates the resources needed for the demo applications.
The setup for the Workload Identity application is quite complex,
so I created this project to provide a reference environment.

## Local environment

I am using Temurin-21.0.6+7 on Windows 11.

The GraalVM is invoked using the default Quarkus native image build image `quay.io/quarkus/ubi9-quarkus-mandrel-builder-image:jdk-21`,
which at time of writing provides these features:
```text
 Java version: 21.0.6+7-LTS, vendor version: Mandrel-23.1.6.0-Final
 Graal compiler: optimization level: 2, target machine: x86-64-v3
 C compiler: gcc (redhat, x86_64, 11.5.0)
 Garbage collector: Serial GC (max heap size: 80% of RAM)
 5 user-specific feature(s):
 - com.oracle.svm.thirdparty.gson.GsonFeature
 - io.quarkus.runner.Feature: Auto-generated class by Quarkus from the existing extensions
 - io.quarkus.runtime.graal.DisableLoggingFeature: Adapts logging during the analysis phase
 - io.quarkus.runtime.graal.SkipConsoleServiceProvidersFeature: Skip unsupported console service providers when quarkus.native.auto-service-loader-registration is false
 - org.eclipse.angus.activation.nativeimage.AngusActivationFeature
------------------------------------------------------------------------------------------------------------------------
 4 experimental option(s) unlocked:
 - '-H:+AllowFoldMethods' (origin(s): command line)
 - '-H:BuildOutputJSONFile' (origin(s): command line)
 - '-H:-UseServiceLoaderFeature' (origin(s): command line)
 - '-H:+GenerateBuildArtifactsFile' (origin(s): command line)
------------------------------------------------------------------------------------------------------------------------
```

# Disclaimer

> The code in this repository is for demonstration purposes only.  
  It does not follow best practices for production code,
  nor does it present any security guidelines.
