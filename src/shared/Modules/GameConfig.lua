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
            -- Common items
            ["White Sneakers"] = 30,
            ["School Backpack"] = 20,
            -- Uncommon items (good chances)
            ["Stylish Hat"] = 20,
            ["Cool Hoodie"] = 15,
            ["Designer Jeans"] = 10,
            ["Sunglasses"] = 4,
            ["Sports Watch"] = 0.8,
            ["Leather Jacket"] = 0.2,
        },
    },
    ["LegendaryCrate"] = {
        Name = "Legendary Crate",
        Price = 1000,
        Rewards = {
            -- Uncommon items
            ["Leather Jacket"] = 35,
            ["Sports Watch"] = 25,
            ["Sunglasses"] = 15,
            -- Rare items (decent chances)
            ["Gaming Headset"] = 15,
            ["Neon Jacket"] = 8,
            ["Cargo Pants"] = 1.8,
            ["VR Goggles"] = 0.15,
            ["Holographic Visor"] = 0.04,
            ["Jetpack"] = 0.01,
        },
    },
    ["MythicalCrate"] = {
        Name = "Mythical Crate",
        Price = 5000,
        Rewards = {
            -- Rare items
            ["Jetpack"] = 40,
            ["Holographic Visor"] = 25,
            ["VR Goggles"] = 15,
            -- Epic items (good chances)
            ["Crown"] = 12,
            ["Dragon Robe"] = 5,
            ["Knight Armor"] = 2.5,
            ["Angel Wings"] = 0.4,
            ["Wizard Hat"] = 0.08,
            ["Power Gauntlet"] = 0.02,
        },
    },
    ["CelestialCrate"] = {
        Name = "Celestial Crate",
        Price = 25000,
        Rewards = {
            -- Epic items
            ["Power Gauntlet"] = 50,
            ["Wizard Hat"] = 25,
            ["Angel Wings"] = 15,
            -- Legendary items (reasonable chances)
            ["Diamond Crown"] = 6,
            ["Phoenix Wings"] = 3,
            ["Void Cloak"] = 0.8,
            ["Time Boots"] = 0.15,
            ["Crystal Sword"] = 0.04,
            ["Celestial Armor"] = 0.01,
        },
    },
    ["DivineCrate"] = {
        Name = "Divine Crate",
        Price = 100000,
        Rewards = {
            -- Legendary items
            ["Celestial Armor"] = 60,
            ["Crystal Sword"] = 25,
            ["Time Boots"] = 10,
            -- Mythical items (good chances)
            ["God's Halo"] = 3,
            ["Reality Gloves"] = 1.5,
            ["Infinity Cloak"] = 0.4,
            ["Cosmic Crown"] = 0.08,
            ["Singularity Staff"] = 0.02,
        },
    },
    ["TranscendentCrate"] = {
        Name = "Transcendent Crate",
        Price = 750000,
        Rewards = {
            -- Mythical items
            ["Singularity Staff"] = 60,
            ["Cosmic Crown"] = 25,
            ["Infinity Cloak"] = 10,
            -- Celestial items (decent chances)
            ["Galaxy Wings"] = 3,
            ["Nebula Armor"] = 1.5,
            ["Stardust Pauldrons"] = 0.4,
            ["Supernova Helmet"] = 0.08,
            ["Black Hole Blade"] = 0.02,
        },
    },
    ["EtherealCrate"] = {
        Name = "Ethereal Crate",
        Price = 5000000,
        Rewards = {
            -- Celestial items
            ["Black Hole Blade"] = 60,
            ["Supernova Helmet"] = 25,
            ["Stardust Pauldrons"] = 10,
            -- Divine items (decent chances)
            ["Aura of the Gods"] = 3,
            ["Creator's Cape"] = 1.5,
            ["The All-Seeing Eye"] = 0.4,
            ["Dominus Astra"] = 0.08,
            ["Valkyrie of the Metaverse"] = 0.02,
        },
    },
    ["QuantumCrate"] = {
        Name = "Quantum Crate",
        Price = 30000000,
        Rewards = {
            -- Divine items
            ["Valkyrie of the Metaverse"] = 50,
            ["Dominus Astra"] = 25,
            ["The All-Seeing Eye"] = 15,
            -- Transcendent items (decent chances)
            ["Rift Walker's Scythe"] = 5,
            ["Chronomancer's Crown"] = 3,
            ["Echoes of the Void"] = 1.5,
            ["Heart of a Dying Star"] = 0.4,
            ["Singularity Wings"] = 0.08,
            -- Ethereal items (rare but possible)
            ["The First Omen"] = 0.015,
            ["Crown of the Silent King"] = 0.008,
            ["Aetherium Blade"] = 0.004,
            ["Mantle of the Architect"] = 0.002,
            ["The Unseen Hand"] = 0.001,
            -- Quantum items (ultra rare but achievable)
            ["Fragment of Creation"] = 0.0005,
            ["The Final Shape"] = 0.0003,
            ["Event Horizon"] = 0.0002,
            ["Glimpse of Infinity"] = 0.0001,
            ["The Robloxian"] = 0.00005,
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