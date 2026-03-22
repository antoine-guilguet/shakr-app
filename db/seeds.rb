# ==============================================================================
# Shakr — Seeds
# ==============================================================================

puts "Creating system user..."
system_user = User.find_or_create_by!(email: "system@shakr.app") do |u|
  u.password = "SecurePassword123!"
  u.first_name = "Shakr"
  u.last_name = "System"
end

puts "Creating ingredients..."

# --- Spirits (kind: 1) ---
gin              = Ingredient.find_or_create_by!(name: "Gin")               { |i| i.kind = 1 }
vodka            = Ingredient.find_or_create_by!(name: "Vodka")             { |i| i.kind = 1 }
white_rum        = Ingredient.find_or_create_by!(name: "White Rum")         { |i| i.kind = 1 }
dark_rum         = Ingredient.find_or_create_by!(name: "Dark Rum")          { |i| i.kind = 1 }
aged_rum         = Ingredient.find_or_create_by!(name: "Aged Rum")          { |i| i.kind = 1 }
tequila          = Ingredient.find_or_create_by!(name: "Tequila")           { |i| i.kind = 1 }
reposado_tequila = Ingredient.find_or_create_by!(name: "Reposado Tequila")  { |i| i.kind = 1 }
mezcal           = Ingredient.find_or_create_by!(name: "Mezcal")            { |i| i.kind = 1 }
bourbon          = Ingredient.find_or_create_by!(name: "Bourbon")           { |i| i.kind = 1 }
rye_whiskey      = Ingredient.find_or_create_by!(name: "Rye Whiskey")       { |i| i.kind = 1 }
scotch           = Ingredient.find_or_create_by!(name: "Scotch Whisky")     { |i| i.kind = 1 }
irish_whiskey    = Ingredient.find_or_create_by!(name: "Irish Whiskey")     { |i| i.kind = 1 }
cognac           = Ingredient.find_or_create_by!(name: "Cognac")            { |i| i.kind = 1 }
pisco            = Ingredient.find_or_create_by!(name: "Pisco")             { |i| i.kind = 1 }
absinthe         = Ingredient.find_or_create_by!(name: "Absinthe")          { |i| i.kind = 1 }
cachaca          = Ingredient.find_or_create_by!(name: "Cachaça")           { |i| i.kind = 1 }
overproof_rum    = Ingredient.find_or_create_by!(name: "Overproof Rum")     { |i| i.kind = 1 }

# --- Liqueurs (kind: 2) ---
triple_sec        = Ingredient.find_or_create_by!(name: "Triple Sec")              { |i| i.kind = 2 }
cointreau         = Ingredient.find_or_create_by!(name: "Cointreau")               { |i| i.kind = 2 }
campari           = Ingredient.find_or_create_by!(name: "Campari")                 { |i| i.kind = 2 }
aperol            = Ingredient.find_or_create_by!(name: "Aperol")                  { |i| i.kind = 2 }
sweet_vermouth    = Ingredient.find_or_create_by!(name: "Sweet Vermouth")          { |i| i.kind = 2 }
dry_vermouth      = Ingredient.find_or_create_by!(name: "Dry Vermouth")            { |i| i.kind = 2 }
bianco_vermouth   = Ingredient.find_or_create_by!(name: "Bianco Vermouth")         { |i| i.kind = 2 }
kahlua            = Ingredient.find_or_create_by!(name: "Kahlúa")                  { |i| i.kind = 2 }
chartreuse_green  = Ingredient.find_or_create_by!(name: "Green Chartreuse")        { |i| i.kind = 2 }
chartreuse_yellow = Ingredient.find_or_create_by!(name: "Yellow Chartreuse")       { |i| i.kind = 2 }
benedictine       = Ingredient.find_or_create_by!(name: "Bénédictine")             { |i| i.kind = 2 }
maraschino        = Ingredient.find_or_create_by!(name: "Maraschino Liqueur")      { |i| i.kind = 2 }
creme_de_cacao    = Ingredient.find_or_create_by!(name: "Crème de Cacao")          { |i| i.kind = 2 }
creme_de_menthe   = Ingredient.find_or_create_by!(name: "Crème de Menthe")         { |i| i.kind = 2 }
creme_de_cassis   = Ingredient.find_or_create_by!(name: "Crème de Cassis")         { |i| i.kind = 2 }
drambuie          = Ingredient.find_or_create_by!(name: "Drambuie")                { |i| i.kind = 2 }
galliano          = Ingredient.find_or_create_by!(name: "Galliano")                { |i| i.kind = 2 }
raspberry_syrup_l = Ingredient.find_or_create_by!(name: "Raspberry Liqueur")       { |i| i.kind = 2 }
amaro_nonino      = Ingredient.find_or_create_by!(name: "Amaro Nonino")            { |i| i.kind = 2 }
peach_schnapps    = Ingredient.find_or_create_by!(name: "Peach Schnapps")          { |i| i.kind = 2 }

# --- Juices (kind: 3) ---
lemon_juice      = Ingredient.find_or_create_by!(name: "Fresh Lemon Juice")   { |i| i.kind = 3 }
lime_juice       = Ingredient.find_or_create_by!(name: "Fresh Lime Juice")    { |i| i.kind = 3 }
orange_juice     = Ingredient.find_or_create_by!(name: "Orange Juice")        { |i| i.kind = 3 }
grapefruit_juice = Ingredient.find_or_create_by!(name: "Grapefruit Juice")    { |i| i.kind = 3 }
pineapple_juice  = Ingredient.find_or_create_by!(name: "Pineapple Juice")     { |i| i.kind = 3 }
cranberry_juice  = Ingredient.find_or_create_by!(name: "Cranberry Juice")     { |i| i.kind = 3 }
passion_juice    = Ingredient.find_or_create_by!(name: "Passion Fruit Juice") { |i| i.kind = 3 }
peach_puree      = Ingredient.find_or_create_by!(name: "White Peach Purée")   { |i| i.kind = 3 }

# --- Syrups (kind: 4) ---
simple_syrup    = Ingredient.find_or_create_by!(name: "Simple Syrup")         { |i| i.kind = 4 }
honey_syrup     = Ingredient.find_or_create_by!(name: "Honey Syrup")          { |i| i.kind = 4 }
agave_syrup     = Ingredient.find_or_create_by!(name: "Agave Syrup")          { |i| i.kind = 4 }
grenadine       = Ingredient.find_or_create_by!(name: "Grenadine")            { |i| i.kind = 4 }
orgeat          = Ingredient.find_or_create_by!(name: "Orgeat")               { |i| i.kind = 4 }
raspberry_syrup = Ingredient.find_or_create_by!(name: "Raspberry Syrup")      { |i| i.kind = 4 }
passion_syrup   = Ingredient.find_or_create_by!(name: "Passion Fruit Syrup")  { |i| i.kind = 4 }
vanilla_syrup   = Ingredient.find_or_create_by!(name: "Vanilla Syrup")        { |i| i.kind = 4 }
ginger_syrup    = Ingredient.find_or_create_by!(name: "Ginger Syrup")         { |i| i.kind = 4 }
falernum        = Ingredient.find_or_create_by!(name: "Falernum")             { |i| i.kind = 4 }

# --- Mixers (kind: 5) ---
soda_water    = Ingredient.find_or_create_by!(name: "Soda Water")    { |i| i.kind = 5 }
tonic_water   = Ingredient.find_or_create_by!(name: "Tonic Water")   { |i| i.kind = 5 }
ginger_beer   = Ingredient.find_or_create_by!(name: "Ginger Beer")   { |i| i.kind = 5 }
prosecco      = Ingredient.find_or_create_by!(name: "Prosecco")      { |i| i.kind = 5 }
champagne     = Ingredient.find_or_create_by!(name: "Champagne")     { |i| i.kind = 5 }
coconut_cream = Ingredient.find_or_create_by!(name: "Coconut Cream") { |i| i.kind = 5 }
heavy_cream   = Ingredient.find_or_create_by!(name: "Heavy Cream")   { |i| i.kind = 5 }
egg_white     = Ingredient.find_or_create_by!(name: "Egg White")     { |i| i.kind = 5 }
espresso      = Ingredient.find_or_create_by!(name: "Espresso")      { |i| i.kind = 5 }
cola          = Ingredient.find_or_create_by!(name: "Cola")          { |i| i.kind = 5 }

# --- Bitters (kind: 6) ---
angostura      = Ingredient.find_or_create_by!(name: "Angostura Bitters")  { |i| i.kind = 6 }
peychauds      = Ingredient.find_or_create_by!(name: "Peychaud's Bitters") { |i| i.kind = 6 }
orange_bitters = Ingredient.find_or_create_by!(name: "Orange Bitters")     { |i| i.kind = 6 }

# --- Garnishes (kind: 7) ---
orange_peel       = Ingredient.find_or_create_by!(name: "Orange Peel")       { |i| i.kind = 7 }
lemon_peel        = Ingredient.find_or_create_by!(name: "Lemon Peel")        { |i| i.kind = 7 }
lime_wedge        = Ingredient.find_or_create_by!(name: "Lime Wedge")        { |i| i.kind = 7 }
mint_sprig        = Ingredient.find_or_create_by!(name: "Fresh Mint")        { |i| i.kind = 7 }
maraschino_cherry = Ingredient.find_or_create_by!(name: "Maraschino Cherry") { |i| i.kind = 7 }
olive             = Ingredient.find_or_create_by!(name: "Green Olive")       { |i| i.kind = 7 }
celery_stalk      = Ingredient.find_or_create_by!(name: "Celery Stalk")      { |i| i.kind = 7 }

# --- Other (kind: 8) ---
sugar_cube     = Ingredient.find_or_create_by!(name: "Sugar Cube")          { |i| i.kind = 8 }
muddled_mint   = Ingredient.find_or_create_by!(name: "Muddled Mint Leaves") { |i| i.kind = 8 }
muddled_lime   = Ingredient.find_or_create_by!(name: "Muddled Lime")        { |i| i.kind = 8 }
tabasco        = Ingredient.find_or_create_by!(name: "Tabasco")             { |i| i.kind = 8 }
worcestershire = Ingredient.find_or_create_by!(name: "Worcestershire Sauce") { |i| i.kind = 8 }
horseradish    = Ingredient.find_or_create_by!(name: "Horseradish")         { |i| i.kind = 8 }

puts "Creating recipes..."

# ==============================================================================
# 50 Classic Cocktails
# ==============================================================================

# 1. Negroni
r = Recipe.create!(user: system_user, name: "Negroni",
  description: "The king of aperitivo cocktails. Bitter, sweet, and perfectly balanced.",
  tags: %w[bitter aperitivo gin classic stirred],
  steps: [
    "Add gin, Campari, and sweet vermouth to a mixing glass filled with ice.",
    "Stir for 30 seconds until well chilled and properly diluted.",
    "Strain into a rocks glass over a large ice cube.",
    "Express an orange peel over the glass and place it on the rim."
  ],
  glassware: "rocks", garnish: "Orange peel",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,            amount: 3, unit: "cl", position: 1 },
  { recipe: r, ingredient: campari,        amount: 3, unit: "cl", position: 2 },
  { recipe: r, ingredient: sweet_vermouth, amount: 3, unit: "cl", position: 3 }
])

# 2. Old Fashioned
r = Recipe.create!(user: system_user, name: "Old Fashioned",
  description: "The original cocktail. Whiskey, bitters, sugar — nothing more, nothing less.",
  tags: %w[classic whiskey bourbon stirred spirit-forward],
  steps: [
    "Place a sugar cube in a rocks glass. Add 2 dashes of Angostura bitters and a splash of water.",
    "Muddle until the sugar is fully dissolved.",
    "Add bourbon and a large ice cube. Stir gently for 20 seconds.",
    "Express an orange peel over the glass, run it around the rim, and drop it in."
  ],
  glassware: "rocks", garnish: "Orange peel and cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: bourbon,    amount: 6,    unit: "cl",    position: 1 },
  { recipe: r, ingredient: angostura,  amount: 2,    unit: "dash",  position: 2 },
  { recipe: r, ingredient: sugar_cube, amount: 1,    unit: "piece", position: 3 }
])

# 3. Margarita
r = Recipe.create!(user: system_user, name: "Margarita",
  description: "The world's most popular cocktail. Tart, citrusy, and refreshing.",
  tags: %w[sour citrus tequila classic shaken],
  steps: [
    "Run a lime wedge around the rim of a coupe glass and dip it in salt.",
    "Add tequila, Cointreau, and fresh lime juice to a shaker with ice.",
    "Shake vigorously for 15 seconds.",
    "Double-strain into the prepared glass.",
    "Garnish with a lime wheel on the rim."
  ],
  glassware: "coupe", garnish: "Salt rim and lime wheel",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: tequila,    amount: 5, unit: "cl", position: 1 },
  { recipe: r, ingredient: cointreau,  amount: 2, unit: "cl", position: 2 },
  { recipe: r, ingredient: lime_juice, amount: 2, unit: "cl", position: 3 }
])

# 4. Daiquiri
r = Recipe.create!(user: system_user, name: "Daiquiri",
  description: "Ernest Hemingway's favourite. Simple, bright, and sublimely refreshing.",
  tags: %w[sour citrus rum classic shaken],
  steps: [
    "Add white rum, fresh lime juice, and simple syrup to a shaker with ice.",
    "Shake hard for 15 seconds until very cold.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with a lime wheel."
  ],
  glassware: "coupe", garnish: "Lime wheel",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: white_rum,    amount: 6,   unit: "cl", position: 1 },
  { recipe: r, ingredient: lime_juice,   amount: 2.5, unit: "cl", position: 2 },
  { recipe: r, ingredient: simple_syrup, amount: 1.5, unit: "cl", position: 3 }
])

# 5. Mojito
r = Recipe.create!(user: system_user, name: "Mojito",
  description: "Cuba's iconic highball. Bright mint, zingy lime, and a fizzy finish.",
  tags: %w[refreshing mint rum citrus highball],
  steps: [
    "Place mint leaves in a highball glass. Add lime juice and simple syrup.",
    "Gently muddle the mint — press, don't shred — to release the oils.",
    "Fill the glass with crushed ice and pour in the white rum.",
    "Top with soda water and stir gently from the bottom up.",
    "Garnish with a mint sprig and a lime wedge."
  ],
  glassware: "highball", garnish: "Mint sprig and lime wedge",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: white_rum,    amount: 5,  unit: "cl",    position: 1 },
  { recipe: r, ingredient: lime_juice,   amount: 3,  unit: "cl",    position: 2 },
  { recipe: r, ingredient: simple_syrup, amount: 2,  unit: "cl",    position: 3 },
  { recipe: r, ingredient: muddled_mint, amount: 10, unit: "piece", position: 4 },
  { recipe: r, ingredient: soda_water,   amount: 6,  unit: "cl",    position: 5 }
])

# 6. Espresso Martini
r = Recipe.create!(user: system_user, name: "Espresso Martini",
  description: "The drink that wakes you up and messes you up. A modern classic.",
  tags: %w[coffee vodka sweet modern shaken],
  steps: [
    "Pull a fresh espresso shot and allow it to cool for 1 minute.",
    "Add vodka, Kahlúa, simple syrup, and the espresso to a shaker with ice.",
    "Shake very hard for 20 seconds — the crema depends on it.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with 3 coffee beans placed in the center of the foam."
  ],
  glassware: "coupe", garnish: "3 coffee beans",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: vodka,        amount: 5, unit: "cl", position: 1 },
  { recipe: r, ingredient: kahlua,       amount: 2, unit: "cl", position: 2 },
  { recipe: r, ingredient: espresso,     amount: 3, unit: "cl", position: 3 },
  { recipe: r, ingredient: simple_syrup, amount: 1, unit: "cl", position: 4 }
])

# 7. Aperol Spritz
r = Recipe.create!(user: system_user, name: "Aperol Spritz",
  description: "Italy's favourite aperitivo. Low ABV, bittersweet, and impossibly easy to drink.",
  tags: %w[aperitivo spritz low-abv italian bubbly],
  steps: [
    "Fill a large wine glass with ice.",
    "Pour in the Prosecco first, then the Aperol.",
    "Add a splash of soda water and stir once gently.",
    "Garnish with a slice of orange."
  ],
  glassware: "wine", garnish: "Orange slice",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: aperol,     amount: 9, unit: "cl", position: 1 },
  { recipe: r, ingredient: prosecco,   amount: 6, unit: "cl", position: 2 },
  { recipe: r, ingredient: soda_water, amount: 3, unit: "cl", position: 3 }
])

# 8. Manhattan
r = Recipe.create!(user: system_user, name: "Manhattan",
  description: "New York's signature cocktail. Bold, rich, and stirred to perfection.",
  tags: %w[classic whiskey stirred spirit-forward rich],
  steps: [
    "Add rye whiskey, sweet vermouth, and Angostura bitters to a mixing glass with ice.",
    "Stir for 30 seconds until well chilled.",
    "Strain into a chilled coupe glass.",
    "Garnish with a maraschino cherry on a pick."
  ],
  glassware: "coupe", garnish: "Maraschino cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: rye_whiskey,    amount: 5,   unit: "cl",   position: 1 },
  { recipe: r, ingredient: sweet_vermouth, amount: 2.5, unit: "cl",   position: 2 },
  { recipe: r, ingredient: angostura,      amount: 2,   unit: "dash", position: 3 }
])

# 9. Cosmopolitan
r = Recipe.create!(user: system_user, name: "Cosmopolitan",
  description: "Made famous by Sex and the City. Pink, citrusy, and deliciously easy.",
  tags: %w[vodka citrus cranberry pink shaken],
  steps: [
    "Add vodka, Cointreau, fresh lime juice, and cranberry juice to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with a flamed orange peel."
  ],
  glassware: "coupe", garnish: "Flamed orange peel",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: vodka,           amount: 4,   unit: "cl", position: 1 },
  { recipe: r, ingredient: cointreau,       amount: 2,   unit: "cl", position: 2 },
  { recipe: r, ingredient: lime_juice,      amount: 1.5, unit: "cl", position: 3 },
  { recipe: r, ingredient: cranberry_juice, amount: 3,   unit: "cl", position: 4 }
])

# 10. Whisky Sour
r = Recipe.create!(user: system_user, name: "Whisky Sour",
  description: "The benchmark sour cocktail. Silky with egg white, tangy and warming.",
  tags: %w[sour whiskey citrus classic shaken],
  steps: [
    "Add bourbon, lemon juice, simple syrup, and egg white to a shaker without ice.",
    "Dry shake vigorously for 15 seconds to emulsify the egg white.",
    "Add ice and shake again hard for another 15 seconds.",
    "Double-strain into a rocks glass over a large ice cube.",
    "Float a few drops of Angostura bitters on top and garnish with a cherry."
  ],
  glassware: "rocks", garnish: "Angostura float and cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: bourbon,      amount: 5,   unit: "cl",    position: 1 },
  { recipe: r, ingredient: lemon_juice,  amount: 2.5, unit: "cl",    position: 2 },
  { recipe: r, ingredient: simple_syrup, amount: 2,   unit: "cl",    position: 3 },
  { recipe: r, ingredient: egg_white,    amount: 1,   unit: "piece", position: 4 }
])

# 11. Gin & Tonic
r = Recipe.create!(user: system_user, name: "Gin & Tonic",
  description: "The simplest cocktail done right. Botanical, bitter, and endlessly drinkable.",
  tags: %w[gin tonic refreshing simple highball],
  steps: [
    "Fill a highball glass with large ice cubes.",
    "Pour in the gin and stir once to chill.",
    "Top slowly with cold tonic water, pouring down the side of the glass to preserve the bubbles.",
    "Garnish with a slice of cucumber and a lime wedge."
  ],
  glassware: "highball", garnish: "Cucumber and lime wedge",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,         amount: 5,  unit: "cl", position: 1 },
  { recipe: r, ingredient: tonic_water, amount: 15, unit: "cl", position: 2 }
])

# 12. Moscow Mule
r = Recipe.create!(user: system_user, name: "Moscow Mule",
  description: "Cool, spicy, and endlessly refreshing. Best served in a copper mug.",
  tags: %w[vodka ginger refreshing highball spicy],
  steps: [
    "Fill a copper mug with crushed ice.",
    "Pour in the vodka and fresh lime juice.",
    "Top with ginger beer and stir gently.",
    "Garnish with a lime wedge and a sprig of mint."
  ],
  glassware: "copper mug", garnish: "Lime wedge and mint",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: vodka,       amount: 5,  unit: "cl", position: 1 },
  { recipe: r, ingredient: lime_juice,  amount: 2,  unit: "cl", position: 2 },
  { recipe: r, ingredient: ginger_beer, amount: 12, unit: "cl", position: 3 }
])

# 13. Dark & Stormy
r = Recipe.create!(user: system_user, name: "Dark & Stormy",
  description: "Bermuda's national drink. Spicy ginger beer topped with a float of dark rum.",
  tags: %w[rum ginger highball spicy tropical],
  steps: [
    "Fill a highball glass with ice.",
    "Add fresh lime juice.",
    "Pour in the ginger beer.",
    "Float dark rum on top by pouring slowly over the back of a spoon.",
    "Garnish with a lime wedge — do not stir."
  ],
  glassware: "highball", garnish: "Lime wedge",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: dark_rum,    amount: 6,   unit: "cl", position: 1 },
  { recipe: r, ingredient: lime_juice,  amount: 1.5, unit: "cl", position: 2 },
  { recipe: r, ingredient: ginger_beer, amount: 12,  unit: "cl", position: 3 }
])

# 14. Paloma
r = Recipe.create!(user: system_user, name: "Paloma",
  description: "Mexico's most popular cocktail. Tequila and grapefruit — salty, bitter, refreshing.",
  tags: %w[tequila grapefruit refreshing salty highball],
  steps: [
    "Salt the rim of a highball glass by rubbing a lime wedge around the edge and dipping it in salt.",
    "Fill the glass with ice.",
    "Add tequila, fresh lime juice, and agave syrup.",
    "Top with fresh grapefruit juice and a splash of soda water.",
    "Stir gently and garnish with a grapefruit wedge."
  ],
  glassware: "highball", garnish: "Grapefruit wedge and salt rim",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: tequila,          amount: 5,   unit: "cl", position: 1 },
  { recipe: r, ingredient: lime_juice,       amount: 1.5, unit: "cl", position: 2 },
  { recipe: r, ingredient: agave_syrup,      amount: 1,   unit: "cl", position: 3 },
  { recipe: r, ingredient: grapefruit_juice, amount: 10,  unit: "cl", position: 4 },
  { recipe: r, ingredient: soda_water,       amount: 3,   unit: "cl", position: 5 }
])

# 15. Classic Martini
r = Recipe.create!(user: system_user, name: "Classic Martini",
  description: "Shaken or stirred, it doesn't matter — just make it cold and make it strong.",
  tags: %w[gin classic stirred dry spirit-forward],
  steps: [
    "Chill a martini glass in the freezer for at least 5 minutes.",
    "Add gin, dry vermouth, and orange bitters to a mixing glass with ice.",
    "Stir for 30-40 seconds until very cold and properly diluted.",
    "Strain into the chilled martini glass.",
    "Garnish with a lemon twist or a skewered olive."
  ],
  glassware: "martini", garnish: "Lemon twist or olive",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,            amount: 6, unit: "cl",   position: 1 },
  { recipe: r, ingredient: dry_vermouth,   amount: 1, unit: "cl",   position: 2 },
  { recipe: r, ingredient: orange_bitters, amount: 1, unit: "dash", position: 3 }
])

# 16. Tom Collins
r = Recipe.create!(user: system_user, name: "Tom Collins",
  description: "The original long gin drink. Refreshing, citrusy, and effervescent.",
  tags: %w[gin sour highball refreshing classic],
  steps: [
    "Add gin, fresh lemon juice, and simple syrup to a shaker with ice.",
    "Shake briefly for 10 seconds.",
    "Strain into a highball glass filled with ice.",
    "Top with soda water and stir once gently.",
    "Garnish with a lemon wheel and a maraschino cherry."
  ],
  glassware: "highball", garnish: "Lemon wheel and cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,          amount: 5, unit: "cl", position: 1 },
  { recipe: r, ingredient: lemon_juice,  amount: 3, unit: "cl", position: 2 },
  { recipe: r, ingredient: simple_syrup, amount: 2, unit: "cl", position: 3 },
  { recipe: r, ingredient: soda_water,   amount: 8, unit: "cl", position: 4 }
])

# 17. Caipirinha
r = Recipe.create!(user: system_user, name: "Caipirinha",
  description: "Brazil's national cocktail. Muddled lime, sugar, and cachaça. Rustic and vibrant.",
  tags: %w[cachaca citrus tropical muddled classic],
  steps: [
    "Cut a lime into 8 wedges and place in a rocks glass.",
    "Add the sugar and muddle firmly to extract the lime juice and oils.",
    "Fill the glass with crushed ice.",
    "Pour in the cachaça and stir well.",
    "Top with a little more crushed ice and garnish with a lime wedge."
  ],
  glassware: "rocks", garnish: "Lime wedge",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: cachaca,      amount: 6, unit: "cl",    position: 1 },
  { recipe: r, ingredient: muddled_lime, amount: 1, unit: "piece", position: 2 },
  { recipe: r, ingredient: sugar_cube,   amount: 2, unit: "piece", position: 3 }
])

# 18. Pisco Sour
r = Recipe.create!(user: system_user, name: "Pisco Sour",
  description: "Peru's pride. Silky egg white foam over a citrusy, floral pisco base.",
  tags: %w[pisco sour citrus south-american shaken],
  steps: [
    "Add pisco, fresh lime juice, simple syrup, and egg white to a shaker without ice.",
    "Dry shake vigorously for 15 seconds to build the foam.",
    "Add ice and shake again hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "Add 3 drops of Angostura bitters onto the foam and draw a pattern with a toothpick."
  ],
  glassware: "coupe", garnish: "Angostura drops on foam",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: pisco,        amount: 6, unit: "cl",    position: 1 },
  { recipe: r, ingredient: lime_juice,   amount: 3, unit: "cl",    position: 2 },
  { recipe: r, ingredient: simple_syrup, amount: 2, unit: "cl",    position: 3 },
  { recipe: r, ingredient: egg_white,    amount: 1, unit: "piece", position: 4 },
  { recipe: r, ingredient: angostura,    amount: 3, unit: "dash",  position: 5 }
])

# 19. Sazerac
r = Recipe.create!(user: system_user, name: "Sazerac",
  description: "New Orleans' signature cocktail, possibly the oldest in America. Absinthe-rinsed and spice-forward.",
  tags: %w[whiskey classic new-orleans stirred spirit-forward],
  steps: [
    "Rinse a chilled rocks glass with absinthe — swirl to coat, then discard the excess.",
    "In a separate mixing glass, muddle the sugar cube with Peychaud's and Angostura bitters.",
    "Add rye whiskey and ice. Stir for 30 seconds.",
    "Strain into the absinthe-rinsed glass — no ice.",
    "Express a lemon peel over the glass but do not drop it in."
  ],
  glassware: "rocks", garnish: "Expressed lemon peel (discarded)",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: rye_whiskey, amount: 6,   unit: "cl",    position: 1 },
  { recipe: r, ingredient: peychauds,   amount: 3,   unit: "dash",  position: 2 },
  { recipe: r, ingredient: angostura,   amount: 1,   unit: "dash",  position: 3 },
  { recipe: r, ingredient: sugar_cube,  amount: 1,   unit: "piece", position: 4 },
  { recipe: r, ingredient: absinthe,    amount: 0.5, unit: "cl",    position: 5 }
])

# 20. Sidecar
r = Recipe.create!(user: system_user, name: "Sidecar",
  description: "A 1920s Parisian classic. Cognac, citrus, and orange liqueur in perfect harmony.",
  tags: %w[cognac citrus classic shaken sour],
  steps: [
    "Optional: sugar-rim the coupe by rubbing a lemon wedge around the edge and dipping it in sugar.",
    "Add cognac, Cointreau, and fresh lemon juice to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Double-strain into the prepared coupe glass.",
    "Garnish with a lemon twist."
  ],
  glassware: "coupe", garnish: "Sugar rim and lemon twist",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: cognac,      amount: 5, unit: "cl", position: 1 },
  { recipe: r, ingredient: cointreau,   amount: 2, unit: "cl", position: 2 },
  { recipe: r, ingredient: lemon_juice, amount: 2, unit: "cl", position: 3 }
])

# 21. Between The Sheets
r = Recipe.create!(user: system_user, name: "Between The Sheets",
  description: "A seductive 1930s classic. Rum and cognac share a bed with lemon and Cointreau.",
  tags: %w[cognac rum citrus classic shaken],
  steps: [
    "Add cognac, white rum, Cointreau, and fresh lemon juice to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with a lemon twist."
  ],
  glassware: "coupe", garnish: "Lemon twist",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: cognac,      amount: 3, unit: "cl", position: 1 },
  { recipe: r, ingredient: white_rum,   amount: 3, unit: "cl", position: 2 },
  { recipe: r, ingredient: cointreau,   amount: 3, unit: "cl", position: 3 },
  { recipe: r, ingredient: lemon_juice, amount: 2, unit: "cl", position: 4 }
])

# 22. Last Word
r = Recipe.create!(user: system_user, name: "Last Word",
  description: "Equal parts and perfectly balanced. Herbal, citrusy, and complex.",
  tags: %w[gin herbal citrus equal-parts classic],
  steps: [
    "Measure equal parts of gin, Green Chartreuse, maraschino, and fresh lime juice into a shaker.",
    "Add ice and shake hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with a maraschino cherry."
  ],
  glassware: "coupe", garnish: "Maraschino cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,              amount: 2.25, unit: "cl", position: 1 },
  { recipe: r, ingredient: chartreuse_green, amount: 2.25, unit: "cl", position: 2 },
  { recipe: r, ingredient: maraschino,       amount: 2.25, unit: "cl", position: 3 },
  { recipe: r, ingredient: lime_juice,       amount: 2.25, unit: "cl", position: 4 }
])

# 23. Aviation
r = Recipe.create!(user: system_user, name: "Aviation",
  description: "A violet-hued pre-Prohibition classic. Floral, tart, and strikingly beautiful.",
  tags: %w[gin floral violet classic shaken],
  steps: [
    "Add gin, maraschino liqueur, and fresh lemon juice to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with a maraschino cherry."
  ],
  glassware: "coupe", garnish: "Maraschino cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,         amount: 5,   unit: "cl", position: 1 },
  { recipe: r, ingredient: maraschino,  amount: 1.5, unit: "cl", position: 2 },
  { recipe: r, ingredient: lemon_juice, amount: 2,   unit: "cl", position: 3 }
])

# 24. Clover Club
r = Recipe.create!(user: system_user, name: "Clover Club",
  description: "A pre-Prohibition gem. Gin, raspberry, and egg white — silky and elegant.",
  tags: %w[gin raspberry sour shaken egg-white],
  steps: [
    "Add gin, fresh lemon juice, raspberry syrup, and egg white to a shaker without ice.",
    "Dry shake for 15 seconds to emulsify.",
    "Add ice and shake again hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with 3 fresh raspberries on a pick."
  ],
  glassware: "coupe", garnish: "Fresh raspberries",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,             amount: 5, unit: "cl",    position: 1 },
  { recipe: r, ingredient: lemon_juice,     amount: 2, unit: "cl",    position: 2 },
  { recipe: r, ingredient: raspberry_syrup, amount: 2, unit: "cl",    position: 3 },
  { recipe: r, ingredient: egg_white,       amount: 1, unit: "piece", position: 4 }
])

# 25. Bee's Knees
r = Recipe.create!(user: system_user, name: "Bee's Knees",
  description: "A Prohibition-era classic created to mask bathtub gin. Honey-sweet and citrusy.",
  tags: %w[gin honey citrus classic prohibition shaken],
  steps: [
    "Add gin, honey syrup, and fresh lemon juice to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with a lemon twist."
  ],
  glassware: "coupe", garnish: "Lemon twist",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,         amount: 6,   unit: "cl", position: 1 },
  { recipe: r, ingredient: honey_syrup, amount: 2.5, unit: "cl", position: 2 },
  { recipe: r, ingredient: lemon_juice, amount: 2.5, unit: "cl", position: 3 }
])

# 26. French 75
r = Recipe.create!(user: system_user, name: "French 75",
  description: "Named after a WWI artillery piece. Gin, citrus, and champagne — light and celebratory.",
  tags: %w[gin champagne sparkling citrus classic],
  steps: [
    "Add gin, fresh lemon juice, and simple syrup to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Double-strain into a chilled champagne flute.",
    "Top with cold champagne.",
    "Garnish with a lemon twist."
  ],
  glassware: "flute", garnish: "Lemon twist",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,          amount: 3,   unit: "cl", position: 1 },
  { recipe: r, ingredient: lemon_juice,  amount: 1.5, unit: "cl", position: 2 },
  { recipe: r, ingredient: simple_syrup, amount: 1,   unit: "cl", position: 3 },
  { recipe: r, ingredient: champagne,    amount: 6,   unit: "cl", position: 4 }
])

# 27. Americano
r = Recipe.create!(user: system_user, name: "Americano",
  description: "The Negroni's lighter sibling. Campari, vermouth, and soda — aperitivo perfection.",
  tags: %w[bitter aperitivo low-abv classic highball],
  steps: [
    "Fill a highball glass with ice.",
    "Add Campari and sweet vermouth.",
    "Top with soda water and stir gently once.",
    "Garnish with a slice of orange."
  ],
  glassware: "highball", garnish: "Orange slice",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: campari,        amount: 3.5, unit: "cl", position: 1 },
  { recipe: r, ingredient: sweet_vermouth, amount: 3.5, unit: "cl", position: 2 },
  { recipe: r, ingredient: soda_water,     amount: 6,   unit: "cl", position: 3 }
])

# 28. Bamboo
r = Recipe.create!(user: system_user, name: "Bamboo",
  description: "A delicate low-ABV stirred cocktail from 19th century Yokohama. Nuanced and sophisticated.",
  tags: %w[vermouth low-abv classic stirred],
  steps: [
    "Add dry vermouth, bianco vermouth, orange bitters, and Angostura bitters to a mixing glass with ice.",
    "Stir for 30 seconds until well chilled.",
    "Strain into a chilled coupe glass.",
    "Garnish with a lemon twist."
  ],
  glassware: "coupe", garnish: "Lemon twist",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: dry_vermouth,    amount: 4, unit: "cl",   position: 1 },
  { recipe: r, ingredient: bianco_vermouth, amount: 2, unit: "cl",   position: 2 },
  { recipe: r, ingredient: orange_bitters,  amount: 2, unit: "dash", position: 3 },
  { recipe: r, ingredient: angostura,       amount: 1, unit: "dash", position: 4 }
])

# 29. Gimlet
r = Recipe.create!(user: system_user, name: "Gimlet",
  description: "Sharp, clean, and deceptively simple. Gin and citrus at their most elegant.",
  tags: %w[gin citrus sour classic shaken],
  steps: [
    "Add gin, fresh lime juice, and simple syrup to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with a lime wheel on the rim."
  ],
  glassware: "coupe", garnish: "Lime wheel",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,          amount: 6,   unit: "cl", position: 1 },
  { recipe: r, ingredient: lime_juice,   amount: 2.5, unit: "cl", position: 2 },
  { recipe: r, ingredient: simple_syrup, amount: 1.5, unit: "cl", position: 3 }
])

# 30. Paper Plane
r = Recipe.create!(user: system_user, name: "Paper Plane",
  description: "Sam Ross's modern classic. Equal parts, bitter, and beautifully amber.",
  tags: %w[bourbon amaro aperol equal-parts modern],
  steps: [
    "Measure equal parts of bourbon, Aperol, Amaro Nonino, and fresh lemon juice into a shaker.",
    "Add ice and shake hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "No garnish needed — the colour speaks for itself."
  ],
  glassware: "coupe", garnish: "None",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: bourbon,      amount: 2.25, unit: "cl", position: 1 },
  { recipe: r, ingredient: aperol,       amount: 2.25, unit: "cl", position: 2 },
  { recipe: r, ingredient: amaro_nonino, amount: 2.25, unit: "cl", position: 3 },
  { recipe: r, ingredient: lemon_juice,  amount: 2.25, unit: "cl", position: 4 }
])

# 31. Penicillin
r = Recipe.create!(user: system_user, name: "Penicillin",
  description: "Sam Ross's other masterpiece. Smoky Scotch float over a honeyed, gingery sour.",
  tags: %w[scotch smoky ginger honey modern sour],
  steps: [
    "Add blended Scotch, fresh lemon juice, honey syrup, and ginger syrup to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Double-strain into a rocks glass over a large ice cube.",
    "Float peaty Scotch on top by pouring slowly over the back of a spoon.",
    "Garnish with a piece of candied ginger on a pick."
  ],
  glassware: "rocks", garnish: "Candied ginger",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: scotch,       amount: 5.5,  unit: "cl", position: 1 },
  { recipe: r, ingredient: lemon_juice,  amount: 2.5,  unit: "cl", position: 2 },
  { recipe: r, ingredient: honey_syrup,  amount: 2,    unit: "cl", position: 3 },
  { recipe: r, ingredient: ginger_syrup, amount: 0.75, unit: "cl", position: 4 }
])

# 32. Jungle Bird
r = Recipe.create!(user: system_user, name: "Jungle Bird",
  description: "A 1970s tiki classic from Malaysia. Rum and Campari in a tropical embrace.",
  tags: %w[rum campari tropical tiki bitter],
  steps: [
    "Add dark rum, Campari, pineapple juice, fresh lime juice, and simple syrup to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Strain into a tiki mug or rocks glass filled with crushed ice.",
    "Garnish with a pineapple leaf and a lime wheel."
  ],
  glassware: "tiki", garnish: "Pineapple leaf and lime wheel",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: dark_rum,        amount: 4.5, unit: "cl", position: 1 },
  { recipe: r, ingredient: campari,         amount: 2,   unit: "cl", position: 2 },
  { recipe: r, ingredient: pineapple_juice, amount: 4.5, unit: "cl", position: 3 },
  { recipe: r, ingredient: lime_juice,      amount: 1.5, unit: "cl", position: 4 },
  { recipe: r, ingredient: simple_syrup,    amount: 1.5, unit: "cl", position: 5 }
])

# 33. Mai Tai
r = Recipe.create!(user: system_user, name: "Mai Tai",
  description: "Trader Vic's 1944 masterpiece. The definitive tiki cocktail — complex, nutty, and tropical.",
  tags: %w[rum tiki tropical almond classic],
  steps: [
    "Add aged rum, fresh lime juice, orgeat, and Cointreau to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Strain into a tiki mug or rocks glass filled with crushed ice.",
    "Float overproof rum on top by pouring slowly over the back of a spoon.",
    "Garnish with a spent lime shell, a mint sprig, and a cherry."
  ],
  glassware: "tiki", garnish: "Mint sprig, lime shell, cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: aged_rum,      amount: 4,   unit: "cl", position: 1 },
  { recipe: r, ingredient: overproof_rum, amount: 2,   unit: "cl", position: 2 },
  { recipe: r, ingredient: lime_juice,    amount: 2.5, unit: "cl", position: 3 },
  { recipe: r, ingredient: orgeat,        amount: 1.5, unit: "cl", position: 4 },
  { recipe: r, ingredient: cointreau,     amount: 1.5, unit: "cl", position: 5 }
])

# 34. Zombie
r = Recipe.create!(user: system_user, name: "Zombie",
  description: "Donn Beach's 1934 rum bomb. Limit two per customer. Potent, tropical, and legendary.",
  tags: %w[rum tiki tropical strong classic],
  steps: [
    "Add white rum, dark rum, lime juice, falernum, and grenadine to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Strain into a tiki mug filled with crushed ice.",
    "Float overproof rum on top by pouring slowly over the back of a spoon.",
    "Garnish with a mint sprig, a lime wheel, and a cherry. Drink responsibly."
  ],
  glassware: "tiki", garnish: "Mint sprig, lime wheel, cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: white_rum,     amount: 4.5, unit: "cl", position: 1 },
  { recipe: r, ingredient: dark_rum,      amount: 3,   unit: "cl", position: 2 },
  { recipe: r, ingredient: overproof_rum, amount: 1.5, unit: "cl", position: 3 },
  { recipe: r, ingredient: lime_juice,    amount: 2,   unit: "cl", position: 4 },
  { recipe: r, ingredient: falernum,      amount: 1.5, unit: "cl", position: 5 },
  { recipe: r, ingredient: grenadine,     amount: 1,   unit: "cl", position: 6 }
])

# 35. Singapore Sling
r = Recipe.create!(user: system_user, name: "Singapore Sling",
  description: "Raffles Hotel, 1915. Pink, fruit-forward, and the original long gin cocktail.",
  tags: %w[gin tropical fruity classic highball],
  steps: [
    "Add gin, Cointreau, Bénédictine, grenadine, fresh lime juice, pineapple juice, and Angostura bitters to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Strain into a highball glass over fresh ice.",
    "Garnish with a pineapple slice and a cherry."
  ],
  glassware: "highball", garnish: "Pineapple slice and cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: gin,             amount: 3,    unit: "cl",   position: 1 },
  { recipe: r, ingredient: cointreau,       amount: 1.5,  unit: "cl",   position: 2 },
  { recipe: r, ingredient: benedictine,     amount: 0.75, unit: "cl",   position: 3 },
  { recipe: r, ingredient: grenadine,       amount: 1,    unit: "cl",   position: 4 },
  { recipe: r, ingredient: lime_juice,      amount: 1.5,  unit: "cl",   position: 5 },
  { recipe: r, ingredient: pineapple_juice, amount: 9,    unit: "cl",   position: 6 },
  { recipe: r, ingredient: angostura,       amount: 1,    unit: "dash", position: 7 }
])

# 36. Long Island Iced Tea
r = Recipe.create!(user: system_user, name: "Long Island Iced Tea",
  description: "No tea, all spirit. Deceptively drinkable and dangerously strong.",
  tags: %w[vodka rum gin tequila strong classic],
  steps: [
    "Add vodka, white rum, gin, tequila, triple sec, fresh lemon juice, and simple syrup to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Strain into a highball glass over fresh ice.",
    "Top with a splash of cola for colour.",
    "Garnish with a lemon wedge."
  ],
  glassware: "highball", garnish: "Lemon wedge",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: vodka,        amount: 1.5, unit: "cl", position: 1 },
  { recipe: r, ingredient: white_rum,    amount: 1.5, unit: "cl", position: 2 },
  { recipe: r, ingredient: gin,          amount: 1.5, unit: "cl", position: 3 },
  { recipe: r, ingredient: tequila,      amount: 1.5, unit: "cl", position: 4 },
  { recipe: r, ingredient: triple_sec,   amount: 1.5, unit: "cl", position: 5 },
  { recipe: r, ingredient: lemon_juice,  amount: 3,   unit: "cl", position: 6 },
  { recipe: r, ingredient: simple_syrup, amount: 1.5, unit: "cl", position: 7 },
  { recipe: r, ingredient: cola,         amount: 4,   unit: "cl", position: 8 }
])

# 37. Sex on the Beach
r = Recipe.create!(user: system_user, name: "Sex on the Beach",
  description: "Fruity, tropical, and unapologetically fun. An 80s classic.",
  tags: %w[vodka fruity tropical fun classic],
  steps: [
    "Fill a highball glass with ice.",
    "Add vodka, peach schnapps, orange juice, and cranberry juice.",
    "Stir gently to combine.",
    "Garnish with an orange slice and a maraschino cherry."
  ],
  glassware: "highball", garnish: "Orange slice and cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: vodka,           amount: 4, unit: "cl", position: 1 },
  { recipe: r, ingredient: peach_schnapps,  amount: 2, unit: "cl", position: 2 },
  { recipe: r, ingredient: orange_juice,    amount: 6, unit: "cl", position: 3 },
  { recipe: r, ingredient: cranberry_juice, amount: 6, unit: "cl", position: 4 }
])

# 38. Harvey Wallbanger
r = Recipe.create!(user: system_user, name: "Harvey Wallbanger",
  description: "A 1970s disco classic. Screwdriver with Galliano — sweet, herbal, and retro.",
  tags: %w[vodka orange herbal classic 70s],
  steps: [
    "Fill a highball glass with ice.",
    "Add vodka and orange juice. Stir to combine.",
    "Float Galliano on top by pouring it slowly over the back of a spoon.",
    "Garnish with an orange slice and a cherry — do not stir the float."
  ],
  glassware: "highball", garnish: "Orange slice and cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: vodka,        amount: 4.5, unit: "cl", position: 1 },
  { recipe: r, ingredient: orange_juice, amount: 9,   unit: "cl", position: 2 },
  { recipe: r, ingredient: galliano,     amount: 1.5, unit: "cl", position: 3 }
])

# 39. Rusty Nail
r = Recipe.create!(user: system_user, name: "Rusty Nail",
  description: "Scotland in a glass. Scotch and Drambuie, stirred and warming.",
  tags: %w[scotch scottish honey stirred simple],
  steps: [
    "Add Scotch whisky and Drambuie to a rocks glass over a large ice cube.",
    "Stir gently for 10 seconds.",
    "Garnish with a lemon twist."
  ],
  glassware: "rocks", garnish: "Lemon twist",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: scotch,   amount: 5,   unit: "cl", position: 1 },
  { recipe: r, ingredient: drambuie, amount: 2.5, unit: "cl", position: 2 }
])

# 40. Stinger
r = Recipe.create!(user: system_user, name: "Stinger",
  description: "Cognac and crème de menthe. An old-school after-dinner classic.",
  tags: %w[cognac mint digestif classic simple],
  steps: [
    "Add cognac and white crème de menthe to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Strain into a chilled coupe glass.",
    "Garnish with a fresh mint sprig."
  ],
  glassware: "coupe", garnish: "Mint sprig",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: cognac,          amount: 5, unit: "cl", position: 1 },
  { recipe: r, ingredient: creme_de_menthe, amount: 2, unit: "cl", position: 2 }
])

# 41. Grasshopper
r = Recipe.create!(user: system_user, name: "Grasshopper",
  description: "Creamy, minty, and dessert-like. A New Orleans classic.",
  tags: %w[mint cream dessert green classic],
  steps: [
    "Add crème de menthe, crème de cacao, and heavy cream to a shaker with ice.",
    "Shake hard for 15 seconds until frothy and cold.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with a mint sprig and a dusting of grated chocolate."
  ],
  glassware: "coupe", garnish: "Mint sprig",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: creme_de_menthe, amount: 3, unit: "cl", position: 1 },
  { recipe: r, ingredient: creme_de_cacao,  amount: 3, unit: "cl", position: 2 },
  { recipe: r, ingredient: heavy_cream,     amount: 3, unit: "cl", position: 3 }
])

# 42. Piña Colada
r = Recipe.create!(user: system_user, name: "Piña Colada",
  description: "Puerto Rico's national drink. Creamy, coconutty, and tropical to the core.",
  tags: %w[rum tropical coconut pineapple blended],
  steps: [
    "Add white rum, coconut cream, and pineapple juice to a blender.",
    "Add a generous scoop of crushed ice.",
    "Blend until smooth.",
    "Pour into a hurricane glass.",
    "Garnish with a pineapple slice, a cherry, and a straw."
  ],
  glassware: "hurricane", garnish: "Pineapple slice and cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: white_rum,       amount: 5, unit: "cl", position: 1 },
  { recipe: r, ingredient: coconut_cream,   amount: 3, unit: "cl", position: 2 },
  { recipe: r, ingredient: pineapple_juice, amount: 9, unit: "cl", position: 3 }
])

# 43. Tequila Sunrise
r = Recipe.create!(user: system_user, name: "Tequila Sunrise",
  description: "A visual spectacle. Tequila, OJ, and grenadine — stunning and sweet.",
  tags: %w[tequila orange tropical visual classic],
  steps: [
    "Fill a highball glass with ice.",
    "Pour in tequila and orange juice. Stir to combine.",
    "Slowly pour grenadine down the side of the glass — it will sink and create a sunrise effect.",
    "Do not stir. Garnish with an orange slice and a cherry."
  ],
  glassware: "highball", garnish: "Orange slice and cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: tequila,      amount: 4.5, unit: "cl", position: 1 },
  { recipe: r, ingredient: orange_juice, amount: 9,   unit: "cl", position: 2 },
  { recipe: r, ingredient: grenadine,    amount: 1.5, unit: "cl", position: 3 }
])

# 44. Kir Royale
r = Recipe.create!(user: system_user, name: "Kir Royale",
  description: "French elegance in a flute. Champagne and cassis — simple, chic, and festive.",
  tags: %w[champagne cassis french sparkling simple],
  steps: [
    "Pour crème de cassis into a chilled champagne flute.",
    "Top slowly with cold champagne, pouring down the side of the glass.",
    "Garnish with a blackcurrant or a lemon twist."
  ],
  glassware: "flute", garnish: "Blackcurrant or lemon twist",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: champagne,       amount: 15,  unit: "cl", position: 1 },
  { recipe: r, ingredient: creme_de_cassis, amount: 1.5, unit: "cl", position: 2 }
])

# 45. Irish Coffee
r = Recipe.create!(user: system_user, name: "Irish Coffee",
  description: "Invented at Shannon Airport in 1943. Coffee, whiskey, and floating cream.",
  tags: %w[whiskey coffee cream warm classic],
  steps: [
    "Pre-warm an Irish coffee glass with hot water, then discard.",
    "Add Irish whiskey and simple syrup to the glass.",
    "Pour in the hot espresso and stir to combine.",
    "Float lightly whipped cream on top by pouring it over the back of a spoon.",
    "Do not stir — sip the coffee through the cream."
  ],
  glassware: "irish-coffee", garnish: "Freshly whipped cream",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: irish_whiskey, amount: 4,   unit: "cl", position: 1 },
  { recipe: r, ingredient: espresso,      amount: 6,   unit: "cl", position: 2 },
  { recipe: r, ingredient: simple_syrup,  amount: 1.5, unit: "cl", position: 3 },
  { recipe: r, ingredient: heavy_cream,   amount: 3,   unit: "cl", position: 4 }
])

# 46. Bellini
r = Recipe.create!(user: system_user, name: "Bellini",
  description: "Harry's Bar, Venice, 1948. White peach purée and Prosecco — the aperitivo icon.",
  tags: %w[prosecco peach sparkling italian brunch],
  steps: [
    "Chill a champagne flute.",
    "Spoon white peach purée into the bottom of the flute.",
    "Slowly pour cold Prosecco over the purée, pouring down the side of the glass.",
    "Stir once very gently to combine."
  ],
  glassware: "flute", garnish: "None",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: prosecco,    amount: 10, unit: "cl", position: 1 },
  { recipe: r, ingredient: peach_puree, amount: 5,  unit: "cl", position: 2 }
])

# 47. Pornstar Martini
r = Recipe.create!(user: system_user, name: "Pornstar Martini",
  description: "Douglas Ankrah's 2002 creation. Vanilla vodka, passion fruit, and a side of Prosecco.",
  tags: %w[vodka passion-fruit vanilla modern sweet],
  steps: [
    "Add vodka, passion fruit syrup, passion fruit juice, fresh lime juice, and vanilla syrup to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "Garnish with half a fresh passion fruit placed on top of the drink.",
    "Serve a small shot of Prosecco on the side."
  ],
  glassware: "coupe", garnish: "Fresh passion fruit half + Prosecco shot on the side",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: vodka,         amount: 5,   unit: "cl", position: 1 },
  { recipe: r, ingredient: passion_syrup, amount: 2,   unit: "cl", position: 2 },
  { recipe: r, ingredient: passion_juice, amount: 2,   unit: "cl", position: 3 },
  { recipe: r, ingredient: lime_juice,    amount: 1,   unit: "cl", position: 4 },
  { recipe: r, ingredient: vanilla_syrup, amount: 0.5, unit: "cl", position: 5 },
  { recipe: r, ingredient: prosecco,      amount: 6,   unit: "cl", position: 6 }
])

# 48. Tommy's Margarita
r = Recipe.create!(user: system_user, name: "Tommy's Margarita",
  description: "Julio Bermejo's 1990s masterpiece. No orange liqueur — just tequila, lime, and agave.",
  tags: %w[tequila citrus agave modern sour],
  steps: [
    "Optional: salt the rim of a rocks glass.",
    "Add reposado tequila, fresh lime juice, and agave syrup to a shaker with ice.",
    "Shake hard for 15 seconds.",
    "Strain into the rocks glass over a large ice cube.",
    "Garnish with a lime wedge."
  ],
  glassware: "rocks", garnish: "Lime wedge",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: reposado_tequila, amount: 6, unit: "cl", position: 1 },
  { recipe: r, ingredient: lime_juice,       amount: 3, unit: "cl", position: 2 },
  { recipe: r, ingredient: agave_syrup,      amount: 2, unit: "cl", position: 3 }
])

# 49. Naked and Famous
r = Recipe.create!(user: system_user, name: "Naked and Famous",
  description: "Joaquín Simó's equal-parts riff on the Paper Plane. Smoky, floral, and bitter.",
  tags: %w[mezcal smoky equal-parts modern bitter],
  steps: [
    "Measure equal parts of mezcal, Aperol, Yellow Chartreuse, and fresh lime juice into a shaker.",
    "Add ice and shake hard for 15 seconds.",
    "Double-strain into a chilled coupe glass.",
    "No garnish — the smoke and colour do the talking."
  ],
  glassware: "coupe", garnish: "None",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: mezcal,            amount: 2.25, unit: "cl", position: 1 },
  { recipe: r, ingredient: aperol,            amount: 2.25, unit: "cl", position: 2 },
  { recipe: r, ingredient: chartreuse_yellow, amount: 2.25, unit: "cl", position: 3 },
  { recipe: r, ingredient: lime_juice,        amount: 2.25, unit: "cl", position: 4 }
])

# 50. Vieux Carré
r = Recipe.create!(user: system_user, name: "Vieux Carré",
  description: "The French Quarter's own cocktail, circa 1938. Rye, cognac, vermouth, and Bénédictine.",
  tags: %w[rye cognac vermouth classic new-orleans stirred],
  steps: [
    "Add rye whiskey, cognac, sweet vermouth, Bénédictine, Peychaud's bitters, and Angostura bitters to a mixing glass with ice.",
    "Stir for 30 seconds until well chilled.",
    "Strain into a rocks glass over a large ice cube.",
    "Garnish with a lemon twist and a cherry."
  ],
  glassware: "rocks", garnish: "Lemon twist and cherry",
  is_public: true)
RecipeIngredient.create!([
  { recipe: r, ingredient: rye_whiskey,    amount: 3, unit: "cl",   position: 1 },
  { recipe: r, ingredient: cognac,         amount: 3, unit: "cl",   position: 2 },
  { recipe: r, ingredient: sweet_vermouth, amount: 3, unit: "cl",   position: 3 },
  { recipe: r, ingredient: benedictine,    amount: 1, unit: "cl",   position: 4 },
  { recipe: r, ingredient: peychauds,      amount: 2, unit: "dash", position: 5 },
  { recipe: r, ingredient: angostura,      amount: 2, unit: "dash", position: 6 }
])

puts "✅ Done! Created:"
puts "   - 1 system user"
puts "   - #{Ingredient.count} ingredients"
puts "   - #{Recipe.count} recipes"
puts "   - #{RecipeIngredient.count} recipe ingredients"
