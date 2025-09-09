#!/bin/bash
# Example Pandoc conversions for WebLaTeX environment
# This script demonstrates common document conversions you might need

set -e

echo "🔄 Pandoc Examples for WebLaTeX"
echo "================================"

# Check if pandoc is available
if ! command -v pandoc &> /dev/null; then
    echo "❌ Pandoc not found. Please run ./install_pandoc.sh first"
    exit 1
fi

echo "✅ Pandoc version: $(pandoc --version | head -1)"
echo ""

# Create example directory if it doesn't exist
mkdir -p /tmp/pandoc_examples
cd /tmp/pandoc_examples

echo "📝 Creating example documents..."

# Create a sample markdown file
cat > sample.md << 'EOF'
# Sample Document

This is a **sample document** with:

- Bullet points
- *Italics* and **bold** text
- [Links](https://github.com)

## Math Formula

When $a \ne 0$, the solutions of $ax^2 + bx + c = 0$ are:

$$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$$

## Code Block

```python
def hello_world():
    print("Hello, World!")
```

## Table

| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| A        | B        | C        |
| 1        | 2        | 3        |
EOF

# Create a sample LaTeX file
cat > sample.tex << 'EOF'
\documentclass{article}
\usepackage{amsmath}
\usepackage{hyperref}

\title{Sample LaTeX Document}
\author{WebLaTeX User}
\date{\today}

\begin{document}
\maketitle

\section{Introduction}

This is a sample \LaTeX{} document that can be converted using Pandoc.

\section{Mathematics}

The quadratic formula is:
\begin{equation}
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
\end{equation}

\section{Lists}

\begin{itemize}
\item First item
\item Second item  
\item Third item
\end{itemize}

\end{document}
EOF

echo "🔄 Running conversion examples..."

echo ""
echo "1️⃣  Converting Markdown to HTML..."
pandoc sample.md -o sample.html
echo "   ✅ Created sample.html"

echo ""
echo "2️⃣  Converting Markdown to LaTeX..."
pandoc sample.md -o sample_from_md.tex
echo "   ✅ Created sample_from_md.tex"

echo ""
echo "3️⃣  Converting LaTeX to HTML..."
pandoc sample.tex -o sample_from_tex.html
echo "   ✅ Created sample_from_tex.html"

echo ""
echo "4️⃣  Converting Markdown to PDF (requires LaTeX)..."
if pandoc sample.md -o sample.pdf 2>/dev/null; then
    echo "   ✅ Created sample.pdf"
else
    echo "   ⚠️  PDF creation failed (LaTeX distribution may be needed)"
    echo "      In WebLaTeX, use LaTeX Workshop for PDF generation"
fi

echo ""
echo "5️⃣  Converting with custom options..."
pandoc sample.md -s --toc --highlight-style=tango -o sample_fancy.html
echo "   ✅ Created sample_fancy.html with table of contents and syntax highlighting"

echo ""
echo "📁 Generated files:"
ls -la *.html *.tex *.pdf 2>/dev/null || ls -la *.html *.tex

echo ""
echo "🎯 Common Pandoc commands for WebLaTeX:"
echo ""
echo "   # Convert any document to HTML"
echo "   pandoc document.md -o output.html"
echo ""
echo "   # Convert with citations (if you have .bib files)"  
echo "   pandoc document.md --bibliography=refs.bib --csl=style.csl -o document.html"
echo ""
echo "   # Convert LaTeX to Markdown (for collaboration)"
echo "   pandoc document.tex -o document.md"
echo ""
echo "   # Merge multiple files"
echo "   pandoc file1.md file2.md file3.md -o combined.html"
echo ""
echo "💡 Pro tip: In WebLaTeX, use LaTeX Workshop for .tex → .pdf"
echo "   Pandoc is perfect for converting between other formats!"

echo ""
echo "🧹 Cleaning up examples..."
cd /
rm -rf /tmp/pandoc_examples

echo "✅ Examples complete!"