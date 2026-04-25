#!/bin/bash

set -euo pipefail

# Script para renderizar el bookdown de Marketing Engineering
# Uso: ./render_book.sh [formato]
# Formatos disponibles: gitbook (default), pdf, epub, all

RSCRIPT="${RSCRIPT:-}"

cd "$(dirname "$0")"

FORMAT=${1:-gitbook}
BOOK_FILE="apunte-marketing-engineering"
PDF_IMAGE="marketingengineering-pdf"
HTML_IMAGE="conoria/alpine-r-bookdown"

if [ -z "$RSCRIPT" ] && command -v Rscript >/dev/null 2>&1; then
  RSCRIPT="$(command -v Rscript)"
fi

render_with_r() {
  local output_format="$1"
  "$RSCRIPT" -e "bookdown::render_book('index.Rmd', '${output_format}')"
}

render_with_docker() {
  local image="$1"
  local output_format="$2"
  docker run --rm -v "$(pwd):/work" -w /work "${image}" \
    R -q -e "bookdown::render_book('index.Rmd', '${output_format}')"
}

render_pdf_docker() {
  docker image inspect "${PDF_IMAGE}" >/dev/null 2>&1 || \
    docker build -f Dockerfile.pdf -t "${PDF_IMAGE}" .

  render_with_docker "${PDF_IMAGE}" "bookdown::pdf_book"
}

case $FORMAT in
  gitbook|html)
    echo "📚 Renderizando GitBook (HTML)..."
    if [ -n "$RSCRIPT" ] && [ -x "$RSCRIPT" ]; then
      render_with_r "bookdown::gitbook"
    else
      render_with_docker "${HTML_IMAGE}" "bookdown::gitbook"
    fi
    echo "✅ GitBook creado en: docs/index.html"
    ;;
  pdf)
    echo "📄 Renderizando PDF..."
    if [ -x "$RSCRIPT" ]; then
      render_with_r "bookdown::pdf_book"
    else
      render_pdf_docker
    fi
    [ -f "${BOOK_FILE}.pdf" ] && cp "${BOOK_FILE}.pdf" "docs/${BOOK_FILE}.pdf"
    echo "✅ PDF creado en: docs/${BOOK_FILE}.pdf"
    ;;
  epub)
    echo "📖 Renderizando EPUB..."
    if [ -n "$RSCRIPT" ] && [ -x "$RSCRIPT" ]; then
      render_with_r "bookdown::epub_book"
    else
      render_with_docker "${HTML_IMAGE}" "bookdown::epub_book"
    fi
    [ -f "${BOOK_FILE}.epub" ] && cp "${BOOK_FILE}.epub" "docs/${BOOK_FILE}.epub"
    echo "✅ EPUB creado en: docs/${BOOK_FILE}.epub"
    ;;
  all)
    echo "📚 Renderizando todos los formatos..."
    if [ -n "$RSCRIPT" ] && [ -x "$RSCRIPT" ]; then
      render_with_r "bookdown::gitbook"
      render_with_r "bookdown::pdf_book"
      render_with_r "bookdown::epub_book"
    else
      render_with_docker "${HTML_IMAGE}" "bookdown::gitbook"
      render_pdf_docker
      render_with_docker "${HTML_IMAGE}" "bookdown::epub_book"
    fi
    [ -f "${BOOK_FILE}.pdf" ] && cp "${BOOK_FILE}.pdf" "docs/${BOOK_FILE}.pdf"
    [ -f "${BOOK_FILE}.epub" ] && cp "${BOOK_FILE}.epub" "docs/${BOOK_FILE}.epub"
    echo "✅ Todos los formatos creados en: docs/"
    ;;
  *)
    echo "❌ Formato no reconocido: $FORMAT"
    echo "Formatos disponibles: gitbook, pdf, epub, all"
    exit 1
    ;;
esac
