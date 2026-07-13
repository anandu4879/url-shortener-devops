import os
import time
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = os.environ["DATABASE_URL"]

def get_engine(retries: int = 10, delay: int = 3):
    last_error = None
    for attempt in range(retries):
        try:
            engine = create_engine(DATABASE_URL, pool_pre_ping=True)
            engine.connect().close()
            return engine
        except Exception as e:
            last_error = e
            time.sleep(delay)
    raise RuntimeError(f"Could not connect to database after {retries} attempts") from last_error

engine = get_engine()
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()