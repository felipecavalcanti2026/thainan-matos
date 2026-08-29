#!/bin/bash
# Instala as 9 fotos de casos no carrossel.
#
#   ./_instalar-fotos.sh ~/Desktop/fotos-thainan
#
# Pega TODOS os arquivos de imagem da pasta indicada (em ordem alfabética),
# renomeia para caso-01..09, converte para JPG se precisar, joga em img/casos/
# e mostra a que caso cada arquivo virou — para você conferir antes de publicar.
# Usa sips, que já vem no macOS. Nada para instalar.
set -e
cd "$(dirname "$0")"

ORIG="$1"
[ -z "$ORIG" ] && { echo "uso: ./_instalar-fotos.sh <pasta-com-as-9-fotos>"; exit 1; }
[ -d "$ORIG" ] || { echo "pasta nao encontrada: $ORIG"; exit 1; }

# ordem esperada + o recorte que ja esta calibrado no index.html
DESC=( "labios, colete listrado          | sem marca"
       "camiseta listrada preta/branca   | marca no TOPO"
       "polo branca, loira               | marca no TOPO"
       "blazer camel                     | marca no TOPO"
       "toalha azul                      | marca no TOPO e na BASE"
       "loira, corrente dourada          | marca no TOPO e na BASE"
       "cacheada, blusa rosa             | sem marca"
       "cabelo preto, camisa branca      | marca no TOPO"
       "brinco dourado, blusa preta      | marca na BASE" )

mkdir -p img/casos
IFS=$'\n'
ARQS=($(find "$ORIG" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.heic' -o -iname '*.webp' \) | sort))
unset IFS

TOTAL=${#ARQS[@]}
echo "encontrei $TOTAL imagem(ns) em $ORIG"
[ "$TOTAL" -eq 0 ] && { echo "nenhuma imagem. abortando."; exit 1; }
[ "$TOTAL" -ne 9 ] && echo "AVISO: o carrossel espera 9. vou instalar as $TOTAL primeiras."
echo

for i in $(seq 0 $((TOTAL-1))); do
  [ "$i" -ge 9 ] && break
  n=$(printf "%02d" $((i+1)))
  src="${ARQS[$i]}"
  dst="img/casos/caso-$n.jpg"
  sips -s format jpeg -s formatOptions 88 "$src" --out "$dst" >/dev/null 2>&1
  dim=$(sips -g pixelWidth -g pixelHeight "$dst" | awk '/pixel/{printf "%s ", $2}')
  printf "  caso-%s.jpg  <-  %-30s  %s\n" "$n" "$(basename "$src")" "(${dim% })"
  printf "               esperado: %s\n" "${DESC[$i]}"
done

echo
echo "Pronto. Confira em img/casos/ se a ordem bateu com a descricao acima."
echo "Se alguma trocou de lugar, basta renomear os arquivos entre si."
echo
echo "Para publicar:"
echo "  git add -A && git commit -m 'Adiciona as fotos de casos' && git push"
