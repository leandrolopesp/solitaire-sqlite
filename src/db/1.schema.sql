/* 
 SPDX-License-Identifier: CC-BY-NC-4.0
 Copyright (c) Leandro Lopes Pereira. Some rights reserved.
 See LICENSE file for full details.
*/

-- Deck Table
-- This table represents the deck of cards, where each card is identified by its suit and rank.
-- The table includes columns to store all necessary information for the game, such as card ordering,
-- position on the tableau, whether they are in the stock or waste pile, and other relevant properties.
-- The 'InTableau' virtual column indicates whether the card is on the tableau (TableauRow IS NOT NULL)
-- The 'InStock' column is a virtual column that indicates if the card is in the stock pile (InFoundation = 0 and TableauRow is NULL).
-- The 'Color' and 'Label' columns are generated columns that indicate the text representation and color (black or red).

-- Columns 'SortOrder', 'TableauCol', 'TableauRow', 'InFoundation', 'FaceUp' and 'IsWasteTop' are used to control 
-- the position and state of the card in the game.
-- The table is created with the WITHOUT ROWID clause to optimize storage and performance, since the primary key 
-- is composed of two columns (Suit and Rank).
-- The table also includes several indexes to optimize frequent queries, such as those involving ordering, 
-- tableau position and card states.
-- The Deck table is created with the STRICT clause to ensure that all constraints (check constraints and data types) 
-- are properly enforced since SQLite is loosely typed.


DROP TABLE IF EXISTS Deck;
CREATE TABLE Deck (
    Suit        TEXT CHECK(Suit IN ('♠', '♣', '♥', '♦')) NOT NULL,
    Rank        INTEGER CHECK(Rank BETWEEN 1 AND 13) NOT NULL,
    Label       TEXT GENERATED ALWAYS AS (                          -- Card face value (e.g., A ♠)
        CASE Rank
            WHEN 1 THEN 'A'
            WHEN 11 THEN 'J'
            WHEN 12 THEN 'Q'
            WHEN 13 THEN 'K'
            ELSE Rank
        END || ' ' || Suit
    ) STORED,
    Color        TEXT GENERATED ALWAYS AS (IIF(Suit IN ('♠', '♣'), 'Black', 'Red')) STORED,
    SortOrder    INT DEFAULT 0,                                                             -- Card ordering in the game
    InTableau    INT GENERATED ALWAYS AS (TableauRow IS NOT NULL) VIRTUAL,                  -- If card is on tableau
    TableauCol   INT NULL,                                                                  -- Card's tableau column
    TableauRow   INT NULL,                                                                  -- Card's tableau row
    FaceUp       INT DEFAULT 0,                                                             -- If tableau card is revealed
    InStock      INT GENERATED ALWAYS AS (NOT InFoundation AND TableauRow IS NULL) VIRTUAL, -- If card is in stock pile
    IsWasteTop   INT DEFAULT 0,                                                             -- If card is top of waste pile
    InFoundation INT NOT NULL DEFAULT 0,                                                    -- If card is in foundation
    PRIMARY KEY (Suit, Rank)
) Strict, WITHOUT ROWID;

/* 
  Indexing Strategy:
  - Minimal covering indexes for trigger-heavy workflow
  - Partial indexes (WHERE) to reduce storage
  - Optimized for frequent filters: IsWasteTop, InStock, TableauCol/Row
*/

-- Essencial indexes for performance
CREATE INDEX idx_Deck_SortOrder                 ON Deck(SortOrder);
CREATE INDEX idx_Deck_TableauCol_Row            ON Deck(TableauCol, TableauRow);
CREATE INDEX idx_Deck_InStock_SortOrder         ON Deck(InStock, SortOrder) WHERE InStock;

-- Specialized indexes for game logic
CREATE INDEX idx_Deck_WasteTop                  ON Deck(IsWasteTop) WHERE IsWasteTop;
CREATE INDEX idx_Deck_WasteTop_InStock          ON Deck(IsWasteTop, InStock)  WHERE IsWasteTop AND InStock;

-- Minimalistic indexes for tableau and foundation
CREATE INDEX idx_Deck_InFoundation              ON Deck(InFoundation) WHERE InFoundation;

-----------------
-- Moves Table --
-----------------
-- This table records the player's moves
-- It has multiple triggers that contain the game logic

DROP TABLE IF EXISTS Moves;
CREATE TABLE Moves (
    Action   TEXT NULL CHECK(Action IN ('move', 'to-foundation', 'from-foundation', 'deal', 'reset','new')) COLLATE NOCASE,
    Source   INT  NULL,
    Target   INT  NULL
) STRICT;