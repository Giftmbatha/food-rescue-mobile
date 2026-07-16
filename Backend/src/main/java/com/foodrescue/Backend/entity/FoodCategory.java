package com.foodrescue.Backend.entity;

/**
 * Categories for food listings.
 *
 * Fixed enum — new categories require code change and migration.
 * Chosen to cover 95% of surplus food types without overwhelming users.
 */

public enum FoodCategory {

    BAKERY, // Bread, pastries, cakes
    PRODUCE, // Fruits, vegetables
    DAIRY, // Milk, cheese, yogurt
    MEAT, // Chicken, beef, fish
    PREPARED, // Cooked meals, ready-to-eat
    BEVERAGES, // Drinks, juices
    GRAINS, // Rice, pasta, cereal
    CANNED, // Long-life, preserved
    FROZEN, // Frozen vegetables, meals
    OTHER // Catch-all for other cases
}
