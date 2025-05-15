package de.hs.demo.azure;

import com.azure.identity.extensions.implementation.credential.provider.DefaultTokenCredentialProvider;
import com.azure.identity.extensions.jdbc.postgresql.AzurePostgresqlAuthenticationPlugin;
import io.quarkus.runtime.annotations.RegisterForReflection;

/**
 * This class serves as a place to put {@link RegisterForReflection @RegisterForReflection} annotations
 * for library classes that would otherwise be removed from the native image because GraalVM cannot
 * detect their usage.
 */
@RegisterForReflection(targets = {
        AzurePostgresqlAuthenticationPlugin.class,
        DefaultTokenCredentialProvider.class
})
public class ReflectionRegistration {
    // Empty class - just used for registration
}