import '@astrojs/internal-helpers/path';
import '@astrojs/internal-helpers/remote';
import 'piccolore';
import { N as NOOP_MIDDLEWARE_HEADER, h as decodeKey } from './chunks/astro/server_C7BzxcQu.mjs';
import 'clsx';
import 'es-module-lexer';
import 'html-escaper';

const NOOP_MIDDLEWARE_FN = async (_ctx, next) => {
  const response = await next();
  response.headers.set(NOOP_MIDDLEWARE_HEADER, "true");
  return response;
};

const codeToStatusMap = {
  // Implemented from IANA HTTP Status Code Registry
  // https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  PAYMENT_REQUIRED: 402,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  METHOD_NOT_ALLOWED: 405,
  NOT_ACCEPTABLE: 406,
  PROXY_AUTHENTICATION_REQUIRED: 407,
  REQUEST_TIMEOUT: 408,
  CONFLICT: 409,
  GONE: 410,
  LENGTH_REQUIRED: 411,
  PRECONDITION_FAILED: 412,
  CONTENT_TOO_LARGE: 413,
  URI_TOO_LONG: 414,
  UNSUPPORTED_MEDIA_TYPE: 415,
  RANGE_NOT_SATISFIABLE: 416,
  EXPECTATION_FAILED: 417,
  MISDIRECTED_REQUEST: 421,
  UNPROCESSABLE_CONTENT: 422,
  LOCKED: 423,
  FAILED_DEPENDENCY: 424,
  TOO_EARLY: 425,
  UPGRADE_REQUIRED: 426,
  PRECONDITION_REQUIRED: 428,
  TOO_MANY_REQUESTS: 429,
  REQUEST_HEADER_FIELDS_TOO_LARGE: 431,
  UNAVAILABLE_FOR_LEGAL_REASONS: 451,
  INTERNAL_SERVER_ERROR: 500,
  NOT_IMPLEMENTED: 501,
  BAD_GATEWAY: 502,
  SERVICE_UNAVAILABLE: 503,
  GATEWAY_TIMEOUT: 504,
  HTTP_VERSION_NOT_SUPPORTED: 505,
  VARIANT_ALSO_NEGOTIATES: 506,
  INSUFFICIENT_STORAGE: 507,
  LOOP_DETECTED: 508,
  NETWORK_AUTHENTICATION_REQUIRED: 511
};
Object.entries(codeToStatusMap).reduce(
  // reverse the key-value pairs
  (acc, [key, value]) => ({ ...acc, [value]: key }),
  {}
);

function sanitizeParams(params) {
  return Object.fromEntries(
    Object.entries(params).map(([key, value]) => {
      if (typeof value === "string") {
        return [key, value.normalize().replace(/#/g, "%23").replace(/\?/g, "%3F")];
      }
      return [key, value];
    })
  );
}
function getParameter(part, params) {
  if (part.spread) {
    return params[part.content.slice(3)] || "";
  }
  if (part.dynamic) {
    if (!params[part.content]) {
      throw new TypeError(`Missing parameter: ${part.content}`);
    }
    return params[part.content];
  }
  return part.content.normalize().replace(/\?/g, "%3F").replace(/#/g, "%23").replace(/%5B/g, "[").replace(/%5D/g, "]");
}
function getSegment(segment, params) {
  const segmentPath = segment.map((part) => getParameter(part, params)).join("");
  return segmentPath ? "/" + segmentPath : "";
}
function getRouteGenerator(segments, addTrailingSlash) {
  return (params) => {
    const sanitizedParams = sanitizeParams(params);
    let trailing = "";
    if (addTrailingSlash === "always" && segments.length) {
      trailing = "/";
    }
    const path = segments.map((segment) => getSegment(segment, sanitizedParams)).join("") + trailing;
    return path || "/";
  };
}

function deserializeRouteData(rawRouteData) {
  return {
    route: rawRouteData.route,
    type: rawRouteData.type,
    pattern: new RegExp(rawRouteData.pattern),
    params: rawRouteData.params,
    component: rawRouteData.component,
    generate: getRouteGenerator(rawRouteData.segments, rawRouteData._meta.trailingSlash),
    pathname: rawRouteData.pathname || void 0,
    segments: rawRouteData.segments,
    prerender: rawRouteData.prerender,
    redirect: rawRouteData.redirect,
    redirectRoute: rawRouteData.redirectRoute ? deserializeRouteData(rawRouteData.redirectRoute) : void 0,
    fallbackRoutes: rawRouteData.fallbackRoutes.map((fallback) => {
      return deserializeRouteData(fallback);
    }),
    isIndex: rawRouteData.isIndex,
    origin: rawRouteData.origin
  };
}

function deserializeManifest(serializedManifest) {
  const routes = [];
  for (const serializedRoute of serializedManifest.routes) {
    routes.push({
      ...serializedRoute,
      routeData: deserializeRouteData(serializedRoute.routeData)
    });
    const route = serializedRoute;
    route.routeData = deserializeRouteData(serializedRoute.routeData);
  }
  const assets = new Set(serializedManifest.assets);
  const componentMetadata = new Map(serializedManifest.componentMetadata);
  const inlinedScripts = new Map(serializedManifest.inlinedScripts);
  const clientDirectives = new Map(serializedManifest.clientDirectives);
  const serverIslandNameMap = new Map(serializedManifest.serverIslandNameMap);
  const key = decodeKey(serializedManifest.key);
  return {
    // in case user middleware exists, this no-op middleware will be reassigned (see plugin-ssr.ts)
    middleware() {
      return { onRequest: NOOP_MIDDLEWARE_FN };
    },
    ...serializedManifest,
    assets,
    componentMetadata,
    inlinedScripts,
    clientDirectives,
    routes,
    serverIslandNameMap,
    key
  };
}

const manifest = deserializeManifest({"hrefRoot":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/","cacheDir":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/node_modules/.astro/","outDir":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/","srcDir":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/","publicDir":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/public/","buildClientDir":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/client/","buildServerDir":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/server/","adapterName":"","routes":[{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/advanced-features.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/advanced-features","isIndex":false,"type":"page","pattern":"^\\/advanced-features$","segments":[[{"content":"advanced-features","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/advanced-features.astro","pathname":"/advanced-features","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/agents.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/agents","isIndex":false,"type":"page","pattern":"^\\/agents$","segments":[[{"content":"agents","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/agents.astro","pathname":"/agents","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/architecture.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/architecture","isIndex":false,"type":"page","pattern":"^\\/architecture$","segments":[[{"content":"architecture","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/architecture.astro","pathname":"/architecture","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/business-patterns.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/business-patterns","isIndex":false,"type":"page","pattern":"^\\/business-patterns$","segments":[[{"content":"business-patterns","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/business-patterns.astro","pathname":"/business-patterns","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/command-flow.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/command-flow","isIndex":false,"type":"page","pattern":"^\\/command-flow$","segments":[[{"content":"command-flow","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/command-flow.astro","pathname":"/command-flow","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/dashboard.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/dashboard","isIndex":false,"type":"page","pattern":"^\\/dashboard$","segments":[[{"content":"dashboard","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/dashboard.astro","pathname":"/dashboard","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/faq.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/faq","isIndex":false,"type":"page","pattern":"^\\/faq$","segments":[[{"content":"faq","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/faq.astro","pathname":"/faq","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/gamification.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/gamification","isIndex":false,"type":"page","pattern":"^\\/gamification$","segments":[[{"content":"gamification","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/gamification.astro","pathname":"/gamification","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/glossary.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/glossary","isIndex":false,"type":"page","pattern":"^\\/glossary$","segments":[[{"content":"glossary","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/glossary.astro","pathname":"/glossary","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/hooks.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/hooks","isIndex":false,"type":"page","pattern":"^\\/hooks$","segments":[[{"content":"hooks","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/hooks.astro","pathname":"/hooks","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/mcp-servers.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/mcp-servers","isIndex":false,"type":"page","pattern":"^\\/mcp-servers$","segments":[[{"content":"mcp-servers","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/mcp-servers.astro","pathname":"/mcp-servers","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/personalization.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/personalization","isIndex":false,"type":"page","pattern":"^\\/personalization$","segments":[[{"content":"personalization","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/personalization.astro","pathname":"/personalization","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/plugin.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/plugin","isIndex":false,"type":"page","pattern":"^\\/plugin$","segments":[[{"content":"plugin","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/plugin.astro","pathname":"/plugin","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/project-planning.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/project-planning","isIndex":false,"type":"page","pattern":"^\\/project-planning$","segments":[[{"content":"project-planning","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/project-planning.astro","pathname":"/project-planning","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/releases.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/releases","isIndex":false,"type":"page","pattern":"^\\/releases$","segments":[[{"content":"releases","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/releases.astro","pathname":"/releases","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/runtime.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/runtime","isIndex":false,"type":"page","pattern":"^\\/runtime$","segments":[[{"content":"runtime","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/runtime.astro","pathname":"/runtime","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/safety.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/safety","isIndex":false,"type":"page","pattern":"^\\/safety$","segments":[[{"content":"safety","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/safety.astro","pathname":"/safety","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/scripts.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/scripts","isIndex":false,"type":"page","pattern":"^\\/scripts$","segments":[[{"content":"scripts","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/scripts.astro","pathname":"/scripts","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/self-improving.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/self-improving","isIndex":false,"type":"page","pattern":"^\\/self-improving$","segments":[[{"content":"self-improving","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/self-improving.astro","pathname":"/self-improving","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/setup-detail.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/setup-detail","isIndex":false,"type":"page","pattern":"^\\/setup-detail$","segments":[[{"content":"setup-detail","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/setup-detail.astro","pathname":"/setup-detail","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/skills.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/skills","isIndex":false,"type":"page","pattern":"^\\/skills$","segments":[[{"content":"skills","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/skills.astro","pathname":"/skills","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/status-line.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/status-line","isIndex":false,"type":"page","pattern":"^\\/status-line$","segments":[[{"content":"status-line","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/status-line.astro","pathname":"/status-line","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/templates.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/templates","isIndex":false,"type":"page","pattern":"^\\/templates$","segments":[[{"content":"templates","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/templates.astro","pathname":"/templates","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/ui-patterns.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/ui-patterns","isIndex":false,"type":"page","pattern":"^\\/ui-patterns$","segments":[[{"content":"ui-patterns","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/ui-patterns.astro","pathname":"/ui-patterns","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/warp.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/warp","isIndex":false,"type":"page","pattern":"^\\/warp$","segments":[[{"content":"warp","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/warp.astro","pathname":"/warp","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/workflow.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/workflow","isIndex":false,"type":"page","pattern":"^\\/workflow$","segments":[[{"content":"workflow","dynamic":false,"spread":false}]],"params":[],"component":"src/pages/workflow.astro","pathname":"/workflow","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}},{"file":"file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/index.html","links":[],"scripts":[],"styles":[],"routeData":{"route":"/","isIndex":true,"type":"page","pattern":"^$","segments":[],"params":[],"component":"src/pages/index.astro","pathname":"/","prerender":true,"fallbackRoutes":[],"distURL":[],"origin":"project","_meta":{"trailingSlash":"never"}}}],"site":"https://fabkrum.github.io","base":"/vibe-crew","trailingSlash":"never","compressHTML":true,"componentMetadata":[["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/advanced-features.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/agents.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/architecture.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/business-patterns.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/command-flow.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/dashboard.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/faq.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/gamification.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/glossary.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/hooks.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/index.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/mcp-servers.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/personalization.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/plugin.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/project-planning.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/releases.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/runtime.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/safety.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/scripts.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/self-improving.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/setup-detail.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/skills.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/status-line.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/templates.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/ui-patterns.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/warp.astro",{"propagation":"none","containsHead":true}],["/Users/fabiankrumbholz/ai-projects/vibe-crew/docs-next/src/pages/workflow.astro",{"propagation":"none","containsHead":true}]],"renderers":[],"clientDirectives":[["idle","(()=>{var l=(n,t)=>{let i=async()=>{await(await n())()},e=typeof t.value==\"object\"?t.value:void 0,s={timeout:e==null?void 0:e.timeout};\"requestIdleCallback\"in window?window.requestIdleCallback(i,s):setTimeout(i,s.timeout||200)};(self.Astro||(self.Astro={})).idle=l;window.dispatchEvent(new Event(\"astro:idle\"));})();"],["load","(()=>{var e=async t=>{await(await t())()};(self.Astro||(self.Astro={})).load=e;window.dispatchEvent(new Event(\"astro:load\"));})();"],["media","(()=>{var n=(a,t)=>{let i=async()=>{await(await a())()};if(t.value){let e=matchMedia(t.value);e.matches?i():e.addEventListener(\"change\",i,{once:!0})}};(self.Astro||(self.Astro={})).media=n;window.dispatchEvent(new Event(\"astro:media\"));})();"],["only","(()=>{var e=async t=>{await(await t())()};(self.Astro||(self.Astro={})).only=e;window.dispatchEvent(new Event(\"astro:only\"));})();"],["visible","(()=>{var a=(s,i,o)=>{let r=async()=>{await(await s())()},t=typeof i.value==\"object\"?i.value:void 0,c={rootMargin:t==null?void 0:t.rootMargin},n=new IntersectionObserver(e=>{for(let l of e)if(l.isIntersecting){n.disconnect(),r();break}},c);for(let e of o.children)n.observe(e)};(self.Astro||(self.Astro={})).visible=a;window.dispatchEvent(new Event(\"astro:visible\"));})();"]],"entryModules":{"\u0000noop-middleware":"_noop-middleware.mjs","\u0000virtual:astro:actions/noop-entrypoint":"noop-entrypoint.mjs","\u0000@astro-page:src/pages/advanced-features@_@astro":"pages/advanced-features.astro.mjs","\u0000@astro-page:src/pages/agents@_@astro":"pages/agents.astro.mjs","\u0000@astro-page:src/pages/architecture@_@astro":"pages/architecture.astro.mjs","\u0000@astro-page:src/pages/business-patterns@_@astro":"pages/business-patterns.astro.mjs","\u0000@astro-page:src/pages/command-flow@_@astro":"pages/command-flow.astro.mjs","\u0000@astro-page:src/pages/dashboard@_@astro":"pages/dashboard.astro.mjs","\u0000@astro-page:src/pages/faq@_@astro":"pages/faq.astro.mjs","\u0000@astro-page:src/pages/gamification@_@astro":"pages/gamification.astro.mjs","\u0000@astro-page:src/pages/glossary@_@astro":"pages/glossary.astro.mjs","\u0000@astro-page:src/pages/hooks@_@astro":"pages/hooks.astro.mjs","\u0000@astro-page:src/pages/mcp-servers@_@astro":"pages/mcp-servers.astro.mjs","\u0000@astro-page:src/pages/personalization@_@astro":"pages/personalization.astro.mjs","\u0000@astro-page:src/pages/plugin@_@astro":"pages/plugin.astro.mjs","\u0000@astro-page:src/pages/project-planning@_@astro":"pages/project-planning.astro.mjs","\u0000@astro-page:src/pages/releases@_@astro":"pages/releases.astro.mjs","\u0000@astro-page:src/pages/runtime@_@astro":"pages/runtime.astro.mjs","\u0000@astro-page:src/pages/safety@_@astro":"pages/safety.astro.mjs","\u0000@astro-page:src/pages/scripts@_@astro":"pages/scripts.astro.mjs","\u0000@astro-page:src/pages/self-improving@_@astro":"pages/self-improving.astro.mjs","\u0000@astro-page:src/pages/setup-detail@_@astro":"pages/setup-detail.astro.mjs","\u0000@astro-page:src/pages/skills@_@astro":"pages/skills.astro.mjs","\u0000@astro-page:src/pages/status-line@_@astro":"pages/status-line.astro.mjs","\u0000@astro-page:src/pages/templates@_@astro":"pages/templates.astro.mjs","\u0000@astro-page:src/pages/ui-patterns@_@astro":"pages/ui-patterns.astro.mjs","\u0000@astro-page:src/pages/warp@_@astro":"pages/warp.astro.mjs","\u0000@astro-page:src/pages/workflow@_@astro":"pages/workflow.astro.mjs","\u0000@astro-page:src/pages/index@_@astro":"pages/index.astro.mjs","\u0000@astro-renderers":"renderers.mjs","\u0000@astrojs-manifest":"manifest_DDD-q_PK.mjs","astro:scripts/before-hydration.js":""},"inlinedScripts":[],"assets":["/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/advanced-features.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/agents.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/architecture.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/business-patterns.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/command-flow.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/dashboard.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/faq.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/gamification.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/glossary.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/hooks.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/mcp-servers.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/personalization.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/plugin.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/project-planning.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/releases.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/runtime.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/safety.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/scripts.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/self-improving.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/setup-detail.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/skills.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/status-line.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/templates.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/ui-patterns.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/warp.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/workflow.html","/vibe-crew/file:///Users/fabiankrumbholz/ai-projects/vibe-crew/docs/index.html"],"buildFormat":"file","checkOrigin":false,"allowedDomains":[],"actionBodySizeLimit":1048576,"serverIslandNameMap":[],"key":"NPDk5e72vArpmnn4/olmQiFqH66Qf/nNPh9IVU4KsEk="});
if (manifest.sessionConfig) manifest.sessionConfig.driverModule = null;

export { manifest };
