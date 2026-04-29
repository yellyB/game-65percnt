// ═══════════════════════════════════════
//  DOM REFERENCES
// ═══════════════════════════════════════
const $ = id => document.getElementById(id);
const bg = $('bg');
const speakerEl = $('speaker');
const textArea = $('text-area');
const continueInd = $('continue-indicator');
const choicesEl = $('choices');
const fade = $('fade');
const flash = $('flash');
const titleScreen = $('title-screen');
const sceneDesc = $('scene-desc');
const sceneDescText = $('scene-desc-text');
const puzzleContainer = $('puzzle-container');
const dialogueBox = $('dialogue-box');
const sceneCg = $('scene-cg');
const portraitEl = $('portrait');
const game = $('game');

// ═══════════════════════════════════════
//  ENGINE STATE
// ═══════════════════════════════════════
let currentLine = 0;
let typing = false;
let typingTimer = null;
let fullText = '';
let canAdvance = false;
let waitingForChoice = false;
let waitingForPuzzle = false;
let gameStarted = false;
let currentPortraits = { heroine: '👩', hero: '🧑', system: '🖥️' };
let relationshipGauge = 50;
let gameMemory = {};

const NARRATOR = 'narrator';
const HEROINE = 'heroine';
const HERO = 'hero';
const SYSTEM = 'system';

function speakerName(type) {
  switch(type) {
    case HEROINE: return '나';
    case HERO: return '남자친구';
    case SYSTEM: return 'SYSTEM';
    default: return '';
  }
}

// ═══════════════════════════════════════
//  UTILITY FUNCTIONS
// ═══════════════════════════════════════
function typeText(text, callback) {
  textArea.textContent = '';
  fullText = text;
  typing = true;
  canAdvance = false;
  continueInd.style.visibility = 'hidden';
  let i = 0;
  const speed = 35;
  function typeChar() {
    if (i < text.length) {
      textArea.textContent += text[i];
      i++;
      typingTimer = setTimeout(typeChar, speed);
    } else {
      typing = false;
      canAdvance = true;
      continueInd.style.visibility = 'visible';
      if (callback) callback();
    }
  }
  typeChar();
}

function skipTyping() {
  if (typing) {
    clearTimeout(typingTimer);
    textArea.textContent = fullText;
    typing = false;
    canAdvance = true;
    continueInd.style.visibility = 'visible';
  }
}

function setBg(gradient) { bg.style.background = gradient; }

function setSceneDesc(text) {
  if (text) {
    sceneDescText.textContent = text;
    sceneDesc.classList.add('visible');
  } else {
    sceneDesc.classList.remove('visible');
  }
}

function doFade(callback) {
  fade.classList.remove('hidden');
  setTimeout(() => {
    if (callback) callback();
    setTimeout(() => fade.classList.add('hidden'), 200);
  }, 800);
}

function doShake() {
  game.classList.add('shake');
  setTimeout(() => game.classList.remove('shake'), 600);
}

function doFlash() {
  flash.classList.add('active');
  setTimeout(() => flash.classList.remove('active'), 500);
}

function showCg(emoji) {
  sceneCg.textContent = emoji;
  sceneCg.classList.add('active');
  requestAnimationFrame(() => sceneCg.classList.add('visible'));
}

function hideCg() {
  sceneCg.classList.remove('visible');
  setTimeout(() => { sceneCg.classList.remove('active'); sceneCg.textContent = ''; }, 600);
}

function showPortrait(type) {
  if (type === NARRATOR || !type) {
    portraitEl.classList.remove('active');
    portraitEl.textContent = '';
    return;
  }
  const emoji = currentPortraits[type] || '';
  if (emoji) {
    portraitEl.textContent = emoji;
    portraitEl.classList.add('active');
  } else {
    portraitEl.classList.remove('active');
  }
}

function createConfetti() {
  const colors = ['#ff6b6b','#feca57','#48dbfb','#ff9ff3','#54a0ff','#5f27cd','#01a3a4','#f368e0'];
  for (let i = 0; i < 50; i++) {
    const c = document.createElement('div');
    c.className = 'confetti';
    c.style.left = Math.random() * 100 + '%';
    c.style.top = '-20px';
    c.style.background = colors[Math.floor(Math.random() * colors.length)];
    c.style.width = (Math.random() * 8 + 5) + 'px';
    c.style.height = (Math.random() * 8 + 5) + 'px';
    c.style.borderRadius = Math.random() > 0.5 ? '50%' : '0';
    c.style.animation = `confetti-fall ${Math.random()*2+2}s linear ${Math.random()*0.5}s forwards`;
    document.body.appendChild(c);
    setTimeout(() => c.remove(), 4500);
  }
}

function updateGauge(delta) {
  relationshipGauge = Math.max(0, Math.min(100, relationshipGauge + delta));
  const fill = document.getElementById('gauge-fill');
  const label = document.getElementById('gauge-label');
  if (fill) fill.style.width = relationshipGauge + '%';
  if (label) {
    label.textContent = getGaugeLabel();
    if (relationshipGauge < 30) label.style.color = 'rgba(255,100,100,0.6)';
    else if (relationshipGauge >= 80) label.style.color = 'rgba(100,255,200,0.6)';
    else label.style.color = 'rgba(255,255,255,0.4)';
  }
  // Popup feedback
  if (delta !== 0) {
    const popup = document.createElement('div');
    popup.className = 'gauge-popup ' + (delta > 0 ? 'positive' : 'negative');
    popup.textContent = (delta > 0 ? '+' : '') + delta;
    document.body.appendChild(popup);
    setTimeout(() => popup.remove(), 1200);
  }
}

function getGaugeLabel() {
  if (relationshipGauge < 30) return '불안정';
  if (relationshipGauge <= 60) return '보통';
  if (relationshipGauge <= 80) return '안정적';
  return '깊은 유대';
}

function getScoreLabel(score) {
  if (score >= 80) return '매우 높은 점수!';
  if (score >= 60) return '평균보다 높음';
  if (score >= 40) return '평균';
  return '평균 이하';
}

function calculateCategoryScores() {
  const g = relationshipGauge;
  let physical = Math.round(g * 0.7 + 20);
  if (gameMemory.gender_thought === 'wonder') physical += 8;
  else if (gameMemory.gender_thought === 'scared') physical -= 5;
  if (gameMemory.night_reaction === 'comfort') physical += 5;
  else if (gameMemory.night_reaction === 'silence') physical -= 3;

  let bond = Math.round(g * 0.8 + 15);
  if (gameMemory.puppy_thought === 'love_same') bond += 10;
  else if (gameMemory.puppy_thought === 'unfair') bond -= 8;
  if (gameMemory.puppy_debate === 'love_same') bond += 5;
  else if (gameMemory.puppy_debate === 'agree') bond -= 3;

  let extreme = Math.round(g * 0.5 + 10);
  if (gameMemory.prison_thought === 'love') extreme += 10;
  else if (gameMemory.prison_thought === 'duty') extreme -= 5;
  if (gameMemory.prison_argument === 'apologize') extreme += 5;
  else if (gameMemory.prison_argument === 'explode') extreme -= 8;
  if (gameMemory.before_confront === 'hope') extreme += 5;
  else if (gameMemory.before_confront === 'resign') extreme -= 5;

  return [
    Math.max(0, Math.min(100, physical)),
    Math.max(0, Math.min(100, bond)),
    Math.max(0, Math.min(100, extreme)),
  ];
}

function showChoices(options, choiceKey) {
  waitingForChoice = true;
  choicesEl.innerHTML = '';
  options.forEach(opt => {
    const btn = document.createElement('button');
    btn.className = 'choice-btn';
    btn.textContent = opt.text;
    btn.addEventListener('click', e => {
      e.stopPropagation();
      waitingForChoice = false;
      choicesEl.classList.remove('active');
      if (choiceKey && opt.value !== undefined) {
        gameMemory[choiceKey] = opt.value;
      }
      if (opt.gauge) updateGauge(opt.gauge);
      currentLine++;
      processLine();
    });
    choicesEl.appendChild(btn);
  });
  choicesEl.classList.add('active');
  continueInd.style.visibility = 'hidden';
}

function showThought(line) {
  waitingForChoice = true;
  choicesEl.innerHTML = '';
  const prompt = document.createElement('div');
  prompt.className = 'thought-prompt';
  prompt.textContent = line.prompt;
  choicesEl.appendChild(prompt);
  line.options.forEach(opt => {
    const btn = document.createElement('button');
    btn.className = 'thought-btn';
    btn.textContent = opt.text;
    btn.addEventListener('click', e => {
      e.stopPropagation();
      waitingForChoice = false;
      choicesEl.classList.remove('active');
      if (line.key && opt.value !== undefined) {
        gameMemory[line.key] = opt.value;
      }
      if (opt.gauge) updateGauge(opt.gauge);
      currentLine++;
      processLine();
    });
    choicesEl.appendChild(btn);
  });
  choicesEl.classList.add('active');
  continueInd.style.visibility = 'hidden';
}

function showMicroChoice(line) {
  waitingForChoice = true;
  const wrap = document.createElement('div');
  wrap.className = 'micro-choice-wrap';
  line.options.forEach(opt => {
    const btn = document.createElement('button');
    btn.className = 'micro-choice-btn';
    btn.textContent = opt.text;
    btn.addEventListener('click', e => {
      e.stopPropagation();
      waitingForChoice = false;
      wrap.remove();
      if (opt.gauge) updateGauge(opt.gauge);
      currentLine++;
      processLine();
    });
    wrap.appendChild(btn);
  });
  document.getElementById('game').appendChild(wrap);
  continueInd.style.visibility = 'hidden';
}

function showTimedChoice(line) {
  waitingForChoice = true;
  const wrap = document.createElement('div');
  wrap.className = 'timed-choice-wrap';

  const ring = document.createElement('div');
  ring.className = 'timed-choice-timer-ring';
  ring.style.setProperty('--angle', '360deg');
  const inner = document.createElement('div');
  inner.className = 'timed-choice-timer-inner';
  inner.textContent = Math.ceil(line.time / 1000);
  ring.appendChild(inner);
  wrap.appendChild(ring);

  if (line.prompt) {
    const p = document.createElement('div');
    p.className = 'timed-choice-prompt';
    p.textContent = line.prompt;
    wrap.appendChild(p);
  }

  let done = false;
  let animFrame;

  function selectOption(opt) {
    if (done) return;
    done = true;
    cancelAnimationFrame(animFrame);
    if (line.key && opt.value !== undefined) {
      gameMemory[line.key] = opt.value;
    }
    if (opt.gauge) updateGauge(opt.gauge);
    wrap.remove();
    waitingForChoice = false;
    currentLine++;
    processLine();
  }

  line.options.forEach(opt => {
    const btn = document.createElement('button');
    btn.className = 'choice-btn';
    btn.textContent = opt.text;
    btn.addEventListener('click', e => {
      e.stopPropagation();
      selectOption(opt);
    });
    wrap.appendChild(btn);
  });

  game.appendChild(wrap);

  const startTime = Date.now();
  function tick() {
    if (done) return;
    const elapsed = Date.now() - startTime;
    const remaining = Math.max(0, 1 - elapsed / line.time);
    ring.style.setProperty('--angle', `${remaining * 360}deg`);
    const secs = Math.ceil(remaining * line.time / 1000);
    inner.textContent = secs > 0 ? secs : '';
    if (remaining <= 0) {
      const idx = line.timeoutIndex !== undefined ? line.timeoutIndex : line.options.length - 1;
      selectOption(line.options[idx]);
      return;
    }
    animFrame = requestAnimationFrame(tick);
  }
  animFrame = requestAnimationFrame(tick);
}

// ═══════════════════════════════════════
//  MODE SWITCHING
// ═══════════════════════════════════════
function enterInteractiveMode(callback) {
  waitingForPuzzle = true;
  canAdvance = false;
  continueInd.style.visibility = 'hidden';
  dialogueBox.classList.add('slide-down');
  sceneDesc.classList.remove('visible');
  setTimeout(() => {
    puzzleContainer.classList.add('active');
    callback();
  }, 600);
}

function exitInteractiveMode() {
  puzzleContainer.classList.remove('active');
  setTimeout(() => {
    puzzleContainer.innerHTML = '';
    dialogueBox.classList.remove('slide-down');
    waitingForPuzzle = false;
    currentLine++;
    setTimeout(() => processLine(), 400);
  }, 500);
}

// ═══════════════════════════════════════
//  MAIN GAME LOOP
// ═══════════════════════════════════════
function processLine() {
  if (currentLine >= scenes.length) return;
  const line = scenes[currentLine];

  // End
  if (line.end) { showEnding(); return; }

  // Portrait change
  if (line.portraits) {
    currentPortraits = { ...currentPortraits, ...line.portraits };
    currentLine++;
    processLine();
    return;
  }

  // CG display
  if (line.cg !== undefined && !line.type && !line.bg) {
    if (line.cg) showCg(line.cg); else hideCg();
    currentLine++;
    processLine();
    return;
  }

  // Puzzle
  if (line.puzzle) {
    enterInteractiveMode(() => {
      puzzles[line.puzzle](puzzleContainer, () => exitInteractiveMode());
    });
    return;
  }

  // Exploration
  if (line.explore) {
    enterInteractiveMode(() => {
      explorations[line.explore](puzzleContainer, () => exitInteractiveMode());
    });
    return;
  }

  // Background change
  if (line.bg) {
    const hasFade = line.fade;
    const hasShake = line.shake;
    const desc = line.desc;

    if (hasFade) {
      canAdvance = false;
      doFade(() => {
        setBg(line.bg);
        if (desc !== undefined) setSceneDesc(desc);
      });
      if (!line.type && !line.choice) {
        currentLine++;
        setTimeout(() => processLine(), 1200);
        return;
      } else {
        setTimeout(() => showDialogue(line), 1200);
        return;
      }
    }

    if (hasShake) {
      setBg(line.bg);
      if (desc !== undefined) setSceneDesc(desc);
      doShake();
      if (!line.type && !line.choice) {
        currentLine++;
        setTimeout(() => processLine(), 400);
        return;
      }
    }

    if (!hasFade && !hasShake) {
      setBg(line.bg);
      if (desc !== undefined) setSceneDesc(desc);
      if (!line.type && !line.choice) {
        currentLine++;
        processLine();
        return;
      }
    }
  }

  // Micro Choice
  if (line.microChoice) { showMicroChoice(line); return; }

  // Thought
  if (line.thought) { showThought(line); return; }

  // Timed Choice
  if (line.timedChoice) { showTimedChoice(line); return; }

  // Conditional
  if (line.conditional) {
    const memVal = gameMemory[line.key];
    const variant = line.variants[memVal] || line.variants['default'] || Object.values(line.variants)[0];
    showDialogue({ type: line.speaker || NARRATOR, text: variant });
    return;
  }

  // Choice
  if (line.choice) { showChoices(line.options, line.choiceKey); return; }

  // Dialogue
  if (line.type) { showDialogue(line); return; }

  // Fallback
  currentLine++;
  processLine();
}

function showDialogue(line) {
  speakerEl.textContent = speakerName(line.type);
  speakerEl.className = line.type || '';
  showPortrait(line.type);
  if (line.shake) doShake();
  typeText(line.text);
}

function advance() {
  if (waitingForChoice || waitingForPuzzle) return;
  if (typing) { skipTyping(); return; }
  if (!canAdvance) return;
  canAdvance = false;
  currentLine++;
  processLine();
}

function showEnding() {
  textArea.textContent = '';
  speakerEl.textContent = '';
  speakerEl.className = '';
  continueInd.style.visibility = 'hidden';
  bg.style.background = 'linear-gradient(135deg, #1a1a2e 0%, #16213e 100%)';
  sceneDesc.classList.remove('visible');
  setTimeout(() => {
    textArea.innerHTML = '<div style="text-align:center; margin-top:2rem; color:rgba(255,255,255,0.4);">화면을 클릭하면 처음부터 다시 시작합니다.</div>';
    canAdvance = false;
    const restartHandler = () => {
      document.removeEventListener('click', restartHandler);
      currentLine = 0;
      startGame();
    };
    setTimeout(() => document.addEventListener('click', restartHandler), 1000);
  }, 2000);
}

// ═══════════════════════════════════════
//  EVENT LISTENERS
// ═══════════════════════════════════════
document.addEventListener('click', e => {
  if (!gameStarted) return;
  if (waitingForChoice || waitingForPuzzle) return;
  advance();
});

document.addEventListener('keydown', e => {
  if (!gameStarted) return;
  if (e.code === 'Space' || e.code === 'Enter') {
    e.preventDefault();
    if (waitingForChoice || waitingForPuzzle) return;
    advance();
  }
});

// ═══════════════════════════════════════
//  START
// ═══════════════════════════════════════
function startGame() {
  gameStarted = false;
  puzzleContainer.classList.remove('active');
  puzzleContainer.innerHTML = '';
  dialogueBox.classList.remove('slide-down');
  sceneDesc.classList.remove('visible');
  titleScreen.style.display = 'flex';
  fade.classList.add('hidden');
  currentLine = 0;
  typing = false;
  canAdvance = false;
  waitingForChoice = false;
  waitingForPuzzle = false;
  textArea.textContent = '';
  speakerEl.textContent = '';
  speakerEl.className = '';
  bg.style.background = '#1a1a2e';
  continueInd.style.visibility = 'hidden';
  hideCg();
  portraitEl.classList.remove('active');
  portraitEl.textContent = '';
  currentPortraits = { heroine: '👩', hero: '🧑', system: '🖥️' };
  relationshipGauge = 50;
  gameMemory = {};
  const gaugeFill = document.getElementById('gauge-fill');
  const gaugeLabel = document.getElementById('gauge-label');
  if (gaugeFill) gaugeFill.style.width = '50%';
  if (gaugeLabel) { gaugeLabel.textContent = '보통'; gaugeLabel.style.color = 'rgba(255,255,255,0.4)'; }

  const startHandler = () => {
    titleScreen.removeEventListener('click', startHandler);
    titleScreen.style.display = 'none';
    gameStarted = true;
    fade.classList.remove('hidden');
    setTimeout(() => {
      processLine();
      setTimeout(() => fade.classList.add('hidden'), 200);
    }, 500);
  };
  titleScreen.addEventListener('click', startHandler);
}
