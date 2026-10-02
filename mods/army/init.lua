-- 1단계: 군대 병사 스폰 + 전투 공유
-- 군대(플레이어 포함) 중 누구든 전투 → 그 적과 군대 전체가 전투. 조직 간 관계(army↔타 조직)는 건드리지 않음.

local NPC_RECORD = "Character.army_soldier" -- tweaks/army/army.yaml (소속·조직·반응·무기는 레코드에서 지정)
local SPAWN_DISTANCE = 3.0
local TAG = "Army"
local LINK_INTERVAL = 0.5        -- 전투 공유 주기(초)
local PLAYER_ENEMY_RANGE = 60.0  -- 플레이어를 공격 중인 적 탐색 반경(m)

local members = {} -- 병사 엔티티 ID. 플레이어는 따로 처리
local linked = {}  -- 이미 전투를 건 "공격자:대상" 쌍 → 매 주기 InjectThreat 반복 방지
local timer = 0

local function hashOf(e) return tostring(e:GetEntityID().hash) end

local function alive(e)
    return e ~= nil and not (e.IsDead and e:IsDead())
end

local function inCombat(npc)
    return EnumInt(npc:GetHighLevelStateFromBlackboard()) == EnumInt(gamedataNPCHighLevelState.Combat)
end

-- 병사가 싸우고 있는 적
local function collectThreats(npc, out)
    for _, t in ipairs(npc:GetTargetTrackerComponent():GetHostileThreats(false)) do
        if alive(t.entity) then out[hashOf(t.entity)] = t.entity end
    end
end

-- 플레이어와 싸우고 있는 적 (AMM 의 주변 NPC 탐색 방식)
local function collectPlayerAttackers(player, out)
    local query = Game["TSQ_NPC;"]()
    query.maxDistance = PLAYER_ENEMY_RANGE
    local ok, parts = Game.GetTargetingSystem():GetTargetParts(player, query)
    if not ok then return end
    for _, part in ipairs(parts) do
        local npc = part:GetComponent(part):GetEntity()
        if alive(npc) and inCombat(npc)
            and EnumInt(npc:GetAttitudeTowards(player)) == EnumInt(EAIAttitude.AIA_Hostile) then
            out[hashOf(npc)] = npc
        end
    end
end

-- 개체 단위 적대 + 위협 등록 (aiActionHelper.script). 조직 관계는 그대로
-- ponytail: 실패도 기록해 재시도 안 함(전투 종료 시 초기화). 상태 변화 후 재시도가 필요해지면 실패는 기록하지 말 것
local function engage(attacker, target)
    local k = hashOf(attacker) .. ":" .. hashOf(target)
    if linked[k] ~= nil then return end
    linked[k] = AIActionHelper.TryStartCombatWithTarget(attacker, target)
    print("[army] engage " .. k .. " -> " .. tostring(linked[k])) -- 디버그
end

local function linkCombat()
    local player = Game.GetPlayer()
    if not player then return end

    local soldiers, enemies = {}, {}
    for _, id in ipairs(members) do
        local npc = Game.FindEntityByID(id)
        if alive(npc) then
            table.insert(soldiers, npc)
            if inCombat(npc) then collectThreats(npc, enemies) end
        end
    end
    if #soldiers == 0 then return end
    if player:IsInCombat() then collectPlayerAttackers(player, enemies) end

    if next(enemies) == nil then
        linked = {} -- 전투 종료
        return
    end

    for _, e in pairs(enemies) do
        for _, s in ipairs(soldiers) do engage(s, e) end
        if e:IsA("ScriptedPuppet") then engage(e, player) end -- 적이 플레이어도 노림 → 플레이어 전투 상태
    end
end

local function spawnNpc()
    local player = Game.GetPlayer()
    if not player then return end

    local pos = player:GetWorldPosition()
    local fwd = player:GetWorldForward()

    local spec = DynamicEntitySpec.new()
    spec.recordID = TweakDBID.new(NPC_RECORD)
    spec.appearanceName = CName.new("random")
    spec.position = Vector4.new(pos.x + fwd.x * SPAWN_DISTANCE, pos.y + fwd.y * SPAWN_DISTANCE, pos.z, 1.0)
    spec.tags = { CName.new(TAG) }

    table.insert(members, Game.GetDynamicEntitySystem():CreateEntity(spec))
    print("[army] spawned " .. NPC_RECORD .. " (members: " .. #members .. ")")
end

local function despawnAll()
    members = {}
    linked = {}
    Game.GetDynamicEntitySystem():DeleteTagged(CName.new(TAG))
    print("[army] despawned all")
end

registerForEvent("onUpdate", function(dt)
    timer = timer + dt
    if timer < LINK_INTERVAL then return end
    timer = 0
    linkCombat()
end)

registerHotkey("SpawnNpc", "Spawn NPC", spawnNpc)
registerHotkey("DespawnAll", "Despawn all spawned NPCs", despawnAll)
