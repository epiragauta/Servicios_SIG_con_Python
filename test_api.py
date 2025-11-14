#!/usr/bin/env python3
"""
Script de pruebas para pygeoapi
"""

import requests
import json
import sys

BASE_URL = "http://localhost:5000"

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'

def test_endpoint(name, endpoint, expected_status=200, check_json=True):
    """Prueba un endpoint y verifica el resultado"""
    print(f"\n{Colors.BLUE}Probando: {name}{Colors.RESET}")
    print(f"Endpoint: {endpoint}")
    print("-" * 60)

    try:
        response = requests.get(f"{BASE_URL}{endpoint}", timeout=10)

        # Verificar status code
        if response.status_code == expected_status:
            print(f"{Colors.GREEN}✓ Status Code: {response.status_code}{Colors.RESET}")
            status_ok = True
        else:
            print(f"{Colors.RED}✗ Status Code: {response.status_code} (esperado {expected_status}){Colors.RESET}")
            status_ok = False

        # Verificar JSON
        if check_json and status_ok:
            try:
                data = response.json()
                print(f"{Colors.GREEN}✓ Respuesta JSON válida{Colors.RESET}")
                print(f"  Campos principales: {', '.join(list(data.keys())[:5])}")

                if 'features' in data:
                    print(f"  Número de features: {len(data['features'])}")
                if 'numberMatched' in data:
                    print(f"  Total matched: {data['numberMatched']}")
                if 'numberReturned' in data:
                    print(f"  Total returned: {data['numberReturned']}")

                json_ok = True
            except json.JSONDecodeError:
                print(f"{Colors.RED}✗ Respuesta no es JSON válido{Colors.RESET}")
                json_ok = False
        else:
            json_ok = True

        return status_ok and json_ok

    except requests.exceptions.RequestException as e:
        print(f"{Colors.RED}✗ Error de conexión: {str(e)}{Colors.RESET}")
        return False

def test_feature_retrieval():
    """Prueba la recuperación de features individuales"""
    print(f"\n{Colors.BLUE}Probando: Recuperación de Feature Individual{Colors.RESET}")
    print("-" * 60)

    try:
        # Obtener lista de features
        response = requests.get(f"{BASE_URL}/collections/amazonas/items?limit=1")
        data = response.json()

        if 'features' in data and len(data['features']) > 0:
            feature_id = data['features'][0]['id']
            print(f"Feature ID obtenido: {feature_id}")

            # Obtener el feature individual
            response = requests.get(f"{BASE_URL}/collections/amazonas/items/{feature_id}")

            if response.status_code == 200:
                feature = response.json()
                print(f"{Colors.GREEN}✓ Feature recuperado exitosamente{Colors.RESET}")
                print(f"  ID: {feature.get('id')}")
                print(f"  Tipo: {feature.get('type')}")
                print(f"  Geometría: {feature.get('geometry', {}).get('type')}")
                return True
            else:
                print(f"{Colors.RED}✗ Error al recuperar feature{Colors.RESET}")
                return False
        else:
            print(f"{Colors.YELLOW}⚠ No hay features disponibles para probar{Colors.RESET}")
            return True

    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        return False

def test_filters():
    """Prueba los filtros de la API"""
    print(f"\n{Colors.BLUE}Probando: Filtros y Parámetros{Colors.RESET}")
    print("-" * 60)

    results = []

    # Probar limit
    print("\n1. Parámetro limit:")
    for limit in [1, 5, 10]:
        try:
            response = requests.get(f"{BASE_URL}/collections/amazonas/items?limit={limit}")
            data = response.json()
            returned = data.get('numberReturned', 0)
            print(f"   limit={limit}: {returned} features devueltos")
            results.append(returned <= limit)
        except Exception as e:
            print(f"{Colors.RED}   Error con limit={limit}: {e}{Colors.RESET}")
            results.append(False)

    # Probar bbox
    print("\n2. Parámetro bbox:")
    try:
        response = requests.get(f"{BASE_URL}/collections/amazonas/items?bbox=-75,-2,-70,2")
        if response.status_code == 200:
            data = response.json()
            print(f"{Colors.GREEN}✓ Filtro bbox funciona{Colors.RESET}")
            print(f"   Features devueltos: {data.get('numberReturned', 0)}")
            results.append(True)
        else:
            print(f"{Colors.RED}✗ Error con filtro bbox{Colors.RESET}")
            results.append(False)
    except Exception as e:
        print(f"{Colors.RED}✗ Error: {e}{Colors.RESET}")
        results.append(False)

    return all(results)

def main():
    """Ejecutar todas las pruebas"""
    print("=" * 60)
    print("Pruebas de pygeoapi - Colección Amazonas")
    print("=" * 60)

    # Verificar que el servidor está ejecutándose
    try:
        response = requests.get(BASE_URL, timeout=5)
        print(f"{Colors.GREEN}✓ Servidor accesible en {BASE_URL}{Colors.RESET}")
    except requests.exceptions.RequestException:
        print(f"{Colors.RED}✗ Error: No se puede conectar a {BASE_URL}{Colors.RESET}")
        print("\nAsegúrate de que el servidor está ejecutándose:")
        print("  ./start.sh")
        sys.exit(1)

    results = []

    # Pruebas de endpoints básicos
    results.append(test_endpoint("Landing Page", "/"))
    results.append(test_endpoint("Conformance", "/conformance"))
    results.append(test_endpoint("OpenAPI Specification", "/openapi"))
    results.append(test_endpoint("Collections", "/collections"))
    results.append(test_endpoint("Collection Amazonas", "/collections/amazonas"))
    results.append(test_endpoint("Amazonas Items", "/collections/amazonas/items"))
    results.append(test_endpoint("Amazonas Items (limit=5)", "/collections/amazonas/items?limit=5"))

    # Pruebas avanzadas
    results.append(test_feature_retrieval())
    results.append(test_filters())

    # Prueba de endpoint inexistente
    results.append(test_endpoint("404 Not Found", "/noexiste", expected_status=404, check_json=False))

    # Resumen
    print("\n" + "=" * 60)
    print("RESUMEN DE PRUEBAS")
    print("=" * 60)

    passed = sum(results)
    total = len(results)
    failed = total - passed

    print(f"Total de pruebas: {total}")
    print(f"{Colors.GREEN}Exitosas: {passed}{Colors.RESET}")
    if failed > 0:
        print(f"{Colors.RED}Fallidas: {failed}{Colors.RESET}")
    else:
        print(f"Fallidas: {failed}")

    print("\n" + "=" * 60)

    if failed == 0:
        print(f"{Colors.GREEN}✓ Todas las pruebas pasaron exitosamente{Colors.RESET}\n")
        print("El servidor pygeoapi está funcionando correctamente.")
        print("\nPuedes acceder a:")
        print(f"  - Landing page:    {BASE_URL}")
        print(f"  - Documentación:   {BASE_URL}/openapi?f=html")
        print(f"  - Colecciones:     {BASE_URL}/collections")
        print(f"  - Items Amazonas:  {BASE_URL}/collections/amazonas/items")
        sys.exit(0)
    else:
        print(f"{Colors.RED}✗ Algunas pruebas fallaron{Colors.RESET}\n")
        print("Revisa los logs para más información:")
        print("  tail -f logs/pygeoapi.log")
        sys.exit(1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Pruebas interrumpidas por el usuario{Colors.RESET}")
        sys.exit(1)
