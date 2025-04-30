from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import List, Optional
import json
import os
from pydantic import BaseModel

app = FastAPI()

origins = ["http://localhost:3000"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

auth_scheme = HTTPBearer(auto_error=False)

# Mock authentication for demo purposes
async def verify_token(token: HTTPAuthorizationCredentials = Depends(auth_scheme)):
    if token:
        # In a real app, we would verify the token with Firebase
        # For demo, we'll just return a mock user
        return {"uid": "demo-user-123", "email": "demo@example.com"}
    return None

class Deal(BaseModel):
    title: str
    price: str
    image: Optional[str] = None
    url: str
    category: str

# Load demo data
def load_demo_data():
    demo_deals = [
        {
            "title": "Apple AirPods Pro (2nd Generation) Wireless Earbuds",
            "price": "199.99 USD",
            "image": "https://m.media-amazon.com/images/I/61SUj2aKoEL._AC_SL1500_.jpg",
            "url": "https://www.amazon.com/Apple-Generation-Cancelling-Transparency-Personalized/dp/B0BDHWDR12/",
            "category": "electronics"
        },
        {
            "title": "Samsung Galaxy S23 Ultra Cell Phone, 256GB, Phantom Black",
            "price": "899.99 USD",
            "image": "https://m.media-amazon.com/images/I/71Sa3dqTqzL._AC_SL1500_.jpg",
            "url": "https://www.amazon.com/Samsung-Unlocked-Smartphone-Nightography-Graphite/dp/B0BLP45GY8/",
            "category": "electronics"
        },
        {
            "title": "Sony WH-1000XM5 Wireless Noise Canceling Headphones",
            "price": "328.00 USD",
            "image": "https://m.media-amazon.com/images/I/61+btxzpfDL._AC_SL1500_.jpg",
            "url": "https://www.amazon.com/Sony-WH-1000XM5-Canceling-Headphones-Hands-Free/dp/B09XS7JWHH/",
            "category": "electronics"
        },
        {
            "title": "PlayStation 5 Console Slim",
            "price": "449.99 USD",
            "image": "https://m.media-amazon.com/images/I/51QKZfyi-dL._SL1000_.jpg",
            "url": "https://www.amazon.com/PlayStation-5-Console-Slim/dp/B0C3KCFQ4G/",
            "category": "gaming"
        },
        {
            "title": "Xbox Series X Console",
            "price": "499.99 USD",
            "image": "https://m.media-amazon.com/images/I/61-jjE67uqL._SL1500_.jpg",
            "url": "https://www.amazon.com/Xbox-X/dp/B08H75RTZ8/",
            "category": "gaming"
        },
        {
            "title": "Nintendo Switch OLED Model",
            "price": "349.99 USD",
            "image": "https://m.media-amazon.com/images/I/61dYrzvBLbL._SL1500_.jpg",
            "url": "https://www.amazon.com/Nintendo-Switch-OLED-Model-White-Joy/dp/B098RKWHHZ/",
            "category": "gaming"
        },
        {
            "title": "Instant Pot Duo 7-in-1 Electric Pressure Cooker",
            "price": "79.95 USD",
            "image": "https://m.media-amazon.com/images/I/71WtwEvYDOS._AC_SL1500_.jpg",
            "url": "https://www.amazon.com/Instant-Pot-Multi-Use-Programmable-Pressure/dp/B00FLYWNYQ/",
            "category": "home"
        },
        {
            "title": "Ninja AF101 Air Fryer, 4 Quart",
            "price": "89.99 USD",
            "image": "https://m.media-amazon.com/images/I/71+8uTMDRFL._AC_SL1500_.jpg",
            "url": "https://www.amazon.com/Ninja-AF101-Fryer-Black-gray/dp/B07FDJMC9Q/",
            "category": "home"
        },
        {
            "title": "Dyson V11 Cordless Vacuum Cleaner",
            "price": "469.99 USD",
            "image": "https://m.media-amazon.com/images/I/61OaV+nS4QL._AC_SL1500_.jpg",
            "url": "https://www.amazon.com/Dyson-Torque-Cordless-Vacuum-Cleaner/dp/B07NX8XBMP/",
            "category": "home"
        },
        {
            "title": "Levi's Men's 501 Original Fit Jeans",
            "price": "39.99 USD",
            "image": "https://m.media-amazon.com/images/I/61R8aKtpMKL._AC_UX569_.jpg",
            "url": "https://www.amazon.com/Levis-Original-Fit-Jeans-Medium/dp/B0018OQZAU/",
            "category": "fashion"
        },
        {
            "title": "adidas Women's Cloudfoam Pure Running Shoe",
            "price": "49.99 USD",
            "image": "https://m.media-amazon.com/images/I/71Wp+KrLUYL._AC_UY575_.jpg",
            "url": "https://www.amazon.com/adidas-Cloudfoam-Running-Black-Silver/dp/B0711R2TNX/",
            "category": "fashion"
        },
        {
            "title": "Ray-Ban Rb3025 Classic Aviator Sunglasses",
            "price": "163.00 USD",
            "image": "https://m.media-amazon.com/images/I/51x0sF+8MzL._AC_UX679_.jpg",
            "url": "https://www.amazon.com/Ray-Ban-RB3025-Aviator-Sunglasses-Gold/dp/B0014C0BRK/",
            "category": "fashion"
        },
        {
            "title": "Apple MacBook Air Laptop M2 Chip",
            "price": "899.99 USD",
            "image": "https://m.media-amazon.com/images/I/71TPda7cwUL._AC_SL1500_.jpg",
            "url": "https://www.amazon.com/Apple-MacBook-Laptop-8%E2%80%91core-7%E2%80%91core/dp/B0CB645VFF/",
            "category": "electronics"
        },
        {
            "title": "LG C2 Series 65-Inch OLED Smart TV",
            "price": "1496.99 USD",
            "image": "https://m.media-amazon.com/images/I/81LHuVVyrcL._AC_SL1500_.jpg",
            "url": "https://www.amazon.com/LG-65-Inch-Alexa-Built-OLED65C2PUA/dp/B09RMRZZGJ/",
            "category": "electronics"
        },
        {
            "title": "Elden Ring - PlayStation 5",
            "price": "39.99 USD",
            "image": "https://m.media-amazon.com/images/I/81goNGEYm6L._SL1500_.jpg",
            "url": "https://www.amazon.com/Elden-Ring-PlayStation-5/dp/B09743F8P6/",
            "category": "gaming"
        }
    ]
    return demo_deals

@app.get("/api/deals", response_model=List[Deal])
async def get_deals(
    token: dict = Depends(verify_token),
    category: str = Query(None, description="Category filter")
):
    deals = load_demo_data()
    
    if category:
        deals = [deal for deal in deals if deal["category"] == category]
    
    return deals

@app.get("/")
async def root():
    return {"message": "Welcome to ZapDeals API. Use /api/deals to get deals data."}