package de.hs.demo.azure;

import com.azure.core.credential.TokenCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.messaging.servicebus.ServiceBusClientBuilder;
import com.azure.messaging.servicebus.ServiceBusProcessorClient;
import io.quarkus.runtime.Shutdown;
import io.quarkus.runtime.Startup;
import jakarta.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

import static com.azure.core.amqp.AmqpTransportType.AMQP_WEB_SOCKETS;

/**
 * Creates a connection to the Azure Service Bus on application startup
 * and disconnects on application shutdown.
 */
class ServiceBusSubscriber {

    @Inject
    Logger logger;

    @ConfigProperty(name = "servicebus.namespace")
    String namespace;

    @ConfigProperty(name = "servicebus.topic")
    String topic;

    @ConfigProperty(name = "servicebus.subscription")
    String subscription;
    private ServiceBusProcessorClient serviceBusClient;

    @Startup
    void connect() {
        logger.info("Connecting to Azure Service Bus.");
        serviceBusClient = createServiceBusProcessorClient();
        serviceBusClient.start();
    }

    private ServiceBusProcessorClient createServiceBusProcessorClient() {
        TokenCredential credential = new DefaultAzureCredentialBuilder().build();

        return new ServiceBusClientBuilder()
                .fullyQualifiedNamespace(namespace)
                .credential(credential)
                .transportType(AMQP_WEB_SOCKETS)
                .processor()
                .topicName(topic)
                .subscriptionName(subscription)
                .processMessage(messageContext ->
                        logger.info("Received message %s: %s".formatted(
                                messageContext.getMessage().getMessageId(),
                                messageContext.getMessage().getBody())))
                .processError(serviceBusErrorContext ->
                        logger.error("Faild to receive message: " + serviceBusErrorContext.getException().getMessage()))
                .buildProcessorClient();
    }

    @Shutdown
    void disconnect() {
        if (serviceBusClient != null) {
            logger.info("Disconnecting from Azure Service Bus.");
            serviceBusClient.close();
        }
    }
}
