// ═══════════════════════════════════════
//  SCENE DATA
// ═══════════════════════════════════════
const scenes = [
  // ═══ PROLOGUE ═══
  { portraits: { heroine: '👩', hero: '🧑', system: '🖥️' } },
  { bg: 'linear-gradient(135deg, #e8a87c 0%, #d3734a 50%, #c8553d 100%)', desc: '🎪 축제 거리' },
  { type: NARRATOR, text: '화려한 축제의 불빛 속, 우리는 손을 잡고 거리를 걸었다.' },
  { type: NARRATOR, text: '여기저기서 맛있는 냄새가 나고, 웃음소리가 넘쳐나는 즐거운 밤이었다.' },

  // ─── Festival Exploration ───
  { explore: 'festival_street' },

  { type: NARRATOR, text: '그때, 한쪽 구석에 좀 허름한 천막 부스가 눈에 들어왔다.' },
  { type: NARRATOR, text: "현수막에는 이렇게 적혀있었다.\n\n'AI가 봐주는 커플 궁합! 서로의 사랑의 크기가 궁금하신가요?'" },
  { type: HERO, text: '야, 이거 재밌겠다! 우리 해볼까?' },
  { type: HEROINE, text: '뭐야 이거... 좀 수상한데? 그래도 재밌겠다, 들어가보자!' },

  // ─── Tent Exploration ───
  { bg: 'linear-gradient(135deg, #2d2438 0%, #1a1625 100%)', desc: '🏮 천막 내부', fade: true },
  { explore: 'tent_interior' },

  // After sitting
  { type: SYSTEM, text: '환영합니다. 장비를 착용하고 원하는 메뉴를 선택해주세요.' },
  { type: NARRATOR, text: '갑자기 기계에서 나온 목소리에 둘 다 깜짝 놀라 서로를 보며 웃었다.' },
  { type: HEROINE, text: '뭐야, 놀랐잖아! 하하.' },
  { type: HERO, text: '자동 안내인가보다. 자, 써보자!' },
  { type: NARRATOR, text: '장비를 착용하자 눈앞에 메뉴가 떠올랐다.\n현수막에서 봤던 [사랑의 크기 테스트]를 선택했다.' },
  { type: SYSTEM, text: '과연 내 알맹이는 그대로인데 껍데기만 다르다면??\n우리의 상황이 지금과 많이 달라진다면??\n\n내 옆에 있는 사람은 나를 계속 사랑할 수 있을까요?' },
  { type: SYSTEM, text: '단순히 재미 용도로 생각하면 오산!\n꽤 정확한 결과를 얻을 수 있습니다.' },
  { type: SYSTEM, text: '*체험자의 데이터로 시뮬레이션을 돌리기 때문에\n가상현실 속 1일은 현실의 0.001초와 비슷합니다.' },
  { type: HEROINE, text: '뭔가 좀 오싹한데...?' },
  { type: HERO, text: '괜찮아, 그냥 게임인데 뭐. 시작하자!' },
  { type: NARRATOR, text: '시작 버튼을 누르자 눈앞이 캄캄해졌다.' },

  // ═══ TEST 1 — Gender Swap ═══
  { portraits: { heroine: '🧑', hero: '👩' } },
  { bg: 'linear-gradient(135deg, #a855f7 0%, #ec4899 50%, #f472b6 100%)', desc: '테스트 1', fade: true },
  { type: NARRATOR, text: '......' },
  { cg: '👩🔄🧑' },
  { type: NARRATOR, text: '정신을 차려보니 내 손을 잡고 있는 사람은—\n내 남자친구가 아니라 어떤 여자였다.' },
  { type: HEROINE, text: '억?!' },
  { type: NARRATOR, text: '소리를 지르며 손을 뗐는데, 그 여자도 똑같이 놀란다.' },
  { microChoice: true, options: [
    { text: '자세히 본다', gauge: 1 },
    { text: '뒷걸음친다', gauge: -1 },
  ]},
  { type: NARRATOR, text: '이상하게 키가 크고 덩치가 큰 그 여자.\n잘 살펴보니... 남자친구의 얼굴과 매우 닮았다.' },
  { type: HEROINE, text: '아, 우리 지금 가상현실에 있는 거야? 깜짝이야.' },
  { type: HERO, text: '그런 거야? 나도 깜짝 놀랐어. 진짜 같다.' },
  { type: HEROINE, text: '난 너한테 바람피는 여자라도 생기는 스토리인 줄 알았는데...\n그게 아니라 네가 여자가 되는 거였네.' },
  { type: HERO, text: '나만 여자가 된 게 아니라 너도...' },
  { type: NARRATOR, text: '무슨 소리지? 그러고 보니 내 목소리가 이상하게 들린다.' },
  { type: HEROINE, text: '나도 남자가 된 거야?? 진짜 신기하다!' },

  // ─── Gender Check Exploration ───
  { explore: 'gender_check' },

  // ─── Thought: After Gender Swap ───
  { thought: true, key: 'gender_thought', prompt: '"이 상황이..."', options: [
    { text: '...신기하다. 이런 경험은 처음이야.', value: 'wonder', gauge: 5 },
    { text: '...혼란스럽다. 나는 누구지?', value: 'confused', gauge: -3 },
    { text: '...무섭다. 원래대로 돌아갈 수 있을까?', value: 'scared', gauge: -3 },
  ]},

  { type: NARRATOR, text: '서로의 모습을 확인했다.\n겉모습은 거의 똑같은데, 성별의 외형적 특징만 달라져 있었다.' },
  { type: NARRATOR, text: '머리 길이는 그대로. 하지만 턱선, 체형, 모든 것이 미묘하게 달랐다.' },
  { type: NARRATOR, text: '가상현실의 성별대로 외형을 바꿔야 할지, 그대로 유지할지 고민이 됐다.' },
  { type: HERO, text: '그래도 넌 내 여자친구니까...\n지금은 남자이긴 하지만 스타일은 여자로 유지했으면 좋겠어.' },
  { type: HEROINE, text: '......' },

  // ─── Puzzle ① Mirror Dressing ───
  { puzzle: 'mirror_dressing' },

  { type: NARRATOR, text: '결국 작은 갈등 끝에 둘 다 외형을 바꿨다.' },
  { type: NARRATOR, text: '그리고 놀랍게도— 적응하고 나니 꽤 즐거웠다.' },
  { type: NARRATOR, text: '성별이 바뀐 채로 데이트를 시작했다.' },

  // ─── Date Montage Exploration ───
  { explore: 'date_montage' },

  { cg: '🌙😔' },
  { type: NARRATOR, text: '하지만 밤이 되고... 분위기가 달라졌다.' },
  { type: NARRATOR, text: '성관계를 가지려고 했는데, 포지션을 어떻게 해야 할지 고민하는 중—' },
  { type: NARRATOR, text: '남자친구가 머뭇거렸다.' },
  { type: HEROINE, text: '...왜? 왜 그래?' },
  { type: NARRATOR, text: '......' },
  { type: HERO, text: '이건 도저히 못하겠어.' },
  { type: HERO, text: '널 사랑해. 하지만 난 원래 남자라고.\n이런 건... 싫어!' },

  // ─── Timed Choice: Test 1 Night ───
  { timedChoice: true, key: 'night_reaction', time: 5000, timeoutIndex: 2, prompt: '그가 괴로워하고 있다...', options: [
    { text: '"괜찮아, 이해해."', value: 'comfort', gauge: 5 },
    { text: '"나도 어려워..."', value: 'empathize', gauge: 2 },
    { text: '(아무 말도 하지 못한다)', value: 'silence', gauge: -2 },
  ]},
  { conditional: true, key: 'night_reaction', speaker: NARRATOR, variants: {
    'comfort': '따뜻한 말에 그의 표정이 조금 누그러졌다.',
    'empathize': '서로의 어려움을 나누며 조금은 가까워진 기분이 들었다.',
    'silence': '어색한 침묵이 흘렀다. 둘 다 어떤 말을 해야 할지 몰랐다.',
  }},

  { type: NARRATOR, text: '그의 목소리에는 진심이 담겨있었다.\n나도 사실... 조금은 이해할 수 있었다.' },

  // ═══ Between Test 1 & 2 ═══
  { cg: '' },
  { portraits: { heroine: '👩', hero: '🧑' } },
  { bg: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 100%)', desc: '', fade: true },
  { type: SYSTEM, text: '테스트가 종료되었습니다.\n다음 테스트를 진행하시겠습니까?' },
  { type: HERO, text: '와, 이거 진짜 실감난다. 어때? 계속해볼래?' },
  { type: HEROINE, text: '그래 좋아. 다음엔 어떤 게 나올지 무섭다.' },

  // ═══ TEST 2 — Puppy ═══
  { portraits: { heroine: '🐕', hero: '🧑' } },
  { bg: 'linear-gradient(135deg, #56ab2f 0%, #a8e063 50%, #dce35b 100%)', desc: '테스트 2', fade: true },
  { type: NARRATOR, text: '누워있다가 눈을 떠서 몸을 일으켰는데—\n뭔가 잘못되었다는 걸 바로 알았다.' },
  { type: NARRATOR, text: '내 시야는 무릎만큼 낮았고, 두 다리로 설 수 없었다.' },
  { type: HERO, text: '너야...?' },
  { type: NARRATOR, text: '"낑낑"' },
  { cg: '🐕💭❓' },
  { type: NARRATOR, text: '말도 안 나왔다.\n나는... 남자친구의 강아지가 되어있었다.' },
  { type: HERO, text: '잠깐, 대화도 안 통하는데 어떻게 서로 교감을 하고\n사랑을 테스트하겠다는 건데?!' },
  { type: NARRATOR, text: '너보다 내가 더 답답하다고...' },

  // ─── Puppy House Exploration ───
  { explore: 'puppy_house' },

  // ─── Puzzle ② Puppy Communication ───
  { puzzle: 'puppy_comm' },

  // ─── Thought: After Puppy Puzzle ───
  { thought: true, key: 'puppy_thought', prompt: '"말이 통하지 않아도..."', options: [
    { text: '사랑은 형태가 달라도 같은 거야.', value: 'love_same', gauge: 5 },
    { text: '불공평해. 대등하지 않으면 사랑이 아니야.', value: 'unfair', gauge: -3 },
    { text: '...모르겠어. 아직 답을 내리기엔 이르다.', value: 'unsure', gauge: 0 },
  ]},

  // ═══ Between Test 2 & 3 ═══
  { cg: '' },
  { portraits: { heroine: '👩', hero: '🧑' } },
  { bg: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 100%)', desc: '', fade: true },
  { type: SYSTEM, text: '테스트가 종료되었습니다.\n다음 테스트를 진행하시겠습니까?' },
  { type: HERO, text: '야, 방금 건 무효야!\n이건 남녀 간의 사랑이 아니라 생명체 간의 사랑이잖아!\n난 이걸 테스트하려는 게 아니라고.' },
  { type: HEROINE, text: '그치만 난 너한테 진짜 사랑을 느꼈는걸?\n많은 것을 희생하더라도 널 지켜주고 싶었고,\n네가 죽을 때까지 곁에 있겠다고 다짐했어.' },
  { type: HERO, text: '나는 강아지였다고.\n나에게 자유는 아무것도 없었어.\n네가 주는 사랑만 받을 뿐이지.\n내가 선택할 수 있는 게 아무것도 없잖아!' },
  { choice: true, choiceKey: 'puppy_debate', options: [
    { text: '"...그래도 사랑은 사랑이야. 형태가 달라도."', value: 'love_same', gauge: 4 },
    { text: '"네 말도 맞아. 대등하지 않은 관계였어."', value: 'agree', gauge: -2 },
    { text: '"그건 네 입장이고, 내 입장에선 진심이었어."', value: 'my_side', gauge: 0 },
  ]},
  { conditional: true, key: 'puppy_debate', speaker: NARRATOR, variants: {
    'love_same': '남자친구는 잠시 말을 멈추었다. 내 진심이 전해진 것 같았다.',
    'agree': '남자친구는 조금 놀란 표정을 지었다. 내가 자기 편을 들어줄 줄은 몰랐나 보다.',
    'my_side': '남자친구는 고개를 저었지만, 더 이상 반박하지는 않았다.',
  }},
  { type: NARRATOR, text: '어쨌든 남자친구는 진짜 사랑을 했다고 우기고,\n나는 찜찜한 마음을 안은 채 다음 테스트로 넘어갔다.' },
  { type: HEROINE, text: '이게 마지막인가 봐.\n제발 이번엔 사람으로 살게 해줘...' },

  // ═══ TEST 3 — Father & Daughter ═══
  { portraits: { heroine: '👩', hero: '👴' } },
  { bg: 'linear-gradient(135deg, #434343 0%, #6b6b6b 50%, #8e8e8e 100%)', desc: '테스트 3', fade: true },
  { type: NARRATOR, text: '다행히 이번에는 사람이다.\n내 모습도 원래 그대로.' },
  { type: SYSTEM, text: '네, 확인되셨습니다.' },
  { type: NARRATOR, text: '안내원이 건네준 종이에는 가족관계증명서가 인쇄되어 있었다.' },
  { type: NARRATOR, text: '그제서야 남자친구의 얼굴을 확인했다.\n30년은 더 산 듯한, 중년의 얼굴.' },
  { cg: '👨‍👧📋' },
  { type: HEROINE, text: '뭐? 이번엔... 부녀지간이야?' },
  { type: NARRATOR, text: '처음엔 말도 안 되는 상황에 둘 다 경악했다.' },
  { microChoice: true, options: [
    { text: '받아들이자', gauge: 2 },
    { text: '이건 아닌데...', gauge: -1 },
  ]},
  { type: NARRATOR, text: '하지만 테스트를 잘 통과하고 싶어서,\n일부러라도 사랑을 느끼려고 노력했다.' },
  { type: NARRATOR, text: '부녀지간이라는 상황 때문에\n자꾸 본능적 거부감이 들었지만...' },
  { type: NARRATOR, text: '그래도 둘은 노력했다.\n아버지로서, 딸로서의 사랑을 진심으로 느끼려고.' },
  { microChoice: true, options: [
    { text: '진심으로 노력한다', gauge: 2 },
    { text: '연기하는 척한다', gauge: -1 },
  ]},
  { type: NARRATOR, text: '그리고 어떤 사건을 계기로—\n남자친구가 나에게 이성적 사랑을 느끼는 순간이 왔다.' },

  // Arrest
  { cg: '' },
  { bg: 'linear-gradient(135deg, #1a1a1a 0%, #2d1b1b 50%, #1a1a1a 100%)', desc: '', shake: true },
  { cg: '🚨👮' },
  { type: NARRATOR, text: '갑자기——' },
  { type: NARRATOR, text: '체험 기구가 벗겨지고, 경찰이 들이닥쳤다.' },

  // ─── Timed Choice: Arrest Moment ───
  { timedChoice: true, key: 'arrest', time: 3000, timeoutIndex: 1, prompt: '경찰이 수갑을 꺼내든다—', options: [
    { text: '"잠깐요, 이건 오해입니다!"', value: 'protest', gauge: 2 },
    { text: '(몸이 얼어붙는다)', value: 'freeze', gauge: -2 },
  ]},

  { type: NARRATOR, text: '알고 보니 아동성범죄자를 잡아내기 위해\n이런 장치를 사용한 것이었다.' },
  { type: NARRATOR, text: '우리는 일부러 서로에게 사랑을 느끼려고\n더 노력한 것뿐인데...\n\n너무나 억울했다.' },

  // Prison
  { cg: '' },
  { portraits: { heroine: '👩', hero: '🧑' } },
  { bg: 'linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 50%, #1a1a1a 100%)', desc: '🔒 감옥', fade: true },
  { cg: '🔒😔' },
  { type: NARRATOR, text: '남자친구는 감옥에 들어갔다.' },
  { type: NARRATOR, text: '나는 꾸준히 면회를 갔다.' },

  // ─── Prison Visit Exploration ───
  { explore: 'prison_visit' },

  // ─── Thought: During Prison ───
  { thought: true, key: 'prison_thought', prompt: '"나는 왜 이러고 있지..."', options: [
    { text: '...의무감. 내가 이 상황에 끌어들인 거니까.', value: 'duty', gauge: -5 },
    { text: '...사랑. 그래도 그를 사랑하니까.', value: 'love', gauge: 5 },
    { text: '...모르겠어. 관성인 것 같기도 해.', value: 'inertia', gauge: 0 },
  ]},

  { type: NARRATOR, text: '꺼내주려고 아주 많은 노력을 했지만,\n아동성범죄는 형량이 세서 쉽지 않았다.' },

  // ─── Puzzle ③ Evidence Board ───
  { puzzle: 'evidence_board' },

  { type: NARRATOR, text: '슬프긴 했지만...\n결혼한 것도 아니고, 솔직히 점점 지쳐갔다.' },
  { type: NARRATOR, text: '그는 어이없게 범죄자 신세가 되어\n너무 답답하고 억울해했다.' },

  // 3 years
  { cg: '' },
  { bg: 'linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 50%, #0a0a0a 100%)', desc: '⏳ 3년 후' },
  { type: NARRATOR, text: '3년이 흘렀다.' },
  { type: NARRATOR, text: '남자친구는 희망이 거의 없다는 걸 깨달았고,\n나를 점점 비난하기 시작했다.' },
  { type: NARRATOR, text: '내가 잘못한 게 아니라는 걸 알면서도,\n자기 상황이 너무 척박하니까 누구라도 탓하게 된 거였다.' },
  { type: NARRATOR, text: '나도 그런 그를 보면서 지쳐갔다.' },
  { microChoice: true, options: [
    { text: '그래도 참는다', gauge: 2 },
    { text: '한계가 온다', gauge: -1 },
  ]},
  { type: NARRATOR, text: '그러다 그가 도를 넘는 말을 했다.' },
  { type: HERO, text: '이게 다 네 탓이야.\n네가 그때 그 테스트를 하자고 안 했으면—!' },

  // ─── Timed Choice: Prison Argument ───
  { timedChoice: true, key: 'prison_argument', time: 4000, timeoutIndex: 2, prompt: '그가 소리를 지르고 있다...', options: [
    { text: '"미안해..."', value: 'apologize', gauge: 3 },
    { text: '"나도 힘들었어!"', value: 'defend', gauge: -2 },
    { text: '"...!!!"', value: 'explode', gauge: -4 },
  ]},
  { conditional: true, key: 'prison_argument', speaker: NARRATOR, variants: {
    'apologize': '사과했지만, 그의 분노는 쉽게 가라앉지 않았다.',
    'defend': '서로의 상처를 드러내며, 말은 점점 거칠어졌다.',
    'explode': '참았던 감정이 폭발했다. 둘 다 상처뿐인 말을 쏟아냈다.',
  }},

  { type: NARRATOR, text: '그동안 다 들어주다가, 나도 결국 폭발했다.' },
  { type: HEROINE, text: '너랑 나랑 결혼한 사이도 아니고,\n우린 고작 5개월 만난 사이야.' },
  { type: HEROINE, text: '그래도 난 너를 생각해서\n이리저리 뛰어다니며 널 꺼낼 방법을 찾아다녔어.' },
  { type: HEROINE, text: '근데 넌 이렇게도 배려가 없니?' },
  { type: HEROINE, text: '그 날 테스트 결과는 알지 못한 채 끝났지만...\n\n널 보면 그 결과를 안 봐도 알 수 있을 것 같네.' },
  { type: NARRATOR, text: '그렇게 쏘아붙이고 나왔다.' },

  // Release
  { bg: 'linear-gradient(135deg, #2d3436 0%, #636e72 100%)', desc: '' },
  { type: NARRATOR, text: '그런데 기적적으로—\n그 기계가 법적 문제에 휘말리게 되면서\n남자친구가 감옥을 나올 수 있게 됐다.' },
  { type: NARRATOR, text: '관계가 악화되긴 했지만,\n다행이라고 생각했다.' },
  { microChoice: true, options: [
    { text: '다시 시작할 수 있을까', gauge: 2 },
    { text: '이미 끝난 거야', gauge: -2 },
  ]},
  { type: NARRATOR, text: '하지만 솔직히... 나에게는 관심 있는 사람이 생겼다.\n너무 힘든 일을 겪어서 누군가에게 의지하고 싶었고,\n3년이란 시간은 충분히 오래 노력한 시간이었으니까.' },
  { type: NARRATOR, text: '그리고 감옥을 나온 남자친구는—\n다른 여자를 만날 수 있다는 생각에\n바로 방탕한 생활을 시작했다.' },
  { type: NARRATOR, text: '...기막혔다.' },
  { type: NARRATOR, text: '하지만 어차피 우리 관계는 예전 같지 않았고,\n나도 나의 삶을 살기로 했다.' },

  // Encounter
  { bg: 'linear-gradient(135deg, #2d3436 0%, #4a1a1a 100%)', desc: '', shake: true },
  { type: NARRATOR, text: '그러다 길에서 우연히 마주쳤다.' },

  // ─── Timed Choice: Post-release Encounter ───
  { timedChoice: true, key: 'encounter', time: 6000, timeoutIndex: 1, prompt: '그가 다가오고 있다...', options: [
    { text: '...안녕.', value: 'greet', gauge: 3 },
    { text: '(피하자)', value: 'avoid', gauge: -3 },
  ]},
  { conditional: true, key: 'encounter', speaker: NARRATOR, variants: {
    'greet': '어색하게 인사를 건넸다. 그의 표정이 복잡해졌다.',
    'avoid': '시선을 돌리고 지나치려 했지만, 그가 먼저 말을 걸었다.',
  }},

  { type: HERO, text: '우린 싸워서 잠시 시간을 갖는 중이었는데—\n바람을 피다니!' },
  { type: HEROINE, text: '너도 여자 만나잖아!' },
  { type: HERO, text: '그건 이거랑 다르지!' },
  { type: NARRATOR, text: '자꾸 화만 내는 그를 진정시키려고\n조용한 공터로 갔다.' },

  // ─── Empty Lot Exploration ───
  { explore: 'empty_lot' },

  // ─── Thought: Before Confrontation ───
  { thought: true, key: 'before_confront', prompt: '"그를 만나면..."', options: [
    { text: '...대화가 통할 거야. 아직 희망이 있어.', value: 'hope', gauge: 5 },
    { text: '...무서워. 어떤 일이 벌어질지 모르겠어.', value: 'fear', gauge: -3 },
    { text: '...어떻게 되든 상관없어. 다 끝났으니까.', value: 'resign', gauge: -3 },
  ]},

  // ─── Puzzle ④ Confrontation ───
  { puzzle: 'confrontation' },

  // Death
  { bg: 'linear-gradient(135deg, #000000 0%, #1a0000 50%, #000000 100%)', shake: true },
  { cg: '🩸💀' },
  { type: NARRATOR, text: '몸싸움을 하다가 그를 밀쳤는데—' },
  { type: NARRATOR, text: '공사 장비에 머리를 부딪힌 남자친구.' },
  { type: NARRATOR, text: '피를 흘리며 나에게 손을 뻗었다.' },
  { microChoice: true, options: [
    { text: '손을 잡는다', gauge: 2 },
    { text: '얼어붙는다', gauge: -1 },
  ]},
  { type: NARRATOR, text: '......' },
  { type: NARRATOR, text: '맥박이 없었다.' },
  { type: NARRATOR, text: '그렇게 그가 눈을 감았다.' },

  // ═══ RESULT ═══
  { cg: '' },
  { portraits: { heroine: '👩', hero: '🧑' } },
  { bg: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 100%)', desc: '', fade: true },
  { type: SYSTEM, text: '테스트가 종료되었습니다.' },
  { type: NARRATOR, text: '...눈을 떴다.' },
  { type: NARRATOR, text: '우리는 축제의 천막 안에 있었다.' },
  { microChoice: true, options: [
    { text: '그를 본다', gauge: 1 },
    { text: '고개를 숙인다', gauge: -1 },
  ]},
  { type: NARRATOR, text: '둘 다 어안이 벙벙하고 실감이 나지 않아,\n당황한 얼굴로 기계를 벗었다.' },

  // ─── Puzzle ⑤ Result Dashboard ───
  { puzzle: 'result_detail' },

  // ═══ EPILOGUE ═══
  { bg: 'linear-gradient(135deg, #606c88 0%, #3f4c6b 50%, #2c3e50 100%)', desc: '', fade: true },
  { type: NARRATOR, text: '화면에는 숫자가 떠있고,\n배경에 빵빠레와 축포 그림이 계속해서 터지고 있었다.' },
  { type: NARRATOR, text: '그 발랄한 축하 연출이\n어째서인지 잔인하게 느껴졌다.' },
  { type: NARRATOR, text: '서로를 잠시 바라보았다.' },
  { type: NARRATOR, text: '아무 말도 나오지 않았다.' },
  { choice: true, choiceKey: 'epilogue', options: [
    { text: '"...나가자."', value: 'leave', gauge: 0 },
    { text: '(아무 말 없이 짐을 챙긴다)', value: 'silent', gauge: -2 },
  ]},
  { type: NARRATOR, text: '내가 먼저 짐을 챙겨서 천막을 나섰다.' },
  { bg: 'linear-gradient(135deg, #2c3e50 0%, #34495e 50%, #4a6741 100%)' },
  { type: NARRATOR, text: '남자친구는 멍한 얼굴로\n기계에서 나오는 발랄한 축하 음악을 듣다가—' },
  { type: NARRATOR, text: '내가 간 길을 따라 나섰다.' },
  { bg: 'linear-gradient(135deg, #2c3e50 0%, #1a1a2e 100%)' },
  { type: NARRATOR, text: '축제의 불빛이 저 멀리서 반짝였다.' },
  { type: NARRATOR, text: '둘은 아주 오랫동안\n한 마디 말도 하지 않았다.' },
  { type: NARRATOR, text: '......' },
  { type: NARRATOR, text: '\n\n— 끝 —' },
  { end: true },
];

// ═══════════════════════════════════════
//  BOOT
// ═══════════════════════════════════════
startGame();
