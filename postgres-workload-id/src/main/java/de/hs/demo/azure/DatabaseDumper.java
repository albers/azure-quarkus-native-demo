package de.hs.demo.azure;

import io.quarkus.runtime.Startup;
import org.jboss.logging.Logger;

/**
 * This class is invoked by Quarkus on application startup.
 * It prints all persons from the database to the console so that you can
 * verify that the database connection is working.
 */
class DatabaseDumper {

    final Logger logger = Logger.getLogger(DatabaseDumper.class);

    @Startup
    void dumpDatabase() {
        logger.info("Dumping database...");
        Person.findAll().stream().forEach(logger::info);
    }

}
