import os
import redis

REDIS_URL = os.environ["REDIS_URL"]
redis_client = redis.from_url(REDIS_URL, decode_responses=True, socket_connect_timeout=2)

CACHE_TTL_SECONDS = 3600

def get_cached_url(short_code: str) -> str | None:
    try:
        return redis_client.get(f"url:{short_code}")
    except redis.RedisError:
        return None

def set_cached_url(short_code: str, original_url: str) -> None:
    try:
        redis_client.setex(f"url:{short_code}", CACHE_TTL_SECONDS, original_url)
    except redis.RedisError:
        pass