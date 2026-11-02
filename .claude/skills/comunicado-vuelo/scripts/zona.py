#!/usr/bin/env python3
"""Genera la zona de vuelo (polígono) en el formato GeoJSON que usa el formulario de Interior.

Uso:
  python3 -I zona.py LAT LON [RADIO_M] [LADOS]
  python3 -I zona.py 36.4170 -5.1520 100

Salida (stdout), una línea JSON con:
  mapa_value  -> texto para formCampos:pestanas:zona_actN:mapa_value
  lugar       -> "lat,lon,17" para Lugar de protección / recuperación
  poligono    -> [[lon,lat],...] para guardar en perfil.yaml > ubicaciones
"""
import json
import math
import sys

PROPIEDADES = {
    "tipo": "Generica", "visible": True, "color": "#0000FF", "centrado": False,
    "editable": False, "precision": 0, "animado": False, "lineaDiscontinua": False,
    "soloContorno": False, "origen": False, "destino": False, "opacity": "0.3",
}


def circulo(lat, lon, radio_m=100.0, lados=16):
    r_lat = radio_m / 111_320.0
    r_lon = radio_m / (111_320.0 * math.cos(math.radians(lat)))
    pts = []
    for i in range(lados):
        a = 2 * math.pi * i / lados
        pts.append([round(lon + r_lon * math.sin(a), 7), round(lat + r_lat * math.cos(a), 7)])
    pts.append(pts[0])
    return pts


def mapa_value(poligono):
    fc = {
        "features": [{
            "geometry": {"coordinates": [poligono], "type": "Polygon"},
            "id": "1", "type": "Feature", "properties": PROPIEDADES,
        }],
        "type": "FeatureCollection",
    }
    return json.dumps(fc, separators=(",", ":"))


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    lat, lon = float(argv[1]), float(argv[2])
    radio = float(argv[3]) if len(argv) > 3 else 100.0
    lados = int(argv[4]) if len(argv) > 4 else 16
    if not (35 < lat < 44 and -19 < lon < 5):
        print(f"Aviso: {lat},{lon} no parece estar en España", file=sys.stderr)
    pol = circulo(lat, lon, radio, lados)
    print(json.dumps({
        "mapa_value": mapa_value(pol),
        "lugar": f"{lat:.5f},{lon:.5f},17",
        "poligono": pol,
    }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
