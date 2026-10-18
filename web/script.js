// JVL TextUI - NUI. Look and behaviour come from config.lua through the 'setup' message.
const caja = document.getElementById('textui');
const texto = document.getElementById('texto');
const icono = document.getElementById('icono');
const iconoI = document.getElementById('icono-i');
const raiz = document.documentElement.style;

const POSICIONES = ['left-center', 'right-center', 'top-center', 'bottom-center', 'top-left', 'top-right', 'bottom-left', 'bottom-right', 'center'];
const ANIMACIONES = { spin: 'fa-spin', beat: 'fa-beat', pulse: 'fa-beat', fade: 'fa-fade', beatFade: 'fa-beat-fade', bounce: 'fa-bounce', shake: 'fa-shake' };

let teclasActivas = true;
let colorIcono = '';
let ultimoSonido = 0;

function escapar(s) {
    return String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[c]));
}

// Escaped first, then: [E] -> key cap, **bold**, line breaks. Nothing from the caller becomes raw HTML.
function formatear(s) {
    let html = escapar(s)
        .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
        .replace(/~n~|\n/g, '<br>');
    if (teclasActivas) html = html.replace(/\[([A-Za-z0-9+\-_. ]{1,12})\]/g, '<span class="tecla">$1</span>');
    return html;
}

// Config.Style / Margins / KeyCaps / Icon / Animation -> CSS variables and classes
function configurar(d) {
    const s = d.style || {};
    const px = (v) => `${Number(v)}px`;
    if (s.accent) raiz.setProperty('--tui-acento', s.accent);
    if (s.textColor) raiz.setProperty('--tui-texto', s.textColor);
    if (s.font) raiz.setProperty('--tui-fuente', `'${s.font}', 'Segoe UI', Arial, sans-serif`);
    if (s.fontSize) raiz.setProperty('--tui-tamano', px(s.fontSize));
    if (s.fontWeight) raiz.setProperty('--tui-peso', s.fontWeight);
    if (s.borderWidth !== undefined) raiz.setProperty('--tui-borde', px(s.borderWidth));
    if (s.radius !== undefined) raiz.setProperty('--tui-radio', px(s.radius));
    if (s.minWidth) raiz.setProperty('--tui-min', px(s.minWidth));
    if (s.maxWidth) raiz.setProperty('--tui-max', px(s.maxWidth));
    if (Array.isArray(s.padding)) raiz.setProperty('--tui-relleno', s.padding.map(px).join(' '));

    const m = d.margins || {};
    if (m.side !== undefined) raiz.setProperty('--tui-lado', px(m.side));
    if (m.top !== undefined) raiz.setProperty('--tui-arriba', `${m.top}%`);
    if (m.bottom !== undefined) raiz.setProperty('--tui-abajo', `${m.bottom}%`);

    const ic = d.icon || {};
    if (ic.size) raiz.setProperty('--tui-icono', px(ic.size));
    colorIcono = ic.color || '';

    const a = d.animation || {};
    if (a.duration !== undefined) raiz.setProperty('--tui-duracion', `${Number(a.duration)}ms`);

    teclasActivas = !d.keyCaps || d.keyCaps.enabled !== false;
    caja.classList.toggle('solido', s.background === 'solid');
    caja.classList.toggle('barra', s.accentBar !== false);
    caja.classList.toggle('linea', s.lightLine !== false);
    caja.classList.toggle('brillo', s.glow !== false);
    caja.classList.toggle('mayusculas', s.uppercase === true);
    ['tecla-silver', 'tecla-blue', 'tecla-outline'].forEach((c) => caja.classList.remove(c));
    caja.classList.add(`tecla-${(d.keyCaps && d.keyCaps.style) || 'silver'}`);
    ['anim-slide', 'anim-fade', 'anim-scale', 'anim-none'].forEach((c) => caja.classList.remove(c));
    caja.classList.add(`anim-${a.type || 'slide'}`);
}

function sonar(sonido) {
    if (!sonido || !sonido.file) return;
    const ahora = Date.now();
    if (ahora - ultimoSonido < (sonido.cooldown || 0)) return;
    ultimoSonido = ahora;
    try {
        const audio = new Audio(`../sounds/${sonido.file}`);
        audio.volume = Math.min(Math.max(Number(sonido.volume) || 0, 0), 1);
        audio.play().catch(() => {});
    } catch (e) { /* sound is optional */ }
}

function ponerPosicion(pos) {
    if (!POSICIONES.includes(pos)) return;
    POSICIONES.forEach((p) => caja.classList.remove(p));
    caja.classList.add(pos);
}

function mostrar(d) {
    ponerPosicion(d.position);
    texto.innerHTML = formatear(d.text);

    if (d.icon) {
        iconoI.className = `${d.icon} ${ANIMACIONES[d.iconAnimation] || ''}`.trim();
        iconoI.style.color = d.iconColor || colorIcono || '';
        icono.classList.remove('oculto');
    } else {
        icono.classList.add('oculto');
    }

    sonar(d.sound);
    // Next frame so the enter transition runs when it was hidden
    requestAnimationFrame(() => caja.classList.add('visible'));
}

window.addEventListener('message', (evento) => {
    const d = evento.data || {};
    switch (d.action) {
        case 'setup': configurar(d); break;
        case 'show': mostrar(d); break;
        case 'hide': caja.classList.remove('visible'); sonar(d.sound); break;
        case 'position': ponerPosicion(d.position); break;
    }
});
