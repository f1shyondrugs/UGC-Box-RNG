local Config = {}

Config.Rarities = {
    Common = { Color = Color3.fromRGB(150, 150, 150) },
    Uncommon = { Color = Color3.fromRGB(50, 200, 50) },
    Rare = { Color = Color3.fromRGB(50, 100, 255) },
    Epic = { Color = Color3.fromRGB(150, 50, 255) },
    Legendary = { Color = Color3.fromRGB(255, 150, 50) },
    Mythical = { Color = Color3.fromRGB(255, 50, 150) },
    Celestial = { Color = Color3.fromRGB(0, 255, 255) },
    Divine = { Color = Color3.fromRGB(255, 255, 100) },
    Transcendent = { Color = Color3.fromRGB(255, 100, 255) },
    Ethereal = { Color = Color3.fromRGB(220, 220, 255) },
    Quantum = { Color = Color3.fromRGB(50, 20, 80) },
}

Config.Items = {
    -- Common UGC Items (R$ 10 - 50)
    ["Basic Cap"] = { 
        Rarity = "Common", 
        Value = 10, 
        AssetId = 12608560678,
        Type = "Hat",
        Description = "A simple cap perfect for everyday wear."
    },
    ["Plain T-Shirt"] = { 
        Rarity = "Common", 
        Value = 15, 
        AssetId = 7867838611,
        Type = "Shirt",
        Description = "A basic t-shirt in classic white."
    },
    ["Simple Pants"] = { 
        Rarity = "Common", 
        Value = 20, 
        AssetId = 1804739,
        Type = "Pants",
        Description = "Comfortable everyday pants."
    },
    ["Basic Glasses"] = { 
        Rarity = "Common", 
        Value = 25, 
        AssetId = 12568844178,
        Type = "Face",
        Description = "Simple reading glasses for a smart look."
    },
    ["School Backpack"] = { 
        Rarity = "Common", 
        Value = 30, 
        AssetId = 15750709511,
        Type = "Back",
        Description = "A practical backpack for carrying your belongings."
    },
    ["White Sneakers"] = { 
        Rarity = "Common", 
        Value = 35, 
        AssetId = 13905362703,
        Type = "Shoes",
        Description = "Clean white sneakers for any occasion."
    },

    -- Uncommon UGC Items (R$ 50 - 250)
    ["Stylish Hat"] = { 
        Rarity = "Uncommon", 
        Value = 55, 
        AssetId = 95868078367137,
        Type = "Hat",
        Description = "A trendy hat that stands out from the crowd."
    },
    ["Cool Hoodie"] = { 
        Rarity = "Uncommon", 
        Value = 75, 
        AssetId = 14784743786,
        Type = "Shirt",
        Description = "A comfortable hoodie with a modern design."
    },
    ["Designer Jeans"] = { 
        Rarity = "Uncommon", 
        Value = 90, 
        AssetId = 93307791450624,
        Type = "Pants",
        Description = "Stylish jeans with premium denim fabric."
    },
    ["Sunglasses"] = { 
        Rarity = "Uncommon", 
        Value = 110, 
        AssetId = 15171164330,
        Type = "Face",
        Description = "Cool sunglasses that block out the haters."
    },
    ["Sports Watch"] = { 
        Rarity = "Uncommon", 
        Value = 150, 
        AssetId = 15713273681,
        Type = "Front",
        Description = "A digital sports watch for tracking your activities."
    },
    ["Leather Jacket"] = { 
        Rarity = "Uncommon", 
        Value = 200, 
        AssetId = 7192549218,
        Type = "Shirt",
        Description = "A classic leather jacket that never goes out of style."
    },

    -- Rare UGC Items (R$ 250 - 1,000)
    ["Gaming Headset"] = { 
        Rarity = "Rare", 
        Value = 260, 
        AssetId = 6097845436,
        Type = "Hat",
        Description = "Professional gaming headset with crystal clear audio."
    },
    ["Neon Jacket"] = { 
        Rarity = "Rare", 
        Value = 350, 
        AssetId = 14971476921,
        Type = "Shirt",
        Description = "A futuristic jacket that glows with neon colors."
    },
    ["Cargo Pants"] = { 
        Rarity = "Rare", 
        Value = 450, 
        AssetId = 18522156233,
        Type = "Pants",
        Description = "Tactical cargo pants with multiple pockets."
    },
    ["VR Goggles"] = { 
        Rarity = "Rare", 
        Value = 600, 
        AssetId = 11989097369,
        Type = "Face",
        Description = "Virtual reality goggles that transport you to other worlds."
    },
    ["Holographic Visor"] = { 
        Rarity = "Rare", 
        Value = 800, 
        AssetId = 5618036089,
        Type = "Hat",
        Description = "A high-tech visor with holographic display capabilities."
    },
    ["Jetpack"] = { 
        Rarity = "Rare", 
        Value = 1000, 
        AssetId = 5768738455,
        Type = "Back",
        Description = "A personal jetpack for aerial adventures."
    },

    -- Epic UGC Items (R$ 1,000 - 5,000)
    ["Crown"] = { 
        Rarity = "Epic", 
        Value = 1200, 
        AssetId = 14943768260,
        Type = "Hat",
        Description = "A royal crown fit for a king or queen."
    },
    ["Dragon Robe"] = { 
        Rarity = "Epic", 
        Value = 1800, 
        AssetId = 82347235066957,
        Type = "Shirt",
        Description = "An ancient robe adorned with dragon motifs."
    },
    ["Knight Armor"] = { 
        Rarity = "Epic", 
        Value = 2500, 
        AssetId = 14458547725,
        Type = "Shirt",
        Description = "Medieval knight armor forged from the finest steel."
    },
    ["Angel Wings"] = { 
        Rarity = "Epic", 
        Value = 3500, 
        AssetId = 135727710186452,
        Type = "Back",
        Description = "Ethereal wings that grant the appearance of divine grace."
    },
    ["Wizard Hat"] = { 
        Rarity = "Epic", 
        Value = 4200, 
        AssetId = 17187373352,
        Type = "Hat",
        Description = "A mystical hat imbued with ancient magical powers."
    },
    ["Power Gauntlet"] = { 
        Rarity = "Epic", 
        Value = 5000, 
        AssetId = 90027970393139,
        Type = "Front",
        Description = "A gauntlet that channels incredible energy."
    },

    -- Legendary UGC Items (R$ 5,000 - 25,000)
    ["Diamond Crown"] = { 
        Rarity = "Legendary", 
        Value = 6000, 
        AssetId = 14815863631,
        Type = "Hat",
        Description = "A crown encrusted with the finest diamonds."
    },
    ["Phoenix Wings"] = { 
        Rarity = "Legendary", 
        Value = 8500, 
        AssetId = 126032464353482,
        Type = "Back",
        Description = "Wings of the legendary phoenix, said to grant rebirth."
    },
    ["Void Cloak"] = { 
        Rarity = "Legendary", 
        Value = 12000, 
        AssetId = 101396490083754,
        Type = "Shirt",
        Description = "A cloak woven from the fabric of space itself."
    },
    ["Time Boots"] = { 
        Rarity = "Legendary", 
        Value = 16000, 
        AssetId = 100378706924256,
        Type = "Shoes",
        Description = "Boots that allow the wearer to manipulate time."
    },
    ["Crystal Sword"] = { 
        Rarity = "Legendary", 
        Value = 20000, 
        AssetId = 14751422959,
        Type = "Front",
        Description = "A blade forged from pure crystal energy."
    },
    ["Celestial Armor"] = { 
        Rarity = "Legendary", 
        Value = 25000, 
        AssetId = 82943442611683,
        Type = "Shirt",
        Description = "Armor blessed by celestial beings."
    },

    -- Mythical UGC Items (R$ 25,000 - 100,000)
    ["God's Halo"] = { 
        Rarity = "Mythical", 
        Value = 30000, 
        AssetId = 18780268549,
        Type = "Hat",
        Description = "A divine halo that radiates holy light."
    },
    ["Reality Gloves"] = { 
        Rarity = "Mythical", 
        Value = 45000, 
        AssetId = 15435394705,
        Type = "Front",
        Description = "Gloves that can bend reality to the wearer's will."
    },
    ["Infinity Cloak"] = { 
        Rarity = "Mythical", 
        Value = 65000, 
        AssetId = 10552660662,
        Type = "Shirt",
        Description = "A cloak that extends beyond the boundaries of existence."
    },
    ["Cosmic Crown"] = { 
        Rarity = "Mythical", 
        Value = 80000, 
        AssetId = 14971249131,
        Type = "Hat",
        Description = "A crown forged from the heart of a dying star."
    },
    ["Singularity Staff"] = { 
        Rarity = "Mythical", 
        Value = 100000, 
        AssetId = 89383395698855,
        Type = "Front",
        Description = "A staff that contains the power of a black hole."
    },

    -- Celestial UGC Items (R$ 100,000 - 500,000)
    ["Galaxy Wings"] = { 
        Rarity = "Celestial", 
        Value = 120000, 
        AssetId = 18746999284,
        Type = "Back",
        Description = "Wings that sparkle with the light of a thousand stars."
    },
    ["Nebula Armor"] = { 
        Rarity = "Celestial", 
        Value = 180000, 
        AssetId = 71453601384352,
        Type = "Shirt",
        Description = "Armor forged from the dust of distant nebulae."
    },
    ["Stardust Pauldrons"] = { 
        Rarity = "Celestial", 
        Value = 250000, 
        AssetId = 17799345182,
        Type = "Shoulders",
        Description = "Shoulder guards made from compressed stardust."
    },
    ["Supernova Helmet"] = { 
        Rarity = "Celestial", 
        Value = 350000, 
        AssetId = 17662144185,
        Type = "Hat",
        Description = "A helmet that burns with the intensity of a supernova."
    },
    ["Black Hole Blade"] = { 
        Rarity = "Celestial", 
        Value = 500000, 
        AssetId = 111367840820187,
        Type = "Front",
        Description = "A weapon that devours light itself."
    },
    
    -- Divine UGC Items (R$ 500,000 - 2,500,000)
    ["Aura of the Gods"] = { 
        Rarity = "Divine", 
        Value = 600000, 
        AssetId = 131802293344145,
        Type = "Shirt",
        Description = "An aura that marks the wearer as divine."
    },
    ["Creator's Cape"] = { 
        Rarity = "Divine", 
        Value = 850000, 
        AssetId = 112619410096862,
        Type = "Back",
        Description = "The cape worn by the creator of worlds."
    },
    ["The All-Seeing Eye"] = { 
        Rarity = "Divine", 
        Value = 1200000, 
        AssetId = 118030,
        Type = "Face",
        Description = "An eye that sees across all dimensions."
    },
    ["Dominus Astra"] = { 
        Rarity = "Divine", 
        Value = 1800000, 
        AssetId = 162067148,
        Type = "Hat",
        Description = "The crown of the stellar emperor."
    },
    ["Valkyrie of the Metaverse"] = { 
        Rarity = "Divine", 
        Value = 2500000, 
        AssetId = 16166647111,
        Type = "Shirt",
        Description = "Armor worn by the guardian of digital realms."
    },

    -- Transcendent UGC Items (R$ 5,000,000 - 25,000,000)
    ["Rift Walker's Scythe"] = { 
        Rarity = "Transcendent", 
        Value = 5000000, 
        AssetId = 82818827434214,
        Type = "Front",
        Description = "A scythe that can cut through the fabric of reality."
    },
    ["Chronomancer's Crown"] = { 
        Rarity = "Transcendent", 
        Value = 8000000, 
        AssetId = 116875747342075,
        Type = "Hat",
        Description = "A crown that grants mastery over time itself."
    },
    ["Echoes of the Void"] = { 
        Rarity = "Transcendent", 
        Value = 12000000, 
        AssetId = 18528865852,
        Type = "Shirt",
        Description = "Clothing that resonates with the emptiness between worlds."
    },
    ["Heart of a Dying Star"] = { 
        Rarity = "Transcendent", 
        Value = 18000000, 
        AssetId = 122518448724885,
        Type = "Front",
        Description = "The crystallized heart of a star in its final moments."
    },
    ["Singularity Wings"] = { 
        Rarity = "Transcendent", 
        Value = 25000000, 
        AssetId = 15099368793,
        Type = "Back",
        Description = "Wings forged from the event horizon itself."
    },

    -- Ethereal UGC Items (R$ 30,000,000 - 150,000,000)
    ["The First Omen"] = { 
        Rarity = "Ethereal", 
        Value = 30000000, 
        AssetId = 14814064596,
        Type = "Hat",
        Description = "The first sign of the coming digital apocalypse."
    },
    ["Crown of the Silent King"] = { 
        Rarity = "Ethereal", 
        Value = 50000000, 
        AssetId = 146083020,
        Type = "Hat",
        Description = "A crown that speaks without words."
    },
    ["Aetherium Blade"] = { 
        Rarity = "Ethereal", 
        Value = 75000000, 
        AssetId = 86216026118611,
        Type = "Front",
        Description = "A blade forged from pure aetherium energy."
    },
    ["Mantle of the Architect"] = { 
        Rarity = "Ethereal", 
        Value = 110000000, 
        AssetId = 95824173117693,
        Type = "Shirt",
        Description = "The mantle worn by the architect of existence."
    },
    ["The Unseen Hand"] = { 
        Rarity = "Ethereal", 
        Value = 150000000, 
        AssetId = 12725518393,
        Type = "Front",
        Description = "A hand that shapes destiny from the shadows."
    },

    -- Quantum UGC Items (R$ 200,000,000 - 1,000,000,000)
    ["Fragment of Creation"] = { 
        Rarity = "Quantum", 
        Value = 200000000, 
        AssetId = 8782356060,
        Type = "Front",
        Description = "A fragment from the moment of universal creation."
    },
    ["The Final Shape"] = { 
        Rarity = "Quantum", 
        Value = 350000000, 
        AssetId = 93566247282147,
        Type = "Shirt",
        Description = "The ultimate form that all things aspire to become."
    },
    ["Event Horizon"] = { 
        Rarity = "Quantum", 
        Value = 500000000, 
        AssetId = 13241957708,
        Type = "Back",
        Description = "The boundary beyond which nothing can return."
    },
    ["Glimpse of Infinity"] = { 
        Rarity = "Quantum", 
        Value = 750000000, 
        AssetId = 16580998098,
        Type = "Face",
        Description = "A view into the endless expanse of possibility."
    },
    ["The Robloxian"] = { 
        Rarity = "Quantum", 
        Value = 1000000000, 
        AssetId = 17720934054,
        Type = "Hat",
        Description = "The ultimate expression of what it means to be Robloxian."
    },
}

Config.Mutations = {
    ["Shiny"] = { Chance = 8, ValueMultiplier = 1.2, Color = Color3.fromRGB(255, 255, 100) },
    ["Glowing"] = { Chance = 4, ValueMultiplier = 1.5, Color = Color3.fromRGB(100, 255, 255) },
    ["Rainbow"] = { Chance = 2, ValueMultiplier = 2, Color = Color3.fromRGB(255, 100, 255) },
    ["Corrupted"] = { Chance = 0.8, ValueMultiplier = 3, Color = Color3.fromRGB(100, 0, 100) },
    ["Stellar"] = { Chance = 0.2, ValueMultiplier = 5, Color = Color3.fromRGB(200, 200, 255) },
    ["Quantum"] = { Chance = 0.05, ValueMultiplier = 10, Color = Color3.fromRGB(50, 20, 80) },
    ["Unknown"] = { Chance = 0.01, ValueMultiplier = 25, Color = Color3.fromRGB(0, 0, 0) },
}

Config.Boxes = {
    ["StarterCrate"] = {
        Name = "Starter Crate",
        Price = 25,
        Rewards = {
            ["Basic Cap"] = 35,
            ["Plain T-Shirt"] = 30,
            ["Simple Pants"] = 20,
            ["Basic Glasses"] = 10,
            ["School Backpack"] = 4,
            ["White Sneakers"] = 1,
        },
    },
    ["PremiumCrate"] = {
        Name = "Premium Crate",
        Price = 150,
        Rewards = {
            -- Removed low-value items, added a Rare item for better value
            ["Cool Hoodie"] = 40,       -- R$ 75 value
            ["Designer Jeans"] = 25,    -- R$ 90 value
            ["Sunglasses"] = 15,        -- R$ 110 value
            ["Sports Watch"] = 10,      -- R$ 150 value (break-even)
            ["Leather Jacket"] = 7,     -- R$ 200 value (profit)
            ["Gaming Headset"] = 3,     -- R$ 260 value (big profit!)
        },
    },
    ["LegendaryCrate"] = {
        Name = "Legendary Crate",
        Price = 1000,
        Rewards = {
            -- Focused on high-value Rares, added an Epic for jackpot
            ["Neon Jacket"] = 35,           -- R$ 350 value
            ["Cargo Pants"] = 25,           -- R$ 450 value
            ["VR Goggles"] = 20,            -- R$ 600 value
            ["Holographic Visor"] = 12,     -- R$ 800 value
            ["Jetpack"] = 6,                -- R$ 1000 value (break-even)
            ["Crown"] = 2,                  -- R$ 1200 value (profit!)
        },
    },
    ["MythicalCrate"] = {
        Name = "Mythical Crate",
        Price = 5000,
        Rewards = {
            -- High-value Epics, added a Legendary for profit chance
            ["Dragon Robe"] = 35,       -- R$ 1800 value
            ["Knight Armor"] = 25,      -- R$ 2500 value
            ["Angel Wings"] = 20,       -- R$ 3500 value
            ["Wizard Hat"] = 12,        -- R$ 4200 value
            ["Power Gauntlet"] = 6,     -- R$ 5000 value (break-even)
            ["Diamond Crown"] = 2,      -- R$ 6000 value (profit!)
        },
    },
    ["CelestialCrate"] = {
        Name = "Celestial Crate",
        Price = 25000,
        Rewards = {
            -- Good Legendaries, added a Mythical for profit chance
            ["Void Cloak"] = 30,        -- R$ 12000 value
            ["Time Boots"] = 25,        -- R$ 16000 value
            ["Crystal Sword"] = 20,     -- R$ 20000 value
            ["Celestial Armor"] = 15,   -- R$ 25000 value (break-even)
            ["God's Halo"] = 10,        -- R$ 30000 value (profit!)
        },
    },
    ["DivineCrate"] = {
        Name = "Divine Crate",
        Price = 100000,
        Rewards = {
            -- Great Mythicals, added a Celestial for profit chance
            ["Infinity Cloak"] = 35,    -- R$ 65000 value
            ["Cosmic Crown"] = 30,      -- R$ 80000 value
            ["Singularity Staff"] = 25, -- R$ 100000 value (break-even)
            ["Galaxy Wings"] = 10,      -- R$ 120000 value (profit!)
        },
    },
    ["TranscendentCrate"] = {
        Name = "Transcendent Crate",
        Price = 750000,
        Rewards = {
            -- High-value Celestials, added a Divine for profit chance
            ["Stardust Pauldrons"] = 35,    -- R$ 250000 value
            ["Supernova Helmet"] = 30,      -- R$ 350000 value
            ["Black Hole Blade"] = 25,      -- R$ 500000 value
            ["Aura of the Gods"] = 10,      -- R$ 600000 value
        },
    },
    ["EtherealCrate"] = {
        Name = "Ethereal Crate",
        Price = 5000000,
        Rewards = {
            -- Top Divine items, added a Transcendent for profit chance
            ["Dominus Astra"] = 50,            -- R$ 1800000 value
            ["Valkyrie of the Metaverse"] = 35, -- R$ 2500000 value
            ["Rift Walker's Scythe"] = 15,     -- R$ 5000000 value (break-even!)
        },
    },
    ["QuantumCrate"] = {
        Name = "Quantum Crate",
        Price = 30000000,
        Rewards = {
            -- All items are now worth the price of the crate or more!
            ["The First Omen"] = 40,            -- R$ 30,000,000 value (break-even)
            ["Crown of the Silent King"] = 25,  -- R$ 50,000,000 value
            ["Aetherium Blade"] = 15,           -- R$ 75,000,000 value
            ["Mantle of the Architect"] = 10,   -- R$ 110,000,000 value
            ["The Unseen Hand"] = 7,            -- R$ 150,000,000 value
            ["Fragment of Creation"] = 2,       -- R$ 200,000,000 value
            ["The Final Shape"] = 0.5,          -- R$ 350,000,000 value
            ["Event Horizon"] = 0.3,            -- R$ 500,000,000 value
            ["Glimpse of Infinity"] = 0.15,     -- R$ 750,000,000 value
            ["The Robloxian"] = 0.05,           -- R$ 1,000,000,000 value
        },
    },
    ["FreeCrate"] = {
        Name = "Free Crate",
        Price = 0,
        Cooldown = 60,
        Rewards = {
            ["Basic Cap"] = 40,
            ["Plain T-Shirt"] = 35,
            ["Simple Pants"] = 20,
            ["Basic Glasses"] = 5,
        },
    },
}

-- Currency settings
Config.Currency = {
    Name = "R$",
    StartingAmount = 500,
}

return Config