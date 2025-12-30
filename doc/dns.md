# DNS Configuration for Erixit Apps

Here are the methods to map `consult.erixit.com` or `erixit.com/consult` to your dynamic DNS address `consult.erixit.duckdns.org`.

## Option 1: Use a Subdomain (Recommended)
**Target URL:** `consult.erixit.com`

This is the cleanest method. You create a **CNAME** (Canonical Name) record in your DNS settings to alias the subdomain to your DuckDNS address.

1.  Log in to your domain registrar (e.g., GoDaddy, Namecheap, Google Domains, Cloudflare).
2.  Navigate to **DNS Management** or **DNS Records** for `erixit.com`.
3.  Add a new record:
    *   **Type:** `CNAME`
    *   **Host** (or Name): `consult`
    *   **Value** (or Target): `consult.erixit.duckdns.org`
    *   **TTL:** Automatic or 1 Hour (3600)
4.  Save the record.

## Option 2: URL Redirection
**Target URL:** `erixit.com/consult`

This requires a "Forwarding" feature provided by your registrar, as DNS records alone cannot handle URL paths (the part after the slash).

1.  In your domain registrar's dashboard, look for **Domain Forwarding** or **Subdomain Forwarding**.
2.  Set up a forward rule:
    *   **Source:** `erixit.com/consult`
    *   **Destination:** `http://consult.erixit.duckdns.org` (or `https` if SSL is configured)
    *   **Type:** 301 (Permanent)

## Important Note on Ports
If your app requires a specific port (e.g., `consult.erixit.duckdns.org:8501`), a CNAME record alone will **not** remove the need for the port. `consult.erixit.com` would still require the user to type `consult.erixit.com:8501`.

To remove the port requirement, you must set up a **Reverse Proxy** (like Nginx, Apache, or Caddy) on your server (Raspberry Pi) to listen on port 80/443 and forward traffic locally to port 8501.