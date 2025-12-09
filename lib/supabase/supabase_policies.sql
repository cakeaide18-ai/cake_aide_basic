-- CakeAide Security Policies
-- Row-level security policies for all tables

-- Enable Row Level Security on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplies ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_supplies ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- User profiles policies
-- Allow users to view their own profile
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

-- Allow users to insert their own profile (required for signup)
CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (true);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id) WITH CHECK (true);

-- Allow users to delete their own profile
CREATE POLICY "Users can delete own profile" ON user_profiles
  FOR DELETE USING (auth.uid() = id);

-- Ingredients policies
CREATE POLICY "Users can manage own ingredients" ON ingredients
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Recipes policies
CREATE POLICY "Users can manage own recipes" ON recipes
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Recipe ingredients policies
CREATE POLICY "Users can manage own recipe ingredients" ON recipe_ingredients
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM recipes 
      WHERE recipes.id = recipe_ingredients.recipe_id 
      AND recipes.user_id = auth.uid()
    )
  ) WITH CHECK (
    EXISTS (
      SELECT 1 FROM recipes 
      WHERE recipes.id = recipe_ingredients.recipe_id 
      AND recipes.user_id = auth.uid()
    )
  );

-- Orders policies
CREATE POLICY "Users can manage own orders" ON orders
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Supplies policies
CREATE POLICY "Users can manage own supplies" ON supplies
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Quotes policies
CREATE POLICY "Users can manage own quotes" ON quotes
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Shopping lists policies
CREATE POLICY "Users can manage own shopping lists" ON shopping_lists
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Shopping list recipes policies
CREATE POLICY "Users can manage own shopping list recipes" ON shopping_list_recipes
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM shopping_lists 
      WHERE shopping_lists.id = shopping_list_recipes.shopping_list_id 
      AND shopping_lists.user_id = auth.uid()
    )
  ) WITH CHECK (
    EXISTS (
      SELECT 1 FROM shopping_lists 
      WHERE shopping_lists.id = shopping_list_recipes.shopping_list_id 
      AND shopping_lists.user_id = auth.uid()
    )
  );

-- Shopping list ingredients policies
CREATE POLICY "Users can manage own shopping list ingredients" ON shopping_list_ingredients
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM shopping_lists 
      WHERE shopping_lists.id = shopping_list_ingredients.shopping_list_id 
      AND shopping_lists.user_id = auth.uid()
    )
  ) WITH CHECK (
    EXISTS (
      SELECT 1 FROM shopping_lists 
      WHERE shopping_lists.id = shopping_list_ingredients.shopping_list_id 
      AND shopping_lists.user_id = auth.uid()
    )
  );

-- Shopping list supplies policies
CREATE POLICY "Users can manage own shopping list supplies" ON shopping_list_supplies
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM shopping_lists 
      WHERE shopping_lists.id = shopping_list_supplies.shopping_list_id 
      AND shopping_lists.user_id = auth.uid()
    )
  ) WITH CHECK (
    EXISTS (
      SELECT 1 FROM shopping_lists 
      WHERE shopping_lists.id = shopping_list_supplies.shopping_list_id 
      AND shopping_lists.user_id = auth.uid()
    )
  );

-- Reminders policies
CREATE POLICY "Users can manage own reminders" ON reminders
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);