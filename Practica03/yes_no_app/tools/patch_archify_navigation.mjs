import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const [htmlArg, specArg] = process.argv.slice(2);
if (!htmlArg || !specArg) {
  throw new Error('Usage: node tools/patch_archify_navigation.mjs <diagram.html> <spec.json>');
}

const htmlPath = resolve(htmlArg);
const specPath = resolve(specArg);
const [html, specText] = await Promise.all([
  readFile(htmlPath, 'utf8'),
  readFile(specPath, 'utf8'),
]);
const spec = JSON.parse(specText);
const repository = spec.meta?.repository?.url?.replace(/\/$/, '');
const revision = spec.meta?.repository?.revision;
if (!repository || !revision) throw new Error('The spec must define a repository URL and revision.');

const sources = Object.fromEntries(spec.components.map((component) => {
  const source = component.sources?.[0];
  if (!source) throw new Error(`Component ${component.id} has no source file.`);
  const fileUrl = `${repository}/blob/${revision}/${source.path}`;
  return [component.id, { url: fileUrl, label: source.label ?? component.label }];
}));

const marker = '<script id="archify-github-node-navigation">';
if (html.includes(marker)) throw new Error('Node navigation is already installed in this HTML.');
const script = `${marker}
(function () {
  const sources = ${JSON.stringify(sources)};
  const diagram = document.querySelector('.diagram-container svg');
  if (!diagram) return;

  function sourceFor(node) {
    const id = node && node.getAttribute('data-node-id');
    return id ? sources[id] : null;
  }
  function openSource(event, node) {
    const source = sourceFor(node);
    if (!source) return;
    event.preventDefault();
    event.stopPropagation();
    event.stopImmediatePropagation();
    window.open(source.url, '_blank', 'noopener,noreferrer');
  }

  diagram.addEventListener('click', function (event) {
    const node = event.target.closest('[data-node-id]');
    if (node && diagram.contains(node)) openSource(event, node);
  }, true);
  diagram.addEventListener('keydown', function (event) {
    if (event.key !== 'Enter' && event.key !== ' ') return;
    const node = event.target.closest('[data-node-id]');
    if (!node || !diagram.contains(node) || !sourceFor(node)) return;
    openSource(event, node);
  }, true);

  Object.entries(sources).forEach(function ([id, source]) {
    const node = diagram.querySelector('[data-node-id="' + id + '"]');
    if (node) node.setAttribute('title', 'Abrir ' + source.label + ' en GitHub');
  });
})();
</script>`;

if (!html.includes('</body>')) throw new Error('Could not find the HTML body closing tag.');
const patched = html.replace('</body>', `${script}\n</body>`);
await writeFile(htmlPath, patched, 'utf8');
console.log(`Added source navigation for ${Object.keys(sources).length} diagram nodes: ${htmlPath}`);
