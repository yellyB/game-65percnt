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
//  EXPLORATION MODULES
// ═══════════════════════════════════════
const explorations = {

  festival_street(container, onComplete) {
    renderPointAndClick(container, {
      hint: '축제 거리를 둘러보자...',
      objects: [
        { emoji: '🍢', label: '포장마차', x: 20, y: 40, size: 2.8, msg: '떡볶이, 순대, 어묵...\n맛있는 냄새가 코를 자극한다.' },
        { emoji: '🎯', label: '게임 부스', x: 78, y: 35, size: 2.8, msg: '인형뽑기와 사격 게임이 있다.\n"나중에 해볼까?"' },
        { emoji: '🎪', label: '수상한 천막', x: 50, y: 65, size: 3.5, msg: '"AI가 봐주는 커플 궁합!"\n...뭔가 끌린다. 들어가볼까?', action: true },
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
