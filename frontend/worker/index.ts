// Cloudflare Worker（Static Assets 対応）
//
// 役割:
//   - /api/*  → fly のバックエンドへプロキシ（vite dev proxy と同じく /api を剥がす）
//   - それ以外 → 静的アセット（SPA）を配信
//
// ブラウザから見ると全リクエストが同一オリジン（*.workers.dev / 独自ドメイン）に
// なるため、CORS も SameSite の考慮も不要になる。

interface Env {
  // wrangler.jsonc の assets.binding
  ASSETS: { fetch: (request: Request) => Promise<Response> }
  // バックエンドのオリジン（wrangler.jsonc の vars）
  API_ORIGIN: string
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url)

    if (url.pathname === "/api" || url.pathname.startsWith("/api/")) {
      const target = new URL(env.API_ORIGIN)
      // /api プレフィックスを剥がして backend のルート（/lessons 等）に合わせる
      target.pathname = url.pathname.replace(/^\/api/, "") || "/"
      target.search = url.search
      // method / headers / body / cookie はそのまま透過する
      return fetch(new Request(target, request))
    }

    return env.ASSETS.fetch(request)
  },
}
