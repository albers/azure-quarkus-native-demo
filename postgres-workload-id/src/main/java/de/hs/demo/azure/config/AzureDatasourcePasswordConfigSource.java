package de.hs.demo.azure.config;

import com.azure.identity.extensions.jdbc.postgresql.AzurePostgresqlAuthenticationPlugin;
import io.quarkus.runtime.LaunchMode;
import org.eclipse.microprofile.config.spi.ConfigSource;

import java.io.IOException;
import java.util.Set;

/**
 * This custom {@link ConfigSource} eases the configuration of the database password in dev mode.
 * You have three choices to provide the database password:
 * <ol>
 *     <li>Use {@link AzurePostgresqlAuthenticationPlugin} by including it in the jdbc url.
 *     This requires setting {@code quarkus.class-loading.parent-first-artifacts}.</li>
 *     <li>Manually retrieve a token with <code>az</code> and set it as {@value #PASSWORD_PROPERTY}.</li>
 *     <li>Use this config provider to automatically retrieve and provide a token whenever
 *     {@value #PASSWORD_PROPERTY} is not set.
 *     This will delay every application startup for about 2 seconds.</li>
 * </ol>
 */
public class AzureDatasourcePasswordConfigSource implements ConfigSource {

    private static final String PASSWORD_PROPERTY = "quarkus.datasource.password";

    private String databaseToken;

    @Override
    public String getName() {
        return AzureDatasourcePasswordConfigSource.class.getSimpleName();
    }

    @Override
    public Set<String> getPropertyNames() {
        return Set.of(PASSWORD_PROPERTY);
    }

    @Override
    public String getValue(String propertyName) {
        if (LaunchMode.isDev() && PASSWORD_PROPERTY.equals(propertyName)) {
            return getDatabaseToken();
        }
        return null;
    }

    private String getDatabaseToken() {
        if (databaseToken == null) {
            loadToken();
        }
        return databaseToken;
    }

    private void loadToken() {
        try {
            this.databaseToken = new EntraIdTokenRetriever().getToken();
        } catch (IOException | InterruptedException e) {
            System.err.println(e.getMessage());
        }
    }
}
