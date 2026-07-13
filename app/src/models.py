from sqlalchemy import Column, String, Integer, DateTime, func
from .database import Base

class URLMapping(Base):
    __tablename__ = "url_mappings"

    id = Column(Integer, primary_key=True)
    short_code = Column(String(10), unique=True, nullable=False, index=True)
    original_url = Column(String(2048), nullable=False)
    click_count = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())