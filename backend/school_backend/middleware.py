"""
Middleware for database connection management
"""
from django.db import connection


class DatabaseConnectionMiddleware:
    """Middleware to ensure database connections are properly closed after each request"""
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        response = self.get_response(request)
        # Close any stale database connections after request
        # This helps prevent transaction errors with Supabase connection pooling
        connection.close()
        return response

