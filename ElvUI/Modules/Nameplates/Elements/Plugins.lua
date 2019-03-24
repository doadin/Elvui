local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local pairs = pairs
local unpack = unpack
local CreateFrame = CreateFrame

function NP:Construct_QuestIcons(nameplate)
	local QuestIcons = CreateFrame('Frame', nameplate:GetDebugName()..'QuestIcons', nameplate)
	QuestIcons:Hide()

	for _, object in pairs({'Item', 'Loot', 'Skull', 'Chat'}) do
		QuestIcons[object] = QuestIcons:CreateTexture(nil, 'BORDER', nil, 1)
		QuestIcons[object]:Point('CENTER')
		QuestIcons[object]:Hide()
	end

	QuestIcons.Item:SetTexCoord(unpack(E.TexCoords))

	QuestIcons.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
	QuestIcons.Chat:SetTexCoord(0, 0.5, 0.5, 1)

	QuestIcons.Text = QuestIcons:CreateFontString(nil, 'OVERLAY')
	QuestIcons.Text:Point('BOTTOMRIGHT', QuestIcons, 'BOTTOMRIGHT', 2, -0.8)
	QuestIcons.Text:FontTemplate(E.Libs.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	return QuestIcons
end

function NP:Update_QuestIcons(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'FRIENDLY_NPC' or nameplate.frameType == 'ENEMY_NPC') and db.questIcon.enable then
		if not nameplate:IsElementEnabled('QuestIcons') then
			nameplate:EnableElement('QuestIcons')
		end

		nameplate.QuestIcons:ClearAllPoints()
		nameplate.QuestIcons:Point(E.InversePoints[db.questIcon.position], nameplate, db.questIcon.position, db.questIcon.xOffset, db.questIcon.yOffset)

		nameplate.QuestIcons:Size(db.questIcon.size + 4, db.questIcon.size + 4)
		nameplate.QuestIcons.Item:Size(db.questIcon.size, db.questIcon.size)
		nameplate.QuestIcons.Loot:Size(db.questIcon.size, db.questIcon.size)
		nameplate.QuestIcons.Skull:Size(db.questIcon.size + 4, db.questIcon.size + 4)
		nameplate.QuestIcons.Chat:Size(db.questIcon.size + 4, db.questIcon.size + 4)
	else
		if nameplate:IsElementEnabled('QuestIcons') then
			nameplate:DisableElement('QuestIcons')
		end
	end
end

function NP:Construct_ClassificationIndicator(nameplate)
	local ClassificationIndicator = nameplate:CreateTexture(nil, 'OVERLAY')

	return ClassificationIndicator
end

function NP:Update_ClassificationIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'FRIENDLY_NPC' or nameplate.frameType == 'ENEMY_NPC') and db.eliteIcon.enable then
		if not nameplate:IsElementEnabled('ClassificationIndicator') then
			nameplate:EnableElement('ClassificationIndicator')
		end

		nameplate.ClassificationIndicator:ClearAllPoints()
		nameplate.ClassificationIndicator:Size(db.eliteIcon.size, db.eliteIcon.size)

		nameplate.ClassificationIndicator:Point(E.InversePoints[db.eliteIcon.position], nameplate, db.eliteIcon.position, db.eliteIcon.xOffset, db.eliteIcon.yOffset)
	else
		if nameplate:IsElementEnabled('ClassificationIndicator') then
			nameplate:DisableElement('ClassificationIndicator')
		end
	end
end

function NP:Construct_TargetIndicator(nameplate)
	local TargetIndicator = CreateFrame('Frame', nameplate:GetDebugName()..'TargetIndicator', nameplate)
	TargetIndicator:SetFrameLevel(0)

	TargetIndicator.Shadow = CreateFrame('Frame', nil, TargetIndicator)
	TargetIndicator.Shadow:SetBackdrop({edgeFile = E.LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(5)})
	TargetIndicator.Shadow:Hide()

	for _, object in pairs({'Spark', 'TopIndicator', 'LeftIndicator', 'RightIndicator'}) do
		TargetIndicator[object] = TargetIndicator:CreateTexture(nil, 'BACKGROUND', nil, -5)
		TargetIndicator[object]:SetSnapToPixelGrid(false)
		TargetIndicator[object]:SetTexelSnappingBias(0)
		TargetIndicator[object]:Hide()
	end

	TargetIndicator.Spark:SetTexture(E.Media.Textures.Spark)
	TargetIndicator.TopIndicator:SetTexture(E.Media.Textures.NameplateTargetIndicator)
	TargetIndicator.LeftIndicator:SetTexture(E.Media.Textures.NameplateTargetIndicatorLeft)
	TargetIndicator.RightIndicator:SetTexture(E.Media.Textures.NameplateTargetIndicatorRight)

	return TargetIndicator
end

function NP:Update_TargetIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if nameplate.frameType == 'PLAYER' then
		if nameplate:IsElementEnabled('TargetIndicator') then
			nameplate:DisableElement('TargetIndicator')
		end
		return
	end

	if not nameplate:IsElementEnabled('TargetIndicator') then
		nameplate:EnableElement('TargetIndicator')
	end

	nameplate.TargetIndicator.style = NP.db.units.TARGET.glowStyle
	nameplate.TargetIndicator.lowHealthThreshold = NP.db.lowHealthThreshold

	if nameplate.TargetIndicator.style ~= 'none' then
		local GlowStyle, Color = NP.db.units.TARGET.glowStyle, NP.db.colors.glowColor

		if not db.health.enable and (GlowStyle ~= 'style2' and GlowStyle ~= 'style6' and GlowStyle ~= 'style8') then
			GlowStyle = 'style2'
			nameplate.TargetIndicator.style = 'style2'
		end

		if nameplate.TargetIndicator.TopIndicator and (GlowStyle == 'style3' or GlowStyle == 'style5' or GlowStyle == 'style6') then
			nameplate.TargetIndicator.TopIndicator:Point('BOTTOM', nameplate.Health, 'TOP', 0, -6)

			nameplate.TargetIndicator.TopIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end

		if (nameplate.TargetIndicator.LeftIndicator and nameplate.TargetIndicator.RightIndicator) and (GlowStyle == 'style4' or GlowStyle == 'style7' or GlowStyle == 'style8') then
			nameplate.TargetIndicator.LeftIndicator:Point('LEFT', nameplate.Health, 'RIGHT', -3, 0)
			nameplate.TargetIndicator.RightIndicator:Point('RIGHT', nameplate.Health, 'LEFT', 3, 0)

			nameplate.TargetIndicator.LeftIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
			nameplate.TargetIndicator.RightIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end

		if nameplate.TargetIndicator.Shadow and (GlowStyle == 'style1' or GlowStyle == 'style5' or GlowStyle == 'style7') then
			nameplate.TargetIndicator.Shadow:SetOutside(nameplate.Health, E:Scale(E.PixelMode and 6 or 8), E:Scale(E.PixelMode and 6 or 8))

			nameplate.TargetIndicator.Shadow:SetBackdropBorderColor(Color.r, Color.g, Color.b)
			nameplate.TargetIndicator.Shadow:SetAlpha(Color.a)
		end

		if nameplate.TargetIndicator.Spark and (GlowStyle == 'style2' or GlowStyle == 'style6' or GlowStyle == 'style8') then
			local scale = NP.db.units.TARGET.useScale and (NP.db.units.TARGET.scale >= .75 and NP.db.units.TARGET.scale or .75) or 1
			local size = (E.Border + 14) * scale;

			nameplate.TargetIndicator.Spark:Point('TOPLEFT', nameplate.Health, 'TOPLEFT', -(size * 2), size)
			nameplate.TargetIndicator.Spark:Point('BOTTOMRIGHT', nameplate.Health, 'BOTTOMRIGHT', (size * 2), -size)

			nameplate.TargetIndicator.Spark:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end
	end
end

function NP:Construct_Highlight(nameplate)
	local Highlight = CreateFrame('Frame', nameplate:GetDebugName()..'Highlight', nameplate)
	Highlight:Hide()
	Highlight:SetFrameLevel(9)

	Highlight.texture = Highlight:CreateTexture(nil, 'ARTWORK')
	Highlight.texture:SetSnapToPixelGrid(false)
	Highlight.texture:SetTexelSnappingBias(0)

	return Highlight
end

function NP:Update_Highlight(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if NP.db.highlight and db.enable then
		if not nameplate:IsElementEnabled('Highlight') then
			nameplate:EnableElement('Highlight')
		end

		if db.health.enable and not (db.nameOnly or nameplate.NameOnlyChanged) then
			nameplate.Highlight.texture:SetColorTexture(1, 1, 1, .3)
			nameplate.Highlight.texture:SetAllPoints(nameplate.Health)
			nameplate.Highlight.texture:SetAlpha(1)
		else
			nameplate.Highlight.texture:SetTexture(E.Media.Textures.Spark)
			nameplate.Highlight.texture:SetAllPoints(nameplate)
			nameplate.Highlight.texture:SetAlpha(.5)
		end
	else
		if nameplate:IsElementEnabled('Highlight') then
			nameplate:DisableElement('Highlight')
		end
	end
end

function NP:Construct_HealerSpecs(nameplate)
	local texture = nameplate:CreateTexture(nil, "OVERLAY")
	texture:Size(40, 40)
	texture:SetTexture(E.Media.Textures.Healer)
	texture:Hide()

	return texture
end

function NP:Update_HealerSpecs(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'FRIENDLY_PLAYER' or nameplate.frameType == 'ENEMY_PLAYER') and db.markHealers then
		if not nameplate:IsElementEnabled('HealerSpecs') then
			nameplate:EnableElement('HealerSpecs')
		end

		nameplate.HealerSpecs:Point("RIGHT", nameplate.Health, "LEFT", -6, 0)
	else
		if nameplate:IsElementEnabled('HealerSpecs') then
			nameplate:DisableElement('HealerSpecs')
		end
	end
end

function NP:Construct_FloatingCombatFeedback(nameplate)
	local FloatingCombatFeedback = CreateFrame("Frame", nil, nameplate)

	for i = 1, 12 do
		FloatingCombatFeedback[i] = FloatingCombatFeedback:CreateFontString(nil, "OVERLAY")
	end

	return FloatingCombatFeedback
end

function NP:Update_FloatingCombatFeedback(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if not db.floatingCombatFeedback then return end

	if db.floatingCombatFeedback.enable then
		if not nameplate:IsElementEnabled('FloatingCombatFeedback') then
			nameplate:EnableElement('FloatingCombatFeedback')
		end

		nameplate.FloatingCombatFeedback:SetPoint(db.floatingCombatFeedback.position)
		nameplate.FloatingCombatFeedback.mode = db.floatingCombatFeedback.mode
		nameplate.FloatingCombatFeedback.xOffset = db.floatingCombatFeedback.xOffset
		nameplate.FloatingCombatFeedback.yOffset = db.floatingCombatFeedback.yOffset
		nameplate.FloatingCombatFeedback.yDirection = db.floatingCombatFeedback.direction == "UP" and 1 or -1
		nameplate.FloatingCombatFeedback.scrollTime = 1.5

		for i = 1, 12 do
			nameplate.FloatingCombatFeedback[i]:FontTemplate(E.LSM:Fetch('font', db.floatingCombatFeedback.font), db.floatingCombatFeedback.fontSize, db.floatingCombatFeedback.fontOutline)
		end

	else
		if nameplate:IsElementEnabled('FloatingCombatFeedback') then
			nameplate:DisableElement('FloatingCombatFeedback')
		end
	end
end

function NP:Construct_Fader(nameplate)
	local Fader = {
		Target = true,
		Health = true,
		Combat = true,
		Power = true,
		Casting = true,
		Smooth = 1,
		Delay = 3,
		MaxAlpha = 1,
		MinAlpha = 0,
	}

	return Fader
end

function NP:Update_Fader(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (not db.visibility) or db.visibility.showAlways then
		if nameplate:IsElementEnabled('Fader') then
			nameplate:DisableElement('Fader')
		end
	else
		if not nameplate:IsElementEnabled('Fader') then
			nameplate:EnableElement('Fader')
		end

		nameplate.Fader.Combat = db.visibility.showInCombat
		nameplate.Fader.Target = db.visibility.showWithTarget
		nameplate.Fader.Health = true
		nameplate.Fader.Power = true
		nameplate.Fader.Casting = true
		nameplate.Fader.Smooth = 1
		nameplate.Fader.Delay = db.visibility.hideDelay
		nameplate.Fader.MaxAlpha = 1
		nameplate.Fader.MinAlpha = 0
	end
end

function NP:Construct_Cutaway(nameplate)
	local Cutaway = CreateFrame('Frame', nameplate:GetDebugName()..'Cutaway', nameplate)

	Cutaway.Health = CreateFrame('StatusBar', nameplate:GetDebugName()..'CutawayHealth', nameplate.Health)
	Cutaway.Health:SetAllPoints()
	Cutaway.Health:SetFrameLevel(4)
	Cutaway.Health:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', NP.db.statusbar))
	NP.StatusBars[Cutaway.Health] = true

	Cutaway.Power = CreateFrame('StatusBar', nameplate:GetDebugName()..'CutawayPower', nameplate.Power)
	Cutaway.Power:SetAllPoints()
	Cutaway.Power:SetFrameLevel(4)
	Cutaway.Power:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', NP.db.statusbar))
	NP.StatusBars[Cutaway.Power] = true

	return Cutaway
end
