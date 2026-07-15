from prometheus_client import Counter, Histogram

REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "app_request_latency_seconds",
    "Request latency in seconds",
    ["endpoint"]
)

CACHE_HITS = Counter("app_cache_hits_total", "Total Redis cache hits")
CACHE_MISSES = Counter("app_cache_misses_total", "Total Redis cache misses")

URLS_CREATED = Counter("app_urls_created_total", "Total shortened URLs created")
