import os

import requests
from fastapi import FastAPI, Depends
from sqlalchemy import create_engine, Column, String
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.exc import IntegrityError
from prometheus_client import Counter, make_asgi_app



app = FastAPI()
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

# Prometheus Metrics
REQUESTS_COUNTER = Counter('ip_country_requests_total', 'Total number of requests to /ip-country')

# Database Configuration
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
Base = declarative_base()


class IPRecord(Base):
    __tablename__ = "ip_records"

    id = Column(String, primary_key=True)
    country = Column(String)

Base.metadata.create_all(bind=engine)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# Dependency to get the database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/ip-country/{ip}")
async def get_ip_country(ip: str, db: SessionLocal = Depends(get_db)):
    REQUESTS_COUNTER.inc()  # Increment Prometheus metric

    # Check if the IP record already exists in the database
    db_record = db.query(IPRecord).filter_by(id=ip).first()

    if db_record:
        country = db_record.country
    else:
        # Fetch country information using an external service or library
        country = fetch_country_info(ip)

        # Save the obtained data to the database
        new_record = IPRecord(id=ip, country=country)
        try:
            db.add(new_record)
            db.commit()
        except IntegrityError:
            db.rollback()

    return {"ip": ip, "country": country}


def fetch_country_info(ip):
    response = requests.get(f"https://ip.guide/{ip}")
    data = response.json()
    return data.get("location").get("country", "Unknown")


