import http from "http";
import { request as httpRequest } from "http";
import { request as httpsRequest } from "https";
import { URL } from "url";

const UPSTREAM_URL = process.env.UPSTREAM_URL; // full upstream endpoint
if (!UPSTREAM_URL) {
  console.error("Missing UPSTREAM_URL. Example:");
  console.error('  export UPSTREAM_URL="$OPENWEBUI_URL/api/v1/chat/completions"');
  process.exit(1);
}

const upstream = new URL(UPSTREAM_URL);
const upstreamReqFn = upstream.protocol === "https:" ? httpsRequest : httpRequest;

function stripReasoning(obj) {
  if (!obj || typeof obj !== "object") return obj;

  // Remove common reasoning knobs/fields that break Bedrock for some models
  delete obj.reasoning;
  delete obj.reasoning_effort;
  delete obj.reasoningEffort;
  delete obj.reasoning_tags;
  delete obj.reasoningTags;

  // Some stacks tuck this under "extra_body" or similar
  if (obj.extra_body && typeof obj.extra_body === "object") {
    delete obj.extra_body.reasoning;
    delete obj.extra_body.reasoning_effort;
    delete obj.extra_body.reasoning_tags;
  }

  return obj;
}

const server = http.createServer((req, res) => {
  // Only handle the OpenWebUI OpenAI-compatible chat endpoint
  if (req.method !== "POST" || req.url !== "/api/v1/chat/completions") {
    res.writeHead(404, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Not found" }));
    return;
  }

  let body = "";
  req.on("data", (chunk) => (body += chunk));
  req.on("end", () => {
    let payload;
    try {
      payload = JSON.parse(body || "{}");
    } catch {
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Invalid JSON" }));
      return;
    }

    payload = stripReasoning(payload);

    // Forward headers, but fix host + content-length
    const headers = { ...req.headers };
    headers.host = upstream.host;
    headers["content-type"] = "application/json";
    delete headers["content-length"]; // will be recomputed by node

    const upstreamReq = upstreamReqFn(
      {
        method: "POST",
        hostname: upstream.hostname,
        port: upstream.port || (upstream.protocol === "https:" ? 443 : 80),
        path: upstream.pathname + upstream.search,
        headers,
      },
      (upstreamRes) => {
        res.writeHead(upstreamRes.statusCode || 502, upstreamRes.headers);
        upstreamRes.pipe(res);
      }
    );

    upstreamReq.on("error", (err) => {
      res.writeHead(502, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: String(err) }));
    });

    upstreamReq.write(JSON.stringify(payload));
    upstreamReq.end();
  });
});

server.listen(3457, "127.0.0.1", () => {
  console.log("✅ strip-reasoning-proxy listening on http://127.0.0.1:3457");
  console.log("   forwarding to:", UPSTREAM_URL);
});

