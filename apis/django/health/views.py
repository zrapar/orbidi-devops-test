from django.http import JsonResponse
from django.db import connection
from django.shortcuts import render
import logging

logger = logging.getLogger(__name__)

def health_check(request):
    """
    Endpoint para verificar la salud del servicio.
    """
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1;")
            result = cursor.fetchone()
            if result:
                logger.info(f"result => {result}")
                return JsonResponse({"status": "ok", "message": "Service is healthy."}, status=200)
    except Exception as e:
        return JsonResponse({"status": "error", "message": f"Database health check failed: {e}"}, status=500)

def home(request):
    """
    Página principal del proyecto.
    """
    return render(request, "home.html", {"title": "Welcome to Orbidi"})
