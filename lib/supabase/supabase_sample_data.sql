CREATE OR REPLACE FUNCTION insert_user_to_auth(
    email text,
    password text
) RETURNS UUID AS $$
DECLARE
  user_id uuid;
  encrypted_pw text;
BEGIN
  user_id := gen_random_uuid();
  encrypted_pw := crypt(password, gen_salt('bf'));
  
  INSERT INTO auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES
    (gen_random_uuid(), user_id, 'authenticated', 'authenticated', email, encrypted_pw, '2023-05-03 19:41:43.585805+00', '2023-04-22 13:10:03.275387+00', '2023-04-22 13:10:31.458239+00', '{"provider":"email","providers":["email"]}', '{}', '2023-05-03 19:41:43.580424+00', '2023-05-03 19:41:43.585948+00', '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (gen_random_uuid(), user_id, format('{"sub":"%s","email":"%s"}', user_id::text, email)::jsonb, 'email', '2023-05-03 19:41:43.582456+00', '2023-05-03 19:41:43.582497+00', '2023-05-03 19:41:43.582497+00');
  
  RETURN user_id;
END;
$$ LANGUAGE plpgsql;


-- Insert sample users into auth.users and retrieve their IDs
SELECT insert_user_to_auth('alice@example.com', 'password123');
SELECT insert_user_to_auth('bob@example.com', 'securepass');
SELECT insert_user_to_auth('charlie@example.com', 'mysecret');

-- Insert user profiles
INSERT INTO user_profiles (id, name, email, phone, business_name, location, experience_level, business_type, bio, profile_image_url)
SELECT
  (SELECT id FROM auth.users WHERE email = 'alice@example.com'),
  'Alice Wonderland',
  'alice@example.com',
  '555-123-4567',
  'Alice''s Cakes',
  'Wonderland City',
  'Experienced',
  'Home Baker',
  'Passionate about creating magical cakes for all occasions.',
  'https://example.com/alice_profile.jpg';

INSERT INTO user_profiles (id, name, email, phone, business_name, location, experience_level, business_type, bio, profile_image_url)
SELECT
  (SELECT id FROM auth.users WHERE email = 'bob@example.com'),
  'Bob The Baker',
  'bob@example.com',
  '555-987-6543',
  'Bob''s Bakeshop',
  'Bakerville',
  'Intermediate',
  'Small Business',
  'Specializing in artisanal breads and custom cakes.',
  'https://example.com/bob_profile.jpg';

INSERT INTO user_profiles (id, name, email, phone, business_name, location, experience_level, business_type, bio, profile_image_url)
SELECT
  (SELECT id FROM auth.users WHERE email = 'charlie@example.com'),
  'Charlie Cake',
  'charlie@example.com',
  '555-111-2222',
  'Charlie''s Confections',
  'Sweet Town',
  'Beginner',
  'Home Baker',
  'Learning the art of cake decorating, one frosting swirl at a time.',
  'https://example.com/charlie_profile.jpg';

-- Insert ingredients
INSERT INTO ingredients (id, user_id, name, brand, category, unit, price, quantity, expiry_date, supplier, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'alice@example.com'),
  'All-Purpose Flour',
  'King Arthur',
  'Baking Staples',
  'kg',
  5.99,
  10.00,
  '2024-12-31',
  'Local Grocer',
  'Store in a cool, dry place.';

INSERT INTO ingredients (id, user_id, name, brand, category, unit, price, quantity, expiry_date, supplier, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'alice@example.com'),
  'Granulated Sugar',
  'Domino',
  'Sweeteners',
  'kg',
  3.49,
  15.00,
  '2025-06-30',
  'Wholesale Foods',
  'Essential for most cake recipes.';

INSERT INTO ingredients (id, user_id, name, brand, category, unit, price, quantity, expiry_date, supplier, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'alice@example.com'),
  'Unsalted Butter',
  'Kerrygold',
  'Dairy',
  'g',
  7.29,
  2000.00,
  '2024-08-15',
  'Dairy Farm Co.',
  'Keep refrigerated.';

INSERT INTO ingredients (id, user_id, name, brand, category, unit, price, quantity, expiry_date, supplier, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'bob@example.com'),
  'Cocoa Powder',
  'Hershey''s',
  'Baking Staples',
  'g',
  4.75,
  500.00,
  '2024-11-01',
  'Local Grocer',
  'Dutch-processed for darker color.';

INSERT INTO ingredients (id, user_id, name, brand, category, unit, price, quantity, expiry_date, supplier, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'bob@example.com'),
  'Vanilla Extract',
  'McCormick',
  'Flavorings',
  'ml',
  8.99,
  100.00,
  '2026-01-20',
  'Specialty Store',
  'Pure vanilla extract for best flavor.';

-- Insert recipes
INSERT INTO recipes (id, user_id, name, description, cake_size_portions, prep_time_minutes, cook_time_minutes, difficulty_level, category, image_url, instructions, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'alice@example.com'),
  'Classic Vanilla Cake',
  'A moist and fluffy vanilla cake, perfect for any celebration.',
  12,
  30,
  35,
  'Easy',
  'Cakes',
  'https://example.com/vanilla_cake.jpg',
  '1. Preheat oven to 350F. 2. Cream butter and sugar. 3. Add eggs one at a time. 4. Mix in dry ingredients alternately with milk. 5. Bake for 30-35 minutes.',
  'Serve with buttercream frosting.';

INSERT INTO recipes (id, user_id, name, description, cake_size_portions, prep_time_minutes, cook_time_minutes, difficulty_level, category, image_url, instructions, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'alice@example.com'),
  'Rich Chocolate Fudge Cake',
  'An intensely rich and decadent chocolate cake.',
  16,
  45,
  40,
  'Medium',
  'Cakes',
  'https://example.com/chocolate_cake.jpg',
  '1. Melt chocolate and butter. 2. Whisk eggs and sugar. 3. Combine wet and dry ingredients. 4. Bake at 325F for 40 minutes.',
  'Great with a ganache topping.';

INSERT INTO recipes (id, user_id, name, description, cake_size_portions, prep_time_minutes, cook_time_minutes, difficulty_level, category, image_url, instructions, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'bob@example.com'),
  'Lemon Drizzle Loaf',
  'A zesty and moist lemon loaf cake, perfect for tea time.',
  8,
  20,
  50,
  'Easy',
  'Loaf Cakes',
  'https://example.com/lemon_loaf.jpg',
  '1. Cream butter and sugar. 2. Add eggs, then lemon zest and juice. 3. Fold in flour. 4. Bake at 350F for 50 minutes. 5. Drizzle with lemon glaze while warm.',
  'Can be made with oranges instead of lemons.';

-- Insert recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM recipes WHERE name = 'Classic Vanilla Cake' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  (SELECT id FROM ingredients WHERE name = 'All-Purpose Flour' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  0.300,
  'kg',
  'Sifted';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM recipes WHERE name = 'Classic Vanilla Cake' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  (SELECT id FROM ingredients WHERE name = 'Granulated Sugar' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  0.250,
  'kg',
  '';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM recipes WHERE name = 'Classic Vanilla Cake' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  (SELECT id FROM ingredients WHERE name = 'Unsalted Butter' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  200.00,
  'g',
  'Softened';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM recipes WHERE name = 'Rich Chocolate Fudge Cake' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  (SELECT id FROM ingredients WHERE name = 'All-Purpose Flour' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  0.200,
  'kg',
  '';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM recipes WHERE name = 'Rich Chocolate Fudge Cake' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  (SELECT id FROM ingredients WHERE name = 'Granulated Sugar' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  0.300,
  'kg',
  '';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM recipes WHERE name = 'Rich Chocolate Fudge Cake' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  (SELECT id FROM ingredients WHERE name = 'Unsalted Butter' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')),
  150.00,
  'g',
  '';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM recipes WHERE name = 'Lemon Drizzle Loaf' AND user_id = (SELECT id FROM auth.users WHERE email = 'bob@example.com')),
  (SELECT id FROM ingredients WHERE name = 'All-Purpose Flour' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')), -- Assuming Bob might use Alice's flour if shared or a generic one
  0.250,
  'kg',
  '';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM recipes WHERE name = 'Lemon Drizzle Loaf' AND user_id = (SELECT id FROM auth.users WHERE email = 'bob@example.com')),
  (SELECT id FROM ingredients WHERE name = 'Granulated Sugar' AND user_id = (SELECT id FROM auth.users WHERE email = 'alice@example.com')), -- Assuming Bob might use Alice's sugar if shared or a generic one
  0.200,
  'kg',
  '';

-- Insert orders
INSERT INTO orders (id, user_id, customer_name, customer_phone, customer_email, cake_details, order_price, deposit_amount, order_date, delivery_date, delivery_time, delivery_address, status, is_custom_design, custom_design_notes, special_instructions)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'alice@example.com'),
  'Emily White',
  '555-333-4444',
  'emily.white@email.com',
  '3-tier wedding cake, vanilla sponge with raspberry filling, white buttercream, floral decoration.',
  450.00,
  150.00,
  '2024-07-01 10:00:00+00',
  '2024-09-15',
  '14:00:00',
  '123 Celebration Lane, Wonderland City',
  'Confirmed',
  TRUE,
  'Client provided reference images for floral design.',
  'Deliver to reception venue. Contact event planner upon arrival.';

INSERT INTO orders (id, user_id, customer_name, customer_phone, customer_email, cake_details, order_price, deposit_amount, order_date, delivery_date, delivery_time, delivery_address, status, is_custom_design, custom_design_notes, special_instructions)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'alice@example.com'),
  'David Green',
  '555-777-8888',
  'david.green@email.com',
  'Birthday cake, chocolate fudge, 8-inch round, blue frosting with sprinkles.',
  75.00,
  25.00,
  '2024-07-05 14:30:00+00',
  '2024-08-01',
  '10:00:00',
  '456 Party Street, Wonderland City',
  'Pending',
  FALSE,
  NULL,
  'Leave with concierge if no one answers.';

INSERT INTO orders (id, user_id, customer_name, customer_phone, customer_email, cake_details, order_price, deposit_amount, order_date, delivery_date, delivery_time, delivery_address, status, is_custom_design, custom_design_notes, special_instructions)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'bob@example.com'),
  'Sarah Johnson',
  '555-222-3333',
  'sarah.j@email.com',
  'Anniversary cake, red velvet, heart-shaped, cream cheese frosting.',
  90.00,
  30.00,
  '2024-07-10 09:00:00+00',
  '2024-08-20',
  '16:00:00',
  '789 Love Lane, Bakerville',
  'Confirmed',
  TRUE,
  'Client wants "Happy Anniversary" written in gold.',
  '';

-- Insert supplies
INSERT INTO supplies (id, user_id, name, brand, category, quantity, unit, price, supplier, purchase_date, expiry_date, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'alice@example.com'),
  'Piping Bags',
  'Wilton',
  'Decorating Tools',
  100.00,
  'count',
  12.99,
  'Baking Supply Co.',
  '2024-06-01',
  NULL,
  'Disposable, 12-inch.';

INSERT INTO supplies (id, user_id, name, brand, category, quantity, unit, price, supplier, purchase_date, expiry_date, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'alice@example.com'),
  'Cake Boards',
  'Fat Daddio''s',
  'Packaging',
  25.00,
  'count',
  25.00,
  'Wholesale Baking',
  '2024-05-15',
  NULL,
  '10-inch round, white.';

INSERT INTO supplies (id, user_id, name, brand, category, quantity, unit, price, supplier, purchase_date, expiry_date, notes)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'bob@example.com'),
  'Offset Spatula',
  'Ateco',
  'Baking Tools',
  2.00,
  'count',
  8.50,
  'Kitchen Essentials',
  '2024-04-20',
  NULL,
  'Small, for frosting cakes.';

-- Insert quotes
INSERT INTO quotes (id, user_id, customer_name, customer_email, customer_phone, cake_type, cake_size, servings, event_date, event_type, special_requirements, base_price