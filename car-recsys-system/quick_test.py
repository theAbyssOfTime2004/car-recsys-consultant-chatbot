#!/usr/bin/env python3
"""
Quick API test script
"""
import requests
import json

BASE_URL = "http://localhost:8000"

print("=== Testing API ===\n")

# 1. Health check
print("1. Health Check:")
try:
    r = requests.get(f"{BASE_URL}/health", timeout=5)
    print(f"   Status: {r.status_code}")
    print(f"   Response: {r.json()}\n")
except Exception as e:
    print(f"   ❌ Error: {e}\n")

# 2. Search vehicles
print("2. Search Vehicles (first 3):")
try:
    r = requests.get(f"{BASE_URL}/api/v1/search?page_size=3", timeout=10)
    print(f"   Status: {r.status_code}")
    if r.status_code == 200:
        data = r.json()
        print(f"   Total: {data.get('total', 0)}")
        print(f"   Results: {len(data.get('results', []))}")
        if data.get('results'):
            print(f"   First vehicle: {data['results'][0].get('title', 'N/A')}")
    else:
        print(f"   Error: {r.text[:200]}")
    print()
except Exception as e:
    print(f"   ❌ Error: {e}\n")

# 3. Register user
print("3. Register User:")
try:
    import time
    email = f"test{int(time.time())}@example.com"
    payload = {
        "email": email,
        "password": "test123456",
        "full_name": "Test User"
    }
    r = requests.post(f"{BASE_URL}/api/v1/auth/register", json=payload, timeout=10)
    print(f"   Status: {r.status_code}")
    if r.status_code in [200, 201]:
        data = r.json()
        print(f"   ✓ User created: {data.get('user', {}).get('email')}")
        print(f"   Token: {data.get('access_token', '')[:50]}...")
    else:
        print(f"   Response: {r.text[:200]}")
    print()
except Exception as e:
    print(f"   ❌ Error: {e}\n")

print("=== Done ===")
