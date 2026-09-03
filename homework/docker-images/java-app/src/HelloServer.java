import com.sun.net.httpserver.HttpServer;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

/**
 * Minimal Hello World web server for the DevOps docker homework.
 * Uses the HTTP server that ships with the JDK, so no external
 * dependencies and no Maven/Gradle are needed.
 */
public class HelloServer {

    private static final int PORT = 8080;

    public static void main(String[] args) throws Exception {
        HttpServer server = HttpServer.create(new InetSocketAddress("0.0.0.0", PORT), 0);

        server.createContext("/", exchange -> {
            String host = InetAddress.getLocalHost().getHostName();
            String body = "<!DOCTYPE html>\n"
                    + "<html>\n"
                    + "  <head><title>Java Hello World</title></head>\n"
                    + "  <body style=\"font-family: sans-serif; text-align: center; margin-top: 80px;\">\n"
                    + "    <h1>Hello World from Java!</h1>\n"
                    + "    <p>Running inside a Docker container</p>\n"
                    + "    <p>container hostname: " + host + "</p>\n"
                    + "    <p>java version: " + System.getProperty("java.version") + "</p>\n"
                    + "  </body>\n"
                    + "</html>";

            byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().set("Content-Type", "text/html; charset=utf-8");
            exchange.sendResponseHeaders(200, bytes.length);
            try (OutputStream os = exchange.getResponseBody()) {
                os.write(bytes);
            }
        });

        server.setExecutor(null);
        System.out.println("java-app listening on port " + PORT);
        server.start();
    }
}
