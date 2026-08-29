#!/bin/bash
# Remove definitivamente a faixa com a marca d'agua das fotos de casos.
# Usa "sips", que ja vem instalado no macOS. Nao precisa instalar nada.
#
#   ./_limpar-marca.sh
#
# Le  img/casos/caso-NN.jpg  e escreve  img/casos/limpas/caso-NN.jpg
# Depois: substitua os originais e troque todos os data-corte por "nenhum"
# (e remova os data-zoom) no index.html.
set -e
cd "$(dirname "$0")"
ORIG="img/casos"; DEST="$ORIG/limpas"; mkdir -p "$DEST"

# arquivo  fracao_topo  fracao_base   (mesma tabela usada no index.html)
CORTES="
caso-01 0     0
caso-02 0.10  0
caso-03 0.085 0
caso-04 0.085 0
caso-05 0.085 0.085
caso-06 0.085 0.085
caso-07 0     0
caso-08 0.10  0
caso-09 0     0.085
"
echo "$CORTES" | while read -r nome t b; do
  [ -z "$nome" ] && continue
  src="$ORIG/$nome.jpg"
  if [ ! -f "$src" ]; then echo "  faltando  $nome.jpg"; continue; fi
  w=$(sips -g pixelWidth  "$src" | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$src" | awk '/pixelHeight/{print $2}')
  top=$(printf "%.0f" "$(echo "$h * $t" | bc -l)")
  bot=$(printf "%.0f" "$(echo "$h * $b" | bc -l)")
  nh=$((h - top - bot))
  if [ "$top" -eq 0 ] && [ "$bot" -eq 0 ]; then
    cp "$src" "$DEST/$nome.jpg"; echo "  intacta   $nome.jpg  (${w}x${h})"
  else
    sips -c "$nh" "$w" --cropOffset "$top" 0 "$src" --out "$DEST/$nome.jpg" >/dev/null
    echo "  cortada   $nome.jpg  ${w}x${h} -> ${w}x${nh}  (topo ${top}px, base ${bot}px)"
  fi
done
echo ""
echo "Prontas em: $DEST"
