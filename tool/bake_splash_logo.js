const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const input = path.join(root, 'assets', 'svg', 'Animated logo.svg');
const outSvg = path.join(root, 'assets', 'svg', 'aiplant_splash_logo_static.svg');

let svg = fs.readFileSync(input, 'utf8');

function lastValue(valuesAttr) {
  const parts = valuesAttr.split(';').map((s) => s.trim()).filter(Boolean);
  return parts[parts.length - 1];
}

// Bake <animate attributeName="d|visibility|opacity" ...>
svg = svg.replace(
  /<([a-zA-Z0-9]+)([^>]*?)>(\s*)<animate\b([^>]*?)\/>/g,
  (full, tag, attrs, ws, animAttrs) => {
    const nameMatch = animAttrs.match(/attributeName="([^"]+)"/);
    const valuesMatch = animAttrs.match(/values="([^"]*)"/);
    if (!nameMatch || !valuesMatch) return full;
    const attrName = nameMatch[1];
    if (!['d', 'visibility', 'opacity'].includes(attrName)) return full;
    const finalVal = lastValue(valuesMatch[1]);
    let nextAttrs = attrs;
    const attrRe = new RegExp(`\\s${attrName}="[^"]*"`);
    if (attrRe.test(nextAttrs)) {
      nextAttrs = nextAttrs.replace(attrRe, ` ${attrName}="${finalVal}"`);
    } else {
      nextAttrs += ` ${attrName}="${finalVal}"`;
    }
    return `<${tag}${nextAttrs}>`;
  },
);

// Also handle <animate>...</animate> (non-self-closing) for path d etc.
svg = svg.replace(
  /<([a-zA-Z0-9]+)([^>]*?)>(\s*)<animate\b([^>]*?)><\/animate>/g,
  (full, tag, attrs, ws, animAttrs) => {
    const nameMatch = animAttrs.match(/attributeName="([^"]+)"/);
    const valuesMatch = animAttrs.match(/values="([^"]*)"/);
    if (!nameMatch || !valuesMatch) return full;
    const attrName = nameMatch[1];
    if (!['d', 'visibility', 'opacity'].includes(attrName)) return full;
    const finalVal = lastValue(valuesMatch[1]);
    let nextAttrs = attrs;
    const attrRe = new RegExp(`\\s${attrName}="[^"]*"`);
    if (attrRe.test(nextAttrs)) {
      nextAttrs = nextAttrs.replace(attrRe, ` ${attrName}="${finalVal}"`);
    } else {
      nextAttrs += ` ${attrName}="${finalVal}"`;
    }
    return `<${tag}${nextAttrs}>`;
  },
);

// Bake animate on sibling pattern: <g attrs><animate .../><g>...
// Already handled when animate is first child of tag via replacements above.
// Handle visibility animate that is first child more generally in a loop.

function bakeAttributeAnimates(source) {
  return source.replace(
    /<(path|g|circle|ellipse|rect|polygon|polyline)\b([^>]*?)>\s*<animate\b([^>]*?)(?:\/>|><\/animate>)/g,
    (full, tag, attrs, animAttrs) => {
      const nameMatch = animAttrs.match(/attributeName="([^"]+)"/);
      const valuesMatch = animAttrs.match(/values="([^"]*)"/);
      if (!nameMatch || !valuesMatch) return full;
      const attrName = nameMatch[1];
      if (!['d', 'visibility', 'opacity'].includes(attrName)) return full;
      const finalVal = lastValue(valuesMatch[1]);
      let nextAttrs = attrs;
      const attrRe = new RegExp(`\\s${attrName}="[^"]*"`);
      if (attrRe.test(nextAttrs)) {
        nextAttrs = nextAttrs.replace(attrRe, ` ${attrName}="${finalVal}"`);
      } else {
        nextAttrs += ` ${attrName}="${finalVal}"`;
      }
      return `<${tag}${nextAttrs}>`;
    },
  );
}

for (let i = 0; i < 20; i++) {
  const next = bakeAttributeAnimates(svg);
  if (next === svg) break;
  svg = next;
}

function transformFromAnimate(type, value) {
  const nums = value.trim().split(/[\s,]+/).filter(Boolean);
  if (type === 'translate') {
    const x = nums[0] || '0';
    const y = nums[1] || '0';
    return `translate(${x},${y})`;
  }
  if (type === 'scale') {
    const x = nums[0] || '1';
    const y = nums[1] || x;
    return `scale(${x},${y})`;
  }
  if (type === 'rotate') {
    return `rotate(${nums[0] || '0'})`;
  }
  return null;
}

function bakeTransforms(source) {
  return source.replace(
    /<g\b([^>]*?)>\s*<animateTransform\b([^>]*?)(?:\/>|><\/animateTransform>)/g,
    (full, attrs, animAttrs) => {
      const typeMatch = animAttrs.match(/type="([^"]+)"/);
      const valuesMatch = animAttrs.match(/values="([^"]*)"/);
      if (!typeMatch || !valuesMatch) return full;
      const type = typeMatch[1];
      const finalVal = lastValue(valuesMatch[1]);
      const baked = transformFromAnimate(type, finalVal);
      if (!baked) return full;

      let nextAttrs = attrs;
      if (/\stransform="[^"]*"/.test(nextAttrs)) {
        // Replace only the matching transform function if present, else replace whole transform.
        nextAttrs = nextAttrs.replace(/\stransform="([^"]*)"/, (m, current) => {
          if (type === 'translate' && /translate\(/.test(current)) {
            return ` transform="${current.replace(/translate\([^)]*\)/, baked)}"`;
          }
          if (type === 'scale' && /scale\(/.test(current)) {
            return ` transform="${current.replace(/scale\([^)]*\)/, baked)}"`;
          }
          if (type === 'rotate' && /rotate\(/.test(current)) {
            return ` transform="${current.replace(/rotate\([^)]*\)/, baked)}"`;
          }
          return ` transform="${baked}"`;
        });
      } else {
        nextAttrs += ` transform="${baked}"`;
      }
      return `<g${nextAttrs}>`;
    },
  );
}

for (let i = 0; i < 40; i++) {
  const next = bakeTransforms(svg);
  if (next === svg) break;
  svg = next;
}

// Remove any remaining animation tags
svg = svg
  .replace(/<animate\b[^>]*?\/>/g, '')
  .replace(/<animate\b[^>]*?>.*?<\/animate>/g, '')
  .replace(/<animateTransform\b[^>]*?\/>/g, '')
  .replace(/<animateTransform\b[^>]*?>.*?<\/animateTransform>/g, '');

// Force remaining hidden groups that still say hidden after bake? leave as-is.

// Ensure root has explicit pixel size for raster/flutter
if (!/viewBox=/.test(svg)) {
  svg = svg.replace('<svg', '<svg viewBox="0 0 1080 1080"');
}
svg = svg.replace(/height="100%"/, 'height="1080"').replace(/width="100%"/, 'width="1080"');

fs.writeFileSync(outSvg, svg, 'utf8');
console.log('Wrote', outSvg, 'bytes', fs.statSync(outSvg).size);
console.log('remaining animate', (svg.match(/<animate\b/g) || []).length);
console.log('remaining animateTransform', (svg.match(/<animateTransform\b/g) || []).length);
console.log('scale(0', (svg.match(/scale\(0/g) || []).length);
console.log('visibility hidden', (svg.match(/visibility="hidden"/g) || []).length);
