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
    ["Basic Cap"] = { Rarity = "Common", Value = 10 },
    ["Plain T-Shirt"] = { Rarity = "Common", Value = 15 },
    ["Simple Pants"] = { Rarity = "Common", Value = 20 },
    ["Basic Glasses"] = { Rarity = "Common", Value = 25 },
    ["School Backpack"] = { Rarity = "Common", Value = 30 },
    ["White Sneakers"] = { Rarity = "Common", Value = 35 },

    -- Uncommon UGC Items (R$ 50 - 250)
    ["Stylish Hat"] = { Rarity = "Uncommon", Value = 55 },
    ["Cool Hoodie"] = { Rarity = "Uncommon", Value = 75 },
    ["Designer Jeans"] = { Rarity = "Uncommon", Value = 90 },
    ["Sunglasses"] = { Rarity = "Uncommon", Value = 110 },
    ["Sports Watch"] = { Rarity = "Uncommon", Value = 150 },
    ["Leather Jacket"] = { Rarity = "Uncommon", Value = 200 },

    -- Rare UGC Items (R$ 250 - 1,000)
    ["Gaming Headset"] = { Rarity = "Rare", Value = 260 },
    ["Neon Jacket"] = { Rarity = "Rare", Value = 350 },
    ["Cargo Pants"] = { Rarity = "Rare", Value = 450 },
    ["VR Goggles"] = { Rarity = "Rare", Value = 600 },
    ["Holographic Visor"] = { Rarity = "Rare", Value = 800 },
    ["Jetpack"] = { Rarity = "Rare", Value = 1000 },

    -- Epic UGC Items (R$ 1,000 - 5,000)
    ["Crown"] = { Rarity = "Epic", Value = 1200 },
    ["Dragon Robe"] = { Rarity = "Epic", Value = 1800 },
    ["Knight Armor"] = { Rarity = "Epic", Value = 2500 },
    ["Angel Wings"] = { Rarity = "Epic", Value = 3500 },
    ["Wizard Hat"] = { Rarity = "Epic", Value = 4200 },
    ["Power Gauntlet"] = { Rarity = "Epic", Value = 5000 },

    -- Legendary UGC Items (R$ 5,000 - 25,000)
    ["Diamond Crown"] = { Rarity = "Legendary", Value = 6000 },
    ["Phoenix Wings"] = { Rarity = "Legendary", Value = 8500 },
    ["Void Cloak"] = { Rarity = "Legendary", Value = 12000 },
    ["Time Boots"] = { Rarity = "Legendary", Value = 16000 },
    ["Crystal Sword"] = { Rarity = "Legendary", Value = 20000 },
    ["Celestial Armor"] = { Rarity = "Legendary", Value = 25000 },

    -- Mythical UGC Items (R$ 25,000 - 100,000)
    ["God's Halo"] = { Rarity = "Mythical", Value = 30000 },
    ["Reality Gloves"] = { Rarity = "Mythical", Value = 45000 },
    ["Infinity Cloak"] = { Rarity = "Mythical", Value = 65000 },
    ["Cosmic Crown"] = { Rarity = "Mythical", Value = 80000 },
    ["Singularity Staff"] = { Rarity = "Mythical", Value = 100000 },

    -- Celestial UGC Items (R$ 100,000 - 500,000)
    ["Galaxy Wings"] = { Rarity = "Celestial", Value = 120000 },
    ["Nebula Armor"] = { Rarity = "Celestial", Value = 180000 },
    ["Stardust Pauldrons"] = { Rarity = "Celestial", Value = 250000 },
    ["Supernova Helmet"] = { Rarity = "Celestial", Value = 350000 },
    ["Black Hole Blade"] = { Rarity = "Celestial", Value = 500000 },
    
    -- Divine UGC Items (R$ 500,000 - 2,500,000)
    ["Aura of the Gods"] = { Rarity = "Divine", Value = 600000 },
    ["Creator's Cape"] = { Rarity = "Divine", Value = 850000 },
    ["The All-Seeing Eye"] = { Rarity = "Divine", Value = 1200000 },
    ["Dominus Astra"] = { Rarity = "Divine", Value = 1800000 },
    ["Valkyrie of the Metaverse"] = { Rarity = "Divine", Value = 2500000 },

    -- Transcendent UGC Items (R$ 5,000,000 - 25,000,000)
    ["Rift Walker's Scythe"] = { Rarity = "Transcendent", Value = 5000000 },
    ["Chronomancer's Crown"] = { Rarity = "Transcendent", Value = 8000000 },
    ["Echoes of the Void"] = { Rarity = "Transcendent", Value = 12000000 },
    ["Heart of a Dying Star"] = { Rarity = "Transcendent", Value = 18000000 },
    ["Singularity Wings"] = { Rarity = "Transcendent", Value = 25000000 },

    -- Ethereal UGC Items (R$ 30,000,000 - 150,000,000)
    ["The First Omen"] = { Rarity = "Ethereal", Value = 30000000 },
    ["Crown of the Silent King"] = { Rarity = "Ethereal", Value = 50000000 },
    ["Aetherium Blade"] = { Rarity = "Ethereal", Value = 75000000 },
    ["Mantle of the Architect"] = { Rarity = "Ethereal", Value = 110000000 },
    ["The Unseen Hand"] = { Rarity = "Ethereal", Value = 150000000 },

    -- Quantum UGC Items (R$ 200,000,000 - 1,000,000,000)
    ["Fragment of Creation"] = { Rarity = "Quantum", Value = 200000000 },
    ["The Final Shape"] = { Rarity = "Quantum", Value = 350000000 },
    ["Event Horizon"] = { Rarity = "Quantum", Value = 500000000 },
    ["Glimpse of Infinity"] = { Rarity = "Quantum", Value = 750000000 },
    ["The Robloxian"] = { Rarity = "Quantum", Value = 1000000000 },
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
            ["Plain T-Shirt"] = 25,         -- R$15 (Small Loss)
            ["Simple Pants"] = 20,          -- R$20 (Small Loss)
            ["Basic Glasses"] = 15,         -- R$25 (Break-even!)
            ["School Backpack"] = 15,       -- R$30 (Win!)
            ["White Sneakers"] = 10,        -- R$35 (Win!)
            ["Stylish Hat"] = 10,           -- R$55 (Big Win!)
            ["Cool Hoodie"] = 5,            -- R$75 (Jackpot!)
        },
    },
    ["PremiumCrate"] = {
        Name = "Premium Crate",
        Price = 150,
        Rewards = {
            ["Designer Jeans"] = 20,        -- R$90 (Loss)
            ["Sunglasses"] = 20,            -- R$110 (Loss)
            ["Sports Watch"] = 15,          -- R$150 (Break-even!)
            ["Leather Jacket"] = 15,        -- R$200 (Win!)
            ["Gaming Headset"] = 10,        -- R$260 (Win!)
            ["Neon Jacket"] = 10,           -- R$350 (Big Win!)
            ["Cargo Pants"] = 7,            -- R$450 (Big Win!)
            ["VR Goggles"] = 3,             -- R$600 (Jackpot!)
        },
    },
    ["LegendaryCrate"] = {
        Name = "Legendary Crate",
        Price = 1000,
        Rewards = {
            ["Gaming Headset"] = 25,
            ["Neon Jacket"] = 20,
            ["Cargo Pants"] = 18,
            ["VR Goggles"] = 15,
            ["Holographic Visor"] = 12,
            ["Jetpack"] = 7,
            ["Crown"] = 3,
        },
    },
    ["MythicalCrate"] = {
        Name = "Mythical Crate",
        Price = 5000,
        Rewards = {
            ["Crown"] = 25,
            ["Dragon Robe"] = 20,
            ["Knight Armor"] = 18,
            ["Angel Wings"] = 15,
            ["Wizard Hat"] = 12,
            ["Power Gauntlet"] = 7,
            ["Diamond Crown"] = 3,
        },
    },
    ["CelestialCrate"] = {
        Name = "Celestial Crate",
        Price = 25000,
        Rewards = {
            ["Diamond Crown"] = 25,
            ["Phoenix Wings"] = 20,
            ["Void Cloak"] = 18,
            ["Time Boots"] = 15,
            ["Crystal Sword"] = 12,
            ["Celestial Armor"] = 7,
            ["God's Halo"] = 3,
        },
    },
    ["DivineCrate"] = {
        Name = "Divine Crate",
        Price = 100000,
        Rewards = {
            ["God's Halo"] = 25,
            ["Reality Gloves"] = 20,
            ["Infinity Cloak"] = 18,
            ["Cosmic Crown"] = 15,
            ["Singularity Staff"] = 10,
            ["Galaxy Wings"] = 6,
            ["Nebula Armor"] = 3,
            ["Stardust Pauldrons"] = 2,
            ["Supernova Helmet"] = 0.8,
            ["Black Hole Blade"] = 0.15,
            ["Aura of the Gods"] = 0.05,
        },
    },
    ["TranscendentCrate"] = {
        Name = "Transcendent Crate",
        Price = 750000, -- 750k
        Rewards = {
            ["Aura of the Gods"] = 30,
            ["Creator's Cape"] = 25,
            ["The All-Seeing Eye"] = 20,
            ["Dominus Astra"] = 15,
            ["Valkyrie of the Metaverse"] = 7,
            ["Rift Walker's Scythe"] = 2,
            ["Chronomancer's Crown"] = 0.8,
            ["Echoes of the Void"] = 0.15,
            ["Heart of a Dying Star"] = 0.04,
            ["Singularity Wings"] = 0.01,
        },
    },
    ["EtherealCrate"] = {
        Name = "Ethereal Crate",
        Price = 5000000, -- 5M
        Rewards = {
            ["Rift Walker's Scythe"] = 30,
            ["Chronomancer's Crown"] = 25,
            ["Echoes of the Void"] = 20,
            ["Heart of a Dying Star"] = 15,
            ["Singularity Wings"] = 7,
            ["The First Omen"] = 2,
            ["Crown of the Silent King"] = 0.8,
            ["Aetherium Blade"] = 0.15,
            ["Mantle of the Architect"] = 0.04,
            ["The Unseen Hand"] = 0.01,
        },
    },
    ["QuantumCrate"] = {
        Name = "Quantum Crate",
        Price = 30000000, -- 30M
        Rewards = {
            ["The First Omen"] = 30,
            ["Crown of the Silent King"] = 25,
            ["Aetherium Blade"] = 20,
            ["Mantle of the Architect"] = 15,
            ["The Unseen Hand"] = 7,
            ["Fragment of Creation"] = 2,
            ["The Final Shape"] = 0.8,
            ["Event Horizon"] = 0.15,
            ["Glimpse of Infinity"] = 0.04,
            ["The Robloxian"] = 0.01,
        },
    },
    ["FreeCrate"] = {
        Name = "Free Crate",
        Price = 0,
        Cooldown = 60, -- 1 minute
        Rewards = {
            ["Basic Cap"] = 30,
            ["Plain T-Shirt"] = 25,
            ["Simple Pants"] = 20,
            ["Basic Glasses"] = 15,
            ["School Backpack"] = 7,
            ["White Sneakers"] = 3,
        },
    },
}

-- Currency settings
Config.Currency = {
    Name = "R$",
    StartingAmount = 500,
}

return Config 