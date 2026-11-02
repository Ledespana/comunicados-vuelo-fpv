// Zona de vuelo (círculo) en el formato GeoJSON del formulario de Interior.
// Funciona igual en Mac y Windows: se ejecuta DENTRO de la página del formulario (Claude in Chrome → javascript_tool),
// así que no necesita Python ni nada instalado.
//
// Uso en la página del formulario (copiar esta función y llamarla):
//   const z = zonaCirculo(36.54567, -5.23548, 500);   // lat, lon, radio en metros
//   z.mapaValue  -> texto para formCampos:pestanas:zona_actN:mapa_value
//   z.lugar      -> "lat,lon,17" para Lugar de protección / recuperación
//   z.poligono   -> [[lon,lat],...] para guardar en perfil.yaml > ubicaciones
function zonaCirculo(lat, lon, radioM = 100, lados = 16) {
  const rLat = radioM / 111320;
  const rLon = radioM / (111320 * Math.cos(lat * Math.PI / 180));
  const poligono = [];
  for (let i = 0; i < lados; i++) {
    const a = 2 * Math.PI * i / lados;
    poligono.push([+(lon + rLon * Math.sin(a)).toFixed(7), +(lat + rLat * Math.cos(a)).toFixed(7)]);
  }
  poligono.push(poligono[0]);
  const fc = {
    features: [{
      geometry: { coordinates: [poligono], type: "Polygon" },
      id: "1", type: "Feature",
      properties: {
        tipo: "Generica", visible: true, color: "#0000FF", centrado: false, editable: false, precision: 0,
        animado: false, lineaDiscontinua: false, soloContorno: false, origen: false, destino: false, opacity: "0.3",
      },
    }],
    type: "FeatureCollection",
  };
  return { mapaValue: JSON.stringify(fc), lugar: `${lat.toFixed(5)},${lon.toFixed(5)},17`, poligono };
}

if (typeof module !== "undefined") module.exports = { zonaCirculo };
