#!/bin/bash

# Script para renderizar el bookdown de Marketing Engineering
# Uso: ./render_book.sh [formato]
# Formatos disponibles: gitbook (default), pdf, epub, all

RSCRIPT="/Library/Frameworks/R.framework/Resources/bin/Rscript"

cd "$(dirname "$0")"

FORMAT=${1:-gitbook}

case $FORMAT in
  gitbook|html)
    echo "📚 Renderizando GitBook (HTML)..."
    $RSCRIPT -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"
    echo "✅ GitBook creado en: docs/index.html"
    ;;
  pdf)
    echo "📄 Renderizando PDF..."
    $RSCRIPT -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"
    echo "✅ PDF creado en: docs/bookdown-demo.pdf"
    ;;
  epub)
    echo "📖 Renderizando EPUB..."
    $RSCRIPT -e "bookdown::render_book('index.Rmd', 'bookdown::epub_book')"
    echo "✅ EPUB creado en: docs/bookdown-demo.epub"
    ;;
  all)
    echo "📚 Renderizando todos los formatos..."
    $RSCRIPT -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"
    $RSCRIPT -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"
    $RSCRIPT -e "bookdown::render_book('index.Rmd', 'bookdown::epub_book')"
    echo "✅ Todos los formatos creados en: docs/"
    ;;
  *)
    echo "❌ Formato no reconocido: $FORMAT"
    echo "Formatos disponibles: gitbook, pdf, epub, all"
    exit 1
    ;;
esac
