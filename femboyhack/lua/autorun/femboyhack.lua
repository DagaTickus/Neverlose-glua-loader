local PANEL = {}

function PANEL:Init()
    self:SetSize(600, 445)
    self:SetPos(ScrW() / 2 - 300, ScrH() / 2 - 222.5)
    self:MakePopup()
    self.bgColor = Color(7, 19, 34)
    self.cornerRadius = 16
    self.SmoothX, self.SmoothY = self:GetPos()
    self.TargetX, self.TargetY = self.SmoothX, self.SmoothY 
    self.Dragging = false
    self.DragOffset = {x = 0, y = 0}

    self.FontTitle = "DermaLarge"
    self.FontSubtitle = "DermaDefault"
    self.FontMenu = "HudSelectionText"
    self.TextColor = Color(168, 191, 204)

    self.ImageMaterial = Material("neverll/neverlogo.png", "noclamp smooth")
    self.ImagePosition = {x = 20, y = 20}
    self.ImageSize = {w = 100, h = 100}

    self.Elements = {}
    self:CreateCloseButtons()
    self.MenuItems = {"Website", "Support", "Market"}
    self.MenuStartY = 110
    self.MenuSpacing = 40

    self.ProfileName = nil 
    self.ProfilePictureSize = 50
    self.ProfilePosition = {x = 20, y = self:GetTall() - 70}

    self.SubscriptionTitle = "Subscription"
    self.SubscriptionSubtitle = "Available subscriptions"
    self.Subscriptions = {
        {
            Title = "Garry's Mod",
            Expiry = "Expires when skibidi govno",
            Icon = Material("neverll/csgo.png", "noclamp smooth")
        }
    }
    self.SubscriptionBoxHeight = 60
    self.SubscriptionBoxSpacing = 15

    self.IsLoading = false

    self:CreateAvatar()
    self:FetchSteamName()
    self:AddSubscriptionPanels()
end

function PANEL:CreateCloseButtons()
    self.CloseButton1 = self:Add("DButton")
    self.CloseButton1:SetSize(16, 16)
    self.CloseButton1:SetPos(self:GetWide() - 36, 12)
    self.CloseButton1:SetText("")
    self.CloseButton1.DoClick = function()
        self:Remove()
    end
    self.CloseButton1.Paint = function(btn, w, h)
        local closeIcon = Material("neverll/close.png", "noclamp smooth")
        surface.SetMaterial(closeIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.CloseButton2 = self:Add("DButton")
    self.CloseButton2:SetSize(16, 16)
    self.CloseButton2:SetPos(self:GetWide() - 60, 12)
    self.CloseButton2:SetText("")
    self.CloseButton2.DoClick = function()
        self:Remove()
    end
    self.CloseButton2.Paint = function(btn, w, h)
        local closeIcon = Material("neverll/nedoclose.png", "noclamp smooth")
        surface.SetMaterial(closeIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(0, 0, w, h)
    end
end

function PANEL:CreateAvatar()
    local avatar = vgui.Create("AvatarImage", self)
    avatar:SetSize(self.ProfilePictureSize, self.ProfilePictureSize)
    avatar:SetPos(self.ProfilePosition.x, self.ProfilePosition.y)
    avatar:SetPlayer(LocalPlayer(), 64)
end

function PANEL:FetchSteamName()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    steamworks.RequestPlayerInfo(ply:SteamID64(), function(name)
        if IsValid(self) then
            self.ProfileName = name or "Unknown"
        end
    end)
end

function PANEL:AddSubscriptionPanels()
    for i, sub in ipairs(self.Subscriptions) do
        local panel = vgui.Create("DPanel", self)
        panel:SetSize(self:GetWide() - 200, self.SubscriptionBoxHeight)
        panel:SetPos(160, 100 + (i - 1) * (self.SubscriptionBoxHeight + self.SubscriptionBoxSpacing))
        panel.Paint = function(pnl, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(10, 25, 50))
            surface.SetFont(self.FontMenu)
            surface.SetTextColor(168, 191, 204)
            surface.SetTextPos(10, 10)
            surface.DrawText(sub.Title)
            surface.SetFont(self.FontSubtitle)
            surface.SetTextPos(10, 30)
            surface.DrawText(sub.Expiry)
            surface.SetMaterial(sub.Icon)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(w - 50, 10, 40, 40)
        end

        panel.OnMousePressed = function(_, mouseCode)
            if mouseCode == MOUSE_LEFT then
                self:TriggerLoading()
            end
        end

        self.Elements[#self.Elements + 1] = panel
    end
end

function PANEL:Think()
    if self.Dragging then
        local mouseX, mouseY = gui.MousePos()
        self.TargetX = mouseX - self.DragOffset.x
        self.TargetY = mouseY - self.DragOffset.y
    end
    self.SmoothX = Lerp(0.1, self.SmoothX, self.TargetX)
    self.SmoothY = Lerp(0.1, self.SmoothY, self.TargetY)
    self:SetPos(self.SmoothX, self.SmoothY)
end

function PANEL:OnMousePressed(mouseCode)
    if mouseCode == MOUSE_LEFT then
        local mouseX, mouseY = gui.MousePos()
        local x, y = self:GetPos()
        self.Dragging = true
        self.DragOffset.x = mouseX - x
        self.DragOffset.y = mouseY - y
    end
end

function PANEL:OnMouseReleased(mouseCode)
    if mouseCode == MOUSE_LEFT then
        self.Dragging = false
    end
end

function PANEL:Paint(width, height)
    draw.RoundedBox(self.cornerRadius, 0, 0, width, height, self.bgColor)

    if not self.IsLoading then
        surface.SetMaterial(self.ImageMaterial)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(self.ImagePosition.x, self.ImagePosition.y, self.ImageSize.w, self.ImageSize.h)

        surface.SetFont(self.FontTitle)
        surface.SetTextColor(self.TextColor.r, self.TextColor.g, self.TextColor.b, 255)
        surface.SetTextPos(160, 20)
        surface.DrawText(self.SubscriptionTitle)

        surface.SetFont(self.FontSubtitle)
        surface.SetTextPos(160, 60)
        surface.DrawText(self.SubscriptionSubtitle)

        surface.SetFont(self.FontMenu)
        local menuX, menuY = 20, self.MenuStartY
        for _, menuItem in ipairs(self.MenuItems) do
            surface.SetTextPos(menuX, menuY)
            surface.DrawText(menuItem)
            menuY = menuY + self.MenuSpacing
        end
    else
        surface.SetFont(self.FontTitle)
        surface.SetTextColor(self.TextColor.r, self.TextColor.g, self.TextColor.b, 255)
        surface.SetTextPos(width / 2 - 50, height / 2 - 20)
        surface.DrawText("Loading...")
    end

    surface.SetFont(self.FontMenu)
    surface.SetTextPos(self.ProfilePosition.x + self.ProfilePictureSize + 10, self.ProfilePosition.y + 15)
    surface.DrawText(self.ProfileName or "Loading...")
end

function PANEL:TriggerLoading()
    self.IsLoading = true

    for _, element in ipairs(self.Elements) do
        if IsValid(element) then
            element:SetVisible(false)
        end
    end

    timer.Simple(3, function()
        if IsValid(self) then
            self:Remove()
        end
    end)
end

vgui.Register("SubscriptionMenu", PANEL, "EditablePanel")

concommand.Add("femboyhack", function()
    if IsValid(_G.SubscriptionMenuInstance) then
        _G.SubscriptionMenuInstance:Remove()
    end

    local frame = vgui.Create("SubscriptionMenu")
    _G.SubscriptionMenuInstance = frame
end)