// ═══════════════════════════════════════
//  PUZZLE MODULES
// ═══════════════════════════════════════
const puzzles = {

  // ─── ① Mirror Dressing ───
  mirror_dressing(container, onComplete) {
    const wrap = document.createElement('div');
    wrap.className = 'mirror-puzzle';

    // Characters
    const chars = document.createElement('div');
    chars.className = 'mirror-chars';
    chars.innerHTML = `
      <div class="mirror-char"><div class="mirror-char-emoji">🧑</div><div class="mirror-char-label">나 (남성화)</div></div>
      <div class="mirror-char"><div class="mirror-char-emoji">👩</div><div class="mirror-char-label">남친 (여성화)</div></div>
    `;
    wrap.appendChild(chars);

    // Boyfriend reaction bubble
    const bubble = document.createElement('div');
    bubble.className = 'mirror-bubble';
    bubble.textContent = '스타일을 골라봐...';
    wrap.appendChild(bubble);

    const reactions = {
      f: ['😊 "그래, 어울려!"', '😊 "이게 좋다"', '😊 "예쁘다!"'],
      n: ['🤔 "음... 괜찮은 것 같기도?"', '🤔 "글쎄..."', '🤔 "나쁘진 않아"'],
      m: ['😟 "...음... 좀 그런데"', '😟 "이건 좀..."', '😟 "차라리 다른 걸로..."'],
    };

    const categories = [
      { label: '머리 스타일', options: [
        { text: '💇‍♀️ 긴 머리', type: 'f' },
        { text: '💇 단발', type: 'n' },
        { text: '💇‍♂️ 짧은 머리', type: 'm' },
      ]},
      { label: '옷', options: [
        { text: '👗 원피스', type: 'f' },
        { text: '👔 셔츠', type: 'n' },
        { text: '🧥 재킷', type: 'm' },
      ]},
      { label: '액세서리', options: [
        { text: '💄 립스틱', type: 'f' },
        { text: '⌚ 시계', type: 'n' },
        { text: '🧢 모자', type: 'm' },
      ]},
    ];

    let selCount = 0;
    let selections = {};

    categories.forEach((cat, ci) => {
      const catEl = document.createElement('div');
      catEl.className = 'mirror-category';
      catEl.innerHTML = `<div class="mirror-cat-label">${cat.label}</div>`;
      const optsEl = document.createElement('div');
      optsEl.className = 'mirror-options';
      cat.options.forEach((opt, oi) => {
        const btn = document.createElement('button');
        btn.className = 'mirror-opt';
        btn.textContent = opt.text;
        btn.addEventListener('click', () => {
          optsEl.querySelectorAll('.mirror-opt').forEach(b => b.classList.remove('selected'));
          btn.classList.add('selected');
          if (!selections[ci]) selCount++;
          selections[ci] = opt.type;
          const rArr = reactions[opt.type];
          bubble.textContent = rArr[ci];
          if (selCount >= 3) confirmBtn.classList.add('visible');
        });
        optsEl.appendChild(btn);
      });
      catEl.appendChild(optsEl);
      wrap.appendChild(catEl);
    });

    const confirmBtn = document.createElement('button');
    confirmBtn.className = 'mirror-confirm';
    confirmBtn.textContent = '🪞 거울 확인';
    confirmBtn.addEventListener('click', () => onComplete());
    wrap.appendChild(confirmBtn);

    container.appendChild(wrap);
  },

  // ─── ② Puppy Communication ───
  puppy_comm(container, onComplete) {
    const wrap = document.createElement('div');
    wrap.className = 'puppy-puzzle';

    const rounds = [
      { scene: '🍽️🧑', text: '남자친구가 밥을 먹고 있다.', options: [
        { emoji: '🐾', correct: true },
        { emoji: '🐕', correct: true },
        { emoji: '😢', correct: false },
        { emoji: '🔄', correct: false },
      ]},
      { scene: '😢🛋️', text: '남자친구가 소파에서 울고 있다.', options: [
        { emoji: '🐾', correct: true },
        { emoji: '🎾', correct: true },
        { emoji: '🐕', correct: true },
        { emoji: '🔄', correct: false },
      ]},
      { scene: '🚶🚪', text: '남자친구가 외출한다.', options: [
        { emoji: '🐕', correct: true },
        { emoji: '🐾', correct: true },
        { emoji: '😢', correct: false },
        { emoji: '🔄', correct: false },
      ]},
      { scene: '🌙👻', text: '밤에 이상한 소리가 들린다.', options: [
        { emoji: '🐾', correct: true },
        { emoji: '🐕', correct: true },
        { emoji: '😢', correct: false },
        { emoji: '🔄', correct: false },
      ]},
      { scene: '👁️✨', text: '남자친구가 나를 바라본다.', options: [
        { emoji: '❤️', correct: true },
        { emoji: '🐾', correct: true },
        { emoji: '🐕', correct: true },
      ]},
    ];

    let currentRound = 0;
    let correctCount = 0;
    let gauge = 20;

    // Gauge
    const gaugeWrap = document.createElement('div');
    gaugeWrap.className = 'puppy-gauge-wrap';
    gaugeWrap.innerHTML = `
      <div class="puppy-gauge-label"><span>유대감</span><span class="puppy-gauge-val">${gauge}%</span></div>
      <div class="puppy-gauge-bar"><div class="puppy-gauge-fill" style="width:${gauge}%"></div></div>
    `;
    wrap.appendChild(gaugeWrap);

    const roundNum = document.createElement('div');
    roundNum.className = 'puppy-round-num';
    wrap.appendChild(roundNum);

    const sceneArea = document.createElement('div');
    sceneArea.className = 'puppy-scene-area';
    wrap.appendChild(sceneArea);

    const optionsArea = document.createElement('div');
    optionsArea.className = 'puppy-options';
    wrap.appendChild(optionsArea);

    function updateGaugeDisplay() {
      gaugeWrap.querySelector('.puppy-gauge-fill').style.width = gauge + '%';
      gaugeWrap.querySelector('.puppy-gauge-val').textContent = gauge + '%';
    }

    function renderRound() {
      if (currentRound >= rounds.length) {
        // Finish
        sceneArea.innerHTML = `<div class="puppy-scene-emoji">🐶❤️🧑</div>
          <div class="puppy-scene-text">${correctCount >= 3
            ? '말이 통하지 않아도, 눈빛으로, 행동으로, 온기로.\n서로의 마음을 전할 수 있었다.\n\n이제까지 느껴보지 못한 유대감이 남아있었다.'
            : '완벽하지는 않았지만...\n어떻게든 마음은 전해졌다.'}</div>`;
        optionsArea.innerHTML = '';
        roundNum.textContent = '';
        setTimeout(() => onComplete(), 2000);
        return;
      }

      const r = rounds[currentRound];
      roundNum.textContent = `${currentRound + 1} / ${rounds.length}`;
      sceneArea.innerHTML = `<div class="puppy-scene-emoji">${r.scene}</div><div class="puppy-scene-text">${r.text}</div>`;
      optionsArea.innerHTML = '';

      r.options.forEach(opt => {
        const btn = document.createElement('button');
        btn.className = 'puppy-opt';
        btn.textContent = opt.emoji;
        btn.addEventListener('click', () => {
          if (opt.correct) {
            correctCount++;
            gauge = Math.min(100, gauge + 16);
          } else {
            gauge = Math.min(100, gauge + 4);
          }
          updateGaugeDisplay();
          currentRound++;
          setTimeout(() => renderRound(), 600);
        });
        optionsArea.appendChild(btn);
      });
    }

    container.appendChild(wrap);
    renderRound();
  },

  // ─── ③ Evidence Board ───
  evidence_board(container, onComplete) {
    const wrap = document.createElement('div');
    wrap.className = 'evidence-puzzle';

    const cards = [
      { emoji: '📋', name: '부스 이용 동의서' },
      { emoji: '🎮', name: 'VR 데이터 로그' },
      { emoji: '📱', name: '커플 대화 기록' },
      { emoji: '👥', name: '목격자 진술' },
      { emoji: '⚖️', name: '기계 설명서' },
      { emoji: '🚨', name: '함정 수사 기록' },
    ];

    const rejections = [
      '증거 불충분. 기각.',
      'VR 내 행위도 범죄 의도로 간주됩니다. 기각.',
      '최종 기각. 항소 불가.',
    ];

    let slots = [null, null, null];
    let selectedCard = null;
    let tries = 0;
    const maxTries = 3;

    const title = document.createElement('div');
    title.className = 'evidence-title';
    title.textContent = '변호를 위한 증거를 제출하세요';
    wrap.appendChild(title);

    const triesEl = document.createElement('div');
    triesEl.className = 'evidence-tries';
    triesEl.textContent = `시도: ${tries} / ${maxTries}`;
    wrap.appendChild(triesEl);

    // Board
    const board = document.createElement('div');
    board.className = 'evidence-board';
    const slotsEl = document.createElement('div');
    slotsEl.className = 'evidence-slots';
    for (let i = 0; i < 3; i++) {
      const slot = document.createElement('div');
      slot.className = 'evidence-slot';
      slot.textContent = `슬롯 ${i + 1}`;
      slot.dataset.index = i;
      slot.addEventListener('click', () => {
        if (slots[i] !== null) {
          // Remove card from slot
          const cardIdx = slots[i];
          slots[i] = null;
          slot.className = 'evidence-slot';
          slot.textContent = `슬롯 ${i + 1}`;
          cardsEl.children[cardIdx].classList.remove('used');
          updateSubmit();
        } else if (selectedCard !== null) {
          // Place selected card
          slots[i] = selectedCard;
          slot.className = 'evidence-slot filled';
          slot.textContent = `${cards[selectedCard].emoji} ${cards[selectedCard].name}`;
          cardsEl.children[selectedCard].classList.add('used');
          cardsEl.children[selectedCard].classList.remove('selected');
          selectedCard = null;
          updateSubmit();
        }
      });
      slotsEl.appendChild(slot);
    }
    board.appendChild(slotsEl);
    wrap.appendChild(board);

    // Cards
    const cardsEl = document.createElement('div');
    cardsEl.className = 'evidence-cards';
    cards.forEach((card, i) => {
      const el = document.createElement('div');
      el.className = 'evidence-card';
      el.textContent = `${card.emoji} ${card.name}`;
      el.addEventListener('click', () => {
        if (el.classList.contains('used')) return;
        cardsEl.querySelectorAll('.evidence-card').forEach(c => c.classList.remove('selected'));
        el.classList.add('selected');
        selectedCard = i;
      });
      cardsEl.appendChild(el);
    });
    wrap.appendChild(cardsEl);

    // Result area
    const resultEl = document.createElement('div');
    resultEl.className = 'evidence-result';
    wrap.appendChild(resultEl);

    // Buttons
    const actions = document.createElement('div');
    actions.className = 'evidence-actions';
    const submitBtn = document.createElement('button');
    submitBtn.className = 'evidence-btn evidence-submit';
    submitBtn.textContent = '제출';
    submitBtn.disabled = true;
    const giveupBtn = document.createElement('button');
    giveupBtn.className = 'evidence-btn evidence-giveup';
    giveupBtn.textContent = '포기';

    function updateSubmit() {
      submitBtn.disabled = slots.filter(s => s !== null).length < 3;
    }

    submitBtn.addEventListener('click', () => {
      tries++;
      triesEl.textContent = `시도: ${tries} / ${maxTries}`;
      resultEl.innerHTML = `<div>${rejections[tries - 1]}</div><div class="evidence-stamp">REJECTED</div>`;
      doShake();

      // Reset slots
      slots = [null, null, null];
      selectedCard = null;
      slotsEl.querySelectorAll('.evidence-slot').forEach((s, i) => {
        s.className = 'evidence-slot';
        s.textContent = `슬롯 ${i + 1}`;
      });
      cardsEl.querySelectorAll('.evidence-card').forEach(c => {
        c.classList.remove('used', 'selected');
      });
      updateSubmit();

      if (tries >= maxTries) {
        submitBtn.disabled = true;
        cardsEl.style.opacity = '0.3';
        cardsEl.style.pointerEvents = 'none';
        setTimeout(() => onComplete(), 2000);
      }
    });

    giveupBtn.addEventListener('click', () => {
      resultEl.innerHTML = '<div>...변호를 포기했다.</div>';
      setTimeout(() => onComplete(), 1200);
    });

    actions.appendChild(submitBtn);
    actions.appendChild(giveupBtn);
    wrap.appendChild(actions);

    container.appendChild(wrap);
  },

  // ─── ④ Confrontation ───
  confrontation(container, onComplete) {
    const wrap = document.createElement('div');
    wrap.className = 'confront-puzzle';

    const rounds = [
      { text: '"난 널 아직 사랑해"', emoji: '😊', time: 5000,
        options: [{e:'❤️',l:'나도',g:3},{e:'😶',l:'침묵',g:0},{e:'🚪',l:'그만하자',g:-3}], shk: false },
      { text: '"다시 시작하자"', emoji: '🥺', time: 4000,
        options: [{e:'❤️',l:'생각해볼게',g:2},{e:'😶',l:'모르겠어',g:0},{e:'🚪',l:'안 돼',g:-2}], shk: false },
      { text: '"왜 고민해?!"', emoji: '😡', time: 3500,
        options: [{e:'🤝',l:'진정해',g:2},{e:'😶',l:'...',g:-1},{e:'🚪',l:'무서워',g:-3}], shk: true },
      { text: '"다시 시작하면 되잖아!!"', emoji: '😤', time: 3000,
        options: [{e:'🤝',l:'잠깐만',g:1},{e:'🚪',l:'도망',g:-2}], shk: true },
      { text: '(팔을 잡는다)', emoji: '😡', time: 2000,
        options: [{e:'✋',l:'밀친다',g:-2}], shk: true },
    ];

    const bgColors = [
      'linear-gradient(135deg, #2d3436 0%, #4a1a1a 100%)',
      'linear-gradient(135deg, #3a1515 0%, #5a1a1a 100%)',
      'linear-gradient(135deg, #4a0a0a 0%, #6a0a0a 100%)',
      'linear-gradient(135deg, #5a0000 0%, #7a0000 100%)',
      'linear-gradient(135deg, #6a0000 0%, #000000 100%)',
    ];

    let currentRound = 0;
    let animFrame = null;

    function renderRound() {
      const r = rounds[currentRound];
      wrap.innerHTML = '';
      bg.style.background = bgColors[currentRound];

      if (r.shk) doShake();

      // Round info
      const info = document.createElement('div');
      info.className = 'confront-round-info';
      info.textContent = `${currentRound + 1} / ${rounds.length}`;
      wrap.appendChild(info);

      // Timer ring + face
      const timerWrap = document.createElement('div');
      timerWrap.className = 'confront-timer-wrap';
      const ring = document.createElement('div');
      ring.className = 'confront-timer-ring';
      ring.style.setProperty('--angle', '360deg');
      const face = document.createElement('div');
      face.className = 'confront-face';
      face.textContent = r.emoji;
      ring.appendChild(face);
      timerWrap.appendChild(ring);
      wrap.appendChild(timerWrap);

      // Dialogue
      const dlg = document.createElement('div');
      dlg.className = 'confront-dialogue';
      dlg.textContent = r.text;
      wrap.appendChild(dlg);

      // Options
      const optsWrap = document.createElement('div');
      optsWrap.className = 'confront-options';
      r.options.forEach((opt, idx) => {
        const btn = document.createElement('button');
        btn.className = 'confront-btn';
        btn.innerHTML = `<span>${opt.e}</span><span class="confront-btn-label">${opt.l}</span>`;
        btn.addEventListener('click', () => selectOption(opt));
        optsWrap.appendChild(btn);
      });
      wrap.appendChild(optsWrap);

      // Timer
      const startTime = Date.now();
      let done = false;
      function tick() {
        if (done) return;
        const elapsed = Date.now() - startTime;
        const remaining = Math.max(0, 1 - elapsed / r.time);
        ring.style.setProperty('--angle', `${remaining * 360}deg`);
        if (remaining <= 0) {
          done = true;
          selectOption(r.options[r.options.length - 1]);
          return;
        }
        animFrame = requestAnimationFrame(tick);
      }
      animFrame = requestAnimationFrame(tick);

      function selectOption(opt) {
        if (done && animFrame) return;
        done = true;
        cancelAnimationFrame(animFrame);
        if (opt && opt.g) updateGauge(opt.g);
        currentRound++;
        if (currentRound >= rounds.length) {
          wrap.innerHTML = '';
          setTimeout(() => onComplete(), 300);
        } else {
          setTimeout(() => renderRound(), 600);
        }
      }
    }

    container.appendChild(wrap);
    renderRound();
  },

  // ─── ⑤ Result Dashboard ───
  result_detail(container, onComplete) {
    const wrap = document.createElement('div');
    wrap.className = 'result-puzzle';

    bg.style.background = 'linear-gradient(135deg, #ffecd2 0%, #fcb69f 50%, #ff9a9e 100%)';

    // Score counter
    const scoreBig = document.createElement('div');
    scoreBig.className = 'result-score-big';
    scoreBig.textContent = '0';
    wrap.appendChild(scoreBig);

    const scorePercent = document.createElement('div');
    scorePercent.className = 'result-score-percent';
    scorePercent.textContent = '%';
    wrap.appendChild(scorePercent);

    const avgText = document.createElement('div');
    avgText.className = 'result-avg-text';
    avgText.textContent = '';
    wrap.appendChild(avgText);

    // Detail button
    const detailBtn = document.createElement('button');
    detailBtn.className = 'result-detail-btn';
    detailBtn.textContent = '상세 결과 보기';
    detailBtn.style.display = 'none';
    wrap.appendChild(detailBtn);

    // Categories
    const catsWrap = document.createElement('div');
    catsWrap.className = 'result-categories';
    catsWrap.style.display = 'none';

    const catScores = calculateCategoryScores();
    const cats = [
      { emoji: '💜', name: '신체적 적응력', score: catScores[0], color: '#a855f7', desc: '서로 다른 모습에서도 사랑 유지' },
      { emoji: '🐕', name: '비언어적 유대감', score: catScores[1], color: '#56ab2f', desc: '말 없이 마음 전달' },
      { emoji: '⚖️', name: '극한 상황 내성', score: catScores[2], color: '#ff6b6b', desc: '극단적 상황에서 관계 유지' },
    ];

    let revealed = 0;

    cats.forEach(cat => {
      const el = document.createElement('div');
      el.className = 'result-cat';
      el.innerHTML = `
        <div class="result-cat-header">
          <span class="result-cat-name">${cat.emoji} ${cat.name}</span>
          <span class="result-cat-score">${cat.score}%</span>
        </div>
        <div class="result-cat-bar"><div class="result-cat-fill" style="background:${cat.color}"></div></div>
      `;
      el.addEventListener('click', () => {
        if (el.classList.contains('revealed')) return;
        el.classList.add('revealed');
        el.querySelector('.result-cat-fill').style.width = cat.score + '%';
        revealed++;
        if (revealed >= cats.length) {
          setTimeout(() => {
            summary.classList.add('visible');
            exitBtn.classList.add('visible');
          }, 800);
        }
      });
      catsWrap.appendChild(el);
    });
    wrap.appendChild(catsWrap);

    // Summary
    const summary = document.createElement('div');
    summary.className = 'result-summary';
    summary.textContent = `종합: ${relationshipGauge}% — ${getScoreLabel(relationshipGauge)}`;
    wrap.appendChild(summary);

    // Exit button
    const exitBtn = document.createElement('button');
    exitBtn.className = 'result-exit';
    exitBtn.textContent = '나가기';
    exitBtn.addEventListener('click', () => onComplete());
    wrap.appendChild(exitBtn);

    container.appendChild(wrap);

    // Count up animation
    let current = 0;
    const target = relationshipGauge;
    const step = target > 0 ? 2000 / target : 30;
    function countUp() {
      if (current <= target) {
        scoreBig.textContent = current;
        current++;
        setTimeout(countUp, step);
      } else {
        createConfetti();
        doFlash();
        avgText.textContent = `커플 평균 64% — ${getScoreLabel(target)}`;
        detailBtn.style.display = 'block';
      }
    }
    countUp();

    detailBtn.addEventListener('click', () => {
      detailBtn.style.display = 'none';
      catsWrap.style.display = 'flex';
    });
  }
};
