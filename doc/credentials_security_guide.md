# Secure Credentials Guide

This guide outlines how to move away from hardcoded credentials in the source code for both the Spring Boot backend and the Angular frontend.

## 1. Backend (Spring Boot)

Instead of hardcoding secrets in `application.yml`, use **Environment Variables**. This allows you to inject secrets at runtime (e.g., via Docker or the OS) while keeping a default value for local development.

### Step 1: Update `application.yml`

Modify `/home/pi/development/repos/invest_microservices/adminapi/src/main/resources/application.yml` to use the `${VARIABLE_NAME:default_value}` syntax.

```yaml
jwt:
  # Tries to read JWT_SECRET from the OS; falls back to the hardcoded string if not found.
  secret: ${JWT_SECRET:8fhgeigayuf64oq8ltw36pi84wl87trf8afpw7ty934t7fwaeGTFyugfldlsjfdglja}

spring:
  security:
    user:
      # Tries to read ADMIN_USER and ADMIN_PASSWORD from the OS.
      name: ${ADMIN_USER:testuser}
      password: ${ADMIN_PASSWORD:testpass}
```

### Step 2: Running the Application Securely

When deploying or running on the Pi, set the variables before starting the jar:

```bash
export ADMIN_USER=myRealAdmin
export ADMIN_PASSWORD=SuperSecretPassword123!
export JWT_SECRET=MyProductionSecretKey
java -jar adminapi.jar
```

---

## 2. Frontend (Angular)

**Never** store passwords or secrets in client-side JavaScript/TypeScript code. It is visible to anyone who inspects the browser.

### Strategy: Login Flow

1.  **Remove Hardcoded Credentials:** Delete any `const password = '...'` from your Angular services.
2.  **Create a Login Component:**
    *   Build a simple form with "Username" and "Password" inputs.
    *   Let the user type their credentials.
3.  **Authenticate:**
    *   Send the user-entered credentials to a backend login endpoint (e.g., `POST /api/login`).
    *   The backend validates the user and returns a **JWT** (JSON Web Token).
4.  **Store the Token:**
    *   Save the received JWT in memory or `localStorage`.
    *   Do **not** save the username/password.
5.  **Use the Token:**
    *   For subsequent requests (like `sharelookup`), add the token to the Authorization header:
        ```typescript
        const headers = new HttpHeaders({
          'Authorization': 'Bearer ' + myStoredToken
        });
        ```

This ensures credentials only exist in the user's memory and briefly during the initial network request.