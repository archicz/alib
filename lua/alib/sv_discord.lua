if not util.IsBinaryModuleInstalled("gwsockets") then return end
if not util.IsBinaryModuleInstalled("chttp") then return end

require("gwsockets")
require("chttp")

discord =
{
	gateway = "wss://gateway.discord.gg/?v=10&encoding=json",
	messages = "https://discordapp.com/api/channels/{ChannelID}/messages",
	message = "https://discordapp.com/api/channels/{ChannelID}/messages/{MessageID}",
	role = "https://discordapp.com/api/guilds/{GuildID}/members/{MemberID}/roles/{RoleID}",
	interaction = "https://discord.com/api/v10/interactions/{InteractionID}/{InteractionToken}/callback"
}

local DiscordIncomingInteraction = {}
DiscordIncomingInteraction.__index = DiscordIncomingInteraction

function DiscordIncomingInteraction:GetID()
	return self.data.custom_id
end

function DiscordIncomingInteraction:GetGuild()
	return self.guild.id
end

function DiscordIncomingInteraction:GetUserID()
	return self.member.user.id
end

function DiscordIncomingInteraction:GetUserName()
	return self.member.user.global_name
end

function DiscordIncomingInteraction:GetUserRoles()
	return self.member.roles
end

function DiscordIncomingInteraction:GetValue(id)
	if not self.data.components then return nil end

	for _, actionRow in pairs(self.data.components) do
		for _, component in pairs(actionRow.components) do
			if component.custom_id == id then
				return component.value
			end
		end
	end

	return nil
end



local DiscordIncomingMessage = {}
DiscordIncomingMessage.__index = DiscordIncomingMessage

function DiscordIncomingMessage:GetText()
	return self.content
end

function DiscordIncomingMessage:IsAuthorBot()
	return self.author.bot or false
end

function DiscordIncomingMessage:GetAuthorID()
	return self.author.id
end

function DiscordIncomingMessage:GetAuthorName()
	return self.author.global_name
end

function DiscordIncomingMessage:GetAuthorRoles()
	return self.member.roles
end



local DiscordMessageEmbed = {}
DiscordMessageEmbed.__index = DiscordMessageEmbed

function DiscordMessageEmbed:New(title, desc, clr)
	local function ColorToInt(clr)
		local r = math.Clamp(clr.r, 0, 255)
		local g = math.Clamp(clr.g, 0, 255)
		local b = math.Clamp(clr.b, 0, 255)

		return bit.bor(bit.lshift(r, 16), bit.lshift(g, 8), b)
	end

	self.title = title
	self.description = desc
	self.fields = {}

	if clr then
		self.color = ColorToInt(clr)
	end
end

function DiscordMessageEmbed:AddField(name, value)
	local field =
	{
		name = name,
		value = value
	}
	
	table.insert(self.fields, field)
end

function DiscordMessageEmbed:SetImage(url)
	self.image = {}
	self.image.url = url
end



local DiscordMessage = {}
DiscordMessage.__index = DiscordMessage

function DiscordMessage:New(bot)
	self.bot = bot
	self.msgData = {}
	self.msgData.embeds = {}
	self.msgData.components = {}
	self.msgData.attachments = {}
end

function DiscordMessage:SetText(txt)
	self.msgData.content = txt
end

function DiscordMessage:NewEmbed(title, desc, clr)
	local instance = {}
	setmetatable(instance, DiscordMessageEmbed)
	instance:New(title, desc, clr)

	table.insert(self.msgData.embeds, instance)
	return instance
end



local DiscordMessageActionRow = {}
DiscordMessageActionRow.__index = DiscordMessageActionRow

function DiscordMessageActionRow:New()
	self.type = 1
	self.components = {}
end

function DiscordMessageActionRow:AddButton(id, label, style, url)
	local btn =
	{
		type = 2,
		style = style,
		label = label,
		url = url,
		custom_id = id
	}

	table.insert(self.components, btn)
end

function DiscordMessage:NewActionRow()
	local instance = {}
	setmetatable(instance, DiscordMessageActionRow)
	instance:New()

	table.insert(self.msgData.components, instance)
	return instance
end

function DiscordMessage:Send(channelId, onSuccess)
	self.bot:SendMessage(channelId, self.msgData, onSuccess)
end



local DiscordInteractionCallback = {}
DiscordInteractionCallback.__index = DiscordInteractionCallback

DISCORD_IN_RESPONSE_MESSAGE = 4
DISCORD_IN_RESPONSE_MODAL = 9

function DiscordInteractionCallback:New(bot, data)
	self.bot = bot
	self.id = data.id
	self.token = data.token
	self.response = {}
	self.response.data = {}
end

local DiscordInteractionCallbackMessage = {}
DiscordInteractionCallbackMessage.__index = DiscordInteractionCallbackMessage

function DiscordInteractionCallback:SetText(txt)
	self.response.data.content = txt
end

function DiscordInteractionCallback:MakeEphemeral()
	self.response.data.flags = 64
end

function DiscordInteractionCallback:MakeMessageResponse()
	self.response.type = DISCORD_IN_RESPONSE_MESSAGE
end

function DiscordInteractionCallback:MakeModalResponse(id, title)
	self.response.type = DISCORD_IN_RESPONSE_MODAL
	self.response.data.custom_id = id
	self.response.data.title = title
	self.response.data.components = {}
end

function DiscordInteractionCallback:AddTextInput(id, label, style, minLength, maxLength, placeholder, required)
	local textInput = 
	{
		type = 4,
		custom_id = id,
		label = label,
		style = style,
		min_length = minLength,
		max_length = maxLength,
		placeholder = placeholder,
		required = required
	}

	local actionRow =
	{
		type = 1,
		components = 
		{
			textInput
		}
	}

	table.insert(self.response.data.components, actionRow)
end

function DiscordInteractionCallback:Send()
	self.bot:SendInteractionCallback(self.id, self.token, self.response)
end



local DiscordBot = {}
DiscordBot.__index = DiscordBot

-- DISCORD_OP_HEARTBEAT_ACK = 11
DISCORD_OP_HELLO = 10
DISCORD_OP_HEARTBEAT = 1
DISCORD_OP_EVENT = 0

DISCORD_EV_READY = "READY"
DISCORD_EV_MESSAGE_CREATE = "MESSAGE_CREATE"
DISCORD_EV_INTERACTION_CREATE = "INTERACTION_CREATE"

DISCORD_IN_MESSAGE_COMPONENT = 3
DISCORD_IN_MODAL_SUBMIT = 5

DISCORD_BOT_RECONNECT_SECS = 2

function DiscordBot:New(token, intents, presenceText)
	local webSocket = GWSockets.createWebSocket(discord.gateway)

	function webSocket.onMessage(ws, message)
		local data = util.JSONToTable(message)
		if not data then return end

		if data.s then
			self.sequence = data.s
		end

		local interactionHandlers = 
		{
			[DISCORD_IN_MESSAGE_COMPONENT] = function()
				setmetatable(data.d, DiscordIncomingInteraction)
				self:OnMessageInteraction(data.d)
			end,

			[DISCORD_IN_MODAL_SUBMIT] = function()
				setmetatable(data.d, DiscordIncomingInteraction)
				self:OnModalInteraction(data.d)
			end
		}

		local eventHandlers =
		{
			[DISCORD_EV_READY] = function()
				self.sessionId = data.d.session_id
			end,

			[DISCORD_EV_MESSAGE_CREATE] = function()
				setmetatable(data.d, DiscordIncomingMessage)
				self:OnMessage(data.d)
			end,

			[DISCORD_EV_INTERACTION_CREATE] = function()
				local interactionHandler = interactionHandlers[data.d.type]
				if interactionHandler then
					print("interactionHandler status:", pcall(interactionHandler))
				end
			end
		}

		local opHandlers = 
		{
			[DISCORD_OP_HELLO] = function()
				if self.sessionId then
					self:SendResume()
				else
					self:SendIdentify()
				end

				self:StartHeartbeat(data.d.heartbeat_interval)
				self:OnConnected()
			end,

			[DISCORD_OP_HEARTBEAT] = function()
				self:SendHeartbeat()
			end,

			[DISCORD_OP_EVENT] = function()
				local eventHandler = eventHandlers[data.t]
				if eventHandler then
					pcall(eventHandler)
				end
			end
		}

		local opHandler = opHandlers[data.op]
		if opHandler then
			print("opHandler status:", pcall(opHandler))
		end
	end

	function webSocket.onError(ws, err)
	end 

	function webSocket.onConnected(ws)
	end 

	function webSocket.onDisconnected(ws)
		self:OnDisconnected()
		self:StopHeartbeat()
		
		timer.Simple(DISCORD_BOT_RECONNECT_SECS, function()
			self:Connect()
		end)
	end

	self.webSocket = webSocket
	self.token = token
	self.intents = intents
	self.presenceText = presenceText
	self.timerName = "DiscordBotHeartbeat" .. util.SHA256(token):sub(1, 6)
end

function DiscordBot:NewMessage()
	local instance = {}
	setmetatable(instance, DiscordMessage)
	instance:New(self)

	return instance
end

function DiscordBot:NewInteractionCallback(data)
	local instance = {}
	setmetatable(instance, DiscordInteractionCallback)
	instance:New(self, data)

	return instance
end

function DiscordBot:WriteJSON(tbl)
	if not tbl then return end

	local json = json.Encode(tbl)
	self.webSocket:write(json)
end

function DiscordBot:SendResume()
	local resume =
	{
		op = 6,
		d =
		{
			token = self.token,
			session_id = self.sessionId,
			seq = self.sequence
		}
	}
	
	self:WriteJSON(resume)
end

function DiscordBot:SendIdentify()
	local identify =
	{
		op = 2,
		d =
		{
			token = self.token,
			properties =
			{
				os = "windows",
				browser = "gmod",
				device = "gmod"
			},
			compress = false,
			large_threshold = 250,
			intents = self.intents,
			presence = 
			{
				activities = 
				{
					{
						name = self.presenceText,
						type = 0
					}
				},
				status = "online",
				since = os.time(),
				afk = false
			}
		}
	}
	
	self:WriteJSON(identify)
end

function DiscordBot:SendHeartbeat()
	local heartbeat =
	{
		op = 1,
		d = self.sequence
	}

	self:WriteJSON(heartbeat)
end

function DiscordBot:SendInteractionCallback(interactionId, interactionToken, data)
	local apiURL = string.Interpolate(discord.interaction,
	{
		["InteractionID"] = interactionId,
		["InteractionToken"] = interactionToken
	})

	local httpStruct = 
	{
		method = "POST",
		url = apiURL,
		parameters = msgStruct,
		body = json.Encode(data),
		headers =
		{
			["Authorization"] = "Bot " .. self.token,
		},
		type = "application/json",
	}

	CHTTP(httpStruct)
end

function DiscordBot:SendMessage(channelId, msgData, onSuccess)
	local apiURL = string.Interpolate(discord.messages,
	{
		["ChannelID"] = tostring(channelId)
	})

	local httpStruct = 
	{
		success = function(code, body)
			if not onSuccess then return end

			local msgInfo = util.JSONToTable(body)
			pcall(onSuccess, self, msgInfo)
		end,
		method = "POST",
		url = apiURL,
		parameters = msgStruct,
		body = json.Encode(msgData),
		headers =
		{
			["Authorization"] = "Bot " .. self.token
		},
		type = "application/json",
	}

	CHTTP(httpStruct)
end

function DiscordBot:DeleteMessage(channelId, msgId)
	local apiURL = string.Interpolate(discord.message,
	{
		["ChannelID"] = tostring(channelId),
		["MessageID"] = tostring(msgId)
	})

	local httpStruct = 
	{
		method = "DELETE",
		url = apiURL,
		headers =
		{
			["Authorization"] = "Bot " .. self.token
		},
		type = "application/json",
	}

	CHTTP(httpStruct)
end

function DiscordBot:GetMessages(channelId, onSuccess)
	local apiURL = string.Interpolate(discord.messages,
	{
		["ChannelID"] = tostring(channelId)
	})

	local httpStruct = 
	{
		success = function(code, body)
			local messages = util.JSONToTable(body)

			for _, message in pairs(messages) do
				setmetatable(message, DiscordIncomingMessage)
			end

			pcall(onSuccess, self, messages)
		end,
		method = "GET",
		url = apiURL,
		headers =
		{
			["Authorization"] = "Bot " .. self.token
		},
		type = "application/json",
	}

	CHTTP(httpStruct)
end

function DiscordBot:AddRole(guildId, userId, roleId)
	local apiURL = string.Interpolate(discord.role,
	{
		["GuildID"] = tostring(guildId),
		["MemberID"] = tostring(userId),
		["RoleID"] = tostring(roleId)
	})

	local httpStruct =
	{
		url = apiURL,
		method = "PUT",
		headers =
		{
			["Authorization"] = "Bot " .. self.token
		},
		type = "application/json",
	}

	CHTTP(httpStruct)
end

function DiscordBot:RemoveRole(guildId, userId, roleId)
	local apiURL = string.Interpolate(discord.role,
	{
		["GuildID"] = tostring(guildId),
		["MemberID"] = tostring(userId),
		["RoleID"] = tostring(roleId)
	})

	local httpStruct =
	{
		url = apiURL,
		method = "DELETE",
		headers =
		{
			["Authorization"] = "Bot " .. self.token
		},
		type = "application/json",
	}

	CHTTP(httpStruct)
end

function DiscordBot:StartHeartbeat(interval)
	timer.Create(self.timerName, interval / 1000, 0, function()
		self:SendHeartbeat()
	end)
end

function DiscordBot:StopHeartbeat()
	timer.Remove(self.timerName)
end

function DiscordBot:Connect()
	if self.webSocket then
		self.webSocket:open()
	end
end

function DiscordBot:Disconnect()
	if self.webSocket then
		self.webSocket:close()
	end
end

function DiscordBot:OnConnected()
end

function DiscordBot:OnDisconnected()
end

function DiscordBot:OnMessage(message)
end

function DiscordBot:OnMessageInteraction(interaction)
end

function DiscordBot:OnModalInteraction(interaction)
end

function discord.CreateBot(...)
	local instance = {}
	setmetatable(instance, DiscordBot)
	instance:New(...)

	return instance
end