// ═══════════════════════════════════════
//  POINT & CLICK RENDERER
// ═══════════════════════════════════════
function renderPointAndClick(container, data, onComplete) {
  const scene = document.createElement('div');
  scene.className = 'pnc-scene';

  const viewport = document.createElement('div');
  viewport.className = 'pnc-viewport';

  if (data.hint) {
    const hint = document.createElement('div');
    hint.className = 'pnc-hint';
    hint.textContent = data.hint;
    viewport.appendChild(hint);
  }

  const requiredCount = data.objects.filter(o => !o.action).length;
  const visited = new Set();
  let exitEl = null;
  let completing = false;

  const dialogueBox = document.createElement('div');
  dialogueBox.className = 'pnc-dialogue-box';
  const dialogueText = document.createElement('div');
  dialogueText.className = 'pnc-dialogue-text';
  dialogueText.textContent = data.startMsg || '';
  const progressEl = document.createElement('div');
  progressEl.className = 'pnc-progress';
  dialogueBox.appendChild(dialogueText);
  dialogueBox.appendChild(progressEl);

  function updateProgress() {
    const found = Math.min(visited.size, requiredCount);
    progressEl.textContent = found + ' / ' + requiredCount;
    if (exitEl && visited.size >= requiredCount) {
      exitEl.classList.add('unlocked');
    }
  }

  data.objects.forEach((obj, i) => {
    const el = document.createElement('div');
    el.className = 'pnc-object';
    if (obj.action) {
      el.classList.add('pnc-exit');
      exitEl = el;
    }
    el.style.left = obj.x + '%';
    el.style.top = obj.y + '%';

    const emoji = document.createElement('div');
    emoji.className = 'pnc-object-emoji';
    if (obj.size) emoji.style.fontSize = obj.size + 'rem';
    emoji.textContent = obj.emoji;
    emoji.style.animationDelay = (i * 0.6) + 's';

    const label = document.createElement('div');
    label.className = 'pnc-object-label';
    label.textContent = obj.label;

    el.appendChild(emoji);
    el.appendChild(label);

    el.addEventListener('click', () => {
      if (completing) return;
      if (obj.action) {
        if (visited.size >= requiredCount) {
          completing = true;
          dialogueText.textContent = obj.msg;
          setTimeout(() => onComplete(), 1000);
        } else {
          dialogueText.textContent = '아직 둘러볼 곳이 남았다...';
        }
        return;
      }
      if (!visited.has(i)) {
        visited.add(i);
        el.classList.add('visited');
        updateProgress();
      }
      dialogueText.textContent = obj.msg;
      if (obj.gauge) updateGauge(obj.gauge);
    });

    viewport.appendChild(el);
  });

  scene.appendChild(viewport);
  scene.appendChild(dialogueBox);
  container.appendChild(scene);
  updateProgress();
}

// ═══════════════════════════════════════
//  RICH EXPLORATION RENDERER (발견형)
//  - goal: 미스터리/목표 배너
//  - need: 핵심 단서 몇 개를 찾으면 숨은 출구가 등장
//  - object.clue: 단서(진행 카운트) / object.bonus: 숨은 보상(선택)
//  - object.hidden + action: 처음엔 안 보이는 출구, 단서 충족 시 등장
//  - object.choices: 클릭 시 선택지 → 게이지 결과가 달라짐
// ═══════════════════════════════════════
function renderExploreRich(container, data, onComplete) {
  const scene = document.createElement('div');
  scene.className = 'pnc-scene';
  const viewport = document.createElement('div');
  viewport.className = 'pnc-viewport';

  if (data.goal) {
    const goal = document.createElement('div');
    goal.className = 'expl-goal';
    goal.textContent = data.goal;
    viewport.appendChild(goal);
  }

  const need = data.need || data.objects.filter(o => o.clue).length;
  let clues = 0;
  let completing = false;
  let exitRevealed = false;
  let exitEl = null;

  const dialogueBox = document.createElement('div');
  dialogueBox.className = 'pnc-dialogue-box';
  const dialogueText = document.createElement('div');
  dialogueText.className = 'pnc-dialogue-text';
  dialogueText.textContent = data.startMsg || '';
  const choicesWrap = document.createElement('div');
  choicesWrap.className = 'expl-choices';
  const progressEl = document.createElement('div');
  progressEl.className = 'pnc-progress';
  dialogueBox.appendChild(dialogueText);
  dialogueBox.appendChild(choicesWrap);
  dialogueBox.appendChild(progressEl);

  function refreshProgress() {
    progressEl.textContent = '🔍 단서 ' + Math.min(clues, need) + ' / ' + need;
    progressEl.classList.toggle('expl-ready', clues >= need);
  }

  function revealExit() {
    if (exitRevealed || !exitEl) return;
    exitRevealed = true;
    exitEl.style.display = '';
    exitEl.classList.add('expl-revealed');
    if (data.revealMsg) dialogueText.textContent = data.revealMsg;
  }

  function countClue() {
    clues++;
    refreshProgress();
    if (clues >= need) revealExit();
  }

  data.objects.forEach((obj) => {
    const el = document.createElement('div');
    el.className = 'pnc-object';
    if (obj.bonus) el.classList.add('expl-bonus');
    if (obj.action) { el.classList.add('pnc-exit', 'unlocked'); exitEl = el; }
    el.style.left = obj.x + '%';
    el.style.top = obj.y + '%';

    const emoji = document.createElement('div');
    emoji.className = 'pnc-object-emoji';
    if (obj.size) emoji.style.fontSize = obj.size + 'rem';
    emoji.textContent = obj.emoji;

    const label = document.createElement('div');
    label.className = 'pnc-object-label';
    label.textContent = obj.label || '?';

    el.appendChild(emoji);
    el.appendChild(label);

    let used = false;
    el.addEventListener('click', () => {
      if (completing) return;

      // 출구
      if (obj.action) {
        if (!exitRevealed) return;
        completing = true;
        dialogueText.textContent = obj.msg;
        choicesWrap.innerHTML = '';
        setTimeout(() => onComplete(), 1100);
        return;
      }

      // 선택지가 있는 단서
      if (obj.choices && !used) {
        dialogueText.textContent = obj.prompt || obj.msg || '';
        choicesWrap.innerHTML = '';
        obj.choices.forEach((c) => {
          const btn = document.createElement('button');
          btn.className = 'expl-choice-btn';
          btn.textContent = c.text;
          btn.addEventListener('click', (ev) => {
            ev.stopPropagation();
            if (used) return;
            used = true;
            el.classList.add('visited');
            dialogueText.textContent = c.msg;
            choicesWrap.innerHTML = '';
            if (c.gauge) updateGauge(c.gauge);
            if (obj.clue) countClue();
          });
          choicesWrap.appendChild(btn);
        });
        return;
      }
      if (obj.choices && used) { dialogueText.textContent = obj.doneMsg || '이미 살펴봤다.'; return; }

      // 일반 단서 / 보너스
      choicesWrap.innerHTML = '';
      dialogueText.textContent = obj.msg;
      if (!used) {
        used = true;
        el.classList.add('visited');
        if (obj.gauge) updateGauge(obj.gauge);
        if (obj.clue) countClue();
      }
    });

    if (obj.hidden) el.style.display = 'none';
    viewport.appendChild(el);
  });

  scene.appendChild(viewport);
  scene.appendChild(dialogueBox);
  container.appendChild(scene);
  refreshProgress();
}

// ═══════════════════════════════════════
//  EXPLORATION MODULES
// ═══════════════════════════════════════
const explorations = {

  // ▼ 리메이크: 발견형 탐색 (목표 제시 → 단서 찾기 → 숨은 천막 등장 → 선택/보너스)
  festival_street(container, onComplete) {
    renderExploreRich(container, {
      goal: '🎯 이상하게 자꾸 눈이 가는 곳이 있다. 뭘까?',
      startMsg: '축제의 불빛 속. 뭔가 우리를 끌어당기는 게 있다.\n주변을 꼼꼼히 둘러보자. (모두 살펴보면 그게 나타날지도?)',
      revealMsg: '그때—\n골목 구석, 낡은 천막 하나가 스르륵 눈에 들어왔다.',
      objects: [
        { emoji: '🍢', label: '포장마차', x: 20, y: 40, size: 2.8, clue: true,
          msg: '떡볶이, 순대, 어묵... 맛있는 냄새.\n"저기 뒤쪽 골목이 좀 이상하지 않아?" 남주가 중얼거린다.' },
        { emoji: '🎯', label: '게임 부스', x: 80, y: 33, size: 2.8, clue: true,
          prompt: '인형뽑기 기계. 남주가 눈을 반짝인다. "하나 뽑아줄까?"',
          doneMsg: '이미 부스를 지나쳤다.',
          choices: [
            { text: '🧸 "응! 뽑아줘~" (기대한다)', gauge: 4,
              msg: '몇 번의 실패 끝에 그가 인형을 뽑아 건넸다.\n"자, 선물." ...심장이 살짝 뛴다.' },
            { text: '👀 "됐어, 돈 아까워." (지나친다)', gauge: -2,
              msg: '그가 머쓱하게 손을 거둔다.\n"...그래, 뭐. 다음에." 살짝 아쉬운 표정.' },
          ] },
        { emoji: '🪑', label: '벤치', x: 32, y: 70, size: 2.4, clue: true,
          msg: '연인들이 앉아 사진을 찍고 있다.\n문득, 우리는 저렇게 웃어본 게 언제였더라.' },
        // 숨은 보너스 — 유심히 봐야 발견 (게이지 보상)
        { emoji: '🐱', label: '?', x: 88, y: 74, size: 1.7, bonus: true,
          msg: '담벼락 위 고양이와 눈이 마주쳤다.\n남주가 조용히 웃는다. "...너 닮았다." 괜히 기분이 좋다.', gauge: 3 },
        // 숨겨진 핵심 출구 — 단서 2개 찾으면 등장
        { emoji: '🎪', label: '수상한 천막', x: 52, y: 60, size: 3.5, action: true, hidden: true,
          msg: '"AI가 봐주는 커플 궁합!"\n...끌린다. 들어가보자.' },
      ]
    }, onComplete);
  },

  tent_interior(container, onComplete) {
    renderPointAndClick(container, {
      hint: '천막 안을 둘러보자...',
      objects: [
        { emoji: '🖥️', label: 'VR 기기', x: 65, y: 30, size: 3, msg: '가상현실 글래스처럼 생긴 첨단 장비다.\n꽤 비싸 보이는데...' },
        { emoji: '📋', label: '설명서', x: 28, y: 45, size: 2.5, msg: '체험자의 데이터로 시뮬레이션을 돌린다고 적혀있다.\n"가상현실 속 1일은 현실의 0.001초"' },
        { emoji: '🪑', label: '앉기', x: 50, y: 72, size: 2.8, msg: '의자에 앉아 장비를 착용하기로 했다.', action: true },
      ]
    }, onComplete);
  },

  gender_check(container, onComplete) {
    renderPointAndClick(container, {
      hint: '바뀐 몸을 확인해보자...',
      objects: [
        { emoji: '🪞', label: '거울', x: 50, y: 25, size: 3.5, msg: '...이게 나? 턱선이 각져있고,\n어깨가 넓어졌다. 낯설다.' },
        { emoji: '🤚', label: '내 손', x: 22, y: 55, size: 2.8, msg: '손이 커졌다. 손등에 핏줄이 선명하다.\n힘도 세진 것 같은데...' },
        { emoji: '👕', label: '옷차림', x: 78, y: 50, size: 2.8, msg: '옷은 그대로인데 핏이 완전히 다르다.\n가슴 쪽이 헐렁하고 어깨가 빡빡하다.' },
        { emoji: '✅', label: '적응하기', x: 50, y: 80, size: 2.5, msg: '이 모습에 익숙해져야 한다.', action: true },
      ]
    }, onComplete);
  },

  date_montage(container, onComplete) {
    renderPointAndClick(container, {
      hint: '데이트 장소를 골라보자!',
      objects: [
        { emoji: '☕', label: '카페', x: 22, y: 38, size: 3, msg: '"이 몸으로 카페라니, 신기하다."\n"너 의외로 아메리카노 잘 어울린다?"' },
        { emoji: '🌳', label: '공원', x: 50, y: 30, size: 3, msg: '"바람이 좋다... 좀 적응된 것 같아."\n"그치? 나도 이제 좀 편해."' },
        { emoji: '🎬', label: '영화관', x: 78, y: 42, size: 3, msg: '"팔걸이가 좀 좁아졌는데?"\n"하하, 덩치가 바뀌었으니까!"' },
        { emoji: '🌙', label: '집으로', x: 50, y: 72, size: 2.8, msg: '밤이 깊어간다... 집으로 돌아가기로 했다.', action: true },
      ]
    }, onComplete);
  },

  puppy_house(container, onComplete) {
    renderPointAndClick(container, {
      hint: '🐾 낮은 시야로 집 안을 둘러본다...',
      objects: [
        { emoji: '🍽️', label: '밥그릇', x: 22, y: 62, size: 2.5, msg: '바닥에 놓인 작은 그릇. 물도 있다.\n...이걸로 먹어야 하나.' },
        { emoji: '🛋️', label: '소파 밑', x: 18, y: 30, size: 3, msg: '어둡고 먼지가 있다.\n이상하게 안전한 느낌이 든다.' },
        { emoji: '🚪', label: '현관문', x: 78, y: 25, size: 3.5, msg: '너무 크다. 손잡이에 닿을 수 없다.\n...발로 긁어보지만 소용없다.' },
        { emoji: '🧸', label: '장난감', x: 72, y: 58, size: 2.5, msg: '씹을 수 있는 인형이다.\n본능적으로 물고 싶어진다... 뭐야 이 감정.' },
        { emoji: '🐕', label: '그에게 가기', x: 50, y: 75, size: 2.8, msg: '남자친구에게 다가간다.', action: true },
      ]
    }, onComplete);
  },

  prison_visit(container, onComplete) {
    renderPointAndClick(container, {
      hint: '면회실을 둘러본다...',
      objects: [
        { emoji: '🪟', label: '유리창', x: 50, y: 22, size: 3.5, msg: '두꺼운 유리 너머로 그의 얼굴이 보인다.\n수척해졌다. 눈 밑이 어둡다.' },
        { emoji: '📞', label: '전화기', x: 25, y: 50, size: 2.8, msg: '이걸 통해서만 대화할 수 있다.\n수화기가 차갑다.' },
        { emoji: '📝', label: '벽의 낙서', x: 80, y: 38, size: 2.5, msg: '누군가 날짜를 세어놓았다.\n수백 개의 줄금... 숨이 막힌다.' },
        { emoji: '🚶', label: '돌아가기', x: 50, y: 78, size: 2.5, msg: '...오늘은 여기까지.', action: true },
      ]
    }, onComplete);
  },

  empty_lot(container, onComplete) {
    renderPointAndClick(container, {
      hint: '어둡고 을씨년스러운 공터...',
      objects: [
        { emoji: '🏗️', label: '공사 장비', x: 25, y: 38, size: 3, msg: '철근과 자재가 널려있다.\n위험해 보인다. 조심해야...' },
        { emoji: '🌑', label: '어두운 골목', x: 78, y: 32, size: 3, msg: '가로등이 깜빡인다.\n도망칠 수 있을까...' },
        { emoji: '💬', label: '말을 건다', x: 50, y: 65, size: 2.8, msg: '...진정시켜야 해.', action: true },
      ]
    }, onComplete);
  }
};
