from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import RedirectResponse
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from sqlalchemy import text

from .database import get_db, engine, Base
from .models import URLMapping
from .schemas import ShortenRequest, ShortenResponse
from .cache import get_cached_url, set_cached_url
from .shortcode import generate_short_code

Base.metadata.create_all(bind=engine)

app = FastAPI(title="URL Shortener")


@app.post("/shorten", response_model=ShortenResponse)
def shorten_url(payload: ShortenRequest, db: Session = Depends(get_db)):
    for _ in range(5):
        code = generate_short_code()
        mapping = URLMapping(short_code=code, original_url=str(payload.url))
        db.add(mapping)
        try:
            db.commit()
            return ShortenResponse(short_code=code, short_url=f"/{code}")
        except IntegrityError:
            db.rollback()
            continue
    raise HTTPException(status_code=500, detail="Could not generate a unique short code")


@app.get("/health")
def health(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"status": "ok"}


@app.get("/{code}")
def redirect(code: str, db: Session = Depends(get_db)):
    cached_url = get_cached_url(code)
    if cached_url:
        _increment_click_count(db, code)
        return RedirectResponse(url=cached_url)

    mapping = db.query(URLMapping).filter(URLMapping.short_code == code).first()
    if not mapping:
        raise HTTPException(status_code=404, detail="Short code not found")

    set_cached_url(code, mapping.original_url)
    _increment_click_count(db, code)
    return RedirectResponse(url=mapping.original_url)


def _increment_click_count(db: Session, code: str):
    db.query(URLMapping).filter(URLMapping.short_code == code).update(
        {URLMapping.click_count: URLMapping.click_count + 1}
    )
    db.commit()
