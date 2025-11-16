#!/usr/bin/env bash
set -e

FILE="src/pages/MoviesPage.jsx"

echo "Patching featured poster size in MoviesPage.jsx..."

# Remove old featured block and replace with constrained version
sed -i '/{featured && (/,+25d' "$FILE"

cat >> "$FILE" << 'NEWBLOCK'

{featured && (
  <section
    style={{
      marginBottom: "20px",
      padding: "14px",
      borderRadius: "12px",
      border: "1px solid #1f2933",
      background:
        "linear-gradient(135deg, rgba(8,47,73,0.9), rgba(15,23,42,0.95))"
    }}
  >
    <h2 style={{ fontSize: "18px", marginBottom: "6px" }}>
      Featured result
    </h2>

    {/* Limit width so poster is not giant */}
    <div
      style={{
        maxWidth: "260px",
        margin: "0 auto"
      }}
    >
      {renderCard(featured)}
    </div>
  </section>
)}

NEWBLOCK

echo "Fix complete. Restart dev server if needed."
