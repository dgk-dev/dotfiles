-- WezTerm Configuration
-- For WSL2 + Ubuntu + Starship setup (multi-machine support)
--
-- ⚠️ 수정 후 dotfiles repo에 커밋+푸시 필수:
-- /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME add ~/.wezterm.lua
-- /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME commit -m "chore(wezterm): update config"
-- /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME push origin main
--
-- Windows 동기화: cp ~/.wezterm.lua /mnt/c/Users/$USER/.wezterm.lua (PowerShell에서 $env:USERNAME)
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ============================================
-- Dynamic User Detection (multi-machine support)
-- ============================================
-- Windows 사용자명 자동 감지 (환경변수에서)
local function get_windows_username()
  return os.getenv("USERNAME") or os.getenv("USER") or "user"
end

-- WSL 사용자명 자동 감지 (WSL 내부 경로용)
local function get_wsl_username()
  -- WSL 내에서 실행시 USER 환경변수 사용
  -- Windows에서 실행시 USERNAME 환경변수 사용
  local user = os.getenv("USER") or os.getenv("USERNAME") or "user"
  return user
end

local wsl_user = get_wsl_username()

-- ============================================
-- WSL Integration
-- ============================================
-- WSL 배포판을 기본 도메인으로 설정 (터미널 열면 바로 WSL)
-- 배포판 이름 확인: wsl -l -v (Ubuntu, Ubuntu-24.04, Ubuntu-22.04 등)
--
-- [gotcha] WSL 배포판 이름이 'Ubuntu'가 아닐 수 있음 (Ubuntu-24.04 등)
--          wsl -l -v 로 확인 후 아래 값 수정 필요
config.default_domain = 'WSL:Ubuntu-24.04'

-- 시작 디렉토리 (WSL 홈 - 동적 경로)
-- '~'는 WSL 도메인에서 Windows 홈으로 해석될 수 있어 명시적 지정
config.default_cwd = '//wsl$/Ubuntu/home/' .. wsl_user

-- ============================================
-- Font (Nerd Font for Starship icons)
-- ============================================
-- Sarasa Term K: 폭 좁은 한글 지원 터미널 폰트
-- 설치: winget install Sarasa.SarasaGothic
config.font = wezterm.font('Sarasa Term K', { weight = 'Regular' })
config.font_size = 14.0

-- fallback: Sarasa 없으면 JetBrains Mono 사용
config.font = wezterm.font_with_fallback {
    { family = 'Sarasa Term K', weight = 'Regular' },
    { family = 'JetBrains Mono', weight = 'Medium' },
}

-- 폰트 렌더링 최적화
config.freetype_load_flags = 'NO_HINTING'

-- ============================================
-- Color Scheme
-- ============================================
-- Catppuccin Mocha (어두운 테마, 가독성 좋음)
config.color_scheme = 'Catppuccin Mocha'

-- ============================================
-- Window
-- ============================================
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- 투명도 (원하면 0.95 등으로 조절)
config.window_background_opacity = 1.0

-- 창 장식 (타이틀바)
config.window_decorations = "RESIZE"

-- 시작 시 창 크기
config.initial_cols = 120
config.initial_rows = 35

-- ============================================
-- Tab Bar
-- ============================================
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true   -- 탭 1개일 때 탭바 숨김
config.use_fancy_tab_bar = false             -- 심플 탭바 (+ 버튼, X 버튼 없음)
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false  -- 새 탭(+) 버튼 숨김

-- 탭 타이틀에 현재 디렉토리 표시 (짧게)
config.tab_max_width = 25

-- 탭 타이틀 자동 포맷팅 (수동 설정 우선)
-- 사용자가 set_title()로 설정한 이름이 있으면 그것을 사용
-- 없으면 현재 디렉토리의 베이스명을 표시
local function basename(path)
  -- Windows(\)와 Unix(/) 경로 분리자 모두 처리
  return path:gsub("(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = tab.tab_title

  -- 1. 사용자가 명시적으로 설정한 제목 우선
  if title and #title > 0 then
    return " " .. title .. " "
  end

  -- 2. 자동 포맷팅: 현재 디렉토리 베이스명
  local pane = tab.active_pane
  local cwd_uri = pane.current_working_dir

  if cwd_uri then
    local cwd = cwd_uri.file_path or tostring(cwd_uri)
    local cwd_base = basename(cwd)
    -- 홈 디렉토리는 ~ 로 표시 (동적 사용자명)
    if cwd_base == wsl_user or cwd_base == "" then
      cwd_base = "~"
    end
    return " " .. cwd_base .. " "
  end

  -- 3. fallback: pane 제목
  return " " .. (pane.title or "terminal") .. " "
end)

-- ============================================
-- Scrollback
-- ============================================
-- 스크롤백 버퍼 크기 (Claude Code 긴 대화용)
config.scrollback_lines = 50000

-- ============================================
-- Keybindings
-- ============================================
local act = wezterm.action

config.keys = {
  -- Shift+Enter: 줄바꿈 (Claude Code 멀티라인 입력)
  { key = 'Enter', mods = 'SHIFT', action = act.SendKey { key = 'Enter', mods = 'SHIFT' } },

  -- 탭 관리
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = true } },

  -- 탭 이름 변경 (Ctrl+Shift+N) - N = Name
  -- 참고: Ctrl+Shift+R은 WezTerm 기본 ReloadConfiguration과 충돌
  {
    key = 'n',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = '탭 이름 입력:',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- 탭 이름 리셋 (Ctrl+Shift+` - 자동 모드로 복귀)
  {
    key = '`',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      window:active_tab():set_title('')
    end),
  },

  -- 탭 이동
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  -- 화면 분할
  { key = 'e', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- 패널 이동
  { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down' },

  -- 폰트 크기
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },

  -- 복사/붙여넣기
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  -- Ctrl+V로 텍스트 붙여넣기 (일반적인 단축키)
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
  -- Ctrl+C 지능형: 선택 있으면 복사, 없으면 SIGINT (프로세스 중단)
  {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if has_selection then
        window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
      end
    end),
  },

  -- 스크롤
  { key = 'PageUp', mods = 'SHIFT', action = act.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(1) },
  { key = 'Home', mods = 'SHIFT', action = act.ScrollToTop },
  { key = 'End', mods = 'SHIFT', action = act.ScrollToBottom },
}

-- ============================================
-- Mouse
-- ============================================
-- 마우스 스크롤 속도
config.scroll_to_bottom_on_input = true

-- URL 클릭으로 열기
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- ============================================
-- Performance
-- ============================================
-- GPU 가속 (스크롤 부드럽게)
config.front_end = "OpenGL"
config.webgpu_power_preference = "HighPerformance"

-- 프레임 속도
config.max_fps = 120

-- ============================================
-- Bell
-- ============================================
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = "CursorColor",
}

-- ============================================
-- Input
-- ============================================
-- IME 지원 (한글 입력 최적화)
config.use_ime = true

-- IME 조합 중 텍스트 렌더링 방식
-- "Builtin": WezTerm이 직접 렌더링 (기본값, 가끔 한글 조합 시 겹침 현상)
-- "System": OS가 렌더링 (한글 조합 안정성 향상)
config.ime_preedit_rendering = "System"

-- 애니메이션 FPS (부드러운 커서 + 배터리 절약)
config.animation_fps = 60

-- ============================================
-- Misc
-- ============================================
-- 종료 확인 비활성화
config.window_close_confirmation = "NeverPrompt"

-- 업데이트 확인 비활성화
config.check_for_updates = false

return config
