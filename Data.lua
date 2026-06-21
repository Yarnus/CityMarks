local _, addon = ...

local ICON = {
    auction = "Interface\\Minimap\\Tracking\\Auctioneer",
    bank = "Interface\\Minimap\\Tracking\\Banker",
    barber = "Interface\\Minimap\\Tracking\\Barbershop",
    flight = "Interface\\Minimap\\Tracking\\FlightMaster",
    inn = "Interface\\Minimap\\Tracking\\Innkeeper",
    portal = "Interface\\Icons\\Spell_Arcane_PortalDalaran",
    profession = "Interface\\Minimap\\Tracking\\Profession",
    stable = "Interface\\Minimap\\Tracking\\StableMaster",
    upgrade = "Interface\\Icons\\UI_ItemUpgrade",
}

local function marker(x, y, key, icon, professionID, color, solo)
    return {
        x = x,
        y = y,
        key = key,
        icon = icon or "Interface\\Icons\\INV_Misc_Map02",
        professionID = professionID,
        color = color,
        solo = solo,
    }
end

local function profession(x, y, key, professionID)
    return marker(x, y, key, ICON.profession, professionID, "40ff70")
end

addon.CityOrder = {2393, 2339, 2472, 2112, 627, 85, 84}

addon.Cities = {
    [84] = {
        name = "STORMWIND",
        scale = 1,
        markers = {
            marker(.6179, .7300, "AUCTION_HOUSE", ICON.auction),
            marker(.6224, .7653, "BANK", ICON.bank),
            marker(.4924, .8420, "PORTAL_ROOM", ICON.portal),
        },
    },
    [85] = {
        name = "ORGRIMMAR",
        scale = 1,
        markers = {
            marker(.5400, .7300, "AUCTION_HOUSE", ICON.auction),
            marker(.4900, .8200, "BANK", ICON.bank),
        },
    },
    [627] = {
        name = "DALARAN",
        scale = 1.15,
        markers = {
            marker(.5532, .2398, "PORTAL_ORGRIMMAR", ICON.portal),
            marker(.3915, .6301, "PORTAL_STORMWIND", ICON.portal),
            marker(.4757, .7031, "BAZAAR", ICON.portal),
            marker(.4446, .7438, "BANK", ICON.bank, nil, "ffd84a"),
            marker(.4765, .8917, "REMIX_VENDORS", "Interface\\GossipFrame\\AvailableQuestIcon"),
        },
    },
    [2339] = {
        name = "DORNOGAL",
        scale = 1.35,
        markers = {
            marker(.5886, .5141, "BARBER", ICON.barber, nil, nil, true),
            marker(.4542, .4751, "INN", ICON.inn, nil, nil, true),
            marker(.5250, .4541, "BANK", ICON.bank, nil, "ffd84a", true),
            marker(.5581, .4860, "AUCTION_HOUSE", ICON.auction, nil, nil, true),
            marker(.5796, .5648, "CRAFTING_ORDERS", "Interface\\Icons\\INV_Misc_Note_06", nil, nil, true),
            marker(.5166, .4206, "UPGRADES", ICON.upgrade, nil, nil, true),
            marker(.4792, .6789, "ROSTRUM", "Interface\\Icons\\Ability_Mount_Drake_Azure", nil, nil, true),
            marker(.4460, .5591, "TRADING_POST", "Interface\\Icons\\TradingPostCurrency", nil, "8fcfff", true),
            marker(.5545, .7718, "TRAINING_DUMMIES", "Interface\\Icons\\Achievement_LegionPVP2Tier3", nil, "ff5050"),
            marker(.4111, .2289, "PORTAL_STORMWIND", ICON.portal, nil, nil, true),
            marker(.3829, .2713, "PORTAL_ORGRIMMAR", ICON.portal, nil, nil, true),
            marker(.5386, .3872, "M_PLUS", "Interface\\Icons\\Spell_Shadow_Teleport", nil, nil, true),
            marker(.4415, .4583, "COOKING", "Interface\\Icons\\INV_Misc_Food_15", nil, "40ff70", true),
            marker(.5048, .2684, "FISHING", "Interface\\Icons\\UI_Profession_Fishing", nil, "40ff70", true),
            profession(.4728, .7045, "ALCHEMY", 171),
            profession(.4907, .6320, "BLACKSMITHING", 164),
            profession(.4862, .7116, "INSCRIPTION", 773),
            profession(.5246, .7129, "ENCHANTING", 333),
            profession(.4905, .5606, "ENGINEERING", 202),
            profession(.4956, .7116, "JEWELCRAFTING", 755),
            profession(.5451, .5894, "LEATHERWORKING", 165),
            profession(.5466, .6337, "TAILORING", 197),
        },
    },
    [2112] = {
        name = "VALDRAKKEN",
        scale = 1.35,
        markers = {
            marker(.5518, .5736, "BANK", ICON.bank, nil, "ffd84a", true),
            marker(.4265, .5979, "AUCTION_HOUSE", ICON.auction, nil, nil, true),
            marker(.4744, .4666, "INN", ICON.inn, nil, nil, true),
            marker(.3486, .6161, "CRAFTING_ORDERS", "Interface\\Icons\\INV_Misc_Note_06", nil, nil, true),
            marker(.4100, .4420, "PVP", "Interface\\Icons\\Achievement_LegionPVP2Tier3", nil, "ff5050", true),
            marker(.4424, .6784, "FLIGHT_MASTER", ICON.flight),
            marker(.3842, .3721, "PRIMAL_VENDORS", "Interface\\GossipFrame\\AvailableQuestIcon"),
            marker(.4690, .7890, "STABLE", ICON.stable),
            marker(.5815, .4005, "PORTALS", ICON.portal, nil, nil, true),
            marker(.2604, .4082, "BADLANDS_PORTAL", ICON.portal),
            marker(.2503, .5059, "ROSTRUM", "Interface\\Icons\\Ability_Mount_Drake_Azure", nil, nil, true),
            marker(.4489, .7488, "FISHING", "Interface\\Icons\\UI_Profession_Fishing", nil, "40ff70", true),
            profession(.3672, .7220, "ALCHEMY", 171),
            profession(.3639, .5024, "BLACKSMITHING", 164),
            profession(.3083, .5972, "ENCHANTING", 333),
            profession(.4229, .4883, "ENGINEERING", 202),
            profession(.3961, .7373, "INSCRIPTION", 773),
            profession(.4081, .6055, "JEWELCRAFTING", 755),
            profession(.2852, .6079, "LEATHERWORKING", 165),
            profession(.3188, .6768, "TAILORING", 197),
        },
    },
    [2472] = {
        name = "TAZAVESH",
        scale = 1,
        markers = {
            marker(.4065, .2911, "RENOWN", "Interface\\GossipFrame\\AvailableQuestIcon"),
            marker(.4107, .2516, "INN", ICON.inn, nil, nil, true),
            marker(.4736, .2679, "STABLE", ICON.stable),
            marker(.4899, .2021, "PORTALS", ICON.portal),
            marker(.4352, .0818, "ALDANI", "Interface\\GossipFrame\\AvailableQuestIcon"),
            marker(.3657, .1351, "TAZAVESH", "Interface\\GossipFrame\\AvailableQuestIcon"),
            marker(.4680, .5683, "PHASE_DIVING", "Interface\\Icons\\Spell_Arcane_PrismaticCloak"),
            marker(.3864, .5102, "KYVEZA", "Interface\\GossipFrame\\AvailableQuestIcon"),
        },
    },
    [2393] = {
        name = "SILVERMOON",
        scale = 1.35,
        markers = {
            marker(.4993, .6454, "BANK", ICON.bank, nil, "ffd84a", true),
            marker(.4861, .6198, "UPGRADES", ICON.upgrade, nil, nil, true),
            marker(.5150, .7468, "AUCTION_HOUSE", ICON.auction, nil, nil, true),
            marker(.7256, .6455, "BANK", ICON.bank, nil, "ffd84a", true),
            marker(.5337, .6631, "PORTALS", ICON.portal, nil, nil, true),
            marker(.4019, .6519, "CATALYST", "Interface\\Icons\\INV_10_EnchantedElements_Mote", nil, nil, true),
            marker(.5628, .7033, "INN", ICON.inn, nil, nil, true),
            marker(.4318, .7823, "BARBER", ICON.barber, nil, nil, true),
            marker(.5250, .7821, "DELVES", "Interface\\Icons\\UI_Delves"),
            marker(.4505, .5559, "CRAFTING_ORDERS", "Interface\\Icons\\INV_Misc_Note_06", nil, nil, true),
            marker(.4203, .5830, "M_PLUS", "Interface\\Icons\\Spell_Shadow_Teleport", nil, nil, true),
            marker(.4888, .7815, "TRADING_POST", "Interface\\Icons\\TradingPostCurrency", nil, "8fcfff", true),
            marker(.3409, .8111, "PVP", "Interface\\Icons\\Achievement_LegionPVP2Tier3", nil, "ff5050"),
            profession(.4702, .5188, "ALCHEMY", 171),
            profession(.4374, .5133, "BLACKSMITHING", 164),
            profession(.4678, .5148, "INSCRIPTION", 773),
            profession(.4797, .5363, "ENCHANTING", 333),
            profession(.4003, .5283, "ENGINEERING", 202),
            profession(.4793, .5515, "JEWELCRAFTING", 755),
            profession(.4315, .5570, "LEATHERWORKING", 165),
            profession(.4825, .5415, "TAILORING", 197),
        },
    },
}
