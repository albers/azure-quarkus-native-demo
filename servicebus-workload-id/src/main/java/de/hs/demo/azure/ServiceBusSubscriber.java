package de.hs.demo.azure;

import com.azure.messaging.servicebus.ServiceBusClientBuilder;
import com.azure.messaging.servicebus.ServiceBusProcessorClient;
import io.quarkus.runtime.Shutdown;
import io.quarkus.runtime.Startup;
import jakarta.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

/**
 * Creates a connection to the Azure Service Bus on application startup
 * and disconnects on application shutdown.
 */
class ServiceBusSubscriber {

    @Inject
    Logger logger;

    @ConfigProperty(name = "servicebus.topic", defaultValue = "topic")
    String topic;

    @ConfigProperty(name = "servicebus.subscription", defaultValue = "subscription")
    String subscription;
    private ServiceBusProcessorClient serviceBusClient;

    @Inject
    ServiceBusClientBuilder serviceBusClientBuilder;

    @Startup
    void connect() {
        logger.info("Connecting to Azure Service Bus.");
        serviceBusClient = createServiceBusProcessorClient();
        serviceBusClient.start();
    }

    private ServiceBusProcessorClient createServiceBusProcessorClient() {
        return serviceBusClientBuilder
                .processor()
                .topicName(topic)
                .subscriptionName(subscription)
                .processMessage(messageContext ->
                        logger.info("Received message %s: %s".formatted(
                                messageContext.getMessage().getMessageId(),
                                messageContext.getMessage().getBody())))
                .processError(serviceBusErrorContext ->
                        logger.error("Failed to receive message: " + serviceBusErrorContext.getException().getMessage()))
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
