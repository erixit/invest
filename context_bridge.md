# Context Bridge

**Context Handover:**
We are working on a Raspberry Pi 5 running a Docker Compose stack with Java Spring Boot microservices and Angular UIs.

**Current Status:**
1. **Infrastructure:** We are moving to VS Code Remote SSH because the Pi's desktop GUI is laggy.
2. **Services:**
   - `consultms` (Java) was recently added.
   - `consultui` (Angular) is running on port 8089 and exposed via Nginx Proxy Manager at `https://consult.erixit.duckdns.org`.
3. **Recent Fixes:**
   - Fixed 403 Forbidden errors on Nginx containers by correcting volume paths (Angular 17+ builds to `dist/.../browser`) and running `chmod 755` on deploy folders.
   - Fixed `adminui` volume conflict in docker-compose.
4. **Next Steps:** We need to verify that `consultms` is correctly connected to the database.