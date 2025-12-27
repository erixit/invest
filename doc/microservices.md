# Microservices Strategy

## Core Microservice (`corems`)
The `corems` service is the central backend service that other microservices depend on.

*   **Service Name**: `corems`
*   **Container Name**: `invest_corems`
*   **Port Mapping**: `6980:6980`
    *   **Internal**: The Spring Boot app listens on port `6980`.
    *   **External**: We map it 1:1 to the host so `localhost:6980` is valid on the Raspberry Pi.

## Handling Hardcoded `localhost` Clients

Other microservices use a client library with a hardcoded URL: `http://localhost:6980/...`. This presents a challenge because `localhost` means different things depending on where the code runs.

### Scenario A: Running Clients on the Raspberry Pi (Native)
If you run other microservices as plain JARs on the Pi (outside Docker):
*   **Status**: **Works immediately.**
*   **Why**: Since `corems` exposes port 6980 to the Pi's network interface, `localhost:6980` resolves correctly to the running container.

### Scenario B: Running Clients in Docker
If you run other microservices inside Docker containers on the Pi:
*   **Challenge**: Inside a standard Docker container, `localhost` refers to the container itself, not the host. The client will fail to find `corems`.
*   **Solution**: Use **Host Networking**.
*   **Configuration**: Add `network_mode: "host"` to the client service in `docker-compose.yml`.
    ```yaml
    services:
      other-microservice:
        image: eclipse-temurin:17-jre
        network_mode: "host"  # This makes 'localhost' refer to the Pi itself
        # Note: When using host mode, 'ports' mappings are ignored.
    ```