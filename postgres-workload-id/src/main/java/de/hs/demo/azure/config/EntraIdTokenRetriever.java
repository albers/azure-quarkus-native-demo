package de.hs.demo.azure.config;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

/**
 * The {@link EntraIdTokenRetriever} calls the Azure CLI ({@code az.cmd}) to retrieve an Entra ID token
 * for the user currently logged-in to Azure.
 */
class EntraIdTokenRetriever {

    private static final String TOKEN_COMMAND = "%s account get-access-token --resource https://ossrdbms-aad.database.windows.net --query accessToken -o tsv";

    public String getToken() throws IOException, InterruptedException {
        String command = isRunningOnWindows() ? "az.cmd" : "az";
        String commandline = TOKEN_COMMAND.formatted(command);
        return executeCommandline(commandline);
    }

    private static boolean isRunningOnWindows() {
        return System.getProperty("os.name").toLowerCase().contains("windows");
    }

    private static String executeCommandline(String commandline) throws IOException, InterruptedException {
        ProcessBuilder processBuilder = new ProcessBuilder(commandline.split(" "));
        Process process = processBuilder.start();
        String output = readOutput(process.getInputStream());
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            String message = readOutput(process.getErrorStream());
            throw new IOException("Error executing command: " + message);
        }
        return output;
    }

    private static String readOutput(InputStream inputStream) throws IOException {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
            StringBuilder output = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append(System.lineSeparator());
            }
            return output.toString().trim(); // remove trailing newline
        }
    }
}
