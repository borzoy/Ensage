--[[ N'aix Script ]]
-- Very sample script that make Rage + Apen wounds + Armelt

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.HeroInfo")

config = ScriptConfig.new()
config:SetParameter("ComboKey", "D", config.TYPE_HOTKEY)
config:SetParameter("TargetLeastHP", false)
config:Load()

local ComboKey       = config.ComboKey
local getLeastHP     = config.TargetLeastHP
local registered	 = false
local range          = 500
local Al_Delay       = 1000
local sleepMain      = 0
local currentMain    = 0
local target         = nil
local active         = false

local x,y            = 100, 700
local monitor        = client.screenSize.x/1600
local F14            = drawMgr:CreateFont("F14","consola",14,750)
local F15            = drawMgr:CreateFont("F15","consola",12,550)
local statusText     = drawMgr:CreateText(x*monitor,y*monitor,0xFF7300FF," N'aix Script ",F14) statusText.visible = false
local statusText2    = drawMgr:CreateText(x*monitor+5,y*monitor+10,0xB1B0AFFF,"Combo-(".. string.char(ComboKey) ..")-OFF",F15) statusText2.visible = false

function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Life_Stealer then
			script:Disable()
		else
			registered = true
			statusText.visible = true
			statusText2.visible = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	
	if code == ComboKey then
		active 	= (msg == KEY_DOWN)
		
	end
	
	if active then 
		statusText2.text = "Combo-(".. string.char(ComboKey) ..")-ON"
	else
		statusText2.text = "Combo-(".. string.char(ComboKey) ..")-OFF"
		
	    end
	end
--end

function Main(tick)
	currentMain = tick
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	if not (me and active) then return end
	
	local Rage = me:GetAbility(1)
	local Apen = me:GetAbility(3)
	local arml = me:FindItem("item_armlet")
	
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me:GetEnemyTeam(), illusion=false})

	    for i,v in ipairs(enemies) do
		local distance = GetDistance2D(v,me)


		if not target and distance < range then
			target = v
		end


		if target then
			if getLeastHP and distance < range then
				target = targetFind:GetLowestEHP(range,"magic")
			elseif distance < GetDistance2D(target,me) and target.alive then
				target = v
			elseif GetDistance2D(target,me) > range or not target.alive then
				target = nil
				active = false
			end
		end
	end
	
	if arml and arml:CanBeCasted() and me:CanCast() then
	    if not me:DoesHaveModifier("modifier_item_armlet_unholy_strength") then
		   me:SafeCastItem("item_armlet")
		   Sleep(Al_Delay) 
	    end
    end
        
        if target and me.alive then
            if Rage and Rage:CanBeCasted() and me:CanCast() then
		       me:SafeCastAbility(Rage)
			   Sleep(200,"Rage")
            end
        end
        if target and me.alive then
            if Apen and Apen:CanBeCasted() and me:CanCast() then
		       me:SafeCastAbility(Apen ,target)
			   Sleep(200, "Apen")
			end
        end
    return
end

function onClose()
	collectgarbage("collect")
	if registered then
	   statusText.visible = false
	   statusText2.visible = false
	   script:UnregisterEvent(Main)
	   script:UnregisterEvent(Key)
	   registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)	
			  
               		   