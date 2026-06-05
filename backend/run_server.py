"""
Server runner script for Child Safety Monitor API
Runs uvicorn on 0.0.0.0:8000 for network-wide access
"""

import uvicorn

if __name__ == "__main__":
    print("🚀 Starting Child Safety Monitor API Server...")
    print("📡 Server accessible at http://0.0.0.0:8000")
    print("📋 API docs available at http://localhost:8000/docs")
    print("-" * 50)
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",  # Critical: allows access from other devices on the network
        port=8000,
        reload=True,  # Auto-reload on code changes during development
        log_level="info"
    )
